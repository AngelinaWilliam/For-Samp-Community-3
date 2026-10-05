// ============================================================================
//  Mineiga_CMD.inc  v2.0.0
//  Command router extension for the Pawn.CMD plugin (SA-MP 0.3.7 / open.mp)
//
//  REQUIRES: Pawn.CMD plugin loaded in server.cfg / config.json
//
//  Features:
//    - Per-player global cooldown            PC_SetCooldown(playerid, ms)
//    - Per-command cooldown                  PC_SetCommandCooldown("heal", 5000)
//    - Flood guard (auto temp-block)         PC_SetFloodGuard(max, windowMs, blockMs)
//    - Real profiler (calls / total / avg / max)   PC_PrintProfile()
//    - Per-player bypass (admins)            PC_SetBypass(playerid, true)
//    - Optional command log                  PC_EnableLogging(true)
//
//  Optional callbacks (just define them as public in your script):
//    public OnPlayerCommandFlood(playerid, count);
//    public OnPlayerCommandCooldown(playerid, const cmd[], remaining_ms);
//
//  Created by: Mineiga
// ============================================================================

#if defined _Mineiga_CMD_INC_
    #endinput
#endif
#define _Mineiga_CMD_INC_

#include <a_samp>

#define Mineiga_CMD_AUTHOR      "Mineiga"
#define Mineiga_CMD_VERSION     (0x020000) // 2.0.0

// ----------------------------------------------------------------------------
//  Config (define these BEFORE including to override)
// ----------------------------------------------------------------------------
#if !defined PC_MAX_TRACKED_CMDS
    #define PC_MAX_TRACKED_CMDS     (256)   // must be a power of 2
#endif
#if !defined PC_MAX_CMD_NAME
    #define PC_MAX_CMD_NAME         (32)
#endif
#if !defined PC_MAX_CD_CMDS
    #define PC_MAX_CD_CMDS          (16)    // max commands with their own cooldown
#endif
#if !defined PC_DEFAULT_FLOOD_MAX
    #define PC_DEFAULT_FLOOD_MAX    (8)     // commands allowed per window (0 = off)
#endif
#if !defined PC_DEFAULT_FLOOD_WINDOW
    #define PC_DEFAULT_FLOOD_WINDOW (3000)  // ms
#endif
#if !defined PC_DEFAULT_FLOOD_BLOCK
    #define PC_DEFAULT_FLOOD_BLOCK  (5000)  // ms
#endif
#if !defined PC_MSG_COLOR
    #define PC_MSG_COLOR            (0xFF6347FF)
#endif

#define PC_NEVER                    (0x3FFFFFFF) // "never used" tick offset

// ----------------------------------------------------------------------------
//  Plugin natives (Pawn.CMD)
// ----------------------------------------------------------------------------
native PC_Init(); // internal

native PC_RegAlias(const cmd[], const alias[], ...);
native PC_SetFlags(const cmd[], flags);
native PC_GetFlags(const cmd[]);
native PC_RenameCommand(const cmd[], const newname[]);
native PC_CommandExists(const cmd[]);
native PC_DeleteCommand(const cmd[]);

native CmdArray:PC_GetCommandArray();
native CmdArray:PC_GetAliasArray(const cmd[]);
native PC_GetArraySize(CmdArray:arr);
native PC_GetCommandName(CmdArray:arr, index, dest[], size = sizeof dest);
native PC_FreeArray(&CmdArray:arr);

native PC_EmulateCommand(playerid, const cmdtext[]);

// ----------------------------------------------------------------------------
//  Internal state
// ----------------------------------------------------------------------------
static stock s_PC_Cooldown[MAX_PLAYERS];
static stock s_PC_LastTick[MAX_PLAYERS];
static stock s_PC_StartTick[MAX_PLAYERS];
static stock bool:s_PC_Bypass[MAX_PLAYERS];
static stock bool:s_PC_Blocked[MAX_PLAYERS];
static stock s_PC_BlockUntil[MAX_PLAYERS];
static stock s_PC_FloodCount[MAX_PLAYERS];
static stock s_PC_FloodStart[MAX_PLAYERS];
static stock s_PC_CdLast[MAX_PLAYERS][PC_MAX_CD_CMDS];

// command table (open-addressing hash table, case-insensitive)
static stock s_PC_TblName[PC_MAX_TRACKED_CMDS][PC_MAX_CMD_NAME];
static stock s_PC_TblHash[PC_MAX_TRACKED_CMDS];
static stock s_PC_TblCount[PC_MAX_TRACKED_CMDS];
static stock s_PC_TblTotal[PC_MAX_TRACKED_CMDS];
static stock s_PC_TblMax[PC_MAX_TRACKED_CMDS];
static stock s_PC_TblCd[PC_MAX_TRACKED_CMDS];
static stock s_PC_TblCdIdx[PC_MAX_TRACKED_CMDS]; // 0 = none, else index+1

static stock s_PC_CdUsed = 0;
static stock s_PC_DefaultCd = 0;
static stock s_PC_FloodMax = PC_DEFAULT_FLOOD_MAX;
static stock s_PC_FloodWindow = PC_DEFAULT_FLOOD_WINDOW;
static stock s_PC_FloodBlock = PC_DEFAULT_FLOOD_BLOCK;
static stock bool:s_PC_ProfilingEnabled = true;
static stock bool:s_PC_Logging = false;

// ----------------------------------------------------------------------------
//  Command table helpers
// ----------------------------------------------------------------------------
stock PC_Hash(const str[])
{
    new h = 5381, c;
    for (new i = 0; i < PC_MAX_CMD_NAME - 1 && (c = str[i]) != 0; i++)
    {
        if ('A' <= c <= 'Z') c += 32;
        h = ((h << 5) + h) + c;
    }
    return h;
}

stock PC_FindSlot(const name[], bool:create = false)
{
    if (!name[0]) return -1;

    new h = PC_Hash(name);
    new idx = h & (PC_MAX_TRACKED_CMDS - 1);

    for (new n = 0; n < PC_MAX_TRACKED_CMDS; n++)
    {
        if (!s_PC_TblName[idx][0])
        {
            if (!create) return -1;
            for (new i = 0; i < PC_MAX_CMD_NAME - 1 && name[i]; i++)
            {
                s_PC_TblName[idx][i] = tolower(name[i]);
                s_PC_TblName[idx][i + 1] = 0;
            }
            s_PC_TblHash[idx] = h;
            return idx;
        }
        if (s_PC_TblHash[idx] == h && !strcmp(s_PC_TblName[idx], name, true, PC_MAX_CMD_NAME - 1))
            return idx;

        idx = (idx + 1) & (PC_MAX_TRACKED_CMDS - 1);
    }
    return -1; // table full
}

stock PC_Record(const name[], elapsed)
{
    new slot = PC_FindSlot(name, true);
    if (slot == -1) return 0;
    s_PC_TblCount[slot]++;
    s_PC_TblTotal[slot] += elapsed;
    if (elapsed > s_PC_TblMax[slot]) s_PC_TblMax[slot] = elapsed;
    return 1;
}

// ----------------------------------------------------------------------------
//  Public API: cooldowns
// ----------------------------------------------------------------------------
stock PC_SetCooldown(playerid, milliseconds)
{
    if (0 <= playerid < MAX_PLAYERS)
    {
        s_PC_Cooldown[playerid] = milliseconds;
        return 1;
    }
    return 0;
}

stock PC_GetCooldown(playerid)
{
    if (0 <= playerid < MAX_PLAYERS) return s_PC_Cooldown[playerid];
    return 0;
}

// Applies to every player, including those already connected.
stock PC_SetDefaultCooldown(milliseconds)
{
    s_PC_DefaultCd = milliseconds;
    for (new i = 0; i < MAX_PLAYERS; i++)
        if (IsPlayerConnected(i)) s_PC_Cooldown[i] = milliseconds;
    return 1;
}

stock PC_SetCommandCooldown(const cmd[], milliseconds)
{
    new slot = PC_FindSlot(cmd, true);
    if (slot == -1) return 0;

    if (milliseconds <= 0)
    {
        s_PC_TblCd[slot] = 0;
        return 1;
    }
    if (!s_PC_TblCdIdx[slot])
    {
        if (s_PC_CdUsed >= PC_MAX_CD_CMDS) return 0;
        s_PC_TblCdIdx[slot] = ++s_PC_CdUsed;
    }
    s_PC_TblCd[slot] = milliseconds;
    return 1;
}

stock PC_GetCommandCooldown(const cmd[])
{
    new slot = PC_FindSlot(cmd);
    if (slot == -1) return 0;
    return s_PC_TblCd[slot];
}

// ----------------------------------------------------------------------------
//  Public API: flood guard, bypass, logging
// ----------------------------------------------------------------------------
stock PC_SetFloodGuard(maxCommands, windowMs = PC_DEFAULT_FLOOD_WINDOW, blockMs = PC_DEFAULT_FLOOD_BLOCK)
{
    s_PC_FloodMax = maxCommands; // 0 disables
    s_PC_FloodWindow = windowMs;
    s_PC_FloodBlock = blockMs;
    return 1;
}

stock PC_SetBypass(playerid, bool:bypass)
{
    if (!(0 <= playerid < MAX_PLAYERS)) return 0;
    s_PC_Bypass[playerid] = bypass;
    return 1;
}

stock bool:PC_IsBypassed(playerid)
{
    if (!(0 <= playerid < MAX_PLAYERS)) return false;
    return s_PC_Bypass[playerid];
}

stock PC_EnableLogging(bool:enable)
{
    s_PC_Logging = enable;
    return 1;
}

// ----------------------------------------------------------------------------
//  Public API: profiler
// ----------------------------------------------------------------------------
stock PC_EnableProfiling(bool:enable)
{
    s_PC_ProfilingEnabled = enable;
    return 1;
}

stock PC_GetCommandExecCount(const cmd[])
{
    new slot = PC_FindSlot(cmd);
    if (slot == -1) return 0;
    return s_PC_TblCount[slot];
}

// Total time spent in the cmd, in ms.
stock PC_GetCommandExecTime(const cmd[])
{
    new slot = PC_FindSlot(cmd);
    if (slot == -1) return 0;
    return s_PC_TblTotal[slot];
}

stock PC_GetCommandMaxTime(const cmd[])
{
    new slot = PC_FindSlot(cmd);
    if (slot == -1) return 0;
    return s_PC_TblMax[slot];
}

stock Float:PC_GetCommandAvgTime(const cmd[])
{
    new slot = PC_FindSlot(cmd);
    if (slot == -1 || s_PC_TblCount[slot] <= 0) return 0.0;
    return float(s_PC_TblTotal[slot]) / float(s_PC_TblCount[slot]);
}

stock PC_ResetProfiling()
{
    for (new i = 0; i < PC_MAX_TRACKED_CMDS; i++)
    {
        s_PC_TblCount[i] = 0;
        s_PC_TblTotal[i] = 0;
        s_PC_TblMax[i] = 0;
    }
    return 1;
}

// Prints the most-used commands to the server console.
stock PC_PrintProfile(top = 10)
{
    new bool:done[PC_MAX_TRACKED_CMDS];

    print("---------- MineigaCMD profile ----------");
    for (new k = 0; k < top; k++)
    {
        new best = -1;
        for (new i = 0; i < PC_MAX_TRACKED_CMDS; i++)
        {
            if (done[i] || s_PC_TblCount[i] <= 0) continue;
            if (best == -1 || s_PC_TblCount[i] > s_PC_TblCount[best]) best = i;
        }
        if (best == -1) break;

        done[best] = true;
        printf("%d. /%s  calls=%d  total=%dms  avg=%.2fms  max=%dms",
            k + 1, s_PC_TblName[best], s_PC_TblCount[best], s_PC_TblTotal[best],
            float(s_PC_TblTotal[best]) / float(s_PC_TblCount[best]), s_PC_TblMax[best]);
    }
    print("----------------------------------------");
    return 1;
}

// ----------------------------------------------------------------------------
//  Per-player state
// ----------------------------------------------------------------------------
stock PC_ResetPlayer(playerid)
{
    if (!(0 <= playerid < MAX_PLAYERS)) return 0;

    new now = GetTickCount();
    s_PC_Cooldown[playerid] = s_PC_DefaultCd;
    s_PC_LastTick[playerid] = now - PC_NEVER;
    s_PC_StartTick[playerid] = now;
    s_PC_Bypass[playerid] = false;
    s_PC_Blocked[playerid] = false;
    s_PC_BlockUntil[playerid] = 0;
    s_PC_FloodCount[playerid] = 0;
    s_PC_FloodStart[playerid] = now;
    for (new i = 0; i < PC_MAX_CD_CMDS; i++)
        s_PC_CdLast[playerid][i] = now - PC_NEVER;
    return 1;
}

stock PC_InitState()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
        if (IsPlayerConnected(i)) PC_ResetPlayer(i);
    return 1;
}

stock PC_PrintBanner()
{
    print(" ");
    print("  MineigaCMD v2.0.0 - cooldown / flood guard / profiler");
    print("  Built on Pawn.CMD | Created by Mineiga");
    print(" ");
    return 1;
}

// ----------------------------------------------------------------------------
//  Macros
// ----------------------------------------------------------------------------
#define cmd:%0(%1) \
    forward pc_cmd_%0(%1); \
    public pc_cmd_%0(%1)

#define alias:%0(%1); \
    forward pc_alias_%0(); \
    public pc_alias_%0() \
        PC_RegAlias(#%0, %1);

#define flags:%0(%1); \
    forward pc_flags_%0(); \
    public pc_flags_%0() \
        PC_SetFlags(#%0, %1);

#define CMD cmd
#define COMMAND cmd

#define callcmd::%0(%1) \
    pc_cmd_%0(%1)

#define PC_HasFlag(%0,%1) \
    (PC_GetFlags(%0) & %1)

#if !defined isnull
    #define isnull(%0) \
        ((!(%0[0])) || (((%0[0]) == '\1') && (!(%0[1]))))
#endif

// Backward compatibility with Pawn.CMD include guard
#if !defined PAWNCMD_INC_
    #define PAWNCMD_INC_
#endif

#if defined PC_OnInit
    forward PC_OnInit();
#endif

// ----------------------------------------------------------------------------
//  Command pipeline hooks
//  (the user's own callbacks are chained by name, so they keep working)
// ----------------------------------------------------------------------------
forward OnPlayerCommandReceived(playerid, cmd[], params[], flags);
public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    new now = GetTickCount(), cdi = -1;
    new bool:check = (0 <= playerid < MAX_PLAYERS && !s_PC_Bypass[playerid]);

    if (check)
    {
        // 1) temporary block from the flood guard
        if (s_PC_Blocked[playerid])
        {
            if ((s_PC_BlockUntil[playerid] - now) > 0) return 0;
            s_PC_Blocked[playerid] = false;
            s_PC_FloodCount[playerid] = 0;
        }

        // 2) flood guard
        if (s_PC_FloodMax > 0)
        {
            if ((now - s_PC_FloodStart[playerid]) > s_PC_FloodWindow)
            {
                s_PC_FloodStart[playerid] = now;
                s_PC_FloodCount[playerid] = 0;
            }
            if (++s_PC_FloodCount[playerid] > s_PC_FloodMax)
            {
                s_PC_Blocked[playerid] = true;
                s_PC_BlockUntil[playerid] = now + s_PC_FloodBlock;

                if (funcidx("OnPlayerCommandFlood") != -1)
                    CallLocalFunction("OnPlayerCommandFlood", "dd", playerid, s_PC_FloodCount[playerid]);
                else
                    SendClientMessage(playerid, PC_MSG_COLOR, "[CMD] Too many commands. Please slow down.");
                return 0;
            }
        }

        // 3) global + per-command cooldown (the longer remaining time wins)
        new remaining = 0;
        if (s_PC_Cooldown[playerid] > 0)
        {
            new gElapsed = now - s_PC_LastTick[playerid];
            if (gElapsed < s_PC_Cooldown[playerid]) remaining = s_PC_Cooldown[playerid] - gElapsed;
        }

        new slot = PC_FindSlot(cmd);
        if (slot != -1 && s_PC_TblCd[slot] > 0 && s_PC_TblCdIdx[slot] > 0)
        {
            cdi = s_PC_TblCdIdx[slot] - 1;
            new cElapsed = now - s_PC_CdLast[playerid][cdi];
            if (cElapsed < s_PC_TblCd[slot])
            {
                new cRemaining = s_PC_TblCd[slot] - cElapsed;
                if (cRemaining > remaining) remaining = cRemaining;
            }
        }

        if (remaining > 0)
        {
            if (funcidx("OnPlayerCommandCooldown") != -1)
                CallLocalFunction("OnPlayerCommandCooldown", "dsd", playerid, cmd, remaining);
            else
            {
                new msg[96];
                format(msg, sizeof msg, "[CMD] Please wait %.1f second(s) before using that command again.", float(remaining) / 1000.0);
                SendClientMessage(playerid, PC_MSG_COLOR, msg);
            }
            return 0;
        }
    }

    // 4) user's own OnPlayerCommandReceived
    new ret = 1;
    if (funcidx("MCmd_OnPlayerCommandReceived") != -1)
        ret = CallLocalFunction("MCmd_OnPlayerCommandReceived", "dssd", playerid, cmd, params, flags);
    if (!ret) return 0;

    // 5) command accepted: update timers
    if (0 <= playerid < MAX_PLAYERS)
    {
        s_PC_StartTick[playerid] = now;
        if (check)
        {
            s_PC_LastTick[playerid] = now;
            if (cdi != -1) s_PC_CdLast[playerid][cdi] = now;
        }
    }
    return 1;
}
#if defined _ALS_OnPlayerCommandReceived
    #undef OnPlayerCommandReceived
#else
    #define _ALS_OnPlayerCommandReceived
#endif
#define OnPlayerCommandReceived MCmd_OnPlayerCommandReceived
forward MCmd_OnPlayerCommandReceived(playerid, cmd[], params[], flags);

forward OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags);
public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
    // only record commands that really exist (ignore random unknown input)
    if (0 <= playerid < MAX_PLAYERS && PC_CommandExists(cmd))
    {
        new elapsed = GetTickCount() - s_PC_StartTick[playerid];

        if (s_PC_ProfilingEnabled) PC_Record(cmd, elapsed);
        if (s_PC_Logging)
            printf("[CMD] player %d: /%s %s (result=%d, %dms)", playerid, cmd, params, result, elapsed);
    }

    if (funcidx("MCmd_OnPlayerCommandPerformed") != -1)
        return CallLocalFunction("MCmd_OnPlayerCommandPerformed", "dssdd", playerid, cmd, params, result, flags);
    return result;
}
#if defined _ALS_OnPlayerCommandPerformed
    #undef OnPlayerCommandPerformed
#else
    #define _ALS_OnPlayerCommandPerformed
#endif
#define OnPlayerCommandPerformed MCmd_OnPlayerCommandPerformed
forward MCmd_OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags);

// ----------------------------------------------------------------------------
//  Player connect hook (resets per-player state)
// ----------------------------------------------------------------------------
public OnPlayerConnect(playerid)
{
    PC_ResetPlayer(playerid);
    if (funcidx("MCmd_OnPlayerConnect") != -1)
        return CallLocalFunction("MCmd_OnPlayerConnect", "d", playerid);
    return 1;
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect MCmd_OnPlayerConnect
forward MCmd_OnPlayerConnect(playerid);

// ----------------------------------------------------------------------------
//  Init hooks
// ----------------------------------------------------------------------------
#if defined FILTERSCRIPT
    public OnFilterScriptInit()
    {
        PC_Init();
        PC_InitState();
        PC_PrintBanner();

        if (funcidx("MCmd_OnFilterScriptInit") != -1)
            return CallLocalFunction("MCmd_OnFilterScriptInit", "");
        return 1;
    }
    #if defined _ALS_OnFilterScriptInit
        #undef OnFilterScriptInit
    #else
        #define _ALS_OnFilterScriptInit
    #endif
    #define OnFilterScriptInit MCmd_OnFilterScriptInit
    forward MCmd_OnFilterScriptInit();
#else
    public OnGameModeInit()
    {
        PC_Init();
        PC_InitState();
        PC_PrintBanner();

        if (funcidx("MCmd_OnGameModeInit") != -1)
            return CallLocalFunction("MCmd_OnGameModeInit", "");
        return 1;
    }
    #if defined _ALS_OnGameModeInit
        #undef OnGameModeInit
    #else
        #define _ALS_OnGameModeInit
    #endif
    #define OnGameModeInit MCmd_OnGameModeInit
    forward MCmd_OnGameModeInit();
#endif

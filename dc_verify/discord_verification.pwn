/*
    ------------------------------------------------------------
        Samp - Discord Verification System
        Developed by: Finn
        Discord: Mineiga24
    ------------------------------------------------------------
    
    1. Create folder: gamemodes/Modules/
    2. Place this file inside Modules
    3. Add this line in main gamemode:
       #include "./Modules/discord_verification.pwn"
    4. Make sure discord connector plugin is installed
    5. Restart server
*/


//////////////////// CONFIGURATION ////////////////////

//#define DISCORD_SERVER_ID        "1366943987675566161"
//#define VERIFICATION_CHANNEL_ID  "1477859830801764546"
//#define VERIFIED_ROLE_ID         "1477860031713116180"
//#define UNVERIFIED_ROLE_ID  "1477860152982900786"

#define DCMD_STRICT_CASE
#define DCMD_ALLOW_BOTS

//////////////////// VARIABLES ////////////////////

new DCC_Channel:gVerificationChannel;
new DCC_Guild:gDiscordGuild;
new DCC_Role:gVerifiedRole;
new DCC_Role:gUnverifiedRole;

//////////////////// INIT HOOK ////////////////////

public OnGameModeInit()
{
    // Find Discord server
    gDiscordGuild = DCC_FindGuildById(GUILD);

    // Find verification channel
    gVerificationChannel = DCC_FindChannelById(CHANNEL_VERIFY);

    // Find verified role
    gVerifiedRole = DCC_FindRoleById(ROLE_VERIFY);

    // Find Unverifiedd role
    gUnverifiedRole = DCC_FindRoleById(ROLE_UNVERIFY);

    #if defined Verification_OnGameModeInit
        return Verification_OnGameModeInit();
    #else
        return 1;
    #endif
}

//////////////////////////////////////////////////////
//////////////// INGAME COMMAND //////////////////////
//////////////////////////////////////////////////////

CMD:getcode(playerid, params[])
{
    if(User[playerid][pVerified])
        return SendClientMessage(playerid, -1,
            "[Discord]: You are already verified.");

    new code = random(900000) + 100000;

    User[playerid][pCode] = code;

    new string[128];
    format(string, sizeof(string), "[Discord]: Your verification code is: %d", code);
    SendClientMessage(playerid, 0x00FF00FF, string);

    SendClientMessage(playerid, -1, "[Discord]: Use !link <code> inside verification channel.");

    mysql_format(connectionID, queryBuffer, sizeof(queryBuffer),"UPDATE users SET code = %i WHERE uid = %i", code, User[playerid][pID]);
	mysql_tquery(connectionID, queryBuffer);

    return 1;
}

//////////////////////////////////////////////////////
//////////////// DISCORD COMMAND /////////////////////
//////////////////////////////////////////////////////

DCMD:link(user, channel, params[])
{
    if(channel != gVerificationChannel)
        return 1;

    new code;

    if(sscanf(params, "i", code))
        return SendBotMessage(gVerificationChannel, 0xFF0000,
            "Invalid Code",
            "Usage: !link <your_code>",
            "sampDevCore"
        );

    mysql_format(connectionID, queryBuffer, sizeof(queryBuffer),
        "SELECT * FROM users WHERE code = %i LIMIT 1",
        code
    );
    mysql_tquery(connectionID, queryBuffer,
        "OnPlayerDiscordVerified", "dd", _:user, code);

    return 1;
}

//////////////////////////////////////////////////////
//////////////// VERIFICATION CALLBACK ///////////////
//////////////////////////////////////////////////////

forward OnPlayerDiscordVerified(DCC_User:user, code);
public OnPlayerDiscordVerified(DCC_User:user, code)
{
    if(!cache_get_row_count(connectionID))
    {
        return SendBotMessage(gVerificationChannel, 0xFF0000,
            "Invalid Code",
            "No account found with this verification code.",
            "Lost Island Roleplay"
        );
    }

    new player_name[MAX_PLAYER_NAME];
    cache_get_field_content(0, "username", player_name, sizeof(player_name));

    new playerid = INVALID_PLAYER_ID;

    foreach(new i : Player)
    {
        if(!strcmp(player_name, GetPlayerNameEx(i), true))
        {
            playerid = i;
            break;
        }
    }

    if(!IsPlayerConnected(playerid))
    {
        return SendBotMessage(gVerificationChannel, 0xFF0000,
            "Player Offline",
            "You must be online in-game to verify.",
            "Lost Island Roleplay"
        );
    }

    // Check already verified
    new bool:isAlreadyVerified;
    DCC_HasGuildMemberRole(gDiscordGuild, user, gVerifiedRole, isAlreadyVerified);

    if(isAlreadyVerified)
    {
        return SendBotMessage(gVerificationChannel, 0xFF0000,
            "Already Verified",
            "Your Discord account is already verified.",
            "Lost Island Roleplay"
        );
    }

    // Check Unverified role
    new bool:hasUnverified;
    DCC_HasGuildMemberRole(gDiscordGuild, user, gUnverifiedRole, hasUnverified);

    if(!hasUnverified)
    {
        return SendBotMessage(gVerificationChannel, 0xFF0000,
            "Verification Failed",
            "You must have the Unverified role before linking.",
            "Lost island Roleplay"
        );
    }

    new user_name[DCC_USERNAME_SIZE];
    new user_tag[10];
    new user_id[DCC_ID_SIZE];

    DCC_GetUserName(user, user_name, sizeof(user_name));
    DCC_GetUserDiscriminator(user, user_tag, sizeof(user_tag));
    DCC_GetUserId(user, user_id, sizeof(user_id));

    //////////////////////////////////////
    // REMOVE UNVERIFIED + ADD VERIFIED
    //////////////////////////////////////

    DCC_RemoveGuildMemberRole(gDiscordGuild, user, gUnverifiedRole);
    DCC_AddGuildMemberRole(gDiscordGuild, user, gVerifiedRole);

    //DCC_SetGuildMemberNickname(gDiscordGuild, user, GetPlayerNameEx(playerid));

	GetPlayerName(playerid, player_name, sizeof(player_name));

	DCC_SetGuildMemberNickname(gDiscordGuild, user, player_name);

    //////////////////////////////////////
    // IN-GAME MESSAGE (OLD STYLE)
    //////////////////////////////////////

    new szString[256];
    format(szString, sizeof(szString),
        "[Discord Verification]: {FFFFFF}Your account has been linked to Discord account "SVRCLR"%s#%s",
        user_name, user_tag);

    SendClientMessage(playerid, SERVER_COLOR, szString);
    TogglePlayerControllable(playerid, 1);

    //////////////////////////////////////
    // DISCORD EMBED DETAILS (OLD RP STYLE)
    //////////////////////////////////////

    new age = cache_get_field_content_int(0, "age");
    new gender = cache_get_field_content_int(0, "gender");
    new skin = cache_get_field_content_int(0, "skin");

    new zstr[256], xstr[512], skinurl[128];

    format(zstr, sizeof(zstr),
        "Congratulations %s#%s!\nThe account below successfully linked:",
        user_name, user_tag);

    format(xstr, sizeof(xstr),
        "> In-game Name: %s\n> Age: %d\n> Gender: %s\n> Skin ID: %d",
        player_name,
        age,
        (gender == 1 ? ("Male") : ("Female")),
        skin
    );

    format(skinurl, sizeof(skinurl),
        "https://assets.open.mp/assets/images/skins/%d.png", skin);

    new DCC_Embed:embed = DCC_CreateEmbed("**Lost Island Roleplay - Verification**");
    DCC_SetEmbedColor(embed, 0x00FF00);
    DCC_AddEmbedField(embed, zstr, xstr, true);
    DCC_SetEmbedImage(embed, skinurl);
    DCC_SetEmbedFooter(embed, "Developed by Finn | Lost Island Roleplay");
    DCC_SendChannelEmbedMessage(gVerificationChannel, embed);

    //////////////////////////////////////
    // DATABASE UPDATE
    //////////////////////////////////////

    User[playerid][pVerified] = 1;

    mysql_format(connectionID, queryBuffer, sizeof(queryBuffer),
        "UPDATE users SET discord_name='%s', discord_tag='%s', verified_id='%e', verified=1, code=0 WHERE uid=%i",
        user_name,
        user_tag,
        user_id,
        User[playerid][pID]
    );
    mysql_tquery(connectionID, queryBuffer);
    
	if(IsPlayerConnected(playerid))
	{
	    DCC_SetGuildMemberNickname(gDiscordGuild, user, GetPlayerNameEx(playerid));

	    format(szString, sizeof(szString),
	        "[Discord Verification]: {FFFFFF}Your account successfully been linked to the discord account "SVRCLR"%s#%s",
	        user_name, user_tag
	    );
	    SendClientMessage(playerid, SERVER_COLOR, szString);

	    format(szString, sizeof(szString),
	        "The account **%s** has been successfully linked to your Discord account\nYou will now be able to access the features in the server and much more.\nJoining events, weapons, vehicles, jobs, and more.\n\n**Welcome to %s.**",
	        GetRPName(playerid),
	        SERVER_NAME
	    );

	    SendBotMessage(
	        gVerificationChannel,
	        0x00FF00,
	        "Successfully Verified!",
	        szString,
	        ""SERVER_NAME" - !help for more information"
	    );

	    SCM(playerid, COLOR_ORANGE, "Your account has been successfully verified to your Discord account.");
	    SCM(playerid, COLOR_ORANGE, "You will now be able to access general in-game features such as");
	    SCM(playerid, COLOR_ORANGE, "Global Chat, joining events, accessing weapons, etc.");
	    SCM(playerid, COLOR_ORANGE, "Welcome to "SERVER_NAME".");

	    SetPlayerPos(playerid, 1715.0828, -1879.6105, 13.5665);
	    SetPlayerFacingAngle(playerid, 358.9924);
	    //SetPlayerInterior(playerid, 0);

	}

    return 1;
}

//////////////////////////////////////////////////////
//////////////// EMBED FUNCTION //////////////////////
//////////////////////////////////////////////////////

forward SendBotMessage(DCC_Channel:channel, color,
    const title[], const message[], const footer[]);

public SendBotMessage(DCC_Channel:channel, color,
    const title[], const message[], const footer[])
{
    new DCC_Embed:embed = DCC_CreateEmbed(title);
    DCC_SetEmbedColor(embed, color);
    DCC_SetEmbedDescription(embed, message);
    DCC_SetEmbedFooter(embed, footer);
    DCC_SendChannelEmbedMessage(channel, embed);
    return 1;
}

stock IsPlayerVerified(playerid)
{
    if(!User[playerid][pVerified])
    {
        SCM(playerid, COLOR_GREY, "You must verify your Discord account first.");
        return 0;
    }

    return 1;
}

//////////////////////////////////////////////////////
//////////////// ALS HOOK ////////////////////////////
//////////////////////////////////////////////////////

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif

#define OnGameModeInit Verification_OnGameModeInit

#if defined Verification_OnGameModeInit
    forward Verification_OnGameModeInit();
#endif


/*

/// DB ADDING SEACTION ///
	phpMyAdmin > SQL tab > paste > GO

ALTER TABLE users
ADD code INT DEFAULT 0,
ADD verified INT DEFAULT 0,
ADD discord_name VARCHAR(32) DEFAULT NULL,
ADD discord_tag VARCHAR(10) DEFAULT NULL,
ADD verified_id VARCHAR(32) DEFAULT NULL;

*/


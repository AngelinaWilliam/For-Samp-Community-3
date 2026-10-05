// crashdetect_advanced.inc
//
// Advanced wrapper around crashdetect.inc for SA-MP / open.mp.
// Adds: detailed file logging, per-error-type callbacks, watchdog/
// long-call monitoring helpers, and debug macros.
//
// Requires the original crashdetect plugin + crashdetect.inc to be
// present, since this file only wraps/extends its natives.
//
// Usage:
//   #include <crashdetect>          // the original plugin include
//   #include <crashdetect_advanced> // this file
//
// NOTE on logging: CrashDetectAdv_Log() takes a plain, already-built
// string — it is NOT variadic (Pawn can't forward "..." from one
// user function into another). Build the message with format()
// yourself first:
//
//   new msg[128];
//   format(msg, sizeof msg, "player %d did %d damage", playerid, dmg);
//   CrashDetectAdv_Log(msg);

//UPGRADE BY MINEIGA<<<

#if defined CRASHDETECT_ADVANCED_INC
	#endinput
#endif
#define CRASHDETECT_ADVANCED_INC

#include <a_samp>

// ---------------------------------------------------------------------
// Config (override with #define BEFORE including this file if needed)
// ---------------------------------------------------------------------

#if !defined CRASHDETECT_ADV_LOGFILE
	#define CRASHDETECT_ADV_LOGFILE "crashdetect_advanced.log"
#endif

#if !defined CRASHDETECT_ADV_WATCHDOG_MS
	#define CRASHDETECT_ADV_WATCHDOG_MS (100) // long_call_time threshold, ms
#endif

#if !defined CRASHDETECT_ADV_MAX_BACKTRACE
	#define CRASHDETECT_ADV_MAX_BACKTRACE (4096)
#endif

// AMX error codes (standard Pawn errors, from amx.h) — used to classify
// what kind of runtime error just happened so we can fire a specific
// callback instead of one generic one.
#define AMX_ERR_NONE            (0)
#define AMX_ERR_EXIT            (1)
#define AMX_ERR_ASSERT          (2)
#define AMX_ERR_STACKERR        (3)
#define AMX_ERR_BOUNDS          (4)
#define AMX_ERR_MEMACCESS       (5)
#define AMX_ERR_INVINSTR        (6)
#define AMX_ERR_STACKLOW        (7)
#define AMX_ERR_HEAPLOW         (8)
#define AMX_ERR_CALLBACK        (9)
#define AMX_ERR_NATIVE          (10)
#define AMX_ERR_DIVIDE          (11)
#define AMX_ERR_SLEEP           (12)
#define AMX_ERR_INVSTATE        (13)
#define AMX_ERR_MEMORY          (16)
#define AMX_ERR_FORMAT          (17)
#define AMX_ERR_VERSION         (18)
#define AMX_ERR_NOTFOUND        (19)
#define AMX_ERR_INDEX           (20)
#define AMX_ERR_DEBUG           (21)
#define AMX_ERR_INIT            (22)
#define AMX_ERR_USERDATA        (23)
#define AMX_ERR_INIT_JIT        (24)
#define AMX_ERR_PARAMS          (25)
#define AMX_ERR_DOMAIN          (26)
#define AMX_ERR_GENERAL         (27)

// ---------------------------------------------------------------------
// Forwards the script can implement for fine-grained handling.
// All are optional — only define the ones you care about.
// ---------------------------------------------------------------------

forward OnCrashDetectLog(const message[]);          // every logged line
forward OnStackOverflow(const backtrace[]);          // AMX_ERR_STACKLOW / STACKERR
forward OnArrayBoundsError(const backtrace[]);       // AMX_ERR_BOUNDS
forward OnDivisionByZero(const backtrace[]);         // AMX_ERR_DIVIDE
forward OnInvalidMemoryAccess(const backtrace[]);    // AMX_ERR_MEMACCESS
forward OnNativeError(const backtrace[]);            // AMX_ERR_NATIVE
forward OnAssertionFailed(const backtrace[]);        // AMX_ERR_ASSERT
forward OnUnclassifiedRuntimeError(code, const backtrace[]); // anything else
forward OnLongCallDetected(elapsed_ms);              // watchdog trip

// ---------------------------------------------------------------------
// Internal state
// ---------------------------------------------------------------------

static bool:g_AdvWatchdogEnabled = false;

// ---------------------------------------------------------------------
// Logging
// ---------------------------------------------------------------------

// Writes a timestamped line to CRASHDETECT_ADV_LOGFILE and fires
// OnCrashDetectLog so the gamemode can mirror it elsewhere (Discord
// webhook, admin chat, etc.) without touching this file.
//
// Takes a plain string. If you need formatting, build it with
// format() before calling this (see note at the top of the file).
stock CrashDetectAdv_Log(const message[])
{
	new year, month, day, hour, minute, second;
	getdate(year, month, day);
	gettime(hour, minute, second);

	new line[320];
	format(line, sizeof line, "[%04d-%02d-%02d %02d:%02d:%02d] %s",
		year, month, day, hour, minute, second, message);

	new File:f = fopen(CRASHDETECT_ADV_LOGFILE, io_append);
	if (f)
	{
		fwrite(f, line);
		fwrite(f, "\r\n");
		fclose(f);
	}

	#if defined OnCrashDetectLog
		CallLocalFunction("OnCrashDetectLog", "s", line);
	#endif
	return 1;
}

// Convenience: format + log in one call for the common "a few args"
// case, without needing a general variadic forwarder. Supports up to
// 4 integer/string-safe args via the normal format() spec you pass.
stock CrashDetectAdv_Logf(const fmt[], arg0 = 0, arg1 = 0, arg2 = 0, arg3 = 0)
{
	new msg[256];
	format(msg, sizeof msg, fmt, arg0, arg1, arg2, arg3);
	CrashDetectAdv_Log(msg);
	return 1;
}

// Pulls the current backtrace from the crashdetect plugin and logs it
// in full, truncated to CRASHDETECT_ADV_MAX_BACKTRACE if needed.
stock CrashDetectAdv_LogBacktrace(const context[] = "")
{
	new bt[CRASHDETECT_ADV_MAX_BACKTRACE];
	GetBacktrace(bt, sizeof bt);

	new header[128];
	if (context[0])
		format(header, sizeof header, "--- Backtrace (%s) ---", context);
	else
		format(header, sizeof header, "--- Backtrace ---");

	CrashDetectAdv_Log(header);
	CrashDetectAdv_Log(bt);
	return 1;
}

// ---------------------------------------------------------------------
// Per-type dispatch. Call this from your OnRuntimeError (see example
// at the bottom) to turn the generic callback into specific ones.
// ---------------------------------------------------------------------

stock CrashDetectAdv_Dispatch(code, &bool:suppress)
{
	new bt[CRASHDETECT_ADV_MAX_BACKTRACE];
	GetBacktrace(bt, sizeof bt);

	CrashDetectAdv_Logf("Runtime error %d caught", code);
	CrashDetectAdv_LogBacktrace("runtime error");

	switch (code)
	{
		case AMX_ERR_STACKLOW, AMX_ERR_STACKERR:
		{
			#if defined OnStackOverflow
				CallLocalFunction("OnStackOverflow", "s", bt);
			#endif
		}
		case AMX_ERR_BOUNDS:
		{
			#if defined OnArrayBoundsError
				CallLocalFunction("OnArrayBoundsError", "s", bt);
			#endif
		}
		case AMX_ERR_DIVIDE:
		{
			#if defined OnDivisionByZero
				CallLocalFunction("OnDivisionByZero", "s", bt);
			#endif
		}
		case AMX_ERR_MEMACCESS:
		{
			#if defined OnInvalidMemoryAccess
				CallLocalFunction("OnInvalidMemoryAccess", "s", bt);
			#endif
		}
		case AMX_ERR_NATIVE:
		{
			#if defined OnNativeError
				CallLocalFunction("OnNativeError", "s", bt);
			#endif
		}
		case AMX_ERR_ASSERT:
		{
			#if defined OnAssertionFailed
				CallLocalFunction("OnAssertionFailed", "s", bt);
			#endif
		}
		default:
		{
			#if defined OnUnclassifiedRuntimeError
				CallLocalFunction("OnUnclassifiedRuntimeError", "is", code, bt);
			#endif
		}
	}

	// Leave `suppress` as the caller set it (crashdetect decides the
	// default); scripts can still flip it inside their own callbacks.
	return 1;
}

// ---------------------------------------------------------------------
// Watchdog: wraps the plugin's built-in long_call_time feature.
// Needs HasCrashDetectLongCall() to be true (plugin built with support).
// ---------------------------------------------------------------------

stock CrashDetectAdv_StartWatchdog(threshold_ms = CRASHDETECT_ADV_WATCHDOG_MS)
{
	if (!HasCrashDetectLongCall())
	{
		CrashDetectAdv_Log("Watchdog not available: plugin lacks long_call_time support");
		return 0;
	}

	SetCrashDetectLongCallTime(threshold_ms);
	EnableCrashDetectLongCall();
	g_AdvWatchdogEnabled = true;

	CrashDetectAdv_Logf("Watchdog started (threshold=%dms)", threshold_ms);
	return 1;
}

stock bool:CrashDetectAdv_IsWatchdogOn()
{
	return g_AdvWatchdogEnabled;
}

stock CrashDetectAdv_StopWatchdog()
{
	if (!g_AdvWatchdogEnabled)
		return 0;

	DisableCrashDetectLongCall();
	g_AdvWatchdogEnabled = false;
	CrashDetectAdv_Log("Watchdog stopped");
	return 1;
}
/*
stock bool:CrashDetectAdv_IsWatchdogEnabled()
{
	return g_AdvWatchdogEnabled;
}*/

// ---------------------------------------------------------------------
// Debug macros — compiled out entirely when CRASHDETECT_ADV_NO_DEBUG
// is defined, so you can strip them from release builds with one line.
// ---------------------------------------------------------------------

#if defined CRASHDETECT_ADV_NO_DEBUG
	#define ADV_ASSERT(%1)
	#define ADV_TRACE(%1)
#else
	#define ADV_ASSERT(%1) \
		if (!(%1)) CrashDetectAdv_Logf("ASSERT FAILED at line %d", __LINE__)
	// %1 must be a string literal/array, e.g. ADV_TRACE("entered OnPlayerDeath")
	#define ADV_TRACE(%1) \
		CrashDetectAdv_Log(%1)
#endif

// ---------------------------------------------------------------------
// Example wiring (copy into your gamemode, not auto-included):
//
// public OnRuntimeError(code, &bool:suppress)
// {
//     CrashDetectAdv_Dispatch(code, suppress);
//     return 1;
// }
//
// public OnGameModeInit()
// {
//     CrashDetectAdv_StartWatchdog(150);
//     return 1;
// }
//
// public OnLongCallDetected(elapsed_ms)
// {
//     CrashDetectAdv_Logf("Long call: %dms", elapsed_ms);
//     return 1;
// }
// ---------------------------------------------------------------------

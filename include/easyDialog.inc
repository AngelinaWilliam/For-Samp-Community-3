/*
	easyDialog.inc (upgraded) - Dialogs made easier!

	Original by Emmet (January 24, 2014).

	Upgrades:
	 - Include guard
	 - Configurable dialog ID (define EASY_DIALOG_ID bago i-include)
	 - Nire-reset ang state kapag nag-disconnect (iwas stale dialog sa reused ID)
	 - Hindi na nagse-send ng extra RPC sa bawat response
	 - Validation: playerid, pangalan ng dialog, laki ng caption/buttons
	 - Dialog_SetData / Dialog_GetData para magpasa ng extra value (hal. targetid)
	 - Dialog_Opened ay direct call na (hindi na CallRemoteFunction)
*/

#if defined _easy_dialog_included
	#endinput
#endif
#define _easy_dialog_included

#if !defined isnull
	#define isnull(%1) \
		((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

#if !defined EASY_DIALOG_ID
	#define EASY_DIALOG_ID 32700
#endif

// Public function name = "dialog_" + pangalan, kaya max 24 chars ang pangalan.
#define EASY_DIALOG_MAX_NAME 24

#define Dialog:%0(%1) \
	forward dialog_%0(%1); public dialog_%0(%1)

#define Dialog_Show(%0,%1, \
	Dialog_Open(%0, #%1,

#define Dialog_Opened(%0) \
	Dialog_IsOpened(%0)

static
	s_DialogName[MAX_PLAYERS][32 char],
	s_DialogOpened[MAX_PLAYERS],
	s_DialogData[MAX_PLAYERS]
;

forward OnDialogPerformed(playerid, dialog[], response, success);

forward @dialog_format(); @dialog_format() {
	format("", 0, "");
}

forward Dialog_IsOpened(playerid);
public Dialog_IsOpened(playerid)
{
	if (!(0 <= playerid < MAX_PLAYERS))
	{
		return 0;
	}
	return (s_DialogOpened[playerid]);
}

static stock Dialog_Reset(playerid)
{
	s_DialogName[playerid]{0} = 0;
	s_DialogOpened[playerid] = 0;
}

// Pwedeng tawagin bago mag-show: Dialog_SetData(playerid, targetid);
// Tapos sa callback: new targetid = Dialog_GetData(playerid);
stock Dialog_SetData(playerid, value)
{
	if (!(0 <= playerid < MAX_PLAYERS))
	{
		return 0;
	}
	s_DialogData[playerid] = value;
	return 1;
}

stock Dialog_GetData(playerid)
{
	if (!(0 <= playerid < MAX_PLAYERS))
	{
		return 0;
	}
	return s_DialogData[playerid];
}

stock Dialog_Close(playerid)
{
	if (!(0 <= playerid < MAX_PLAYERS))
	{
		return 0;
	}
	Dialog_Reset(playerid);

	return ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, " ", " ", " ", "");
}

stock Dialog_Open(playerid, function[], style, caption[], info[], button1[], button2[], {Float,_}:...)
{
	static
		string[4096],
		args
	;

	if (!(0 <= playerid < MAX_PLAYERS) || !IsPlayerConnected(playerid))
	{
		return 0;
	}
	if (!strlen(info) || !strlen(function) || strlen(function) > EASY_DIALOG_MAX_NAME)
	{
		return 0;
	}
	if ((args = numargs()) > 7)
	{
		while (--args >= 7)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S info
		#emit PUSH.C 4096
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit CONST.alt 16
		#emit SUB
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		ShowPlayerDialog(playerid, EASY_DIALOG_ID, style, caption, string, button1, button2);
	}
	else
	{
		ShowPlayerDialog(playerid, EASY_DIALOG_ID, style, caption, info, button1, button2);
	}
	s_DialogOpened[playerid] = 1;

	strpack(s_DialogName[playerid], function, 32 char);

	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	static
		s_Public = cellmax;

	if (s_Public == cellmax)
	{
		s_Public = funcidx("OnDialogPerformed");
	}

	// Sanitize inputs.
	for (new i = 0, l = strlen(inputtext); i < l; i ++)
	{
		if (inputtext[i] == '%')
		{
			inputtext[i] = '#';
		}
	}
	if (dialogid == EASY_DIALOG_ID && s_DialogOpened[playerid] && strlen(s_DialogName[playerid]) > 0)
	{
		new
			string[40];

		strcat(string, "dialog_");
		strcat(string, s_DialogName[playerid]);

		// Reset lang ang state; hindi na kailangan mag-send ng RPC dahil sumagot na ang player.
		Dialog_Reset(playerid);

		if ((s_Public == -1) || (CallLocalFunction("OnDialogPerformed", "dsdd", playerid, string[7], response, funcidx(string) != -1)))
		{
			CallLocalFunction(string, "ddds", playerid, response, listitem, (!inputtext[0]) ? ("\1") : (inputtext));
		}
	}
	#if defined DR_OnDialogResponse
		return DR_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	#else
		return 0;
	#endif
}

#if defined _ALS_OnDialogResponse
	#undef OnDialogResponse
#else
	#define _ALS_OnDialogResponse
#endif

#define OnDialogResponse DR_OnDialogResponse

#if defined DR_OnDialogResponse
	forward DR_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

// Linisin ang state pag-disconnect.
public OnPlayerDisconnect(playerid, reason)
{
	Dialog_Reset(playerid);
	s_DialogData[playerid] = 0;

	#if defined ED_OnPlayerDisconnect
		return ED_OnPlayerDisconnect(playerid, reason);
	#else
		return 1;
	#endif
}

#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif

#define OnPlayerDisconnect ED_OnPlayerDisconnect

#if defined ED_OnPlayerDisconnect
	forward ED_OnPlayerDisconnect(playerid, reason);
#endif

#include <YSI_Coding\y_hooks>
#include <discord-cmd>

#define DCMD_PREFIX '!'
//#define DCMD_STRICT_CASE 
//#define DCMD_ALLOW_BOTS

#define GUILD "1180757118698131517"


// Roles
#define ROLE_VERIFY "1554504072466268260"
#define ROLE_UNVERIFY "1554504136710561892"
#define ROLE_ADMIN "1170214712206700626"
#define ROLE_HELPER "1170214711967612967"

// Channels (Default fallback IDs; overridden dynamically by !setlog / discord_channels.cfg)
#define CHANNEL_VERIFY "1419718059752427695"
#define CHANNEL_GLOBALCHAT "1552721103032557588"     // log-globalchat
#define CHANNEL_ROLEREQ "1162821986402185235"
#define CHANNEL_ADMINLOG "1552721051530694766"       // log-admin
#define CHANNEL_PUNISHMENT "1552721070409130126"     // log-punishment
#define CHANNEL_ANTICHEAT "1552721077539446918"      // log-anticheat
#define CHANNEL_REPORTS "1552721091812790312"        // log-reports
#define CHANNEL_SERVERSTATUS "1552721236818137108"   // server-announcements

#define DC_FOOTER "Lost Island Roleplay - !help for info"

new g_dcChannelAdminLog[DCC_ID_SIZE] = CHANNEL_ADMINLOG;
new g_dcChannelPunish[DCC_ID_SIZE] = CHANNEL_PUNISHMENT;
new g_dcChannelAntiCheat[DCC_ID_SIZE] = CHANNEL_ANTICHEAT;
new g_dcChannelReports[DCC_ID_SIZE] = CHANNEL_REPORTS;
new g_dcChannelGlobal[DCC_ID_SIZE] = CHANNEL_GLOBALCHAT;
new g_dcChannelAdminChat[DCC_ID_SIZE] = "1552721055456559145"; // log-adminchat
new g_dcChannelRPLog[DCC_ID_SIZE] = "1552721099408674848";     // log-chat
new g_dcChannelLogin[DCC_ID_SIZE] = "";
new g_dcChannelKill[DCC_ID_SIZE] = "";
new g_dcChannelDamage[DCC_ID_SIZE] = "";
new g_dcChannelWeapons[DCC_ID_SIZE] = "";
new g_dcChannelBan[DCC_ID_SIZE] = "";
new g_dcChannelPM[DCC_ID_SIZE] = "";
new g_dcChannelWhisper[DCC_ID_SIZE] = "";
new g_dcChannelFB[DCC_ID_SIZE] = "";
new g_dcChannelTwitter[DCC_ID_SIZE] = "";
new g_dcChannelInsta[DCC_ID_SIZE] = "";
new g_dcChannelOOC[DCC_ID_SIZE] = "";
new g_dcChannelDynamic[DCC_ID_SIZE] = "";
new g_dcChannelCommands[DCC_ID_SIZE] = "";
new g_dcChannelFaction[DCC_ID_SIZE] = "";
new g_dcChannelBusiness[DCC_ID_SIZE] = "";
new g_dcServerIP[64] = "143.14.88.9:34719";

stock DC_SaveChannels()
{
	new File:handle = fopen("discord_channels.cfg", io_write);
	if(handle)
	{
		new line[128];
		format(line, sizeof(line), "admin=%s\r\n", g_dcChannelAdminLog); fwrite(handle, line);
		format(line, sizeof(line), "punish=%s\r\n", g_dcChannelPunish); fwrite(handle, line);
		format(line, sizeof(line), "anticheat=%s\r\n", g_dcChannelAntiCheat); fwrite(handle, line);
		format(line, sizeof(line), "reports=%s\r\n", g_dcChannelReports); fwrite(handle, line);
		format(line, sizeof(line), "global=%s\r\n", g_dcChannelGlobal); fwrite(handle, line);
		format(line, sizeof(line), "adminchat=%s\r\n", g_dcChannelAdminChat); fwrite(handle, line);
		format(line, sizeof(line), "rp=%s\r\n", g_dcChannelRPLog); fwrite(handle, line);
		format(line, sizeof(line), "login=%s\r\n", g_dcChannelLogin); fwrite(handle, line);
		format(line, sizeof(line), "kill=%s\r\n", g_dcChannelKill); fwrite(handle, line);
		format(line, sizeof(line), "damage=%s\r\n", g_dcChannelDamage); fwrite(handle, line);
		format(line, sizeof(line), "weapons=%s\r\n", g_dcChannelWeapons); fwrite(handle, line);
		format(line, sizeof(line), "ban=%s\r\n", g_dcChannelBan); fwrite(handle, line);
		format(line, sizeof(line), "pm=%s\r\n", g_dcChannelPM); fwrite(handle, line);
		format(line, sizeof(line), "whisper=%s\r\n", g_dcChannelWhisper); fwrite(handle, line);
		format(line, sizeof(line), "fb=%s\r\n", g_dcChannelFB); fwrite(handle, line);
		format(line, sizeof(line), "twitter=%s\r\n", g_dcChannelTwitter); fwrite(handle, line);
		format(line, sizeof(line), "insta=%s\r\n", g_dcChannelInsta); fwrite(handle, line);
		format(line, sizeof(line), "ooc=%s\r\n", g_dcChannelOOC); fwrite(handle, line);
		format(line, sizeof(line), "dynamic=%s\r\n", g_dcChannelDynamic); fwrite(handle, line);
		format(line, sizeof(line), "commands=%s\r\n", g_dcChannelCommands); fwrite(handle, line);
		format(line, sizeof(line), "faction=%s\r\n", g_dcChannelFaction); fwrite(handle, line);
		format(line, sizeof(line), "business=%s\r\n", g_dcChannelBusiness); fwrite(handle, line);
		format(line, sizeof(line), "ip=%s\r\n", g_dcServerIP); fwrite(handle, line);
		fclose(handle);
		return 1;
	}
	return 0;
}

stock DC_CleanChannelId(const input[], output[], maxlen = sizeof(output))
{
	new idx = 0, outIdx = 0;
	while(input[idx] != '\0' && outIdx < maxlen - 1)
	{
		if(input[idx] >= '0' && input[idx] <= '9')
		{
			output[outIdx++] = input[idx];
		}
		idx++;
	}
	output[outIdx] = '\0';
	return (outIdx > 0);
}

stock DC_LoadChannels()
{
	if(!fexist("discord_channels.cfg")) return 0;
	new File:handle = fopen("discord_channels.cfg", io_read);
	if(handle)
	{
		new line[128], key[32], val[64], cleanVal[DCC_ID_SIZE];
		while(fread(handle, line))
		{
			for(new i = strlen(line) - 1; i >= 0; i--)
			{
				if(line[i] == '\r' || line[i] == '\n' || line[i] == ' ') line[i] = '\0';
				else break;
			}
			if(!sscanf(line, "p<=>s[32]s[64]", key, val))
			{
				if(!strcmp(key, "ip", true) && strlen(val) > 3) format(g_dcServerIP, sizeof(g_dcServerIP), "%s", val);
				else if(DC_CleanChannelId(val, cleanVal) && strlen(cleanVal) >= 15)
				{
					if(!strcmp(key, "admin", true)) format(g_dcChannelAdminLog, sizeof(g_dcChannelAdminLog), "%s", cleanVal);
					else if(!strcmp(key, "punish", true)) format(g_dcChannelPunish, sizeof(g_dcChannelPunish), "%s", cleanVal);
					else if(!strcmp(key, "anticheat", true) || !strcmp(key, "ac", true)) format(g_dcChannelAntiCheat, sizeof(g_dcChannelAntiCheat), "%s", cleanVal);
					else if(!strcmp(key, "reports", true) || !strcmp(key, "report", true)) format(g_dcChannelReports, sizeof(g_dcChannelReports), "%s", cleanVal);
					else if(!strcmp(key, "global", true)) format(g_dcChannelGlobal, sizeof(g_dcChannelGlobal), "%s", cleanVal);
					else if(!strcmp(key, "adminchat", true)) format(g_dcChannelAdminChat, sizeof(g_dcChannelAdminChat), "%s", cleanVal);
					else if(!strcmp(key, "rp", true) || !strcmp(key, "chat", true)) format(g_dcChannelRPLog, sizeof(g_dcChannelRPLog), "%s", cleanVal);
					else if(!strcmp(key, "login", true)) format(g_dcChannelLogin, sizeof(g_dcChannelLogin), "%s", cleanVal);
					else if(!strcmp(key, "kill", true)) format(g_dcChannelKill, sizeof(g_dcChannelKill), "%s", cleanVal);
					else if(!strcmp(key, "damage", true)) format(g_dcChannelDamage, sizeof(g_dcChannelDamage), "%s", cleanVal);
					else if(!strcmp(key, "weapons", true)) format(g_dcChannelWeapons, sizeof(g_dcChannelWeapons), "%s", cleanVal);
					else if(!strcmp(key, "ban", true)) format(g_dcChannelBan, sizeof(g_dcChannelBan), "%s", cleanVal);
					else if(!strcmp(key, "pm", true)) format(g_dcChannelPM, sizeof(g_dcChannelPM), "%s", cleanVal);
					else if(!strcmp(key, "whisper", true)) format(g_dcChannelWhisper, sizeof(g_dcChannelWhisper), "%s", cleanVal);
					else if(!strcmp(key, "fb", true) || !strcmp(key, "facebook", true)) format(g_dcChannelFB, sizeof(g_dcChannelFB), "%s", cleanVal);
					else if(!strcmp(key, "twitter", true)) format(g_dcChannelTwitter, sizeof(g_dcChannelTwitter), "%s", cleanVal);
					else if(!strcmp(key, "insta", true) || !strcmp(key, "instagram", true)) format(g_dcChannelInsta, sizeof(g_dcChannelInsta), "%s", cleanVal);
					else if(!strcmp(key, "ooc", true)) format(g_dcChannelOOC, sizeof(g_dcChannelOOC), "%s", cleanVal);
					else if(!strcmp(key, "dynamic", true) || !strcmp(key, "dynamics", true)) format(g_dcChannelDynamic, sizeof(g_dcChannelDynamic), "%s", cleanVal);
					else if(!strcmp(key, "commands", true) || !strcmp(key, "cmd", true)) format(g_dcChannelCommands, sizeof(g_dcChannelCommands), "%s", cleanVal);
					else if(!strcmp(key, "faction", true) || !strcmp(key, "factions", true)) format(g_dcChannelFaction, sizeof(g_dcChannelFaction), "%s", cleanVal);
					else if(!strcmp(key, "business", true) || !strcmp(key, "biz", true)) format(g_dcChannelBusiness, sizeof(g_dcChannelBusiness), "%s", cleanVal);
				}
			}
		}
		fclose(handle);
		return 1;
	}
	return 0;
}

hook OnGameModeInit()
{
	DC_LoadChannels();
	return 1;
}

// -----------------------------------------------------------------------------
// Embed & Logging Helpers
// -----------------------------------------------------------------------------
stock DCC_Channel:DC_ResolveChannel(const channelId[], const fallbackName1[], const fallbackName2[] = "", const fallbackId[] = "")
{
	new DCC_Channel:chan = DCC_INVALID_CHANNEL;
	if(strlen(channelId) >= 15) chan = DCC_FindChannelById(channelId);
	if(!chan && strlen(fallbackName1) > 0) chan = DCC_FindChannelByName(fallbackName1);
	if(!chan && strlen(fallbackName2) > 0) chan = DCC_FindChannelByName(fallbackName2);
	if(!chan && strlen(fallbackId) >= 15) chan = DCC_FindChannelById(fallbackId);
	return chan;
}

CreateEmbed(const channel[], const desc[] = "")
{
	new DCC_Channel:chan = DCC_FindChannelById(channel);
	if(!chan) chan = DCC_FindChannelByName(channel);
	if(!chan) return 0;
	return DCC_SendChannelEmbedMessage(chan, DCC_CreateEmbed("", desc, "", "", 0, DC_FOOTER));
}

stock DC_SendAdminLog(const title[], const desc[], color = 0x3498DB)
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelAdminLog, "log-admin", "admin-log", g_dcChannelGlobal);
	if(!chan) return 0;
	new DCC_Embed:embed = DCC_CreateEmbed(title, desc, "", "", color, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendPunishmentLog(const title[], const desc[], color = 0xE74C3C)
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelPunish, "log-punish", "log-punishment", g_dcChannelAdminLog);
	if(!chan) return 0;
	new DCC_Embed:embed = DCC_CreateEmbed(title, desc, "", "", color, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendACLog(const desc[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelAntiCheat, "log-anticheat", "anticheat-log", g_dcChannelAdminLog);
	if(!chan) return 0;
	new DCC_Embed:embed = DCC_CreateEmbed("Anticheat Alert", desc, "", "", 0xE67E22, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendReportLog(const title[], const desc[], color = 0xF1C40F)
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelReports, "log-reports", "reports-log", g_dcChannelAdminLog);
	if(!chan) return 0;
	new DCC_Embed:embed = DCC_CreateEmbed(title, desc, "", "", color, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendLoginLog(playerid, const desc[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelLogin, "log-join-exit", "join-exit", g_dcChannelAdminLog);
	if(!chan) chan = DCC_FindChannelByName("log-login");
	if(!chan) chan = DCC_FindChannelByName("log-system");
	if(!chan) chan = DCC_FindChannelById(g_dcChannelGlobal);
	if(!chan) return 0;
	new DCC_Embed:embed = DCC_CreateEmbed("Player Connection", desc, "", "", 0x2ECC71, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendDisconnectLog(playerid, const desc[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelLogin, "log-join-exit", "join-exit", g_dcChannelAdminLog);
	if(!chan) chan = DCC_FindChannelByName("log-login");
	if(!chan) chan = DCC_FindChannelByName("log-system");
	if(!chan) chan = DCC_FindChannelById(g_dcChannelGlobal);
	if(!chan) return 0;
	new DCC_Embed:embed = DCC_CreateEmbed("Player Disconnection", desc, "", "", 0xE74C3C, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendKillLog(killerid, victimid, const reason[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelKill, "log-kill", "kills-log", g_dcChannelPunish);
	if(!chan) chan = DC_ResolveChannel(g_dcChannelAdminLog, "log-admin", "admin-log", "");
	if(!chan) return 0;
	new desc[256];
	if(killerid != INVALID_PLAYER_ID)
		format(desc, sizeof(desc), "💀 **%s** (ID: %d) killed **%s** (ID: %d)\nWeapon: `%s`", GetRPName(killerid), killerid, GetRPName(victimid), victimid, reason);
	else
		format(desc, sizeof(desc), "💀 **%s** (ID: %d) died (%s)", GetRPName(victimid), victimid, reason);
	new DCC_Embed:embed = DCC_CreateEmbed("Kill / Death Log", desc, "", "", 0xE74C3C, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendDamageLog(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelDamage, "log-damage", "damage-log", g_dcChannelAntiCheat);
	if(!chan) return 0;
	new desc[160];
	format(desc, sizeof(desc), "💥 **%s** damaged **%s** (%.1f HP) with %s (Bodypart: %d)", GetRPName(issuerid), GetRPName(playerid), amount, GetWeaponNameEx(weaponid), bodypart);
	new DCC_Embed:embed = DCC_CreateEmbed("Combat Damage", desc, "", "", 0xE67E22, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendWeaponLog(playerid, const action[], const weaponName[], ammo)
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelWeapons, "log-weapons", "weapons-log", g_dcChannelAdminLog);
	if(!chan) return 0;
	new desc[160];
	format(desc, sizeof(desc), "🔫 **%s** (ID: %d) %s `%s` (Ammo: %d)", GetRPName(playerid), playerid, action, weaponName, ammo);
	new DCC_Embed:embed = DCC_CreateEmbed("Weapon Transaction", desc, "", "", 0x34495E, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendBanLog(const title[], const desc[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelBan, "log-ban", "bans-log", g_dcChannelPunish);
	if(!chan) chan = DC_ResolveChannel(g_dcChannelAdminLog, "log-admin", "admin-log", "");
	if(!chan) return 0;
	new DCC_Embed:embed = DCC_CreateEmbed(title, desc, "", "", 0xC0392B, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendPMLog(playerid, targetid, const message[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelPM, "log-pm-message", "log-pm", "");
	if(!chan) return 0;
	new desc[256];
	format(desc, sizeof(desc), "📩 **%s** (ID: %d) ➔ **%s** (ID: %d):\n*%s*", GetRPName(playerid), playerid, GetRPName(targetid), targetid, message);
	new DCC_Embed:embed = DCC_CreateEmbed("Private Message", desc, "", "", 0x9B59B6, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendWhisperLog(playerid, targetid, const message[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelWhisper, "log-whisper", "whisper-log", "");
	if(!chan) return 0;
	new desc[256];
	format(desc, sizeof(desc), "🤫 **%s** (ID: %d) whispered to **%s** (ID: %d):\n*%s*", GetRPName(playerid), playerid, GetRPName(targetid), targetid, message);
	new DCC_Embed:embed = DCC_CreateEmbed("Whisper Log", desc, "", "", 0x1ABC9C, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendSocialLog(const platform[], playerid, const username[], const text[])
{
	new DCC_Channel:chan = DCC_Channel:0;
	new color = 0x3B5998;
	if(!strcmp(platform, "facebook", true)) { chan = DC_ResolveChannel(g_dcChannelFB, "log-facebookchat", "facebook-log", g_dcChannelGlobal); color = 0x3B5998; }
	else if(!strcmp(platform, "twitter", true)) { chan = DC_ResolveChannel(g_dcChannelTwitter, "log-twitterchat", "twitter-log", g_dcChannelGlobal); color = 0x1DA1F2; }
	else if(!strcmp(platform, "insta", true)) { chan = DC_ResolveChannel(g_dcChannelInsta, "log-instachat", "insta-log", g_dcChannelGlobal); color = 0xE1306C; }
	if(!chan) chan = DC_ResolveChannel(g_dcChannelGlobal, "log-globalchat", "global-chat", "");
	if(!chan) return 0;

	new title[64], desc[256];
	format(title, sizeof(title), "%s Post", platform);
	format(desc, sizeof(desc), "📱 **@%s** (%s - ID: %d):\n%s", username, GetRPName(playerid), playerid, text);
	new DCC_Embed:embed = DCC_CreateEmbed(title, desc, "", "", color, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendNormalChat(playerid, const text[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelRPLog, "log-chat", "chat-log", g_dcChannelGlobal);
	if(!chan) return 0;
	new msg[256];
	format(msg, sizeof(msg), "💬 **%s** (ID: %d) says: %s", GetRPName(playerid), playerid, text);
	return DCC_SendChannelMessage(chan, msg);
}

stock DC_SendGlobalChat(playerid, const text[], const prefix[] = "Global")
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelGlobal, "log-globalchat", "global-chat", "");
	if(!chan) return 0;
	new msg[256];
	format(msg, sizeof(msg), "🌐 **[%s] %s** (ID: %d): %s", prefix, GetRPName(playerid), playerid, text);
	return DCC_SendChannelMessage(chan, msg);
}

stock DC_SendOOCChat(playerid, const text[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelOOC, "log-ooc", "ooc-chat", "");
	if(!chan) chan = DC_ResolveChannel(g_dcChannelGlobal, "log-globalchat", "global-chat", "");
	if(!chan) chan = DC_ResolveChannel(g_dcChannelRPLog, "log-chat", "chat-log", "");
	if(!chan) return 0;
	new msg[256];
	format(msg, sizeof(msg), "🌐 **[OOC] %s** (ID: %d): %s", GetRPName(playerid), playerid, text);
	return DCC_SendChannelMessage(chan, msg);
}

stock DC_SendAdminChat(playerid, const text[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelAdminChat, "log-adminchat", "adminchat-log", g_dcChannelAdminLog);
	if(!chan) return 0;
	new msg[256];
	format(msg, sizeof(msg), "🔒 **[Admin Chat] %s** (%s - ID: %d): %s", GetRPName(playerid), GetAdminRank(playerid), playerid, text);
	return DCC_SendChannelMessage(chan, msg);
}

stock DC_SendBusinessLog(const title[], const desc[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelBusiness, "log-business", "log-businesses", g_dcChannelDynamic);
	if(!chan) chan = DC_ResolveChannel(g_dcChannelDynamic, "log-dynamic-systems", "log-dynamics", g_dcChannelAdminLog);
	if(!chan) chan = DC_ResolveChannel(g_dcChannelAdminLog, "log-admin", "admin-log", g_dcChannelGlobal);
	if(!chan) return 0;
	new DCC_Embed:embed = DCC_CreateEmbed(title, desc, "", "", 0x2ECC71, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendDynamicSystemLog(const title[], const desc[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelDynamic, "log-dynamic-systems", "log-dynamics", g_dcChannelBusiness);
	if(!chan) chan = DC_ResolveChannel(g_dcChannelBusiness, "log-business", "log-businesses", g_dcChannelAdminLog);
	if(!chan) chan = DC_ResolveChannel(g_dcChannelAdminLog, "log-admin", "admin-log", g_dcChannelGlobal);
	if(!chan) return 0;
	new DCC_Embed:embed = DCC_CreateEmbed(title, desc, "", "", 0x3498DB, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendCommandUsageLog(playerid, const cmd[], const params[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelCommands, "commands", "log-commands", g_dcChannelDynamic);
	if(!chan) chan = DC_ResolveChannel(g_dcChannelDynamic, "log-dynamic-systems", "log-dynamics", g_dcChannelAdminLog);
	if(!chan) chan = DC_ResolveChannel(g_dcChannelAdminLog, "log-admin", "admin-log", g_dcChannelGlobal);
	if(!chan) return 0;
	new desc[256];
	if(isnull(params))
		format(desc, sizeof(desc), "⌨️ **%s** (ID: %d) executed: `/%s`", GetRPName(playerid), playerid, cmd);
	else
		format(desc, sizeof(desc), "⌨️ **%s** (ID: %d) executed: `/%s %s`", GetRPName(playerid), playerid, cmd, params);
	new DCC_Embed:embed = DCC_CreateEmbed("Command Executed", desc, "", "", 0x95A5A6, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_SendFactionLog(const title[], const desc[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelFaction, "log-factions", "log-faction", g_dcChannelDynamic);
	if(!chan) chan = DC_ResolveChannel(g_dcChannelDynamic, "log-dynamic-systems", "log-dynamics", g_dcChannelAdminLog);
	if(!chan) chan = DC_ResolveChannel(g_dcChannelAdminLog, "log-admin", "admin-log", g_dcChannelGlobal);
	if(!chan) return 0;
	new DCC_Embed:embed = DCC_CreateEmbed(title, desc, "", "", 0x2980B9, DC_FOOTER);
	return DCC_SendChannelEmbedMessage(chan, embed);
}

stock DC_ForwardLogWrite(const table[], const message[])
{
	if(!strcmp(table, "log_property", true))
	{
		DC_SendBusinessLog("🏢 Property / Business Event", message);
	}
	else if(!strcmp(table, "log_faction", true) || !strcmp(table, "log_gang", true))
	{
		DC_SendFactionLog("👥 Faction / Gang Event", message);
	}
	else if(!strcmp(table, "log_admin", true))
	{
		DC_SendAdminLog("⚙️ Admin Action", message);
	}
	else if(!strcmp(table, "log_namechanges", true))
	{
		new DCC_Channel:chan = DC_ResolveChannel("", "log-namechanges", "namechanges", g_dcChannelAdminLog);
		if(chan) DCC_SendChannelEmbedMessage(chan, DCC_CreateEmbed("📝 Namechange Log", message, "", "", 0x3498DB, DC_FOOTER));
	}
	else if(!strcmp(table, "log_vip", true))
	{
		new DCC_Channel:chan = DC_ResolveChannel("", "log-vip", "vip-log", g_dcChannelAdminLog);
		if(chan) DCC_SendChannelEmbedMessage(chan, DCC_CreateEmbed("⭐ VIP Event", message, "", "", 0xF1C40F, DC_FOOTER));
	}
	else if(!strcmp(table, "log_punishments", true))
	{
		DC_SendPunishmentLog("⚖️ Punishment Log", message);
	}
	return 1;
}

stock DC_ForwardAdminMessage(const message[])
{
	if(strfind(message, "business", true) != -1)
	{
		DC_SendBusinessLog("🏢 Business Admin Action", message);
	}
	else if(strfind(message, "house", true) != -1 || strfind(message, "garage", true) != -1 || strfind(message, "gate", true) != -1 || strfind(message, "faction", true) != -1)
	{
		DC_SendDynamicSystemLog("🏢 Dynamic System Admin Action", message);
	}
	else
	{
		DC_SendAdminLog("🛡️ Admin Action", message);
	}
	return 1;
}

stock DC_SendRPLog(playerid, const type[], const text[])
{
	new DCC_Channel:chan = DC_ResolveChannel(g_dcChannelRPLog, "log-chat", "chat-log", g_dcChannelGlobal);
	if(!chan) return 0;
	new embedDesc[320];
	if(!strcmp(type, "ME", true))
	{
		format(embedDesc, sizeof(embedDesc), "**%s** (ID: %d) *%s*", GetRPName(playerid), playerid, text);
		new DCC_Embed:embed = DCC_CreateEmbed("Roleplay: /me", embedDesc, "", "", 0x9B59B6, DC_FOOTER);
		return DCC_SendChannelEmbedMessage(chan, embed);
	}
	else if(!strcmp(type, "DO", true))
	{
		format(embedDesc, sizeof(embedDesc), "*%s* **(( %s - ID: %d ))**", text, GetRPName(playerid), playerid);
		new DCC_Embed:embed = DCC_CreateEmbed("Roleplay: /do", embedDesc, "", "", 0x8E44AD, DC_FOOTER);
		return DCC_SendChannelEmbedMessage(chan, embed);
	}
	else if(!strcmp(type, "ADO", true))
	{
		format(embedDesc, sizeof(embedDesc), "*%s* **(( %s - ID: %d ))**", text, GetRPName(playerid), playerid);
		new DCC_Embed:embed = DCC_CreateEmbed("Roleplay: /ado", embedDesc, "", "", 0x9B59B6, DC_FOOTER);
		return DCC_SendChannelEmbedMessage(chan, embed);
	}
	else if(!strcmp(type, "SAY", true) || !strcmp(type, "LOCAL", true))
	{
		format(embedDesc, sizeof(embedDesc), "💬 **%s** (ID: %d) says: %s", GetRPName(playerid), playerid, text);
		return DCC_SendChannelMessage(chan, embedDesc);
	}
	else if(!strcmp(type, "SHOUT", true) || !strcmp(type, "S", true))
	{
		format(embedDesc, sizeof(embedDesc), "📢 **%s** (ID: %d) shouts: %s!", GetRPName(playerid), playerid, text);
		return DCC_SendChannelMessage(chan, embedDesc);
	}
	else if(!strcmp(type, "LOW", true) || !strcmp(type, "L", true))
	{
		format(embedDesc, sizeof(embedDesc), "🤫 **%s** (ID: %d) [low]: %s", GetRPName(playerid), playerid, text);
		return DCC_SendChannelMessage(chan, embedDesc);
	}
	else if(!strcmp(type, "B", true) || !strcmp(type, "LOCAL_OOC", true))
	{
		format(embedDesc, sizeof(embedDesc), "(( [%d] **%s**: %s ))", playerid, GetRPName(playerid), text);
		return DCC_SendChannelMessage(chan, embedDesc);
	}
	return 0;
}

stock bool:DC_IsUserAdmin(DCC_User:user, DCC_Channel:channel = DCC_Channel:0)
{
	new userId[DCC_ID_SIZE];
	DCC_GetUserId(user, userId, sizeof(userId));

	// Whitelisted Discord Administrator User IDs
	if(!strcmp(userId, "1033324697309425724")) return true;

	new bool:hasRole = false;
	new DCC_Guild:guild = DCC_FindGuildById(GUILD);
	new DCC_Role:roleAdmin = DCC_FindRoleById(ROLE_ADMIN);
	if(guild && roleAdmin)
	{
		DCC_HasGuildMemberRole(guild, user, roleAdmin, hasRole);
		if(hasRole) return true;
	}

	if(channel != DCC_Channel:0)
	{
		new DCC_Guild:chanGuild = DCC_Guild:0;
		DCC_GetChannelGuild(channel, chanGuild);
		if(chanGuild != DCC_Guild:0)
		{
			new ownerId[DCC_ID_SIZE];
			DCC_GetGuildOwnerId(chanGuild, ownerId, sizeof(ownerId));
			if(strlen(ownerId) > 0 && !strcmp(ownerId, userId)) return true;

			new roleCount = 0;
			DCC_GetGuildMemberRoleCount(chanGuild, user, roleCount);
			for(new r = 0; r < roleCount; r++)
			{
				new DCC_Role:mRole = DCC_Role:0;
				if(DCC_GetGuildMemberRole(chanGuild, user, r, mRole) && mRole != DCC_Role:0)
				{
					// Discord ADMINISTRATOR permission bit (0x8)
					new pHigh, pLow;
					if(DCC_GetRolePermissions(mRole, pHigh, pLow) && (pLow & 0x00000008))
					{
						return true;
					}

					new rName[64];
					DCC_GetRoleName(mRole, rName, sizeof(rName));
					if(!strcmp(rName, "admin", true) || !strcmp(rName, "administrator", true) || !strcmp(rName, "head admin", true) || !strcmp(rName, "owner", true) || !strcmp(rName, "mod", true) || !strcmp(rName, "moderator", true) || strfind(rName, "admin", true) != -1)
					{
						return true;
					}
				}
			}
		}
	}

	new DCC_Guild:allGuilds[10];
	new gCount = DCC_GetAllGuilds(allGuilds, sizeof(allGuilds));
	for(new g = 0; g < gCount; g++)
	{
		if(allGuilds[g] == DCC_Guild:0) continue;
		new ownerId[DCC_ID_SIZE];
		DCC_GetGuildOwnerId(allGuilds[g], ownerId, sizeof(ownerId));
		if(strlen(ownerId) > 0 && !strcmp(ownerId, userId)) return true;

		new roleCount = 0;
		DCC_GetGuildMemberRoleCount(allGuilds[g], user, roleCount);
		for(new r = 0; r < roleCount; r++)
		{
			new DCC_Role:mRole = DCC_Role:0;
			if(DCC_GetGuildMemberRole(allGuilds[g], user, r, mRole) && mRole != DCC_Role:0)
			{
				new pHigh, pLow;
				if(DCC_GetRolePermissions(mRole, pHigh, pLow) && (pLow & 0x00000008))
				{
					return true;
				}

				new rName[64];
				DCC_GetRoleName(mRole, rName, sizeof(rName));
				if(!strcmp(rName, "admin", true) || !strcmp(rName, "administrator", true) || !strcmp(rName, "head admin", true) || !strcmp(rName, "owner", true) || !strcmp(rName, "mod", true) || !strcmp(rName, "moderator", true) || strfind(rName, "admin", true) != -1)
				{
					return true;
				}
			}
		}
	}
	return false;
}

// -----------------------------------------------------------------------------
// Dynamic Bot Status Presence
// -----------------------------------------------------------------------------
forward DC_UpdateBotPresence();
public DC_UpdateBotPresence()
{
	new DCC_BotPresenceStatus:status = DCC_GetBotPresenceStatus();
	if (status == DCC_BotPresenceStatus:INVALID || status == DCC_BotPresenceStatus:OFFLINE)
	{
		return 0;
	}
	new onlineCount = 0;
	foreach(new i : Player)
	{
		onlineCount++;
	}
	new statusStr[64];
	format(statusStr, sizeof(statusStr), "SOM | %d/%d Online", onlineCount, MAX_PLAYERS);
	DCC_SetBotActivity(statusStr);
	DCC_SetBotPresenceStatus(DCC_BotPresenceStatus:ONLINE);
	return 1;
}

// -----------------------------------------------------------------------------
// Discord to In-Game Message Relay (Two-Way Bridge)
// -----------------------------------------------------------------------------
public DCC_OnMessageCreate(DCC_Message:message)
{
	new DCC_Channel:channel, DCC_User:author, bool:isBot;
	DCC_GetMessageChannel(message, channel);
	DCC_GetMessageAuthor(message, author);
	DCC_IsUserBot(author, isBot);
	if(isBot) return 1;

	new channelId[DCC_ID_SIZE];
	DCC_GetChannelId(channel, channelId);

	// Relay if message is in GLOBAL CHAT and not a command
	if(!strcmp(channelId, g_dcChannelGlobal))
	{
		new content[144], username[DCC_USERNAME_SIZE];
		DCC_GetMessageContent(message, content, sizeof(content));
		DCC_GetUserName(author, username, sizeof(username));

		if(content[0] != DCMD_PREFIX && strlen(content) > 0)
		{
			new str[180];
			format(str, sizeof(str), "{7289DA}[Discord] {FFFFFF}%s: %s", username, content);
			SendClientMessageToAll(-1, str);
		}
	}
	else if(!strcmp(channelId, g_dcChannelAdminChat))
	{
		new content[144], username[DCC_USERNAME_SIZE];
		DCC_GetMessageContent(message, content, sizeof(content));
		DCC_GetUserName(author, username, sizeof(username));

		if(content[0] != DCMD_PREFIX && strlen(content) > 0)
		{
			new str[180];
			format(str, sizeof(str), "{E74C3C}[Discord Admin] {FFFFFF}%s: %s", username, content);
			foreach(new i : Player)
			{
				if(User[i][pAdmin] > 0)
				{
					SCM(i, -1, str);
				}
			}
		}
	}
	return 1;
}

// -----------------------------------------------------------------------------
// Verification Flow
// -----------------------------------------------------------------------------
stock DiscordVerification(playerid)
{
	User[playerid][pDiscordCode] = random(900) + 100;

	SM(playerid, COLOR_YELLOW, "Your confirmation code is: %i. Your code expires in 5 minutes.", User[playerid][pDiscordCode]);
	Dialog_Show(playerid, -1, DIALOG_STYLE_MSGBOX, "Character - Discord Verification", "Your confirmation code is: %i. Your code expires in 5 minutes\nReply '!verify %i' in verification channel at "DISCORD_URL"", "Close", "", User[playerid][pDiscordCode], User[playerid][pDiscordCode]);

	SetTimerEx("ExpireDiscordCode", 5 * 60 * 1000, false, "i", playerid);
	return 1;
}

stock DC_OnUserUnlink(playerid)
{
	DCC_RemoveGuildMemberRole(DCC_FindGuildById(GUILD), DCC_FindUserById(User[playerid][pDiscord]), DCC_FindRoleById(ROLE_VERIFY));
	if(User[playerid][pAdmin])
	{
		DCC_RemoveGuildMemberRole(DCC_FindGuildById(GUILD), DCC_FindUserById(User[playerid][pDiscord]), DCC_FindRoleById(ROLE_ADMIN));
	}
	if(User[playerid][pHelper])
	{
		DCC_RemoveGuildMemberRole(DCC_FindGuildById(GUILD), DCC_FindUserById(User[playerid][pDiscord]), DCC_FindRoleById(ROLE_HELPER));
	}

	strcpy(User[playerid][pDiscord], "None", 21);
	mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE users SET discord_id = 'None' WHERE uid = %i", User[playerid][pID]);
	mysql_tquery(connectionID, queryBuffer);
	return 1;
}

forward ExpireDiscordCode(playerid);
public ExpireDiscordCode(playerid)
{
    User[playerid][pDiscordCode] = 0;
    SM(playerid, COLOR_GREY, "Your Discord verification code has expired.");
    return 1;
}
/*
DCMD:verify(user, channel, params[])
{
	// VARIABLES //
	new user_name[DCC_USERNAME_SIZE];
	new duserid[DCC_ID_SIZE];

	new DCC_Guild:guild = DCC_FindGuildById(GUILD);
	new DCC_Role:role = DCC_FindRoleById(ROLE_VERIFY);
	new DCC_Role:role1 = DCC_FindRoleById(ROLE_UNVERIFY);
	new DCC_Channel:channell = DCC_FindChannelById(CHANNEL_VERIFY);

	new chan[256];
	DCC_GetChannelName(channell, chan, sizeof(chan));

	new bool:hasRole;
	new code;
	new date[6];
	new string[128];
	new szString[290];

	// TIME //
	gettime(date[3], date[4], date[5]);

	// DISCORD USERNAME / ID //
	DCC_GetUserName(user, user_name, sizeof(user_name));
	DCC_GetUserId(user, duserid, sizeof(duserid));

	DCC_TriggerBotTypingIndicator(channel);

	// CHECK VERIFIED ROLE //
	DCC_HasGuildMemberRole(guild, user, role, hasRole);

	// WRONG CHANNEL //
	if(channel != DCC_FindChannelById(CHANNEL_VERIFY))
	{
		new DCC_Embed:wrongchannel = DCC_CreateEmbed("ERROR: Wrong Channel!");
		new str[512];

		format(
			str,
			sizeof(str),
			"You can use this command at <#%s>.",
			CHANNEL_VERIFY
		);

		DCC_SetEmbedDescription(wrongchannel, str);

		format(
			string,
			sizeof(string),
			"Lost Island Roleplay | UTC: %02d:%02d",
			date[3],
			date[4]
		);

		DCC_SetEmbedFooter(wrongchannel, string);
		DCC_SetEmbedColour(wrongchannel, 0xff0000);

		DCC_SetEmbedThumbnail(
			wrongchannel,
			"https://media.discordapp.net/attachments/1422296837959712889/1429048872327446688/34851ac302b14f12be685c2229032219.gif?ex=6abb8e79&is=6aba3cf9&hm=cf7d1fd3e894a7395e3bd4d7a818c0e81056c45d5189c0f2e9d8362b18e12e17&="
		);

		DCC_SendChannelEmbedMessage(channel, wrongchannel);
		return 1;
	}

	// NUMERICAL CHECK //
	if(!IsNumeric(params))
	{
		return DCC_SendChannelMessage(
			channel,
			"> ***Please Use Numerical Because it wont work!***"
		);
	}

	// INVALID CODE FORMAT //
	if(sscanf(params, "i", code))
	{
		new test[256];
		new DCC_Embed:error = DCC_CreateEmbed("ERROR: Invalid Verification Token!");

		format(
			test,
			sizeof(test),
			"Please follow the instructions given to you in-game.\nHINT: /settings -> Discord"
		);

		DCC_SetEmbedDescription(error, test);

		format(
			string,
			sizeof(string),
			"Lost Island Roleplay | UTC: %02d:%02d",
			date[3],
			date[4]
		);

		DCC_SetEmbedFooter(error, string);
		DCC_SetEmbedColour(error, 0xff0000);

		DCC_SetEmbedThumbnail(
			error,
			"https://media.discordapp.net/attachments/1422296837959712889/1429048872327446688/34851ac302b14f12be685c2229032219.gif?ex=6abb8e79&is=6aba3cf9&hm=cf7d1fd3e894a7395e3bd4d7a818c0e81056c45d5189c0f2e9d8362b18e12e17&="
		);

		DCC_SendChannelEmbedMessage(channel, error);
		return 1;
	}

	// ALREADY VERIFIED //
	if(hasRole)
	{
		new str[512];
		new DCC_Embed:merongrole = DCC_CreateEmbed("ERROR: Invalid Role!");

		format(
			str,
			sizeof(str),
			"This Bot Prevents\nUsers from verifying/creating multiple accounts to the server."
		);

		DCC_SetEmbedDescription(merongrole, str);

		format(
			string,
			sizeof(string),
			"Lost Island Roleplay | UTC: %02d:%02d",
			date[3],
			date[4]
		);

		DCC_SetEmbedFooter(merongrole, string);
		DCC_SetEmbedColour(merongrole, 0xff0000);

		DCC_SetEmbedThumbnail(
			merongrole,
			"https://media.discordapp.net/attachments/1422296837959712889/1429048872327446688/34851ac302b14f12be685c2229032219.gif?ex=6abb8e79&is=6aba3cf9&hm=cf7d1fd3e894a7395e3bd4d7a818c0e81056c45d5189c0f2e9d8362b18e12e17&="
		);

		DCC_SendChannelEmbedMessage(channel, merongrole);
		return 1;
	}

	// EMPTY / INVALID CODE //
	if(code == 0 || code == -1)
	{
		new notc[256];
		new DCC_Embed:notconnected = DCC_CreateEmbed("ERROR: Invalid Verification Token!");

		format(
			notc,
			sizeof(notc),
			"We cannot find a user with this code in the database.\nPlease try again use the command /verify to see your verification code"
		);

		DCC_SetEmbedDescription(notconnected, notc);

		format(
			string,
			sizeof(string),
			"Lost Island Roleplay | UTC: %02d:%02d",
			date[3],
			date[4]
		);

		DCC_SetEmbedFooter(notconnected, string);
		DCC_SetEmbedColour(notconnected, 0xff0000);

		DCC_SetEmbedThumbnail(
			notconnected,
			"https://media.discordapp.net/attachments/1422296837959712889/1429048872327446688/34851ac302b14f12be685c2229032219.gif?ex=6abb8e79&is=6aba3cf9&hm=cf7d1fd3e894a7395e3bd4d7a818c0e81056c45d5189c0f2e9d8362b18e12e17&="
		);

		DCC_SendChannelEmbedMessage(channel, notconnected);
		return 1;
	}

	// FIND PLAYER //
	foreach(new i : Player)
	{
		if(User[i][pDiscordCode] == code)
		{
			// CREATE PRIVATE DM //
			DCC_CreatePrivateChannel(user, "DCC_DM");

			new role_id[DCC_ID_SIZE];
			new role_name[64];
			new role_position;

			DCC_GetRoleId(role, role_id, sizeof(role_id));
			DCC_GetRoleName(role, role_name, sizeof(role_name));
			DCC_GetRolePosition(role, role_position);

			// ADD VERIFIED ROLE //
			printf("[VERIFY] Role Handle: %d", _:role);
			printf("[VERIFY] Role ID: %s", role_id);
			printf("[VERIFY] Role Name: %s", role_name);
			printf("[VERIFY] Role Position: %d", role_position);

			DCC_AddGuildMemberRole(guild, user, role);
			printf("[VERIFY] AddGuildMemberRole executed.");

			new role_count;
			DCC_GetGuildMemberRoleCount(guild, user, role_count);

			printf("[VERIFY] Discord Member Role Count: %d", role_count);

			for(new r = 0; r < role_count; r++)
			{
				new DCC_Role:member_role;
				new member_role_id[DCC_ID_SIZE];
				new member_role_name[64];

				DCC_GetGuildMemberRole(
					guild,
					user,
					r,
					member_role
				);

				DCC_GetRoleId(
					member_role,
					member_role_id,
					sizeof(member_role_id)
				);

				DCC_GetRoleName(
					member_role,
					member_role_name,
					sizeof(member_role_name)
				);

				printf(
					"[VERIFY] Member Role #%d: %s | %s",
					r,
					member_role_id,
					member_role_name
				);
			}

			// REMOVE UNVERIFIED ROLE //
			DCC_RemoveGuildMemberRole(guild, user, role1);

			// SET DISCORD NICKNAME //
			DCC_SetGuildMemberNickname(
				guild,
				user,
				GetRPName(i)
			);

			// SET VERIFIED //
			User[i][pVerified] = 1;

			// CLEAR VERIFICATION CODE //
			User[i][pDiscordCode] = -1;

			// STORE DISCORD ID IN PLAYER DATA //
			format(User[i][pDiscord], 21, "%s", duserid);

			// SAVE DISCORD ID TO MYSQL //
			mysql_format(
				connectionID,
				queryBuffer,
				sizeof(queryBuffer),
				"UPDATE users SET discord_id = %s WHERE uid = %i",
				duserid,
				User[i][pID]
			);

			mysql_tquery(connectionID, queryBuffer);

			// SUCCESS EMBED //
			new DCC_Embed:embed = DCC_CreateEmbed("Account Verification Success!");

			format(
				szString,
				sizeof(szString),
				"The account **%s** has been successfully linked to your discord account (**%s**).\nYou will now be able to access general in-game features such as Global Chat, joining events, accessing weapons, etc.\n\n**Welcome to Lost Island Roleplay**",
				GetRPName(i),
				user_name
			);

			DCC_SetEmbedDescription(embed, szString);

			format(
				string,
				sizeof(string),
				"Requested by: %s",
				user_name
			);

			DCC_SetEmbedFooter(embed, string);
			DCC_SetEmbedColour(embed, 0xb8e83f);

			DCC_SetEmbedThumbnail(
				embed,
				"https://media.discordapp.net/attachments/1422296837959712889/1429048872327446688/34851ac302b14f12be685c2229032219.gif?ex=6abb8e79&is=6aba3cf9&hm=cf7d1fd3e894a7395e3bd4d7a818c0e81056c45d5189c0f2e9d8362b18e12e17&="
			);

			DCC_SendChannelEmbedMessage(channel, embed);

			return 1;
		}
	}

	// CODE NOT FOUND //
	new DCC_Embed:notfound = DCC_CreateEmbed("ERROR: Invalid Verification Token!");
	new notfoundstr[512];

	format(
		notfoundstr,
		sizeof(notfoundstr),
		"We cannot find a user with this verification code.\n\nPlease make sure you entered the correct code from the in-game ** /settings -> Discord** menu."
	);

	DCC_SetEmbedDescription(notfound, notfoundstr);

	format(
		string,
		sizeof(string),
		"Lost Island Roleplay | UTC: %02d:%02d",
		date[3],
		date[4]
	);

	DCC_SetEmbedFooter(notfound, string);
	DCC_SetEmbedColour(notfound, 0xff0000);

	DCC_SetEmbedThumbnail(
		notfound,
		"https://media.discordapp.net/attachments/1422296837959712889/1429048872327446688/34851ac302b14f12be685c2229032219.gif?ex=6abb8e79&is=6aba3cf9&hm=cf7d1fd3e894a7395e3bd4d7a818c0e81056c45d5189c0f2e9d8362b18e12e17&="
	);

	DCC_SendChannelEmbedMessage(channel, notfound);

	return 1;
}*/
/*
// -----------------------------------------------------------------------------
// Basic & Community Commands
// -----------------------------------------------------------------------------
DCMD:verify(user, channel, params[])
{
	new duserid[DCC_ID_SIZE], code;
	DCC_GetUserId(user, duserid, sizeof(duserid));

	if(channel != DCC_FindChannelById(CHANNEL_VERIFY)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("", "`You can use this command in verification channel.`", "", "", 0, DC_FOOTER));
	if(sscanf(params, "i", code)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("", "`Usage: !verify [code]`", "", "", 0, DC_FOOTER));
	if(code == -1) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("", "`Usage: !verify [code]`", "", "", 0, DC_FOOTER));

	foreach(new i : Player)
	{
		if(User[i][pDiscordCode] == code)
		{
			new string[256];
			format(string, sizeof(string), "**Player Verification**\nThe user has been successfully linked.\n`Name:` %s\n`Discord:` <@%s>\n`Level:` %i\n`Role added:` <@&"ROLE_VERIFY">", GetRPName(i), duserid, User[i][pLevel]);
			DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("", string, "", "", 0x2ECC71, DC_FOOTER));

			DCC_SetGuildMemberNickname(DCC_FindGuildById(GUILD), user, GetRPName(i));
			DCC_AddGuildMemberRole(DCC_FindGuildById(GUILD), user, DCC_FindRoleById(ROLE_VERIFY));

			mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE users SET discord_id = %s WHERE uid = %i", duserid, User[i][pID]);
			mysql_tquery(connectionID, queryBuffer);
			User[i][pDiscordCode] = -1;
			return 1;
		}
	}
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("", "`Error: Invalid or expired verification code!`", "", "", 0xE74C3C, DC_FOOTER));
	return 1;
}
*/
DCMD:status(user, channel, params[])
{
	new adminDutyCount = 0;
	foreach(new i : Player)
	{
		if(User[i][pAdminDuty]) adminDutyCount++;
	}

	new string[384];
	format(string, sizeof(string), "**Server Status**\n`IP:` %s\n`Players Online:` %i/%i\n`Staff On Duty:` %i\n`Peak Player Record:` %i\n`Record Date:` %s", g_dcServerIP, Iter_Count(Player), MAX_PLAYERS, adminDutyCount, gPlayerRecord, gRecordDate);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed(SERVER_NAME, string, "", "", 0x3498DB, DC_FOOTER));
	return 1;
}
DCMD:serverinfo(user, channel, params[]) return DCMD_status(user, channel, params);
DCMD:server(user, channel, params[]) return DCMD_status(user, channel, params);

DCMD:ip(user, channel, params[])
{
	new string[384];
	format(string, sizeof(string), "**Server Connection Info**\n\n**IP Address:**\n```\n%s\n```\n**Hostname:** %s\n**Players Online:** %i/%i\n\n*Copy the IP address above and add it to your SA-MP / open.mp client!*", g_dcServerIP, SERVER_NAME, Iter_Count(Player), MAX_PLAYERS);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Lost Island Roleplay | Server IP", string, "", "", 0x3498DB, DC_FOOTER));
	return 1;
}
DCMD:serverip(user, channel, params[]) return DCMD_ip(user, channel, params);
DCMD:address(user, channel, params[]) return DCMD_ip(user, channel, params);
DCMD:connect(user, channel, params[]) return DCMD_ip(user, channel, params);

DCMD:help(user, channel, params[])
{
	new string[1000];
	format(string, sizeof(string), "**General Commands:**\n`!help` - Display bot commands\n`!ip` - Get the server IP address\n`!status` - Live server status\n`!players` - List online players\n`!stats` - View your account stats\n`!verify [code]` - Link your in-game account\n`!duty` - Staff duty status\n`!dutytime [user]` - Check staff duty hours\n`!top [rich/hours/level]` - Leaderboards\n`!find [username]` - Player account lookup\n\n**Staff Commands (Admin Role Required):**\n`!setip [ip:port]` - Update server IP\n`!setlog [admin/punish/ac/reports/all] [channel]`\n`!logchannels` - View active log channels\n`!kick [id/name] [reason]`\n`!ban [id/name] [days] [reason]`\n`!oban [username] [days] [reason]`\n`!unban [username]`\n`!jail [id/name] [minutes] [reason]`\n`!mute [id/name] [reason]`\n`!freeze [id/name]`\n`!makeadmin [id/name] [level]`\n`!omakeadmin [username] [level]`\n`!sendto [id/name] [location]`");
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Bot Commands Directory", string, "", "", 0x9B59B6, DC_FOOTER));
	return 1;
}

DCMD:stats(user, channel, params[])
{
	new uid[DCC_ID_SIZE], chid[DCC_ID_SIZE];
	DCC_GetUserId(user, uid, sizeof(uid));
	DCC_GetChannelId(channel, chid, sizeof(chid));

	mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "SELECT username, level, hours, adminlevel, admindutytime FROM users WHERE discord_id = '%s'", uid);
	mysql_tquery(connectionID, queryBuffer, "DC_OnPlayerCheckStats", "ss", uid, chid);
	return 1;
}

forward DC_OnPlayerCheckStats(discordtag[], channel[]); 
public DC_OnPlayerCheckStats(discordtag[], channel[])
{
	if(!cache_get_row_count(connectionID))
	{
		CreateEmbed(channel, "`You are not verified yet. Use /verify in-game first.`");
	}
	else
	{
		new username[MAX_PLAYER_NAME];
		cache_get_field_content(0, "username", username);
		new dutySecs = cache_get_field_content_int(0, "admindutytime");
		new string[256];
		format(string, sizeof(string), "`Name:` %s\n`Discord:` <@%s>\n`Level:` %i\n`Hours:` %i\n`Admin Level:` %i\n`Duty Hours:` %.2f hrs", username, discordtag, cache_get_field_content_int(0, "level"), cache_get_field_content_int(0, "hours"), cache_get_field_content_int(0, "adminlevel"), float(dutySecs) / 3600.0);
		CreateEmbed(channel, string);
	}
}

DCMD:role(user, channel, params[])
{
	new uid[DCC_ID_SIZE], chid[DCC_ID_SIZE];
	DCC_GetUserId(user, uid, sizeof(uid));
	DCC_GetChannelId(channel, chid, sizeof(chid));

	if(channel != DCC_FindChannelById(CHANNEL_ROLEREQ)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("", "`You can only use this command in the role request channel.`", "", "", 0xE74C3C, DC_FOOTER));

	mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "SELECT adminlevel, helperlevel, faction, gang FROM users WHERE discord_id = '%s'", uid);
	mysql_tquery(connectionID, queryBuffer, "DC_OnPlayerRole", "ss", uid, chid);
	return 1;
}

forward DC_OnPlayerRole(user[], channel[]); 
public DC_OnPlayerRole(user[], channel[])
{
	if(!cache_get_row_count(connectionID))
	{
		CreateEmbed(channel, "`You are not verified yet.`");
	}
	else
	{
		new string[128], count = 0;
		if(cache_get_field_content_int(0, "adminlevel") > 0)
		{
			DCC_AddGuildMemberRole(DCC_FindGuildById(GUILD), DCC_FindUserById(user), DCC_FindRoleById(ROLE_ADMIN));
			format(string, sizeof(string), "`Discord:` <@%s>\n`Role added:` <@&"ROLE_ADMIN">", user);
			CreateEmbed(channel, string);
			count++;
		}
		if(cache_get_field_content_int(0, "helperlevel") > 0)
		{
			DCC_AddGuildMemberRole(DCC_FindGuildById(GUILD), DCC_FindUserById(user), DCC_FindRoleById(ROLE_HELPER));
			format(string, sizeof(string), "`Discord:` <@%s>\n`Role added:` <@&"ROLE_HELPER">", user);
			CreateEmbed(channel, string);
			count++;
		}
		if(count == 0)
		{
			CreateEmbed(channel, "`You don't have permission for any staff roles.`");
		}
	}
}

// -----------------------------------------------------------------------------
// Item 4: Online Players, Top Leaderboards, Player Lookup, Factions
// -----------------------------------------------------------------------------
DCMD:players(user, channel, params[])
{
	new count = 0;
	new list[1024] = "";
	foreach(new i : Player)
	{
		if(count < 25)
		{
			new line[64];
			format(line, sizeof(line), "`[%d]` %s (Lvl %d, %dms)\n", i, GetRPName(i), User[i][pLevel], GetPlayerPing(i));
			strcat(list, line);
		}
		count++;
	}
	if(count == 0)
	{
		return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Online Players", "`No players are currently connected.`", "", "", 0xE74C3C, DC_FOOTER));
	}
	if(count > 25)
	{
		new extra[48];
		format(extra, sizeof(extra), "\n*...and %d more players*", count - 25);
		strcat(list, extra);
	}
	new title[64];
	format(title, sizeof(title), "Online Players (%d/%d)", count, MAX_PLAYERS);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed(title, list, "", "", 0x3498DB, DC_FOOTER));
	return 1;
}
DCMD:online(user, channel, params[]) return DCMD_players(user, channel, params);

DCMD:top(user, channel, params[])
{
	new chid[DCC_ID_SIZE];
	DCC_GetChannelId(channel, chid, sizeof(chid));

	if(!strcmp(params, "rich", true) || !strcmp(params, "money", true))
	{
		mysql_tquery(connectionID, "SELECT username, (cash + bank) AS totalmoney FROM users ORDER BY totalmoney DESC LIMIT 10", "DC_OnTopRich", "s", chid);
		return 1;
	}
	else if(!strcmp(params, "hours", true) || !strcmp(params, "time", true))
	{
		mysql_tquery(connectionID, "SELECT username, hours, level FROM users ORDER BY hours DESC LIMIT 10", "DC_OnTopHours", "s", chid);
		return 1;
	}
	else if(!strcmp(params, "level", true) || !strcmp(params, "lvl", true))
	{
		mysql_tquery(connectionID, "SELECT username, level, hours FROM users ORDER BY level DESC LIMIT 10", "DC_OnTopLevel", "s", chid);
		return 1;
	}
	else
	{
		return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Leaderboard Usage", "`!top rich` - Top 10 richest players\n`!top hours` - Top 10 most active players\n`!top level` - Top 10 highest level players", "", "", 0xF39C12, DC_FOOTER));
	}
}

forward DC_OnTopRich(channel[]);
public DC_OnTopRich(channel[])
{
	new rows = cache_get_row_count(connectionID);
	if(!rows) return CreateEmbed(channel, "`No leaderboard data available.`");

	new list[1024] = "";
	for(new i = 0; i < rows; i++)
	{
		new name[MAX_PLAYER_NAME];
		cache_get_field_content(i, "username", name);
		new money = cache_get_field_content_int(i, "totalmoney");
		new line[96];
		format(line, sizeof(line), "**#%d.** %s - `$%s`\n", i + 1, name, FormatNumber(money));
		strcat(list, line);
	}
	DCC_SendChannelEmbedMessage(DCC_FindChannelById(channel), DCC_CreateEmbed("ðŸ† Wealth Leaderboard (Top 10)", list, "", "", 0xF1C40F, DC_FOOTER));
	return 1;
}

forward DC_OnTopHours(channel[]);
public DC_OnTopHours(channel[])
{
	new rows = cache_get_row_count(connectionID);
	if(!rows) return CreateEmbed(channel, "`No leaderboard data available.`");

	new list[1024] = "";
	for(new i = 0; i < rows; i++)
	{
		new name[MAX_PLAYER_NAME];
		cache_get_field_content(i, "username", name);
		new hours = cache_get_field_content_int(i, "hours");
		new line[96];
		format(line, sizeof(line), "**#%d.** %s - `%d hours` (Lvl %d)\n", i + 1, name, hours, cache_get_field_content_int(i, "level"));
		strcat(list, line);
	}
	DCC_SendChannelEmbedMessage(DCC_FindChannelById(channel), DCC_CreateEmbed("ðŸ† Activity Leaderboard (Top 10)", list, "", "", 0x3498DB, DC_FOOTER));
	return 1;
}

forward DC_OnTopLevel(channel[]);
public DC_OnTopLevel(channel[])
{
	new rows = cache_get_row_count(connectionID);
	if(!rows) return CreateEmbed(channel, "`No leaderboard data available.`");

	new list[1024] = "";
	for(new i = 0; i < rows; i++)
	{
		new name[MAX_PLAYER_NAME];
		cache_get_field_content(i, "username", name);
		new lvl = cache_get_field_content_int(i, "level");
		new line[96];
		format(line, sizeof(line), "**#%d.** %s - `Level %d` (%d hrs)\n", i + 1, name, lvl, cache_get_field_content_int(i, "hours"));
		strcat(list, line);
	}
	DCC_SendChannelEmbedMessage(DCC_FindChannelById(channel), DCC_CreateEmbed("ðŸ† Level Leaderboard (Top 10)", list, "", "", 0x2ECC71, DC_FOOTER));
	return 1;
}

DCMD:find(user, channel, params[])
{
	if(isnull(params)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!find [character_name]`", "", "", 0xF39C12, DC_FOOTER));

	new chid[DCC_ID_SIZE];
	DCC_GetChannelId(channel, chid, sizeof(chid));
	mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "SELECT username, level, hours, phone, faction, gang, adminlevel FROM users WHERE username = '%e'", params);
	mysql_tquery(connectionID, queryBuffer, "DC_OnFindPlayer", "ss", params, chid);
	return 1;
}

forward DC_OnFindPlayer(username[], channel[]);
public DC_OnFindPlayer(username[], channel[])
{
	if(!cache_get_row_count(connectionID))
	{
		CreateEmbed(channel, "`Character not found in database.`");
		return 1;
	}
	new isOnline = 0, onlineId = INVALID_PLAYER_ID;
	foreach(new i : Player)
	{
		if(!strcmp(User[i][pUsername], username, true))
		{
			isOnline = 1;
			onlineId = i;
			break;
		}
	}
	new desc[384];
	format(desc, sizeof(desc), "**Character Lookup: %s**\n`Status:` %s\n`Level:` %d\n`Hours Played:` %d\n`Phone Number:` %d\n`Admin Level:` %d\n`Faction ID:` %d | `Gang ID:` %d",
		username,
		(isOnline) ? ("ðŸŸ¢ Online") : ("ðŸ”´ Offline"),
		cache_get_field_content_int(0, "level"),
		cache_get_field_content_int(0, "hours"),
		cache_get_field_content_int(0, "phone"),
		cache_get_field_content_int(0, "adminlevel"),
		cache_get_field_content_int(0, "faction"),
		cache_get_field_content_int(0, "gang")
	);
	if(isOnline)
	{
		new extra[64];
		format(extra, sizeof(extra), "\n`Current Player ID:` %d", onlineId);
		strcat(desc, extra);
	}
	DCC_SendChannelEmbedMessage(DCC_FindChannelById(channel), DCC_CreateEmbed("Player Lookup", desc, "", "", 0x3498DB, DC_FOOTER));
	return 1;
}

DCMD:factions(user, channel, params[])
{
	new list[1024] = "";
	new totalFactions = 0;
	for(new f = 0; f < MAX_FACTIONS; f++)
	{
		if(strlen(FactionInfo[f][fName]) > 0)
		{
			new count = 0;
			foreach(new i : Player)
			{
				if(User[i][pFaction] == f) count++;
			}
			new line[96];
			format(line, sizeof(line), "`[%d]` **%s** - %d online\n", f, FactionInfo[f][fName], count);
			strcat(list, line);
			totalFactions++;
		}
	}
	if(totalFactions == 0) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Factions", "`No factions configured on this server.`", "", "", 0xE74C3C, DC_FOOTER));
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Server Factions", list, "", "", 0x3498DB, DC_FOOTER));
	return 1;
}

// -----------------------------------------------------------------------------
// Staff & Remote Moderation Commands (Role Protected)
// -----------------------------------------------------------------------------
DCMD:duty(user, channel, params[])
{
	new count = 0;
	new list[1024] = "";
	foreach(new i : Player)
	{
		if(User[i][pAdmin] > 0)
		{
			new curTimeStr[40] = "OFF DUTY";
			if(User[i][pAdminDuty])
			{
				new curSecs = gettime() - User[i][pAdminDutyStart];
				format(curTimeStr, sizeof(curTimeStr), "ON DUTY (%02dm %02ds)", curSecs / 60, curSecs % 60);
			}
			new line[128];
			format(line, sizeof(line), "`%s` (Lvl %d) - **%s** | Total: `%.1f hrs`\n", GetRPName(i), User[i][pAdmin], curTimeStr, float(User[i][pAdminDutyTime]) / 3600.0);
			strcat(list, line);
			count++;
		}
	}
	if(count == 0)
	{
		return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Staff Duty Status", "`No administrators are currently online.`", "", "", 0xE74C3C, DC_FOOTER));
	}
	new title[64];
	format(title, sizeof(title), "Online Staff Duty Status (%d Online)", count);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed(title, list, "", "", 0x3498DB, DC_FOOTER));
	return 1;
}
DCMD:aduty(user, channel, params[]) return DCMD_duty(user, channel, params);
DCMD:admins(user, channel, params[]) return DCMD_duty(user, channel, params);
DCMD:staff(user, channel, params[]) return DCMD_duty(user, channel, params);

DCMD:dutytime(user, channel, params[])
{
	if(isnull(params))
	{
		return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!dutytime [username]`", "", "", 0xF39C12, DC_FOOTER));
	}
	new chid[DCC_ID_SIZE];
	DCC_GetChannelId(channel, chid, sizeof(chid));

	mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "SELECT username, adminlevel, admindutytime FROM users WHERE username = '%e'", params);
	mysql_tquery(connectionID, queryBuffer, "DC_OnCheckDutyTime", "ss", params, chid);
	return 1;
}

forward DC_OnCheckDutyTime(username[], channel[]);
public DC_OnCheckDutyTime(username[], channel[])
{
	if(!cache_get_row_count(connectionID))
	{
		CreateEmbed(channel, "`Specified administrator was not found in database.`");
	}
	else
	{
		new dutySecs = cache_get_field_content_int(0, "admindutytime");
		new adminLvl = cache_get_field_content_int(0, "adminlevel");
		new desc[256];
		format(desc, sizeof(desc), "**Admin:** %s\n`Rank:` Level %d\n`Total Duty Time:` %d hours, %d minutes (%.2f hours total)", username, adminLvl, dutySecs / 3600, (dutySecs % 3600) / 60, float(dutySecs) / 3600.0);
		CreateEmbed(channel, desc);
	}
}

DCMD:kick(user, channel, params[])
{
	new duserid[DCC_ID_SIZE];
	DCC_GetUserId(user, duserid, sizeof(duserid));

	if(!DC_IsUserAdmin(user)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions.`", "", "", 0xE74C3C, DC_FOOTER));

	new target[32], reason[128];
	if(sscanf(params, "s[32]s[128]", target, reason)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!kick [playerid/username] [reason]`", "", "", 0xF39C12, DC_FOOTER));

	new targetid = INVALID_PLAYER_ID;
	if(isnumeric(target)) targetid = strval(target);
	else
	{
		foreach(new i : Player)
		{
			if(!strcmp(User[i][pUsername], target, true)) { targetid = i; break; }
		}
	}
	if(targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid) || !User[targetid][pLogged]) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Player Not Found", "`Target player is not online or logged in.`", "", "", 0xE74C3C, DC_FOOTER));

	SMA(COLOR_ADMCMD, "AdmCmd: %s was kicked by Discord Admin (<@%s>), reason: %s", GetRPName(targetid), duserid, reason);
	Log_Write("log_punishments", "Discord Admin (<@%s>) kicked %s (uid: %i), reason: %s", duserid, GetPlayerNameEx(targetid), User[targetid][pID], reason);

	new logStr[256];
	format(logStr, sizeof(logStr), "**Player Kicked**\n`Target:` %s (ID %d)\n`Reason:` %s\n`Authorized By:` <@%s>", GetRPName(targetid), targetid, reason, duserid);
	DC_SendPunishmentLog("Moderation: Kick", logStr, 0xE67E22);

	KickPlayer(targetid);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Kick Executed", logStr, "", "", 0x2ECC71, DC_FOOTER));
	return 1;
}

DCMD:ban(user, channel, params[])
{
	new duserid[DCC_ID_SIZE];
	DCC_GetUserId(user, duserid, sizeof(duserid));

	if(!DC_IsUserAdmin(user)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions.`", "", "", 0xE74C3C, DC_FOOTER));

	new target[32], days, reason[128];
	if(sscanf(params, "s[32]is[128]", target, days, reason) || days < 1 || days > 30) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!ban [playerid/username] [days (1-30)] [reason]`", "", "", 0xF39C12, DC_FOOTER));

	new targetid = INVALID_PLAYER_ID;
	if(isnumeric(target)) targetid = strval(target);
	else
	{
		foreach(new i : Player)
		{
			if(!strcmp(User[i][pUsername], target, true)) { targetid = i; break; }
		}
	}
	if(targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid) || !User[targetid][pLogged]) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Player Not Found", "`Target player is not online or logged in. Use !oban for offline bans.`", "", "", 0xE74C3C, DC_FOOTER));

	new logStr[256];
	format(logStr, sizeof(logStr), "**Player Banned**\n`Target:` %s (ID %d)\n`Duration:` %d days\n`Reason:` %s\n`Authorized By:` <@%s>", GetRPName(targetid), targetid, days, reason, duserid);
	DC_SendPunishmentLog("Moderation: Ban", logStr, 0xE74C3C);

	BanPlayer(targetid, "DiscordAdmin", days, reason);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Ban Executed", logStr, "", "", 0x2ECC71, DC_FOOTER));
	return 1;
}

DCMD:oban(user, channel, params[])
{
	new duserid[DCC_ID_SIZE];
	DCC_GetUserId(user, duserid, sizeof(duserid));

	if(!DC_IsUserAdmin(user)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions.`", "", "", 0xE74C3C, DC_FOOTER));

	new username[MAX_PLAYER_NAME], days, reason[128];
	if(sscanf(params, "s[24]is[128]", username, days, reason) || days < 1 || days > 30) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!oban [username] [days (1-30)] [reason]`", "", "", 0xF39C12, DC_FOOTER));

	if(IsPlayerOnline(username)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Player Online", "`Player is currently online. Use !ban instead.`", "", "", 0xE74C3C, DC_FOOTER));

	new expire = gettime() + (days * 86400);
	AddBan(username, "0.0.0.0", "DiscordAdmin", expire, reason, 0);

	SMA(COLOR_ADMCMD, "AdmCmd: %s was offline banned for %d days by Discord Admin, reason: %s", username, days, reason);
	new logStr[256];
	format(logStr, sizeof(logStr), "**Offline Ban**\n`Target:` %s\n`Duration:` %d days\n`Reason:` %s\n`Authorized By:` <@%s>", username, days, reason, duserid);
	DC_SendPunishmentLog("Moderation: Offline Ban", logStr, 0xE74C3C);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Offline Ban Executed", logStr, "", "", 0x2ECC71, DC_FOOTER));
	return 1;
}

DCMD:unban(user, channel, params[])
{
	new duserid[DCC_ID_SIZE];
	DCC_GetUserId(user, duserid, sizeof(duserid));

	if(!DC_IsUserAdmin(user)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions.`", "", "", 0xE74C3C, DC_FOOTER));

	if(isnull(params)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!unban [username]`", "", "", 0xF39C12, DC_FOOTER));

	mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "DELETE FROM bans WHERE username = '%e'", params);
	mysql_tquery(connectionID, queryBuffer);

	SMA(COLOR_ADMCMD, "AdmCmd: %s was unbanned by Discord Administrator.", params);
	new logStr[256];
	format(logStr, sizeof(logStr), "**Player Unbanned**\n`Username:` %s\n`Authorized By:` <@%s>", params, duserid);
	DC_SendPunishmentLog("Moderation: Unban", logStr, 0x2ECC71);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Unban Executed", logStr, "", "", 0x2ECC71, DC_FOOTER));
	return 1;
}

DCMD:jail(user, channel, params[])
{
	new duserid[DCC_ID_SIZE];
	DCC_GetUserId(user, duserid, sizeof(duserid));

	if(!DC_IsUserAdmin(user)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions.`", "", "", 0xE74C3C, DC_FOOTER));

	new target[32], minutes, reason[128];
	if(sscanf(params, "s[32]is[128]", target, minutes, reason) || minutes < 1 || minutes > 60) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!jail [playerid/username] [minutes (1-60)] [reason]`", "", "", 0xF39C12, DC_FOOTER));

	new targetid = INVALID_PLAYER_ID;
	if(isnumeric(target)) targetid = strval(target);
	else
	{
		foreach(new i : Player)
		{
			if(!strcmp(User[i][pUsername], target, true)) { targetid = i; break; }
		}
	}
	if(targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid) || !User[targetid][pLogged]) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Player Not Found", "`Target player is not online or logged in.`", "", "", 0xE74C3C, DC_FOOTER));

	User[targetid][pJailType] = 1;
	User[targetid][pJailTime] = minutes * 60;
	SetPlayerInJail(targetid);

	mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE users SET prisonedby = 'DiscordAdmin', prisonreason = '%e' WHERE uid = %i", reason, User[targetid][pID]);
	mysql_tquery(connectionID, queryBuffer);

	strcpy(User[targetid][pPrisonReason], reason, 128);

	SMA(COLOR_ADMCMD, "AdmCmd: %s was prisoned for %i minutes by Discord Admin, reason: %s", GetRPName(targetid), minutes, reason);
	SM(targetid, COLOR_LIGHTBLUE, "* You have been admin prisoned for %i minutes by Discord Admin.", minutes);

	new logStr[256];
	format(logStr, sizeof(logStr), "**Player Jailed**\n`Target:` %s (ID %d)\n`Minutes:` %d\n`Reason:` %s\n`Authorized By:` <@%s>", GetRPName(targetid), targetid, minutes, reason, duserid);
	DC_SendPunishmentLog("Moderation: Jail", logStr, 0xE67E22);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Jail Executed", logStr, "", "", 0x2ECC71, DC_FOOTER));
	return 1;
}

DCMD:mute(user, channel, params[])
{
	new duserid[DCC_ID_SIZE];
	DCC_GetUserId(user, duserid, sizeof(duserid));

	if(!DC_IsUserAdmin(user)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions.`", "", "", 0xE74C3C, DC_FOOTER));

	new target[32], reason[128];
	if(sscanf(params, "s[32]s[128]", target, reason)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!mute [playerid/username] [reason]`", "", "", 0xF39C12, DC_FOOTER));

	new targetid = INVALID_PLAYER_ID;
	if(isnumeric(target)) targetid = strval(target);
	else
	{
		foreach(new i : Player)
		{
			if(!strcmp(User[i][pUsername], target, true)) { targetid = i; break; }
		}
	}
	if(targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid) || !User[targetid][pLogged]) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Player Not Found", "`Target player is not online or logged in.`", "", "", 0xE74C3C, DC_FOOTER));

	User[targetid][pGlobalMuted] = 1;
	User[targetid][pNewbieMuted] = 1;

	SAM(COLOR_ADMCMD, "AdmCmd: %s was muted by Discord Admin, reason: %s", GetRPName(targetid), reason);
	SM(targetid, COLOR_ADMCMD, "* You have been muted by Discord Administrator.");

	new logStr[256];
	format(logStr, sizeof(logStr), "**Player Muted**\n`Target:` %s (ID %d)\n`Reason:` %s\n`Authorized By:` <@%s>", GetRPName(targetid), targetid, reason, duserid);
	DC_SendPunishmentLog("Moderation: Mute", logStr, 0xE67E22);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Mute Executed", logStr, "", "", 0x2ECC71, DC_FOOTER));
	return 1;
}

DCMD:unmute(user, channel, params[])
{
	new duserid[DCC_ID_SIZE];
	DCC_GetUserId(user, duserid, sizeof(duserid));

	if(!DC_IsUserAdmin(user)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions.`", "", "", 0xE74C3C, DC_FOOTER));

	if(isnull(params)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!unmute [playerid/username]`", "", "", 0xF39C12, DC_FOOTER));

	new targetid = INVALID_PLAYER_ID;
	if(isnumeric(params)) targetid = strval(params);
	else
	{
		foreach(new i : Player)
		{
			if(!strcmp(User[i][pUsername], params, true)) { targetid = i; break; }
		}
	}
	if(targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid) || !User[targetid][pLogged]) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Player Not Found", "`Target player is not online or logged in.`", "", "", 0xE74C3C, DC_FOOTER));

	User[targetid][pGlobalMuted] = 0;
	User[targetid][pNewbieMuted] = 0;

	SAM(COLOR_ADMCMD, "AdmCmd: %s was unmuted by Discord Administrator.", GetRPName(targetid));
	SM(targetid, COLOR_YELLOW, "* You have been unmuted by Discord Administrator.");

	new logStr[256];
	format(logStr, sizeof(logStr), "**Player Unmuted**\n`Target:` %s (ID %d)\n`Authorized By:` <@%s>", GetRPName(targetid), targetid, duserid);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Unmute Executed", logStr, "", "", 0x2ECC71, DC_FOOTER));
	return 1;
}

DCMD:freeze(user, channel, params[])
{
	if(!DC_IsUserAdmin(user)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions.`", "", "", 0xE74C3C, DC_FOOTER));
	if(isnull(params)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!freeze [playerid/username]`", "", "", 0xF39C12, DC_FOOTER));

	new targetid = INVALID_PLAYER_ID;
	if(isnumeric(params)) targetid = strval(params);
	else
	{
		foreach(new i : Player)
		{
			if(!strcmp(User[i][pUsername], params, true)) { targetid = i; break; }
		}
	}
	if(targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid) || !User[targetid][pLogged]) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Player Not Found", "`Target player is not online.`", "", "", 0xE74C3C, DC_FOOTER));

	TogglePlayerControllable(targetid, false);
	SM(targetid, COLOR_ADMCMD, "* You have been frozen by Discord Administrator.");

	new logStr[128];
	format(logStr, sizeof(logStr), "`Target:` %s (ID %d) has been **frozen**.", GetRPName(targetid), targetid);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Freeze Executed", logStr, "", "", 0x3498DB, DC_FOOTER));
	return 1;
}

DCMD:unfreeze(user, channel, params[])
{
	if(!DC_IsUserAdmin(user)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions.`", "", "", 0xE74C3C, DC_FOOTER));
	if(isnull(params)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!unfreeze [playerid/username]`", "", "", 0xF39C12, DC_FOOTER));

	new targetid = INVALID_PLAYER_ID;
	if(isnumeric(params)) targetid = strval(params);
	else
	{
		foreach(new i : Player)
		{
			if(!strcmp(User[i][pUsername], params, true)) { targetid = i; break; }
		}
	}
	if(targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid) || !User[targetid][pLogged]) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Player Not Found", "`Target player is not online.`", "", "", 0xE74C3C, DC_FOOTER));

	TogglePlayerControllable(targetid, true);
	SM(targetid, COLOR_YELLOW, "* You have been unfrozen by Discord Administrator.");

	new logStr[128];
	format(logStr, sizeof(logStr), "`Target:` %s (ID %d) has been **unfrozen**.", GetRPName(targetid), targetid);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Unfreeze Executed", logStr, "", "", 0x2ECC71, DC_FOOTER));
	return 1;
}

DCMD:makeadmin(user, channel, params[])
{
	new duserid[DCC_ID_SIZE];
	DCC_GetUserId(user, duserid, sizeof(duserid));

	if(!DC_IsUserAdmin(user)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions on Discord.`", "", "", 0xE74C3C, DC_FOOTER));

	new target[32], level;
	if(sscanf(params, "s[32]i", target, level) || level < 0 || level > 7) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!makeadmin [playerid/username] [level (0-7)]`", "", "", 0xF39C12, DC_FOOTER));

	new targetid = INVALID_PLAYER_ID;
	if(isnumeric(target)) targetid = strval(target);
	else
	{
		foreach(new i : Player)
		{
			if(!strcmp(User[i][pUsername], target, true)) { targetid = i; break; }
		}
	}
	if(targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid) || !User[targetid][pLogged]) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Player Not Found", "`Target player is not online or logged in. Use !omakeadmin for offline players.`", "", "", 0xE74C3C, DC_FOOTER));

	User[targetid][pAdmin] = level;
	if(level == 0 && User[targetid][pAdminDuty])
	{
		User[targetid][pAdminDuty] = 0;
		SetPlayerName(targetid, User[targetid][pUsername]);
	}

	mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE users SET adminlevel = %i WHERE uid = %i", level, User[targetid][pID]);
	mysql_tquery(connectionID, queryBuffer);

	SAM(COLOR_ADMCMD, "AdmCmd: Discord Administrator (<@%s>) set %s's admin level to %d.", duserid, GetRPName(targetid), level);
	SM(targetid, COLOR_LIGHTBLUE, "Your admin level was updated to %s (%d) via Discord command.", GetAdminRank(targetid), level);

	new string[256];
	format(string, sizeof(string), "**Admin Level Updated**\n`Target:` %s (ID: %d)\n`New Level:` %s (%d)\n`Authorized By:` <@%s>", GetRPName(targetid), targetid, GetAdminRank(targetid), level, duserid);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Discord Makeadmin", string, "", "", 0x2ECC71, DC_FOOTER));
	return 1;
}

DCMD:omakeadmin(user, channel, params[])
{
	new duserid[DCC_ID_SIZE];
	DCC_GetUserId(user, duserid, sizeof(duserid));

	if(!DC_IsUserAdmin(user)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions on Discord.`", "", "", 0xE74C3C, DC_FOOTER));

	new targetName[MAX_PLAYER_NAME], level;
	if(sscanf(params, "s[24]i", targetName, level) || level < 0 || level > 7) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!omakeadmin [username] [level (0-7)]`", "", "", 0xF39C12, DC_FOOTER));

	mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE users SET adminlevel = %i WHERE username = '%e'", level, targetName);
	mysql_tquery(connectionID, queryBuffer);

	new string[256];
	format(string, sizeof(string), "**Offline Admin Level Updated**\n`Username:` %s\n`New Level:` %d\n`Authorized By:` <@%s>", targetName, level, duserid);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Discord Offline Makeadmin", string, "", "", 0x2ECC71, DC_FOOTER));

	SAM(COLOR_ADMCMD, "AdmCmd: Discord Administrator (<@%s>) set offline user %s's admin level to %d.", duserid, targetName, level);
	return 1;
}

DCMD:sendto(user, channel, params[])
{
	new duserid[DCC_ID_SIZE];
	DCC_GetUserId(user, duserid, sizeof(duserid));

	if(!DC_IsUserAdmin(user)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions on Discord.`", "", "", 0xE74C3C, DC_FOOTER));

	new target[32], location[20];
	if(sscanf(params, "s[32]s[20]", target, location)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!sendto [playerid/username] [location]`\n*Locations: ls, sf, lv, bank, idlewood, market, casino*", "", "", 0xF39C12, DC_FOOTER));

	new targetid = INVALID_PLAYER_ID;
	if(isnumeric(target)) targetid = strval(target);
	else
	{
		foreach(new i : Player)
		{
			if(!strcmp(User[i][pUsername], target, true)) { targetid = i; break; }
		}
	}
	if(targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid) || !User[targetid][pLogged]) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Player Not Found", "`Target player is not online or logged in.`", "", "", 0xE74C3C, DC_FOOTER));

	new Float:tx, Float:ty, Float:tz, Float:ta;
	new locName[32];
	if(!strcmp(location, "ls", true)) { tx = 1544.44; ty = -1675.55; tz = 13.55; ta = 90.0; format(locName, sizeof(locName), "Los Santos"); }
	else if(!strcmp(location, "sf", true)) { tx = -1989.70; ty = 142.18; tz = 27.68; ta = 90.0; format(locName, sizeof(locName), "San Fierro"); }
	else if(!strcmp(location, "lv", true)) { tx = 2026.54; ty = 1343.83; tz = 10.82; ta = 270.0; format(locName, sizeof(locName), "Las Venturas"); }
	else if(!strcmp(location, "bank", true)) { tx = 1462.46; ty = -1012.39; tz = 23.82; ta = 180.0; format(locName, sizeof(locName), "City Bank"); }
	else if(!strcmp(location, "idlewood", true)) { tx = 1952.12; ty = -1753.11; tz = 13.54; ta = 270.0; format(locName, sizeof(locName), "Idlewood"); }
	else if(!strcmp(location, "market", true)) { tx = 1098.24; ty = -1440.35; tz = 15.79; ta = 90.0; format(locName, sizeof(locName), "Market"); }
	else if(!strcmp(location, "casino", true)) { tx = 2026.54; ty = 1007.83; tz = 10.82; ta = 270.0; format(locName, sizeof(locName), "Four Dragons Casino"); }
	else return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Invalid Location", "`Valid locations: ls, sf, lv, bank, idlewood, market, casino`", "", "", 0xE74C3C, DC_FOOTER));

	SetPlayerPos(targetid, tx, ty, tz);
	SetPlayerFacingAngle(targetid, ta);
	SetPlayerInterior(targetid, 0);
	SetPlayerVirtualWorld(targetid, 0);
	SetCameraBehindPlayer(targetid);

	SM(targetid, COLOR_LIGHTBLUE, "You were teleported to %s via Discord Admin command.", locName);
	SAM(COLOR_ADMCMD, "AdmCmd: Discord Administrator (<@%s>) sent %s to %s.", duserid, GetRPName(targetid), locName);

	new string[256];
	format(string, sizeof(string), "**Teleport Successful**\n`Target:` %s (ID: %d)\n`Destination:` %s\n`Authorized By:` <@%s>", GetRPName(targetid), targetid, locName, duserid);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Discord SendTo", string, "", "", 0x3498DB, DC_FOOTER));
	return 1;
}

// -----------------------------------------------------------------------------
// Discord Log Channel Setup Commands
// -----------------------------------------------------------------------------

DCMD:setlog(user, channel, params[])
{
	new duserid[DCC_ID_SIZE];
	DCC_GetUserId(user, duserid, sizeof(duserid));

	if(!DC_IsUserAdmin(user, channel)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions on Discord.`", "", "", 0xE74C3C, DC_FOOTER));

	new targetChId[DCC_ID_SIZE], chType[24], rawTarget[64];
	if(sscanf(params, "s[24]S()[64]", chType, rawTarget))
	{
		// No parameters provided: bind current channel to ALL log types
		DCC_GetChannelId(channel, targetChId, sizeof(targetChId));
		format(g_dcChannelAdminLog, sizeof(g_dcChannelAdminLog), "%s", targetChId);
		format(g_dcChannelPunish, sizeof(g_dcChannelPunish), "%s", targetChId);
		format(g_dcChannelAntiCheat, sizeof(g_dcChannelAntiCheat), "%s", targetChId);
		format(g_dcChannelReports, sizeof(g_dcChannelReports), "%s", targetChId);
		format(g_dcChannelGlobal, sizeof(g_dcChannelGlobal), "%s", targetChId);
		format(g_dcChannelAdminChat, sizeof(g_dcChannelAdminChat), "%s", targetChId);
		format(g_dcChannelRPLog, sizeof(g_dcChannelRPLog), "%s", targetChId);
		DC_SaveChannels();

		new string[420];
		format(string, sizeof(string), "**Log Channel Configured**\nThis channel (<#%s>) is now set as the **Primary Channel** for all server events.\n\n• **Normal Chat:** Active\n• **Admin Chat:** Active\n• **/me & /do Logs:** Active\n• **Admin Logs:** Active\n• **Punishments:** Active\n• **Anticheat Alerts:** Active\n• **Player Reports:** Active\n\n`Channel ID:` `%s`\n`Configured By:` <@%s>", targetChId, targetChId, duserid);
		DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Discord Log Setup", string, "", "", 0x2ECC71, DC_FOOTER));
		return 1;
	}

	if(strlen(rawTarget) > 0)
	{
		if(!DC_CleanChannelId(rawTarget, targetChId, sizeof(targetChId)) || strlen(targetChId) < 15)
		{
			return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Invalid Channel ID", "`Please provide a valid Discord Channel ID or #mention.`", "", "", 0xE74C3C, DC_FOOTER));
		}
	}
	else
	{
		DCC_GetChannelId(channel, targetChId, sizeof(targetChId));
	}

	new DCC_Channel:destChan = DCC_FindChannelById(targetChId);
	if(!destChan)
	{
		new errStr[180];
		format(errStr, sizeof(errStr), "`Warning: The bot cannot find channel ID '%s'. Ensure the bot is in the server and has access to this channel.`", targetChId);
		DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Channel Not Found", errStr, "", "", 0xE67E22, DC_FOOTER));
	}

	new typeLabel[32];
	if(!strcmp(chType, "admin", true))
	{
		format(g_dcChannelAdminLog, sizeof(g_dcChannelAdminLog), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Admin Logs");
	}
	else if(!strcmp(chType, "punish", true) || !strcmp(chType, "punishment", true))
	{
		format(g_dcChannelPunish, sizeof(g_dcChannelPunish), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Punishment Logs");
	}
	else if(!strcmp(chType, "ac", true) || !strcmp(chType, "anticheat", true))
	{
		format(g_dcChannelAntiCheat, sizeof(g_dcChannelAntiCheat), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Anticheat Alerts");
	}
	else if(!strcmp(chType, "report", true) || !strcmp(chType, "reports", true))
	{
		format(g_dcChannelReports, sizeof(g_dcChannelReports), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Player Reports");
	}
	else if(!strcmp(chType, "global", true) || !strcmp(chType, "normal", true))
	{
		format(g_dcChannelGlobal, sizeof(g_dcChannelGlobal), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Global Chat Relay");
	}
	else if(!strcmp(chType, "adminchat", true) || !strcmp(chType, "a", true))
	{
		format(g_dcChannelAdminChat, sizeof(g_dcChannelAdminChat), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Admin Chat Relay");
	}
	else if(!strcmp(chType, "rp", true) || !strcmp(chType, "chat", true) || !strcmp(chType, "me", true) || !strcmp(chType, "do", true))
	{
		format(g_dcChannelRPLog, sizeof(g_dcChannelRPLog), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "In-Game RP Chat");
	}
	else if(!strcmp(chType, "login", true) || !strcmp(chType, "connect", true) || !strcmp(chType, "connections", true))
	{
		format(g_dcChannelLogin, sizeof(g_dcChannelLogin), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Connection & Login Logs");
	}
	else if(!strcmp(chType, "kill", true) || !strcmp(chType, "death", true) || !strcmp(chType, "kills", true))
	{
		format(g_dcChannelKill, sizeof(g_dcChannelKill), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Kill & Death Logs");
	}
	else if(!strcmp(chType, "damage", true) || !strcmp(chType, "combat", true))
	{
		format(g_dcChannelDamage, sizeof(g_dcChannelDamage), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Damage Logs");
	}
	else if(!strcmp(chType, "weapons", true) || !strcmp(chType, "weapon", true) || !strcmp(chType, "guns", true))
	{
		format(g_dcChannelWeapons, sizeof(g_dcChannelWeapons), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Weapon Logs");
	}
	else if(!strcmp(chType, "ban", true) || !strcmp(chType, "bans", true))
	{
		format(g_dcChannelBan, sizeof(g_dcChannelBan), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Ban Logs");
	}
	else if(!strcmp(chType, "pm", true) || !strcmp(chType, "sms", true) || !strcmp(chType, "msg", true))
	{
		format(g_dcChannelPM, sizeof(g_dcChannelPM), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Private Message Logs");
	}
	else if(!strcmp(chType, "whisper", true) || !strcmp(chType, "w", true))
	{
		format(g_dcChannelWhisper, sizeof(g_dcChannelWhisper), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Whisper Logs");
	}
	else if(!strcmp(chType, "fb", true) || !strcmp(chType, "facebook", true))
	{
		format(g_dcChannelFB, sizeof(g_dcChannelFB), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Facebook Chat Logs");
	}
	else if(!strcmp(chType, "twitter", true) || !strcmp(chType, "tweet", true))
	{
		format(g_dcChannelTwitter, sizeof(g_dcChannelTwitter), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Twitter Chat Logs");
	}
	else if(!strcmp(chType, "insta", true) || !strcmp(chType, "instagram", true))
	{
		format(g_dcChannelInsta, sizeof(g_dcChannelInsta), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Instagram Chat Logs");
	}
	else if(!strcmp(chType, "business", true) || !strcmp(chType, "biz", true) || !strcmp(chType, "property", true))
	{
		format(g_dcChannelBusiness, sizeof(g_dcChannelBusiness), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Business & Property Logs");
	}
	else if(!strcmp(chType, "dynamic", true) || !strcmp(chType, "dynamics", true))
	{
		format(g_dcChannelDynamic, sizeof(g_dcChannelDynamic), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Dynamic Systems Logs");
	}
	else if(!strcmp(chType, "commands", true) || !strcmp(chType, "cmd", true))
	{
		format(g_dcChannelCommands, sizeof(g_dcChannelCommands), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Command Usage Logs");
	}
	else if(!strcmp(chType, "faction", true) || !strcmp(chType, "factions", true))
	{
		format(g_dcChannelFaction, sizeof(g_dcChannelFaction), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "Faction Logs");
	}
	else if(!strcmp(chType, "all", true))
	{
		format(g_dcChannelAdminLog, sizeof(g_dcChannelAdminLog), "%s", targetChId);
		format(g_dcChannelPunish, sizeof(g_dcChannelPunish), "%s", targetChId);
		format(g_dcChannelAntiCheat, sizeof(g_dcChannelAntiCheat), "%s", targetChId);
		format(g_dcChannelReports, sizeof(g_dcChannelReports), "%s", targetChId);
		format(g_dcChannelGlobal, sizeof(g_dcChannelGlobal), "%s", targetChId);
		format(g_dcChannelAdminChat, sizeof(g_dcChannelAdminChat), "%s", targetChId);
		format(g_dcChannelRPLog, sizeof(g_dcChannelRPLog), "%s", targetChId);
		format(g_dcChannelBusiness, sizeof(g_dcChannelBusiness), "%s", targetChId);
		format(typeLabel, sizeof(typeLabel), "All Server Logs & Chats");
	}
	else
	{
		return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Command Usage", "`!setlog [business/dynamic/commands/faction/login/kill/damage/weapons/ban/punish/ac/reports/chat/global/pm/whisper/fb/twitter/insta] [#channel or ID]`\n*Tip: Run `!createchannels` to automatically create all missing channels!*", "", "", 0xF39C12, DC_FOOTER));
	}

	DC_SaveChannels();

	new confirm[320];
	format(confirm, sizeof(confirm), "**Log Channel Updated**\n`Category:` %s\n`Channel:` <#%s> (`%s`)\n`Updated By:` <@%s>\n\n*Saved permanently to server config.*", typeLabel, targetChId, targetChId, duserid);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Discord Channel Configuration", confirm, "", "", 0x2ECC71, DC_FOOTER));

	if(destChan && destChan != channel)
	{
		new pingMsg[256];
		format(pingMsg, sizeof(pingMsg), "🔔 This channel has been set to receive **%s** by <@%s>.", typeLabel, duserid);
		DCC_SendChannelEmbedMessage(destChan, DCC_CreateEmbed("Channel Connected", pingMsg, "", "", 0x3498DB, DC_FOOTER));
	}
	return 1;
}

DCMD:setlogs(user, channel, params[]) return DCMD_setlog(user, channel, params);
DCMD:setlogchannel(user, channel, params[]) return DCMD_setlog(user, channel, params);
DCMD:setchannel(user, channel, params[]) return DCMD_setlog(user, channel, params);

DCMD:setip(user, channel, params[])
{
	if(!DC_IsUserAdmin(user, channel)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions.`", "", "", 0xE74C3C, DC_FOOTER));

	new newIp[64];
	if(sscanf(params, "s[64]", newIp))
	{
		return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Usage Help", "`Usage: !setip [ip:port]`", "", "", 0xF1C40F, DC_FOOTER));
	}

	format(g_dcServerIP, sizeof(g_dcServerIP), "%s", newIp);
	DC_SaveChannels();

	new confirm[256];
	format(confirm, sizeof(confirm), "**Server IP Updated**\n`New Address:` `%s`\n\n*Saved permanently to server config.*", g_dcServerIP);
	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Server Configuration", confirm, "", "", 0x2ECC71, DC_FOOTER));
	return 1;
}

forward OnDcChannelCreated(const chType[]);
public OnDcChannelCreated(const chType[])
{
	new DCC_Channel:newChan = DCC_GetCreatedGuildChannel();
	if(newChan != DCC_Channel:0)
	{
		new chId[DCC_ID_SIZE];
		DCC_GetChannelId(newChan, chId, sizeof(chId));
		if(!strcmp(chType, "global", true)) format(g_dcChannelGlobal, sizeof(g_dcChannelGlobal), "%s", chId);
		else if(!strcmp(chType, "adminchat", true)) format(g_dcChannelAdminChat, sizeof(g_dcChannelAdminChat), "%s", chId);
		else if(!strcmp(chType, "rp", true) || !strcmp(chType, "chat", true)) format(g_dcChannelRPLog, sizeof(g_dcChannelRPLog), "%s", chId);
		else if(!strcmp(chType, "admin", true)) format(g_dcChannelAdminLog, sizeof(g_dcChannelAdminLog), "%s", chId);
		else if(!strcmp(chType, "punish", true)) format(g_dcChannelPunish, sizeof(g_dcChannelPunish), "%s", chId);
		else if(!strcmp(chType, "ac", true) || !strcmp(chType, "anticheat", true)) format(g_dcChannelAntiCheat, sizeof(g_dcChannelAntiCheat), "%s", chId);
		else if(!strcmp(chType, "reports", true)) format(g_dcChannelReports, sizeof(g_dcChannelReports), "%s", chId);
		else if(!strcmp(chType, "login", true)) format(g_dcChannelLogin, sizeof(g_dcChannelLogin), "%s", chId);
		else if(!strcmp(chType, "kill", true)) format(g_dcChannelKill, sizeof(g_dcChannelKill), "%s", chId);
		else if(!strcmp(chType, "damage", true)) format(g_dcChannelDamage, sizeof(g_dcChannelDamage), "%s", chId);
		else if(!strcmp(chType, "weapons", true)) format(g_dcChannelWeapons, sizeof(g_dcChannelWeapons), "%s", chId);
		else if(!strcmp(chType, "ban", true)) format(g_dcChannelBan, sizeof(g_dcChannelBan), "%s", chId);
		else if(!strcmp(chType, "pm", true)) format(g_dcChannelPM, sizeof(g_dcChannelPM), "%s", chId);
		else if(!strcmp(chType, "whisper", true)) format(g_dcChannelWhisper, sizeof(g_dcChannelWhisper), "%s", chId);
		else if(!strcmp(chType, "fb", true)) format(g_dcChannelFB, sizeof(g_dcChannelFB), "%s", chId);
		else if(!strcmp(chType, "twitter", true)) format(g_dcChannelTwitter, sizeof(g_dcChannelTwitter), "%s", chId);
		else if(!strcmp(chType, "insta", true)) format(g_dcChannelInsta, sizeof(g_dcChannelInsta), "%s", chId);
		DC_SaveChannels();
	}
	return 1;
}

DCMD:createchannels(user, channel, params[])
{
	if(!DC_IsUserAdmin(user, channel)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions on Discord.`", "", "", 0xE74C3C, DC_FOOTER));

	new DCC_Guild:guild = DCC_Guild:0;
	DCC_GetChannelGuild(channel, guild);
	if(guild == DCC_Guild:0) guild = DCC_FindGuildById(GUILD);
	if(guild == DCC_Guild:0)
	{
		new DCC_Guild:allGuilds[5];
		new gCount = DCC_GetAllGuilds(allGuilds, sizeof(allGuilds));
		if(gCount > 0) guild = allGuilds[0];
	}

	if(guild == DCC_Guild:0)
	{
		return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Error", "`Could not find Discord Guild/Server.`", "", "", 0xE74C3C, DC_FOOTER));
	}

	DCC_CreateGuildChannel(guild, "log-admin", GUILD_TEXT, "OnDcChannelCreated", "s", "admin");
	DCC_CreateGuildChannel(guild, "log-adminchat", GUILD_TEXT, "OnDcChannelCreated", "s", "adminchat");
	DCC_CreateGuildChannel(guild, "log-login", GUILD_TEXT, "OnDcChannelCreated", "s", "login");
	DCC_CreateGuildChannel(guild, "log-ban", GUILD_TEXT, "OnDcChannelCreated", "s", "ban");
	DCC_CreateGuildChannel(guild, "log-punishment", GUILD_TEXT, "OnDcChannelCreated", "s", "punish");
	DCC_CreateGuildChannel(guild, "log-anticheat", GUILD_TEXT, "OnDcChannelCreated", "s", "ac");
	DCC_CreateGuildChannel(guild, "log-kill", GUILD_TEXT, "OnDcChannelCreated", "s", "kill");
	DCC_CreateGuildChannel(guild, "log-damage", GUILD_TEXT, "OnDcChannelCreated", "s", "damage");
	DCC_CreateGuildChannel(guild, "log-weapons", GUILD_TEXT, "OnDcChannelCreated", "s", "weapons");
	DCC_CreateGuildChannel(guild, "log-reports", GUILD_TEXT, "OnDcChannelCreated", "s", "reports");
	DCC_CreateGuildChannel(guild, "log-chat", GUILD_TEXT, "OnDcChannelCreated", "s", "chat");
	DCC_CreateGuildChannel(guild, "log-globalchat", GUILD_TEXT, "OnDcChannelCreated", "s", "global");
	DCC_CreateGuildChannel(guild, "log-pm-message", GUILD_TEXT, "OnDcChannelCreated", "s", "pm");
	DCC_CreateGuildChannel(guild, "log-whisper", GUILD_TEXT, "OnDcChannelCreated", "s", "whisper");
	DCC_CreateGuildChannel(guild, "log-facebookchat", GUILD_TEXT, "OnDcChannelCreated", "s", "fb");
	DCC_CreateGuildChannel(guild, "log-twitterchat", GUILD_TEXT, "OnDcChannelCreated", "s", "twitter");
	DCC_CreateGuildChannel(guild, "log-instachat", GUILD_TEXT, "OnDcChannelCreated", "s", "insta");

	new string[520];
	format(string, sizeof(string), "**Creating & Configuring All Discord Log Channels...**\n\n\
	• `#log-login` — Player Connection & Login Logs\n\
	• `#log-kill` — Player Kills & Deaths\n\
	• `#log-damage` — Combat Damage\n\
	• `#log-weapons` — Weapon Logs\n\
	• `#log-ban` — Ban Logs\n\
	• `#log-punishment` — Kicks, Warns & Jails\n\
	• `#log-anticheat` — Weapon & Speed AC Alerts\n\
	• `#log-reports` — Player /report Submissions\n\
	• `#log-chat` & `#log-globalchat` — Local RP & Global Chat\n\
	• `#log-pm-message` & `#log-whisper` — PM & Whispers\n\
	• Social: Facebook, Twitter & Insta Logs\n\n\
	*The bot is creating any missing channels and saving them automatically!*");

	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Discord Channels Auto-Setup", string, "", "", 0x2ECC71, DC_FOOTER));
	return 1;
}
DCMD:setupchannels(user, channel, params[]) return DCMD_createchannels(user, channel, params);
DCMD:autochannels(user, channel, params[]) return DCMD_createchannels(user, channel, params);

DCMD:logchannels(user, channel, params[])
{
	if(!DC_IsUserAdmin(user, channel)) return DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Access Denied", "`You do not have Administrator permissions on Discord.`", "", "", 0xE74C3C, DC_FOOTER));

	new string[900];
	format(string, sizeof(string), "**Active Discord Channels Configuration**\n\n\
	• **Logins:** <#%s>\n\
	• **Global Chat:** <#%s>\n\
	• **Local RP Chat:** <#%s>\n\
	• **Admin Logs:** <#%s>\n\
	• **Bans:** <#%s>\n\
	• **Punishments:** <#%s>\n\
	• **Anticheat:** <#%s>\n\
	• **Kills:** <#%s>\n\
	• **Damage:** <#%s>\n\
	• **Weapons:** <#%s>\n\
	• **Reports:** <#%s>\n\
	• **PMs:** <#%s>\n\
	• **Whispers:** <#%s>\n\n\
	*Tip: Use `!setlog [type] <#channel>` to bind any channel!*",
	g_dcChannelLogin,
	g_dcChannelGlobal,
	g_dcChannelRPLog,
	g_dcChannelAdminLog,
	g_dcChannelBan,
	g_dcChannelPunish,
	g_dcChannelAntiCheat,
	g_dcChannelKill,
	g_dcChannelDamage,
	g_dcChannelWeapons,
	g_dcChannelReports,
	g_dcChannelPM,
	g_dcChannelWhisper);

	DCC_SendChannelEmbedMessage(channel, DCC_CreateEmbed("Discord Channels Status", string, "", "", 0x3498DB, DC_FOOTER));
	return 1;
}
DCMD:channels(user, channel, params[]) return DCMD_logchannels(user, channel, params);

CMD:setdiscordlog(playerid, params[])
{
	if(User[playerid][pAdmin] < 6 && !IsPlayerAdmin(playerid))
	{
		return SCM(playerid, COLOR_GREY, "You are not authorized to use this command.");
	}

	new type[24], rawId[64], cleanId[DCC_ID_SIZE];
	if(sscanf(params, "s[24]s[64]", type, rawId))
	{
		SM(playerid, COLOR_SYNTAX, "USAGE: /setdiscordlog [login/kill/damage/weapons/ban/punish/ac/reports/global/chat/pm/whisper/fb/twitter/insta] [channel_id]");
		return 1;
	}

	if(!DC_CleanChannelId(rawId, cleanId, sizeof(cleanId)) || strlen(cleanId) < 15)
	{
		return SCM(playerid, COLOR_GREY, "Invalid Discord channel ID specified.");
	}

	new typeLabel[32];
	if(!strcmp(type, "admin", true)) { format(g_dcChannelAdminLog, sizeof(g_dcChannelAdminLog), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Admin Logs"); }
	else if(!strcmp(type, "punish", true) || !strcmp(type, "punishment", true)) { format(g_dcChannelPunish, sizeof(g_dcChannelPunish), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Punishment Logs"); }
	else if(!strcmp(type, "ac", true) || !strcmp(type, "anticheat", true)) { format(g_dcChannelAntiCheat, sizeof(g_dcChannelAntiCheat), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Anticheat Alerts"); }
	else if(!strcmp(type, "reports", true) || !strcmp(type, "report", true)) { format(g_dcChannelReports, sizeof(g_dcChannelReports), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Player Reports"); }
	else if(!strcmp(type, "global", true)) { format(g_dcChannelGlobal, sizeof(g_dcChannelGlobal), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Global Chat"); }
	else if(!strcmp(type, "adminchat", true) || !strcmp(type, "a", true)) { format(g_dcChannelAdminChat, sizeof(g_dcChannelAdminChat), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Admin Chat"); }
	else if(!strcmp(type, "rp", true) || !strcmp(type, "chat", true)) { format(g_dcChannelRPLog, sizeof(g_dcChannelRPLog), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "In-Game RP Chat"); }
	else if(!strcmp(type, "login", true)) { format(g_dcChannelLogin, sizeof(g_dcChannelLogin), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Connection & Login Logs"); }
	else if(!strcmp(type, "kill", true)) { format(g_dcChannelKill, sizeof(g_dcChannelKill), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Kill & Death Logs"); }
	else if(!strcmp(type, "damage", true)) { format(g_dcChannelDamage, sizeof(g_dcChannelDamage), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Damage Logs"); }
	else if(!strcmp(type, "weapons", true)) { format(g_dcChannelWeapons, sizeof(g_dcChannelWeapons), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Weapon Logs"); }
	else if(!strcmp(type, "ban", true)) { format(g_dcChannelBan, sizeof(g_dcChannelBan), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Ban Logs"); }
	else if(!strcmp(type, "pm", true)) { format(g_dcChannelPM, sizeof(g_dcChannelPM), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Private Message Logs"); }
	else if(!strcmp(type, "whisper", true)) { format(g_dcChannelWhisper, sizeof(g_dcChannelWhisper), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Whisper Logs"); }
	else if(!strcmp(type, "fb", true)) { format(g_dcChannelFB, sizeof(g_dcChannelFB), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Facebook Chat Logs"); }
	else if(!strcmp(type, "twitter", true)) { format(g_dcChannelTwitter, sizeof(g_dcChannelTwitter), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Twitter Chat Logs"); }
	else if(!strcmp(type, "insta", true)) { format(g_dcChannelInsta, sizeof(g_dcChannelInsta), "%s", cleanId); format(typeLabel, sizeof(typeLabel), "Instagram Chat Logs"); }
	else
	{
		return SCM(playerid, COLOR_GREY, "Invalid type. Valid: login, kill, damage, weapons, ban, punish, ac, reports, global, chat, pm, whisper, fb, twitter, insta.");
	}

	DC_SaveChannels();
	SM(playerid, COLOR_GREEN, "[DISCORD] Log channel for '%s' has been updated to: %s.", typeLabel, cleanId);

	new DCC_Channel:chan = DCC_FindChannelById(cleanId);
	if(chan)
	{
		new msg[256];
		format(msg, sizeof(msg), "🔔 This channel was set to receive **%s** by in-game Administrator %s.", typeLabel, GetRPName(playerid));
		DCC_SendChannelEmbedMessage(chan, DCC_CreateEmbed("Log Channel Connected", msg, "", "", 0x2ECC71, DC_FOOTER));
	}
	return 1;
}

CMD:discordchannels(playerid, params[])
{
	if(User[playerid][pAdmin] < 6 && !IsPlayerAdmin(playerid))
	{
		return SCM(playerid, COLOR_GREY, "You are not authorized to use this command.");
	}

	SM(playerid, COLOR_LIGHTBLUE, "--- Active Discord Bot Configuration ---");
	SM(playerid, COLOR_WHITE, "Server IP: %s", g_dcServerIP);
	SM(playerid, COLOR_WHITE, "Login Logs: %s", g_dcChannelLogin);
	SM(playerid, COLOR_WHITE, "Global Chat: %s", g_dcChannelGlobal);
	SM(playerid, COLOR_WHITE, "RP Chat: %s", g_dcChannelRPLog);
	SM(playerid, COLOR_WHITE, "Kills: %s | Damage: %s | Weapons: %s", g_dcChannelKill, g_dcChannelDamage, g_dcChannelWeapons);
	SM(playerid, COLOR_WHITE, "Bans: %s | Punishments: %s", g_dcChannelBan, g_dcChannelPunish);
	SM(playerid, COLOR_WHITE, "Anticheat: %s | Reports: %s", g_dcChannelAntiCheat, g_dcChannelReports);
	SM(playerid, COLOR_WHITE, "PMs: %s | Whispers: %s", g_dcChannelPM, g_dcChannelWhisper);
	return 1;
}

CMD:setserverip(playerid, params[])
{
	if(User[playerid][pAdmin] < 6 && !IsPlayerAdmin(playerid))
	{
		return SCM(playerid, COLOR_GREY, "You are not authorized to use this command.");
	}

	new newIp[64];
	if(sscanf(params, "s[64]", newIp))
	{
		SM(playerid, COLOR_SYNTAX, "USAGE: /setserverip [ip:port]");
		return 1;
	}

	format(g_dcServerIP, sizeof(g_dcServerIP), "%s", newIp);
	DC_SaveChannels();
	SM(playerid, COLOR_GREEN, "[DISCORD] Server IP updated to: %s (saved to config).", g_dcServerIP);
	return 1;
}


forward DCC_DM(playerid);
public DCC_DM(playerid)
{
	new string[300];
	new szString[300];
	new date[6];
	new DCC_Channel:channel;

	new DCC_Embed:private = DCC_CreateEmbed("Lost Island Roleplay");

	channel = DCC_GetCreatedPrivateChannel();

	gettime(date[3], date[4], date[5]);

	format(
		szString,
		sizeof(szString),
		"Hello there %s\nThank you so much for choosing our server, I hope you enjoy it and invite more friends so we can have fun together. This is Lost Island Roleplay the one and only gives enjoyment in your life.\n\n**You are now verified**",
		User[playerid][pUsername]
	);

	DCC_SetEmbedDescription(private, szString);

	// FOOTER //
	format(
		string,
		sizeof(string),
		"Lost Island Roleplay | UTC: %02d:%02d",
		date[3],
		date[4]
	);

	DCC_SetEmbedFooter(private, string);

	// COLOR //
	DCC_SetEmbedColour(private, 0xb8e83f);

	// THUMBNAIL //
	DCC_SetEmbedThumbnail(
		private,
		"https://media.discordapp.net/attachments/1422296837959712889/1429048872327446688/34851ac302b14f12be685c2229032219.gif?ex=6abb8e79&is=6aba3cf9&hm=cf7d1fd3e894a7395e3bd4d7a818c0e81056c45d5189c0f2e9d8362b18e12e17&="
	);

	DCC_SendChannelEmbedMessage(channel, private);

	return 1;
}
/*
hook OnPlayerUpdate(playerid)
{
	if(!User[playerid][pVerified])
	{
		TogglePlayerControllable(playerid, false);
	}
	else
	{
		TogglePlayerControllable(playerid, true);
	}
	return 1;
}*/

hook OnPlayerSpawn(playerid)
{
	if(!User[playerid][pVerified])
	{
		TogglePlayerControllable(playerid, false);
		SendClientMessage(playerid, -1, "You are not linked in Discord. Use '/getcode' to generate your verification code.");
	}
	else
	{
		TogglePlayerControllable(playerid, true);
	}
	return 1;
}

hook OnPlayerUpdate(playerid)
{
	if(!User[playerid][pVerified])
	{
		TogglePlayerControllable(playerid, false);
	}
	return 1;
}

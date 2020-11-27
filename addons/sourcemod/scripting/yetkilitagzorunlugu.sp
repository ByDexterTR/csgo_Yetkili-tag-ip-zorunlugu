#include <sourcemod>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

ConVar g_sClanTagName = null, g_sDomainName = null, Admingrupenable = null, Adminisimenable = null;

public Plugin myinfo = 
{
	name = "Yetkili ip ve tag zorunluğu", 
	author = "ByDexter", 
	description = "Yetkili olan oyuncular ip ve ya tag almazsa komut kullanmasını engeller", 
	version = "1.2", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	g_sClanTagName = CreateConVar("admin_clantag", "ByDexter", "Steam Klan Tagınız");
	g_sDomainName = CreateConVar("admin_serverip", "github.com/ByDexterTR", "Sunucu ip adresiniz");
	Admingrupenable = CreateConVar("admin_clantag_enable", "1", "Group Tag Plugin Enabled/Disabled", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	Adminisimenable = CreateConVar("admin_serverip_enable", "0", "Server Ip Plugin Enabled/Disabled", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig(true, "YetkiliTagZorunlugu", "ByDexter");
	LoadConfig();
}

void LoadConfig()
{
	KeyValues Kv = new KeyValues("ByDexter");
	char sBuffer[256];
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), "configs/dexter/command_list.ini");
	if (!FileToKeyValues(Kv, sBuffer))SetFailState("%s dosyası bulunamadı.", sBuffer);
	if (Kv.GotoFirstSubKey())
	{
		do
		{
			if (Kv.GetSectionName(sBuffer, sizeof(sBuffer)))
			{
				AddCommandListener(Control_CommandAdmin, sBuffer);
			}
		}
		while (Kv.GotoNextKey());
	}
	delete Kv;
}

public void OnMapStart()
{
	LoadConfig();
}

public Action Control_CommandAdmin(int client, char[] command, int args)
{
	if (GetUserAdmin(client) != INVALID_ADMIN_ID)
	{
		if (Admingrupenable.BoolValue)
		{
			char clanTag[32], ClanTagName[512];
			g_sClanTagName.GetString(ClanTagName, sizeof(ClanTagName));
			CS_GetClientClanTag(client, clanTag, sizeof(clanTag));
			if (strcmp(clanTag, ClanTagName, false) == -1)
			{
				ReplyToCommand(client, "[SM] \x01Bu komutu kullanmak için \x10%s \x01grup etiketimizi kullanmanız gerek", ClanTagName);
				return Plugin_Stop;
			}
		}
		if (Adminisimenable.BoolValue)
		{
			char DomainName[512], playerName[MAX_NAME_LENGTH];
			g_sDomainName.GetString(DomainName, sizeof(DomainName));
			GetClientName(client, playerName, sizeof(playerName));
			if (strcmp(playerName, DomainName, false) == -1)
			{
				ReplyToCommand(client, "[SM] \x01Bu komutu kullanmak için isminizde \x10%s \x01bulunması gerek!", DomainName);
				return Plugin_Stop;
			}
		}
	}
	return Plugin_Continue;
} 
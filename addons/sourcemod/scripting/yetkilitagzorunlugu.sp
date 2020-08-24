#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <multicolors>

// char //
char ClanTagName[512];
char DomainName[512];

// ConVar //
ConVar g_sClanTagName;
ConVar g_sDomainName;

// Handle //
Handle Admingrupenable;
Handle Adminisimenable;

#pragma semicolon 1
#pragma newdecls required

#define DEBUG
#define PLUGIN_AUTHOR "ByDexter"
#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
	name = "Yetkili ip ve tag zorunluğu", 
	author = PLUGIN_AUTHOR, 
	description = "Yetkili olan oyuncular ip ve ya tag almazsa komut kullanmasını engeller", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/ByDexterTR/"
};

public void OnPluginStart()
{
	g_sClanTagName = CreateConVar("admin_clantag", "ByDexter", "Steam Klan Tagınız");
	g_sDomainName = CreateConVar("admin_serverip", "github.com/ByDexterTR", "Sunucu ip adresiniz");
	Admingrupenable = CreateConVar("admin_clantag_enable", "1", "Group Tag Plugin Enabled/Disabled", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	Adminisimenable = CreateConVar("admin_serverip_enable", "0", "Server Ip Plugin Enabled/Disabled", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig(true, "YetkiliTagZorunlugu", "ByDexter");
}

void LoadConfig()
{
	KeyValues Kv = new KeyValues("ByDexter");
	
	char sBuffer[256];
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), "configs/dexter/command_list.ini");
	if (!FileToKeyValues(Kv, sBuffer)) SetFailState("%s dosyası bulunamadı.", sBuffer);
	
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
	g_sClanTagName.GetString(ClanTagName, sizeof(ClanTagName));
	g_sDomainName.GetString(DomainName, sizeof(DomainName));
}

public Action Control_CommandAdmin(int client, char[] command, int args)
{
	if(GetUserAdmin(client) != INVALID_ADMIN_ID)
	{
		if(GetConVarInt(Admingrupenable))
		{
			char clanTag[16];
			CS_GetClientClanTag(client, clanTag, 16);
			if(StrEqual(clanTag, ClanTagName, false))
			{
				// Boş aynı nora gibi
			}
			else
			{
				CPrintToChat(client, "{darkred}[ByDexter] {default}Bu komutu kullanmak için {green}klan tagı kullanmanız gerekiyor");
				return Plugin_Stop;
			}
		}
		if(GetConVarInt(Adminisimenable))
		{
			char playerName[32];
			GetClientName(client, playerName, 32);
			if(StrContains(playerName, DomainName, false) != -1)
			{
				// Boş aynı nora gibi
			}
			else
			{
				CPrintToChat(client, "{darkred}[ByDexter] {default}Bu komutu kullanmak için {green}isminize ip almanız gerekiyor");
				return Plugin_Stop;
			}
		}
	}
	return Plugin_Continue;
}
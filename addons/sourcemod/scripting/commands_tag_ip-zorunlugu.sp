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
	version = "1.3", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	g_sClanTagName = CreateConVar("admin_clantag", "ByDexter", "Steam Klan Tagınız");
	g_sDomainName = CreateConVar("admin_serverip", "github.com/ByDexterTR", "Sunucu ip adresiniz");
	Admingrupenable = CreateConVar("admin_clantag_enable", "1", "Group Tag Plugin Enabled/Disabled", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	Adminisimenable = CreateConVar("admin_serverip_enable", "0", "Server Ip Plugin Enabled/Disabled", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig(true, "commands_tag_ip-zorunlugu", "ByDexter");
}

void LoadConfig()
{
	KeyValues Kv = new KeyValues("ByDexter");
	char sBuffer[256];
	BuildPath(Path_SM, sBuffer, 256, "configs/ByDexter/commands_tag_ip-zorunlugu.ini");
	
	if (!FileToKeyValues(Kv, sBuffer))SetFailState("commands_tag_ip-zorunlugu.ini dosyası bulunamadı.", sBuffer);
	if (!Kv.GotoFirstSubKey())SetFailState("commands_tag_ip-zorunlugu.ini dosyası hatalı.", sBuffer);
	
	do
	{
		if (Kv.GetSectionName(sBuffer, sizeof(sBuffer)))
		{
			AddCommandListener(Control_CommandAdmin, sBuffer);
		}
	}
	while (Kv.GotoNextKey());
	
	delete Kv;
}

public void OnMapStart()
{
	LoadConfig();
}

public Action Control_CommandAdmin(int client, char[] command, int args)
{
	if (IsValidClient(client))
	{
		if (Admingrupenable.BoolValue)
		{
			char servertag[12], playertag[12];
			
			g_sClanTagName.GetString(servertag, 12);
			CS_GetClientClanTag(client, playertag, 12);
			
			if (strncmp(playertag, servertag, sizeof(servertag)) != 0)
			{
				ReplyToCommand(client, "[SM] \x01Bu komutu kullanmak için \x10%s \x01grup etiketimizi kullanmanız gerek.", servertag);
				return Plugin_Stop;
			}
		}
		if (Adminisimenable.BoolValue)
		{
			char domain[128], playername[128];
			
			g_sDomainName.GetString(domain, 128);
			GetClientName(client, playername, 128);
			
			if (StrContains(playername, domain) == -1)
			{
				ReplyToCommand(client, "[SM] \x01Bu komutu kullanmak için isminizde \x10%s \x01bulunması gerek.", domain);
				return Plugin_Stop;
			}
		}
	}
	return Plugin_Continue;
}

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || GetUserAdmin(client) == INVALID_ADMIN_ID || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
} 
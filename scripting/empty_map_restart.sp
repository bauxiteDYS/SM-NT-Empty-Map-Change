#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

bool g_lateLoad;
bool g_firstStart;
int g_checkCount;

public Plugin myinfo = {
	name = "Server testart and Map reloader",
	author = "bauxite, rain",
	description = "Reloads current map when server is empty to prevent issues, also restarts periodically",
	version = "0.3.0",
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_lateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	if(g_lateLoad)
	{
		g_firstStart = false;
	}
	else
	{
		g_firstStart = true;
	}
}

public void OnMapStart()
{
	if(g_firstStart)
	{
		g_firstStart = false;
		
		CreateTimer(3.0, Timer_ReloadMap, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{	
		CreateTimer(2341.0, Timer_ReloadMapIfEmptyServer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_ReloadMap(Handle timer, any data)
{
	ReloadLevel();
	return Plugin_Stop;
}

public Action Timer_ReloadMapIfEmptyServer(Handle timer, any data)
{
	++g_checkCount;
	
	int playerCount = GetClientCount(true);
	
	if (playerCount <= 1)
	{
		if(g_checkCount <= 11)
		{
			ReloadLevel();
			return Plugin_Stop;
		}
		else
		{
			ServerCommand("_restart");
		}
	}

	return Plugin_Continue;
}

void ReloadLevel()
{
	char mapName[32];
	GetCurrentMap(mapName, sizeof(mapName));

	ForceChangeLevel(mapName, "Empty server");
}
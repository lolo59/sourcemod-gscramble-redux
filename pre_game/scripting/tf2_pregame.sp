/************************************************************************
*************************************************************************
Waiting For Players
Description:
	Friendlyfire during waiting for players
*************************************************************************
*************************************************************************

This plugin is free software: you can redistribute 
it and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the License, or
later version. 

This plugin is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this plugin.  If not, see <http://www.gnu.org/licenses/>.
*************************************************************************
*************************************************************************
File Information
$Id$
$Author$
$Revision$
$Date$
$LastChangedBy$
$LastChangedDate$
$URL$
$Copyright: (c) Tf2Tmng 2009-2011$
*************************************************************************
*************************************************************************
*/
#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

#define MINI_CRIT 0
#define FULL_CRIT 1
#define NO_CRIT 2

new g_iCrits;
new g_iMelee;
new bool:g_bPreGame;

new g_iFrags[MAXPLAYERS+1];

#define PL_VERSION "1.0.0"

new Handle:g_VarTime;

enum e_RoundState
{
	newMap,
	preGame,
	normal
};
new e_RoundState:g_iRoundState;

public Plugin:myinfo = 
{
	name = "[TF2] Pregame Slaughter",
	author = "Goerge",
	description = "Funtimes for pregame round",
	version = PL_VERSION,
	url = "http://tf2tmng.googlecode.com/"
};

public OnClientConnected(client)
{
	g_iFrags[client] = 0;
}

public OnPluginStart()
{
	HookEvent("teamplay_round_start", 		Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	g_VarTime = CreateConVar("tf2_pregame_timelimit", "60", "time in seconds that pregame lasts", FCVAR_PLUGIN, true, 10.0, false);
	AutoExecConfig();
	
	CreateConVar("sm_pregame_slaughter_version", PL_VERSION, _, FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
}

public OnConfigsExecuted()
{
	SetConVarInt(FindConVar("mp_waitingforplayers_time"), GetConVarInt(g_VarTime));
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (g_bPreGame)
	{
		new iUserId = GetEventInt(event, "userid");
		new iClient = GetClientOfUserId(GetEventInt(event, "attacker"));
		if (iClient)
		{
			g_iFrags[iClient]++;
			if (!IsFakeClient(iClient))
			{
				PrintHintText(iClient, "TeamKills: %i", g_iFrags[iClient]);
			}
		}
		CreateTimer(0.3, Timer_Spawn, iUserId);
	}
	return Plugin_Continue;
}

public Action:Timer_Spawn(Handle:timer, any:userid)
{
	if (g_bPreGame)
	{
		new client = GetClientOfUserId(userid);
		if (client)
		{
			TF2_RespawnPlayer(client);
		}
	}
	return Plugin_Handled;
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	switch (g_iRoundState)
	{
		case newMap:
		{
			g_iRoundState = preGame;
		}
		case preGame:
		{
			g_iRoundState = normal;
		}
	}
	if (g_iRoundState == preGame)
	{
		StartPreGame();
	}
	else StopPreGame();
}

public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bPreGame)
		return Plugin_Continue;
	
	CreateTimer(0.2, Timer_Cond, GetEventInt(event, "userid"));
	return Plugin_Continue;
}

public Action:Timer_Cond(Handle:timer, any:userid)
{
	if (g_bPreGame)
	{
		new client = GetClientOfUserId(userid);
		if (client)
		{
			switch (g_iCrits)
			{
				case MINI_CRIT:
				{
					TF2_AddCondition(client, TFCond_Buffed, GetConVarFloat(g_VarTime));
				}
				case FULL_CRIT:
				{
					TF2_AddCondition(client, TFCond_Kritzkrieged, GetConVarFloat(g_VarTime));
				}
			}
			if (g_iMelee)
			{
				RemoveWeapons(client);
			}
			else
			{
				RemoveFlameMedi(client);
			}
			PrintToChat(client, "[SM] Pregame Slaughter is ACTIVE. KILL YOUR TEAMMATES!");
		}
	}
	return Plugin_Handled;
}

stock RemoveFlameMedi(client)
{
	new TFClassType:iClass = TF2_GetPlayerClass(client),
		iWeapon = -1;
	if (iClass == TFClass_Pyro)
	{	
		iWeapon = GetPlayerWeaponSlot(client, 0);
		if (iWeapon != -1)
		{
			TF2_RemoveWeaponSlot(client, 0);
		}
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, 1));
	}
	if (iClass == TFClass_Medic)
	{
		iWeapon = GetPlayerWeaponSlot(client, 1);
		if (iWeapon != -1)
		{
			TF2_RemoveWeaponSlot(client, 1);
		}
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, 0));
	}
}

stock RemoveWeapons(client)
{
	for (new i; i < 5; i++)
	{
		if (i != 2)
		{
			if (GetPlayerWeaponSlot(client, i))
			{
				TF2_RemoveWeaponSlot(client, i);
			}
		}
	}
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, 2));
}

stock StartPreGame()
{
	g_bPreGame = true;
	g_iCrits = GetRandomInt(0,2);
	g_iMelee = GetRandomInt(0,1);
	SetConVarBool(FindConVar("mp_friendlyfire"), true);
	SetConVarBool(FindConVar("tf_avoidteammates"), false);
	ModifyLockers("disable");
	RespawnAll();
}

stock RespawnAll()
{
	for (new i=1; i<= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) > 1 && TF2_GetPlayerClass(i) != TFClass_Unknown)
		{
			TF2_RespawnPlayer(i);
		}
	}
}

stock StopPreGame()
{
	if (g_bPreGame)
	{
		g_bPreGame = false;
		SetConVarBool(FindConVar("mp_friendlyfire"), false);
		SetConVarBool(FindConVar("tf_avoidteammates"), true);
		ModifyLockers("enable");
		CreateTimer(0.5, Timer_Winners);
		/**
		AddNotify("mp_friendlyfire");
		AddNotify("sv_tags");
		AddNotify("tf_avoidteammates");
		*/
	}
}

public Action:Timer_Winners(Handle:timer)
{
	new iRedScores[GetTeamClientCount(2)][2],
		iBluScores[GetTeamClientCount(3)][2],
		iRedCount,
		iBluCount;
	for (new i = 1; i<= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (GetClientTeam(i) == 2)
			{
				iRedScores[iRedCount][0] = i;
				iRedScores[iRedCount++][1] = g_iFrags[i];
			}
			if (GetClientTeam(i) == 3)
			{
				iBluScores[iBluCount][0] = i;
				iBluScores[iBluCount++][1] = g_iFrags[i];
			}
		}
	}
	if (iRedCount && iBluCount)
	{
		decl String:sNameBuffer[MAX_NAME_LENGTH+1];
		decl String:sBuffer[255];
		SortCustom2D(iRedScores, GetTeamClientCount(2), SortIntsDesc);
		SortCustom2D(iBluScores, GetTeamClientCount(3), SortIntsDesc);
		new Handle:hMenu = CreatePanel();
		DrawPanelText(hMenu, "Red Team Winners\n");
		for (new i; i < 3; i++)
		{
			GetClientName(iRedScores[i][0], sNameBuffer, sizeof(sNameBuffer));
			Format(sBuffer, sizeof(sBuffer), "%i  '%i' Frags: %s", i+1, iRedScores[i][1], sNameBuffer);
			DrawPanelText(hMenu, sBuffer);
		}
		DrawPanelText(hMenu, "-----------------");
		DrawPanelText(hMenu, "Blue Team Winners\n");
		for (new i; i < 3; i++)
		{
			GetClientName(iBluScores[i][0], sNameBuffer, sizeof(sNameBuffer));
			Format(sBuffer, sizeof(sBuffer), "%i  '%i' Frags: %s", i+1, iBluScores[i][1], sNameBuffer);
			DrawPanelText(hMenu, sBuffer);
		}
		DrawPanelItem(hMenu, "exit");
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				SendPanelToClient(hMenu, i, Panel_Callback, 20);
			}
		}
	}		
}

public Panel_Callback(Handle:menu, MenuAction:action, param1, param2)
{
	CloseHandle(menu);
}

public SortIntsDesc(x[], y[], array[][], Handle:data)		// this sorts everything in the info array descending
{
    if (x[1] > y[1]) 
		return -1;
    else if (x[1] < y[1]) 
		return 1;    
    return 0;
}

public OnMapStart()
{
	StripNotify("mp_friendlyfire");
	StripNotify("sv_tags");
	StripNotify("tf_avoidteammates");
	g_iRoundState = newMap;
	g_bPreGame = false;
}

stock StripNotify(const String:setting[])
{
	new Handle:hVar, iFlags;
	hVar = FindConVar(setting);
	if (hVar != INVALID_HANDLE)
	{
		iFlags = GetConVarFlags(hVar);
		if (iFlags & FCVAR_NOTIFY)
		{
			SetConVarFlags(hVar, iFlags &~FCVAR_NOTIFY);
		}
	}
}

stock AddNotify(const String:setting[])
{
	new Handle:hVar, iFlags;
	hVar = FindConVar(setting);
	if (hVar != INVALID_HANDLE)
	{
		iFlags = GetConVarFlags(hVar);
		if (!(iFlags & FCVAR_NOTIFY))
		{
			SetConVarFlags(hVar, iFlags |FCVAR_NOTIFY);
		}
	}
}

stock ModifyLockers(const String:input[]) 
{
	new iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "func_regenerate")) != -1) 
	{
		AcceptEntityInput(iEnt, input);
	}
}
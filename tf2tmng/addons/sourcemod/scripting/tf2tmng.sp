/************************************************************************
*************************************************************************
Team Manager for TF2
Description:
	Automatic scramble and balance script for TF2
*************************************************************************
*************************************************************************
TF2 Team Management Project

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
$Author$Author$ $
$Revision$
$Date$
$LastChangedBy$
$LastChangedDate$
$URL$
$Copyright: (c) TF2 Team Manager 2010-2011$
*************************************************************************
*************************************************************************
*/

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <clientprefs>
#define VERSION "$Revision$"

#undef REQUIRE_PLUGIN
#include <adminmenu>
#define REQUIRE_PLUGIN
#undef REQUIRE_EXTENSIONS
#include <clientprefs>
#define REQUIRE_EXTENSIONS


#define AUTOBALANCE
#define AUTOSCRAMBLE

#define SPECTATOR	1
#define INVLAID 	0
#define RED 		2
#define BLUE		3


#include "tf2tmng/scramble.sp"			// has all the functions that deal with the scramble portion of the plugin
#include "tf2tmng/balance.sp"			// auto-balance functions
#include "tf2tmng/convar_settings.sp"	// has all the functions that create and copy convar settings into global values
#include "tf2tmng/round_timer.sp"		// the code that keeps track of the round time remaining... since valve won't simply read from the HUD timer
#include "tf2tmng/menus.sp"				// all the stuff dealing with menus and their callbacks

enum e_clientSettings
{
	bool:bScrambleImmune,
	bool:bBalanceImmune,
	iLastConnectTime,
	iBalanceTime,
	bool:TeamChangeBlocked,
	iFrags,
	iDeaths,
	iHealing,
	bool:bHasFlag
};

enum e_TeamData
{
	/**
		Tracking fags and deaths on a per-round basis
	*/
	iFrags,
	iDeaths,
	bool:bGoal,
	iWinStreak
};

enum e_Names
{
	TeamRed,
	TeamBlue,
};

enum e_RoundState
{
	NewMap, 	// map loaded, no one has spawned yet
	Waiting 	// someone has spawned, firing the start event, now in 'waiting for players' mode
	Setup, 	// start event fires again, this map has a setup period
	Normal,	// normal play, gates opened, objectives are optainable
	Bonus,		// A team has won, one team is crit buffed, the other team is defenseless
	SuddenDeath	// Stalemate, no spawning.
};
	
new g_aTeams[e_Teams];
new g_aTeamData[e_Names][e_TeamData];
new g_aPlayers[MAXPLAYERS+1][e_clientSettings];
new bool:g_bClientPrefs;

public Plugin:myinfo = 
{
	name = "[TF2] Team Manager",
	author = "Goerge",
	description = "A comprehensive team management plugin.",
	version = VERSION,
	url = "tf2tmng.googlecode.com"
};

public OnPluginStart()
{
	
	g_bLoading = true;
	CheckGameMod();
	CheckClientPrefs();
	CreateConVars();
	LoadConVarListeners();
	RegCommands();
	HookEvents();
	CreateCookies();
	CreateMenuSettings();
	AutoExecConfig(false, "auto_scramble", "tf2tmng");
	AutoExecConfig(false, "auto_balance", "tf2tmng");
	LoadTranslations("tf2tmng.phrases");
	g_bLoading = false;
}

stock HookEvents()
{
	MyLogMessage("Hooking Events");
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("player_team", Event_PlayerTeam, EventHookMode_Pre);
	HookEvent("teamplay_round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("teamplay_setup_finished", Event_SetupFinished, EventHookMode_PostNoCopy);
	HookEvent("teamplay_round_win", Event_RoundWin, EventHookMode_Post);
	HookEvent("teamplay_round_stalemate", Event_SuddenDeath, EventHookMode_PostNoCopy);
	HookEvent("teamplay_point_captured", Event_PointCaptured, EventHookMode_Post);
	HookEvent("medic_death", Event_MedicDeath, EventHookMode_Post);
	HookEvent("player_chargedeployed", Event_UberDeploy, EventHookMode_Post);
	HookEvent("player_sapped_object", Event_Sapper, EventHookMode_Post);
	HookEvent("player_escort_score", Event_EscortScore, EventHookMode_Post);	
	HookEvent("teamplay_timer_time_added", Event_TimeAdded, EventHookMode_Post);
	HookEvent("object_destroyed", Event_ObjectDestroyed, EventHookMode_Post);
	HookUserMessage(GetUserMessageId("TextMsg"), Event_MessageTest, false);
}

stock RegCommands()
{
	RegAdminCmd("sm_scramblevote", Cmd_ScrambleVote, ADMFLAG_VOTE, "Command to start a scramble vote");
	RegAdminCmd("sm_startscramble", Cmd_StartScramble, ADMFLAG_GENERIC, "Command to start a scramble");
	RegAdminCmd("sm_forcebalance", Cmd_Forcebalance, ADMFLAG_GENERIC, "command to force a balance");
	RegAdminCmd("sm_cancelscramble", Cmd_CancelScramble, ADMFLAG_GENERIC, "Command to cancel a pending scramble");
	RegAdminCmd("sm_undoscramble", Cmd_UndoScramble, ADMFLAG_GENERIC, "Command to undo a scramble");
	RegAdminCmd("sm_block_teamchange", Cmd_BlockTeamChange, ADMFLAG_BAN, "Command to force players to remain on their teams");

}

stock CheckGameMod()
{
	decl String:sMod[5];
	GetGameFolderName(sMod, sizeof(sMod));
	if (!StrEqual(sMod, "TF", false))
	{
		SetFailState("This plugin only works on Team Fortress 2");
	}
}

stock CheckClientPrefs()
{
	decl String:sExtError[133];
	if (GetExtensionFileStatus("clientprefs.ext", sExtError, sizeof(sExtError)) == 1)
	{
		g_bClientPrefs = true;
	}
	else
	{
		LogError("The clientprefs extension is not running correctly. %s", sExtError);
	}
}

public OnConfigsExecuted()
{
	UpdateSettings();
}

public OnClientPostAdminCheck(client)
{
	LoadClient(client);
}

public OnMapStart()
{
	ResetData();
}

stock MyLogMessage(const String:message[])
{
	if (g_bLoading || GetConVarBool(g_hDetailedLog))
	{
		LogMessage("%s", message);
	}
}

/**
	events
*/
public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
		
	if (g_RoundState != normal || GetEventInt(event, "death_flags") & 32)
	{
		return Plugin_Continue;
	}
		
	new iKiller = GetClientOfUserId(GetEventInt(event, "attacker"));
		
	new	iVictim = GetClientOfUserId(GetEventInt(event, "userid"));
	g_aPlayers[iKiller][iFrags]++;
	g_aPlayers[iVictim][iDeaths]++;
	CheckForBalance(iVictim);		
	if (!iKiller || iKiller == iVictim || iKiller > MaxClients)
	{
		return Plugin_Continue;
	}		
	GetClientTeam(iKiller) == TEAM_RED ? (g_aTeams[iRedFrags]++) : (g_aTeams[iBluFrags]++);	
	return Plugin_Continue;
}
	

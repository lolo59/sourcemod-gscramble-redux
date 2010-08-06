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
#undef REQUIRE_EXTENSIONS
#include <clientprefs>


#define AUTOBALANCE
#define AUTOSCRAMBLE

#define SPECTATOR	1
#define INVLAID 	0
#define RED 		2
#define BLUE		3

#include "tf2tmng/scramble.sp"			// has all the functions that deal with the scramble portion of the plugin
#include "tf2tmng/convar_settings.sp"	// has all the functions that create and copy convar settings into global values
#include "tf2tmng/round_timer.sp"		// the code that keeps track of the round time remaining... since valve won't simply read from the HUD timer
#include "tf2tmng/menus.sp"				// all the stuff dealing with menus and their callbacks

enum e_clientSettings
{
	bool:bScrambleImmune,
	bool:bBalanceImmune,
	iConnectTime,
	iBalanceTime,
	bool:TeamChangeBlocked,
	iFrags,
	iDeaths,
	iHealing
};

enum e_TeamData
{
	/**
		Tracking fags and deaths on a per-round basis
	*/
	iFrags,
	iDeaths,
	bool:bGoal
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
	CreateConVars();
	LoadConVarListeners();
	RegCommands();
	HookEvents();
	CreateCookies();
	CreateMenuSettings();
	AutoExecConfig(false, "auto_scramble", "tf2tmng");
	AutoExecConfig(false, "auto_balance", "tf2tmng");
	LoadTranslations("tf2tmng.phrases");
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
/************************************************************************
*************************************************************************
Team Manager for TF2
	Golbal Convar Settings File
Description: 
	Creates Convars, and loads values into global functions, and handles convar hooks
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

new Handle:g_hEnabled,
	Handle:g_hDetailedLog,
	Handle:g_hRememberDisconnects,
	Handle:g_hMenuIntegration;

new Handle:g_hAutoBalance,
	Handle:g_hBalanceDelay,
	Handle:g_hTeamDifference,
	Handle:g_hSkillBalance,
	Handle:g_hSkillOVerride,
	Handle:g_hAbImmAdmin,
	Handle:g_hAbImmClass,
	Handle:g_hAbForceTeam;

new bool:g_bLoading;

stock CreateConVars()
{
	MyLogMessage("Creating ConVars");
	
	g_hEnabled	= CreateConVar("tf2tmng_enabled", "1", "If set to 0, will totally disable every automatic aspect of the plugin", true, 0.0, true, 1.0);			
	g_hDetailedLog = CreateConVar("tf2tmng_detailed_log", "1", "Enables logging in detail what the plugin is doing", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hRememberDisconnects = CreateConVar("tf2tmng_remember_disconnects", "0", "If set to 1, the plugin will remember the disconnect time if someone leaves while they are blocked from changing teams, and will force them back to their team if they reconnect", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hMenuIntegration = CreateConVar("tf2tmng_menu_integration", "1", "If set to 1, the plugin will auto-integrate into the SM admin menu", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	/**
	AUTO BALANCE VARS
	*/
	g_hAutoBalance	= CreateConVar("tf2tmng_ab_enable", "0", "Enable TF2 Team Manager's Auto-Balance feature", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hBalanceDelay	= CreateConVar("tf2tmng_ab_delay", "10", "Time, in seconds, to wait after teams are found to be imbalanced before players can be swapped", FCVAR_PLUGIN, true, 0.0, false);
	g_hTeamDifference = CreateConVar("tf2tmng_ab_team_difference", "2", "If a team has this many more players than the other team,then consider the teams un-even.", FCVAR_PLUGIN, true, 2.0, false);
	g_hSkillBalance = CreateConVar("tf2tmng_ab_skill", "0", "If enabled, will take into consideration both teams average skill and attempt to even this up", FCVAR_PLUGIN, true, 0.0, false, 1.0);
	g_hSkillOverride= CreateConVar("tf2tmng_ab_skill_override", "180", "Time, in seconds, in which if the plugin cannot fand a player to balance in skill mode where this sheck is ignored", FCVAR_PLUGIN, true, 10.0, false);
	g_hAbImmAdmin	= CreateConVar("tf2tmn_ab_admin_immunity", "1", "Enables admin immunity for auto balance", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hAbImmClass	= CreateConVar("tf2tmng_ab_class", "0", "Enables class-based immunity", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hAbForceTeam	= CreateConVar("tf2tmng_ab_forceteam", "1", "Force players to remain ont heir team after being swapped. Will block changes to spectator and the other team", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	/**
	SCRAMBLE VARS
	*/
	g_hAutoScramble = CreateConVar("tf2tmng_as_enable", "0", "Enable TF2 Team Manager's Auto-Scramble feature", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hAsRoundTrigger = CreateConVar("tf2tmng_as_round_trigger", "0", "Scrable the teams after this many rounds", FCVAR_PLUGIN, true, 0.0, false);
	g_hAsWinTrigger = CreateConVar("tf2tmng_as_win_trigger", "0", "Scramble the teams after a team wins this many rounds in a row", FCVAR_PLUGIN, true, 0.0, false);
	g_hAsFullRoundsOnly= CreateConVar("tf2tmng_as_fullround_only", "1", "Do not count a mini-round as a full round", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hAsSortMode	= CreateConVar("tf2tmng_as_sort_mode", "0", "0: random, 1: skill, 2: top-player exchange, 3: class sorting"), FCVAR_PLUGIN, true, 0.0, true 2.0);
	g_hAsRandomPercent = CreateConVar("tf2tmng_as_random_percent", "50", "Percentage of each team to randomly select for swapping"), FCVAR_PLUGIN, true, 0.0, true, 100);
	g_hAsShowStats	= CreateConVar("tf2tmng_as_show_stats", "1", "Print To Chat the scramble statistics"), FCVAR_PLUGIN, true, 0.0, true, 100);
	g_hAsForceTeam = CreateConVar("tf2tmng_as_force_team", "1", "Force players to remain on their teams after a scramble");
}
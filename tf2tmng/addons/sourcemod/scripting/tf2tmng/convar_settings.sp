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
	Handle:g_hAbForceTeam,
	Handle:g_hAbPriority,
	Handle:g_hAbPrioMode,
	Handle:g_hAbPrio_Medics,
	Handle:g_hAbPrio_Engineer,
	Handle:g_hAbPrio_Spy,
	Handle:g_hAbPrio_Scount,
	Handle:g_hAbPrio_Demo,
	Handle:g_hAbPrio_Soldier,
	Handle:g_hAbPrio_Heavy,
	Handle:g_hAbPrio_Sniper,
	Handle:g_hAbPrio_Pyro,
	Handle:g_hAbPrio_OnlyClass,
	Handle:g_hAbPrio_Admin,
	Handle:g_hAbPrio_NewPlayers,
	Handle:g_hAbPrio_NewConnectTime,
	Handle:g_hAbPrio_OldPlayers,
	Handle:g_hAbPrio_OldConnectTime,
	Handle:g_hAbPrio_Events,
	Handle:g_hAbPrio_EventsTimeLimit,
	Handle:g_hAbPrio_FlagTouch,
	Handle:g_hAbPrio_FlagCapture,
	Handle:g_hAbPrio_FlagKill,
	Handle:g_hAbPrio_CpCapture,
	Handle:g_hAbPrio_CpDefend,
	Handle:g_hAbPrio_PlCapture,
	Handle:g_hAbPrio_PlDefend,
	Handle:g_hAbPrio_PlPush,
	Handle:g_hAbPrio_DeployCharge,
	Handle:g_hAbPrio_MedicAssist,
	Handle:g_hAbPrio_KillBuilding,
	Handle:g_hAbPrio_SapBuilding,
	Handle:g_hAbPrio_KdRatio;
	

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
	g_hAbAdminImmune	= CreateConVar("tf2tmng_ab_admin_immunity", "1", "Enables admin immunity for auto balance. 0- no admin immunity, 1- admins immune, 2- admin priority", FCVAR_PLUGIN, true, 0.0, true, 2.0);
	g_hAbAdminFlags	= CreateConVar("tf2tmng_ab_admin_flags", "a", "Flag(s) for auto-balance admin immunity", FCVAR_PLUGIN);
	g_hAbImmClass	= CreateConVar("tf2tmng_ab_class", "0", "Enables class-based immunity", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hAbForceTeam	= CreateConVar("tf2tmng_ab_forceteam", "1", "Force players to remain ont heir team after being swapped. Will block changes to spectator and the other team", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	/**
	Priority cvars so admins can decide how much priority gets added for certain classes, events, and other circumstances
	*/
	g_hAbPriority = CreateConVar("tf2tmng_ab_priority", "0", "Consider a player's priority when deciding who to balance", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hAbPrioMode	= CreateConVar("tf2tmng_ab_priomode", "0", "Priority mode. 0 sonly swap people with priority <= 0. 1 only swap players with a higer priority than the unbalanced team's average. 2 only swap players with a lower priority than the unbalance'd team's average", FCVAR_PLUGIN, true, 0.0, true, 2);
	
	g_hAbPrio_Medics	= CreateConVar("tf2tmng_ab_prio_medic", "5", "Amount of priority to put on medics from -10 to 10; -10.0 being likely to be swapped, 10 being not likely to be swapped", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_Engineer = CreateConVar("tf2tmng_ab_prio_engineer", "5", "Amount of priority to put on engineers", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_Spy		= CreateConVar("tf2tmng_ab_prio_spy", "5", "Amount of priority to put on engineers", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_Scount	= CreateConVar("tf2tmng_ab_prio_scout", "5", "Amount of priority to put on engineers", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_Demo		= CreateConVar("tf2tmng_ab_prio_demo", "5", "Amount of priority to put on engineers", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_Soldier	= CreateConVar("tf2tmng_ab_prio_soldier", "5", "Amount of priority to put on engineers", FCVAR_PLUGIN, true, -10.0, true, 10.0); 
	g_hAbPrio_Heavy		= CreateConVar("tf2tmng_ab_prio_heavy", "5", "Amount of priority to put on engineers", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_Sniper	= CreateConVar("tf2tmng_ab_prio_sniper", "5", "Amount of priority to put on engineers", FCVAR_PLUGIN, true, -10.0, true, 10.0); 
	g_hAbPrio_Pyro 		= CreateConVar("tf2tmng_ab_prio_pyro", "5", "Amount of priority to put on engineers", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_OnlyClass = CreateConVar("tf2tmng_ab_prio_loneclass_add", "5", "Amount of priority to add to a class if there is just 1", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_Admin		= CreateConVar("tf2tmng_ab_prio_admin", "10", "Amount of priority to add to an admin", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_NewPlayers = CreateConVar("tf2Tmng_ab_prio_new", "-5", "Amount of priority to put on a recent connections", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_NewConnectTime = CreateConVar("tf2tmng_ab_prio_newtime", "180", "If a client has less than this many seconds in connection time, consider them a newly connected player", FCVAR_PLUGIN, true, 0.0, false);
	g_hAbPrio_OldPlayers = CreateConVar("tf2tmng_ab_prio_old", "5", "Amount of priority to put on a player who has been playing a long time", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_OldConnectTime = CreateConVar("tf2tmng_ab_prio_oldtime", "10", "If a client has this many minutes of more of connection time, then consider them an old player", FCVAR_PLUGIN, true, 0.0, false);
	/**
	Game events to consider for priority
	*/
	g_hAbPrio_Events		= CreateConVar("tf2tmng_ab_prio_enable_events", "1", "Enable prioirty event tracking", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hAbPrio_EventsTimeLimit = CreateConVar("tf2tmng_ab_prio_event_time", "60", "Time in seconds in which the event priorities remain valid after a player achieves one", FCVAR_PLUGIN, true, 0.0, false);
	g_hAbPrio_FlagTouch	= CreateConVar("tf2tmng_ab_prio_flagtouch", "5", "Amount of prioritty to put on someone touching the CTF Flag", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_FlagCapture	= CreateConVar("tf2tmng_ab_prio_flagcapture", "6", "Amount of priority to put on someone capturing the CTF Flag", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_FlagKill		= CreateConVar("tf2tmng_ab_prio_flagkill", "5", "Amount of priority to put on someone who kills the flag carrier", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	
	g_hAbPrio_CpCapture	= CreateConVar("tf2tmng_ab_prio_cpcapture", "5", "Amount of priority to put on someone who captures a control point", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_CpDefend		= CreateConVar("tf2tmng_ab_prio_cpdefend", "5", "Amount of priority to put on someone who defends a control point", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	
	g_hAbPrio_PlCapture	= CreateConVar("tf2tmng_ab_prio_plcapture", "5", "Amount of priority to put on someone who captures a payload control point", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_PlDefend		= CreateConVar("tf2tmng_ab_prio_pldefend", "5", "Amount of priority to put on someone who defends the payload cart", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_PlPush		= CreateConVar("tf2tmng_ab_prio_plpush", "2", "Amount of priority to put on someone who triggers the cart progress event", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	
	g_hAbPrio_DeployCharge = CreateConVar("tf2tmng_ab_prio_deploy", "5", "Amount of priority to put on a medic who depoys charge", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_MedicAssist = 	CreateConVar("tf2tmng_ab_prio_medicassist", "1", "Amount of priority to put on medic kill assists", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_KillBuilding = CreateConVar("tf2tmng_ab_prio_kill_building", "5", "Amount of priority to put on someone killing an engineer building", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	g_hAbPrio_SapBuilding 	= CreateConVar("tf2tmng_ab_prio_sap_building", "2", "Amount of priority to put on someone sapping an engineer building", FCVAR_PLUGIN, true, -10.0, true, 10.0);
	
	g_hAbPrio_KdRatio		= CreateConVar("tf2tmng_ab_prio_kdeath", "1", "Add a player's rounded kill-death ratio to their priority", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	
	/**
	SCRAMBLE VARS
	*/
	g_hAutoScramble = CreateConVar("tf2tmng_as_enable", "0", "Enable TF2 Team Manager's Auto-Scramble feature", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hAsRoundTrigger = CreateConVar("tf2tmng_as_round_trigger", "0", "Scrable the teams after this many rounds", FCVAR_PLUGIN, true, 0.0, false);
	g_hAsWinTrigger = CreateConVar("tf2tmng_as_win_trigger", "0", "Scramble the teams after a team wins this many rounds in a row", FCVAR_PLUGIN, true, 0.0, false);
	g_hAsFullRoundOnly = CreateConVar("tf2tmng_as_fullround_only", "1", "Do not count a mini-round as a full round", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	
	g_hAsRapeTrigger = CreateConVar("tf2tmng_as_rape_trigger", "0", "Trigger a scramble when a team rapes another team", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hAsRapeThreshold = CreateConVar("tf2tmng_as_rape_threshold", "15", "If the rape-score surpasses this, then trigger an auto-scramble", FCVAR_PLUGIN, true, 0.0, true, 50.0);
	g_hAsRapeDominations = CreateConVar("tf2tmng_as_rape_dominations", "5", "If a team has this many more dominations than the other team, add the domination rape score", FCVAR_PLUGIN, true, 0.0, false);
	g_hAsRapeDominationScore = CreateConVar("tf2tmng_as_rape_score", "5", "Score to add for the domination rape-score", FCVAR_PLUGIN, true, 0.0, true, 50.0);
	g_hAsRapeNoObjective = CreateConVar("tf2tmng_as_rape_objective", "1", "Add the rape objective score if a losing team never achieves an objective during a round", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hAsRapeNoObjectiveScore = CreateConVar("tf2tmng_as_rape_objective_score", "5", "Score to add for the rape objective trigger", FCVAR_PLUGIN, true, 0.0, true, 50.0);
	g_hAsRapeAvgScoreDiff = CreateConVar("tf2tmng_as_rape_average_score_difference", "25", "If the winning team's average score is greater than this, add this trigger's rape score", FCVAR_PLUGIN, true, 0.0, false);
	g_hAsRapeAvgScoreDiffScore = CreateConVar("tf2tmng_as_rape_average_score_diff_score", "5", "Score to add for the average score difference trigger", FCVAR_PLUGIN, true, 0.0, true, 50.0);
	g_hAsRapeTimeLimit = CreateConVar("tf2tmng_as_rape_time_limit", "60", "If a team wins a round in this amount of time (seconds) or less, add this trigger's rape score", FCVAR_PLUGIN, true, 0.0, false);
	g_hAsRapeTimeLimitScore = CreateConVar("tf2mng_as_rape_time_limit_score", "5", "Score to add for the time limit trigger", FCVAR_PLUGIN, true, 0.0, true, 50.0);
	
	g_hAsAdminImmunue = CreateConVar("tf2mng_as_admin_immune", "0", "Toggles scramble admin immunity", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hAsAdminFlags = CreateConVar("tf2tmng_as_admin_flags", "a", "Flag, or flags to consider for scramble admin immunity", FCVAR_PLUGIN);
	
	g_hAsSortMode	= CreateConVar("tf2tmng_as_sort_mode", "0", "0: random, 1: skill, 2: top-player exchange, 3: class sorting"), FCVAR_PLUGIN, true, 0.0, true 2.0);
	g_hAsRandomPercent = CreateConVar("tf2tmng_as_random_percent", "50", "Percentage of each team to randomly select for swapping"), FCVAR_PLUGIN, true, 0.0, true, 100);
	g_hAsShowStats	= CreateConVar("tf2tmng_as_show_stats", "1", "Print To Chat the scramble statistics"), FCVAR_PLUGIN, true, 0.0, true, 100);
	g_hAsForceTeam = CreateConVar("tf2tmng_as_force_team", "1", "Force players to remain on their teams after a scramble");
}
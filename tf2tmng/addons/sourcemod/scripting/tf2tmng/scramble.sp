/************************************************************************
*************************************************************************
Scramble.sp
	Contains code for detecting auto-scramble, traking how many rounds between scramble
	sort code.
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

new Handle:g_hAutoScramble 	= INVALID_HANDLE;
new Handle:g_hSortMode		= INVALID_HANDLE;
new Handle:g_hDomDiff			= INVALID_HANDLE;
new Handle:g_hTimeLimit		= INVALID_HANDLE;
new Handle:g_hTimeRatio		= INVALID_HANDLE;
new Handle:g_hTimeMinFrags	= INVALID_HANDLE;
new Handle:g_hRageLimit		= INVALID_HANDLE;
new Handle:g_hGoals			= INVALID_HANDLE;
new Handle:g_hSkill			= INVALID_HANDLE;
new Handle:g_hAction			= INVALID_HANDLE;

new Handle:g_hScrImm_Admin	= INVALID_HANDLE;
new Handle:g_hScrImm_AdmFlags = INVALID_HANDLE;
new Handle:g_hScrImm_Engy	= INVALID_HANDLE;
new Handle:g_hScrImm_Medic	= INVALID_HANDLE;

enum e_ScrambleReasons
{
	Reason_TimeLimit,
	Reason_FragDifference,
	Reason_RatioDifference,
	Reason_DominationDifference,
	Reason_TeamImbalance,
	Reason_SkillDifference,
	Reason_Goal,
	Reason_RoundTrigger,
	Reason_Vote,
	Reason_Admin,
	Reason_PreGame
};

enum e_SortModes
{
	Sort_Ranom,
	Sort_Skill,
	Sort_Ratio,
	Sort_Score,
	Sort_TopSwap,
	Sort_Class,
	Sort_ChooseRandom,
};

CreateScrambleConVars()
{
	g_hAutoScramble = CreateConVar("tf2tmng_auto_scramble", "0", "If set to 1, auto-scramble checks from the auto-scramble convars will take place", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hSortMode		= CreateConVar("tf2tmng_default_sortmode", "0", "Choose the default sort mode.\n0 is ranom.\n1 is by a computation of skill.\n3 is player kill-ratios.\4 is player scores as they are on the score board.\5 will swap the top players on each team as determined by the topswap var.\6 Sorts teams by player classes.\n7 will randomly choose a mode", FCVAR_PLUGIN, true, 0.0, true, 7.0);
	g_hDomDiff		= CreateConVar("tf2tmng_domination_trigger", "10", "Auto-scramble triggers when a team has this many more dominations than the other team.", FCVAR_PLUGIN, true, 0.0, false);
	g_hTimeLimit		= CreateConVar("tf2tmng_time_tigger", "140", "If a team wins within this threshold, trigger a scramble. Value is in seconds", FCVAR_PLUGIN, true, 0.0, false);
	g_hTimeRatio		= CreateConVar("tf2tmng_time_ratio", "1.55", "Kill ratio of the winning team vs the smaller team for the time trigger to be valid", FCVAR_PLUGIN, true, 0.0, false);
	g_hTimeMinFrags	= CreateConVar("tf2tmng_time_min_frags", "30", "Minimum amount of frags before a time trigger is valid", FCVAR_PLUGIN, true, 0.0, false);
	g_hRageLimit		= CreateConVar("tf2tmng_imbalance_scramble", "4", "If the round ends with the teams imbalanced by this many players, trigger", FCVAR_PLUGIN, true, 0.0, true, 64);
	g_hGoals			= CreateConVar("tf2tmng_goal_trigger", "0", "If a team never wins a goal (flag cap on CTF, CP on KOTH or push maps, or cp on PL race) then trigger", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hSkill			= CreateConVar("tf2tmng_skill_difference", "0", "Computes teams' skills with avg score, avg Kill ratio, and AVG connection time, then compares them.", FCVAR_PLUGIN, true, 0.0, false);
	g_hAction			= CreateConVar("tf2tmng_auto_action", "0", "Action to take if there is a trigger. 0 to scramble, 1 to start a vote", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hTriggers		= CreateConVar("tf2tmng_multiple_triggers", "1", "Number if successive triggers before an action is taken", FCVAR_PLUGIN, true, 1.0, false);

	
}

LoadScrambleSettings()
{


}
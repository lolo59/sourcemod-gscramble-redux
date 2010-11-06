/************************************************************************
*************************************************************************
Team Manager for TF2
	Autobalance.Sp
Description: 
	Functions for auto team balance
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
$Id: convar_settings.sp 19 2010-11-05 19:24:09Z brutalgoergectf $
$Author: brutalgoergectf $Author$ $
$Revision: 19 $
$Date: 2010-11-05 13:24:09 -0600 (Fri, 05 Nov 2010) $
$LastChangedBy: brutalgoergectf $
$LastChangedDate: 2010-11-05 13:24:09 -0600 (Fri, 05 Nov 2010) $
$URL: https://tf2tmng.googlecode.com/svn/trunk/tf2tmng/addons/sourcemod/scripting/tf2tmng/convar_settings.sp $
$Copyright: (c) TF2 Team Manager 2010-2011$
*************************************************************************
*************************************************************************
*/
enum e_EventPrio
{
	FlagTouch
	FlagKill
	FlagCapture
	CpCapture
	CpDefend
	PlCapture
	PlDefend
	PlPush
	DeployUber
	MedicAssist
	KillBuilding
	SapBuilding
	TeleportPlayer
	BuildBuilding
	BuffBanner
}
new g_aEventPoints[e_EventPrio];

new bool:g_bAutoBalance;
new bool:g_bPermanentPrio;
new bool:g_bEventPrio;


LoadAbSettings()
{
	g_bAutoBalance = GetConVarBool(g_hAutoBalance);
	g_bPermanentPrio = GetConVarBool(g_hAbPriority);
	g_bEventPrio = GetConVarBool(g_hAbPrio_Events);

	g_aEventPoints[FlagTouch] = GetConVarInt(g_hAbPrio_FlagTouch);
	g_aEventPoints[FlagKill] = GetConVarInt(g_hAbPrio_FlagKill);
	g_aEventPoints[FlagCapture] = GetConVarInt(g_hAbPrio_FlagCapture);
	g_aEventPoints[CpCapture] = GetConVarInt(g_hAbPrio_CpCapture);
	g_aEventPoints[CpDefend] = GetConVarInt(g_hAbPrio_CpDefend);
	g_aEventPoints[PlCapture] = GetConVarint(g_hAbPrio_PlCapture);
	g_aEventPoints[PlDefend] = GetConVarInt(g_hAbPrio_PlDefend);
	a_aEventPoints[PlPush] = GetConVarInt(g_hAbPrio_PlPush);
	g_aEventPoints[DeployUber] = GetConVarInt(g_hAbPrio_DeployUber);
	g_aEventPoints[MedicAssist] = GetConVarInt(g_hAbPrio_MedicAssist);
	g_aEventPoints[KillBuilding] = GetConVarInt(g_hAbPrio_KillBuilding);
	g_aEventPoints[SapBuilding] = GetConVarInt(g_hAbPrio_SapBuilding);
	g_aEventPoints[TeleportPlayer] = GetConVarInt(g_hAbPrio_TeleportPlayer);
	g_aEventPoints[BuildBuilding] = GetConVarInt(g_hAbPrio_BuildBuilding);
	g_aEventPoints[BuffBanner] = GetConVarInt(g_hAbPrio_BuffBanner);
	
	if (g_bAutoBalance)
	{
		if (GetConVarBool(FindConVar(mp_autoteambalance)))
		{
			MyLogMessage("Setting mp_autoteambalance to false");
			SetConVarBool(FindConVar(mp_autoteambalance), false);
		}
	}
	else
	{
		if (!GetConVarBool(FindConVar(mp_autoteambalance)))
		{
			MyLogMessage("Setting mp_autoteambalance to true");
			SetConVarBool(FindConVar(mp_autoteambalance), true);
		}
	}
}
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
enum e_EventPrio
{
	FlagTouch,
	FlagKill,
	FlagCapture,
	CpCapture,
	CpDefend,
	PlCapture,
	PlDefend,
	PlPush,
	DeployUber,
	MedicAssist,
	KillBuilding,
	SapBuilding,
	TeleportPlayer,
	BuildBuilding,
	BuffBanner
};

enum e_Prio
{
	Medic,
	Engineer,
	Spy,
	Scout,
	Demo,
	Soldier,
	Heavy,
	Sniper,
	Pyro,
	OnlyClass,
	Admin,
	NewPlayers,
	OldPlayers
};

new g_aEventPoints[e_EventPrio];
new g_aPrioPoints[e_Prio];

new bool:g_bAutoBalance;
new bool:g_bPermanentPrio;
new bool:g_bEventPrio;


LoadAbSettings()
{
	g_bAutoBalance = GetConVarBool(g_hAutoBalance);
	g_bPermanentPrio = GetConVarBool(g_hAbPriority);
	g_bEventPrio = GetConVarBool(g_hAbPrio_Events);

	/**
		class and time base priority points
	*/
	g_aEventPoints[Medic] = GetConVarInt(g_hAbPrio_Medic);
	g_aEventPoints[Engineer] = GetConVarInt(g_hAbPrio_Engineer;
	g_aEventPoints[Spy] = GetConVarInt(g_hAbPrio_Spy);
	g_aEventPoints[Scout] = GetConVarInt(g_hAbPrio_Scout);
	g_aEventPoints[Demo] = GetConVarInt(g_hAbPrio_Demo);
	g_aEventPoints[Soldier] = GetConVarInt(g_hAbPrio_Soldier);
	g_aEventPoints[Heavy] = GetConVarInt(g_hAbPrio_Heavy);
	g_aEventPoints[Sniper] = GetConVarInt(g_hAbPrio_Sniper);
	g_aEventPoints[Pyro] = GetConVarInt(g_hAbPrio_Pyro);
	g_aEventPoints[OnlyClass] = GetConVarInt(g_hAbPrio_OnlyClass);
	g_aEventPoints[Admin] = GetConVarInt(g_hAbPrio_Admin);
	g_aEventPoints[NewPlayers] = GetConVarInt(g_hAbPrio_NewPlayers);
	g_aEventPoints[OldPlayers] = GetConVarInt(g_hAbPrio_OldPlayers);
	
	/**
		event priority points
	*/
	g_aEventPoints[FlagTouch] = GetConVarInt(g_hAbPrio_FlagTouch);
	g_aEventPoints[FlagKill] = GetConVarInt(g_hAbPrio_FlagKill);
	g_aEventPoints[FlagCapture] = GetConVarInt(g_hAbPrio_FlagCapture);
	g_aEventPoints[CpCapture] = GetConVarInt(g_hAbPrio_CpCapture);
	g_aEventPoints[CpDefend] = GetConVarInt(g_hAbPrio_CpDefend);
	g_aEventPoints[PlCapture] = GetConVarint(g_hAbPrio_PlCapture);
	g_aEventPoints[PlDefend] = GetConVarInt(g_hAbPrio_PlDefend);
	g_aEventPoints[PlPush] = GetConVarInt(g_hAbPrio_PlPush);
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
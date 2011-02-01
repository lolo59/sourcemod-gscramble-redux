/************************************************************************
*************************************************************************
Tf2 Show Ammow
Description:
	Shows medics how mucha ammo the person they are healing has
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
#include <tf2>
#include <tf2_stocks>

#define PL_VERSION "1.0"

new Handle:h_HudMessage = INVALID_HANDLE;

public Plugin:myinfo = 
{
	name = "[TF2] Show My Ammo",
	author = "Goerge",
	description = "Shows medics how much ammo a person has",
	version = PL_VERSION,
	url = "http://tf2tmng.googlecode.com/"
};

public OnPluginStart()
{
	CreateConVar("medic_ammocounts_version", PL_VERSION, _, FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_SPONLY|FCVAR_DONTRECORD);
	h_HudMessage = CreateHudSynchronizer();
	CreateTimer(0.5, Timer_MedicCheck, _, TIMER_REPEAT);
}

public Action:Timer_MedicCheck(Handle:timer)
{
	CheckHealers();
	return Plugin_Continue;
}

stock CheckHealers()
{
	new iTarget;
	for (new i = 1; i <= MaxClients; i++)
	{
		iTarget = TF2_GetHealingTarget(i);
		if (iTarget > 0)
		{
			ShowInfo(i, iTarget);
		}
	}
}

stock ShowInfo(medic, target)
{
	new iSlot = TF2_GetSlotByWeapon(target);
	new iWeapon = TF2_GetCurrentWeapon(target);
	new iAmmo = TF2_GetSlotAmmo(target, iSlot);
	new iClip1 = TF2_WeaponClip(iWeapon);
	new iClip2 = TF2_WeaponClip(iWeapon, 2);
	SetHudTextParams(0.04, 0.6, 0.5, 22, 192, 255, 255);
	ShowSyncHudText(medic, h_HudMessage, "Ammo: %i, clip1: %i, clip2: %i", iAmmo, iClip1, iClip2);
}

stock TF2_GetHealingTarget(client)
{
	new String:classname[64];
	TF2_GetCurrentWeaponClass(client, classname, sizeof(classname));
	
	if(StrEqual(classname, "CWeaponMedigun"))
	{
		new index = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if( GetEntProp(index, Prop_Send, "m_bHealing") == 1 )
		{
			return GetEntPropEnt(index, Prop_Send, "m_hHealingTarget");
		}
	}
	return -1;
}

stock TF2_GetCurrentWeaponClass(client, String:name[], maxlength)
{
	if( client > 0 )
	{
		new index = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if (index > 0)
			GetEntityNetClass(index, name, maxlength);
	}
}

stock TF2_GetCurrentWeapon(any:client)
{
	if( client > 0 )
	{
		new weaponIndex = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		return weaponIndex;
	}
	return -1;
}

stock TF2_WeaponClip(weapon, clip = 1)
{
	if ( weapon != -1 )
	{
		if (clip == 1)
		{
			return GetEntProp( weapon, Prop_Send, "m_iClip1" );
		}
		else
		{
			return GetEntProp( weapon, Prop_Send, "m_iClip2" );
		}
	}
	return -1;
}

stock TF2_GetSlotAmmo(any:client, slot)
{
	if( client > 0 )
	{
		new offset = FindDataMapOffs(client, "m_iAmmo") + ((slot + 1) * 4);
		return GetEntData(client, offset, 4);
	}
	return -1;
}

stock TF2_GetSlotByWeapon(client)
{
	new weapon = TF2_GetCurrentWeapon(client);
	for (new i; i < 10; i++)
	{
		if (TF2_GetSlotWeapon(client, i) == weapon)
		{
			return i;
		}
	}
	return -1;
}

stock TF2_GetSlotWeapon(any:client, slot)
{
	if( client > 0 && slot >= 0)
	{
		new weaponIndex = GetPlayerWeaponSlot(client, slot-1);
		return weaponIndex;
	}
	return -1;
}
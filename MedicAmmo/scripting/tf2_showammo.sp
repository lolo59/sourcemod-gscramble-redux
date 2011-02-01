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

new Handle:g_hVarUpdateSpeed = INVALID_HANDLE;
new Handle:g_hVarChargeLevel = INVALID_HANDLE;

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
	g_hVarUpdateSpeed = CreateConVar("sm_showammo_update_speed", "0.5", "Delay between updates", FCVAR_PLUGIN, true, 0.1, true, 5.0);
	g_hVarChargeLevel = CreateConVar("sm_showammo_charge_level", "90.0", "Charge level where medics see ammo counts", FCVAR_PLUGIN, true, 0.0, true, 100.0);
	AutoExecConfig();
}

public OnMapStart()
{
	CreateTimer(GetConVarFloat(g_hVarUpdateSpeed), Timer_MedicCheck, _, TIMER_REPEAT);
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
		if (IsClientInGame(i)&& IsPlayerAlive(i) && !IsFakeClient(i))
		{
			iTarget = TF2_GetHealingTarget(i);
			if (iTarget > 0)
			{
				ShowInfo(i, iTarget);
			}
		}
	}
}

stock ShowInfo(medic, target)
{
	if (!TF2_IsClientUberCharged(medic))
	{
		return;
	}
	new iRed, iBlue, iGreen, TFClassType:class, iAmmo1, iAmmo2, iClip1, iClip2;
	new String:sMessage[255];
	if (GetClientTeam(medic) == 2)
	{
		iRed = 255;
	}
	else
	{
		iBlue = 255;
		iGreen = 180;
		iRed = 150;
	}
	class = TF2_GetPlayerClass(target);
	if (class == TFClass_Pyro || class == TFClass_Heavy)
	{
		iAmmo1 = GetHeavyPyroAmmo(target);
		Format(sMessage, sizeof(sMessage), "Prim Ammo: %i ", iAmmo1);
	}
	iAmmo1 = TF2_GetSlotAmmo(target, 0);
	iClip1 = TF2_WeaponClip(TF2_GetSlotWeapon(target, 0));
	iAmmo2 = TF2_GetSlotAmmo(target, 1);
	iClip2 = TF2_WeaponClip(TF2_GetSlotWeapon(target, 1));
	if (class != TFClass_Pyro && class != TFClass_Heavy)
	{
		if (iClip1 != -1)
		{
			Format(sMessage, sizeof(sMessage), "Prim Clip: %i ", iClip1);
		}
	}
	if (class == TFClass_DemoMan)
	{

		if (iClip2 != -1 && class != TFClass_Medic)
		{
			Format(sMessage, sizeof(sMessage), "%sSec Clip: %i ", sMessage, iClip2);
		}
	}	
	if (iAmmo1 != -1 && class != TFClass_Heavy && class != TFClass_Pyro)
	{
		Format(sMessage, sizeof(sMessage), "%s Prim Ammo: %i ", sMessage, iAmmo1);
	}
	if (iAmmo2 != -1 && class == TFClass_DemoMan)
	{
		Format(sMessage, sizeof(sMessage), "%sSec Ammo: %i ", sMessage, iAmmo2);
	}	
	SetHudTextParams(0.01, 0.78, 5.0, iRed, iGreen, iBlue, 255);
	ShowSyncHudText(medic, h_HudMessage, sMessage);
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

stock GetHeavyPyroAmmo(client)
{
	new ammoOffset = FindSendPropInfo("CTFPlayer", "m_iAmmo");
	return GetEntData(client, ammoOffset + 4, 4);
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
		new weaponIndex = GetPlayerWeaponSlot(client, slot);
		return weaponIndex;
	}
	return -1;
}

stock bool:TF2_IsClientUberCharged(client)
{
	if (!IsPlayerAlive(client))
		return false;
	new TFClassType:class = TF2_GetPlayerClass(client);
	if (class == TFClass_Medic)
	{			
		new entityIndex = GetPlayerWeaponSlot(client, 1);
		new Float:chargeLevel = GetEntPropFloat(entityIndex, Prop_Send, "m_flChargeLevel");
		if (chargeLevel >= GetConVarFloat(g_hVarChargeLevel))				
			return true;				
	}
	return false;
}

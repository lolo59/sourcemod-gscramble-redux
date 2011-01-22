/************************************************************************
*************************************************************************
Bonk!
Description:
	Plays the scout 'bonk' sound on melee death
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

#define PL_VERSION "1.0"
#define DMG_CLUB (1 << 7)
#define BONK "vo/scout_specialcompleted03.wav"

#include <sourcemod>
#include <sdktools>
#pragma semicolon 1

public Plugin:myinfo = 
{
	name = "[TF2] Bonk!",
	author = "Goerge",
	description = "Plays the scout BONK! sound on melee death",
	version = PL_VERSION,
	url = "http://tf2tmng.googlecode.com/"
};

public OnPluginStart()
{
	HookEvent("player_death", Event_Player_Death, EventHookMode_Post);
}

public Event_Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetEventInt(event, "death_flags") & 32)
	{
		return;
	}
	
	new iKiller = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (iKiller && iKiller <= MaxClients)
	{
		if (GetEventInt(event, "damagebits")& DMG_CLUB)
		{
			new Float:fPos[3];
			GetClientAbsOrigin(iKiller, fPos);
			EmitAmbientSound(BONK, fPos, iKiller);
		}
	}
}

public OnMapStart()
{
	PrecacheSound(BONK);
}
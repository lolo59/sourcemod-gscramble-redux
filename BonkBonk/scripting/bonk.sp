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

#define PL_VERSION "1.1"
#define BONK "vo/scout_specialcompleted03.wav"
#define DMG_CLUB (1<<7)

#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#pragma semicolon 1
new Handle:g_hCvar_SoundSetting = INVALID_HANDLE;
new Handle:g_hCvar_SpySetting 	= INVALID_HANDLE;

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
	g_hCvar_SoundSetting = CreateConVar("sm_bonksound_play", "2", "Play the bonk sound, 0 disables, 1 emits sound from the killer, 2 plays sound for everyone full volume", FCVAR_PLUGIN, true, 0.0, true, 2.0);
	g_hCvar_SpySetting = CreateConVar("sm_bonksound_ignore_spy", "0", "Ignore spies or not", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "plugin.bonk");
}

public Event_Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetEventInt(event, "death_flags") & 32)
	{
		return;
	}
	new iSetting = GetConVarInt(g_hCvar_SoundSetting);
	new iKiller = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (iKiller && iKiller <= MaxClients)
	{
		if (GetEventInt(event, "damagebits")& DMG_CLUB)
		{
			if (iSetting && !IsFakeClient(iKiller) && GetConVarInt(g_hCvar_SpySetting) && TF2_GetPlayerClass(iKiller) == TFClass_Spy)
			{
				EmitSoundToClient(iKiller, BONK);
				return;
			}
			switch (iSetting)
			{
				case 0:
				{
					return;
				}
				case 1:
				{
					new Float:fPos[3];
					GetClientAbsOrigin(iKiller, fPos);
					EmitSoundToAll(BONK,
						 iKiller,
						 SNDCHAN_AUTO,
						 SNDLEVEL_NORMAL,
						 SND_NOFLAGS,
						 SNDVOL_NORMAL,
						 SNDPITCH_NORMAL,
						-1,
						 fPos);
				}
				case 2:
				{
					EmitSoundToAll(BONK);
				}
			}
		}
	}
}

public OnMapStart()
{
	PrecacheSound(BONK);
}
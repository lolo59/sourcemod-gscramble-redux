/************************************************************************
*************************************************************************
donator menu
Description:
	Donator features on a menu
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
$Id: gscramble.sp 158 2011-12-15 21:17:06Z brutalgoergectf@gmail.com $
$Author: brutalgoergectf@gmail.com $
$Revision: 158 $
$Date: 2011-12-15 14:17:06 -0700 (Thu, 15 Dec 2011) $
$LastChangedBy: brutalgoergectf@gmail.com $
$LastChangedDate: 2011-12-15 14:17:06 -0700 (Thu, 15 Dec 2011) $
$URL: https://tf2tmng.googlecode.com/svn/trunk/gscramble/addons/sourcemod/scripting/gscramble.sp $
$Copyright: (c) Tf2Tmng 2009-2011$
*************************************************************************
*************************************************************************
*/
#pragma semicolon 1
#include <sourcemod>

public Plugin:myinfo = 
{
	name = "Donator Menu",
	author = "Goerge",
	description = "Puts donator features on a menu",
	version = "1.0",
	url = "http://tf2tmng.googlecode.com/"
};

public OnPluginStart()
{
	RegAdminCmd("sm_donator", CMD_DONATOR, ADMFLAG_GENERIC);
}

public Action:CMD_DONATOR(client, args)
{
	if (!client)
	{
		return Plugin_Handled;
	}
	new Handle:hMenu = INVALID_HANDLE;
	hMenu = CreateMenu(DonatorMenu_Callback);
	SetMenuTitle(hMenu, "Donator Menu");
	SetMenuExitButton(hMenu, true);
	AddMenuItem(hMenu, "0", "Set Gravity");
	AddMenuItem(hMenu, "1", "Set Invisibility");
	AddMenuItem(hMenu, "2", "Set Glow");
	AddMenuItem(hMenu, "3", "Explode Myself");
	AddMenuItem(hMenu, "4", "Set Your Color");
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public DonatorMenu_Callback(Handle:functionMenu, MenuAction:action, client, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			decl String:sOption[2];
			GetMenuItem(functionMenu, param2, sOption, sizeof(sOption));
			switch (StringToInt(sOption))
			{
				case 0:
					ShowGravityMenu(client);
				case 1:
					ShowInvisivilityMenu(client);
				case 2:
					ShowGlowMenu(client);
				case 3:
					ServerCommand("sm_timebomb %i", GetClientUserId(client));
				case 4:
					ShowPlayerColorMenu(client);
			}
		}	
		case MenuAction_End:
			CloseHandle(functionMenu);
	}
}

ShowGravityMenu(client)
{
	new Handle:hMenu = INVALID_HANDLE;
	hMenu = CreateMenu(GravityMenu_Callback);
	SetMenuTitle(hMenu, "Select your gravity");
	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);
	AddMenuItem(hMenu, "0.25", "Low");
	AddMenuItem(hMenu, "1.0", "Normal");
	AddMenuItem(hMenu, "1.75", "High");
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public GravityMenu_Callback(Handle:functionMenu, MenuAction:action, client, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			decl String:sOption[7];
			GetMenuItem(functionMenu, param2, sOption, sizeof(sOption));
			ServerCommand("sm_gravity #%i %f", GetClientUserId(client), StringToFloat(sOption));
		}		
		case MenuAction_End:
		{
			CloseHandle(functionMenu);
		}
	}
}

ShowInvisivilityMenu(client)
{
	new Handle:hMenu = INVALID_HANDLE;
	hMenu = CreateMenu(InvisibilityMenu_Callback);
	SetMenuTitle(hMenu, "Select your invisbility");
	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);
	AddMenuItem(hMenu, "0", "Make Me Invisible");
	AddMenuItem(hMenu, "1", "Make Me Visible");
	AddMenuItem(hMenu, "2", "Make Me Dark");
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public InvisibilityMenu_Callback(Handle:functionMenu, MenuAction:action, client, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			decl String:sOption[2];
			GetMenuItem(functionMenu, param2, sOption, sizeof(sOption));
			switch (StringToInt(sOption))
			{
				case 1:
					ServerCommand("sm_makemeinvis #%i", GetClientUserId(client));
				case 2:
					ServerCommand("sm_makemenormal #%i", GetClientUserId(client));
				case 3:
					ServerCommand("sm_makemecolored #%i 0 0 0", GetClientUserId(client));
			}
		}		
		case MenuAction_End:
		{
			CloseHandle(functionMenu);
		}
	}
}

ShowPlayerColorMenu(client)
{
	new Handle:hMenu = INVALID_HANDLE;
	hMenu = CreateMenu(ColorMenu_Callback);
	SetMenuTitle(hMenu, "Set your colour");
	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);
	AddMenuItem(hMenu, "0", "Blue");
	AddMenuItem(hMenu, "1", "Red");
	AddMenuItem(hMenu, "2", "Green");
	AddMenuItem(hMenu, "3", "Yellow");
	AddMenuItem(hMenu, "4", "Purple");
	AddMenuItem(hMenu, "5", "Remove Color");
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}
	
public ColorMenu_Callback(Handle:functionMenu, MenuAction:action, client, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			decl String:sOption[2];
			GetMenuItem(functionMenu, param2, sOption, sizeof(sOption));
			switch (StringToInt(sOption))
			{
				case 0:
					ServerCommand("sm_makemecolored #%i 0 0 255", GetClientUserId(client));
				case 1:
					ServerCommand("sm_makemecolored #%i 255 0 0", GetClientUserId(client));
				case 2:
					ServerCommand("sm_makemecolored #%i 0 255 0", GetClientUserId(client));
				case 3:
					ServerCommand("sm_makemecolored #%i 255 255 0", GetClientUserId(client));
				case 4:
					ServerCommand("sm_makemecolored #%i 255 0 255", GetClientUserId(client));
				case 5:
					ServerCommand("sm_makemecolored #%i 0 0 0", GetClientUserId(client));
			}
		}		
		case MenuAction_End:
		{
			CloseHandle(functionMenu);
		}
	}
}

ShowGlowMenu(client)
{
	new Handle:hMenu = INVALID_HANDLE;
	hMenu = CreateMenu(GlowMenu_Callback);
	SetMenuTitle(hMenu, "Set your glow colour");
	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);
	AddMenuItem(hMenu, "Red", "Red");
	AddMenuItem(hMenu, "Green", "Green");
	AddMenuItem(hMenu, "Blue", "Blue");
	AddMenuItem(hMenu, "Yellow", "Yellow");
	AddMenuItem(hMenu, "Purple", "Purple");
	AddMenuItem(hMenu, "Cyan", "Cyan");
	AddMenuItem(hMenu, "Orange", "Orange");
	AddMenuItem(hMenu, "Pink", "Pink");
	AddMenuItem(hMenu, "Olive", "Olive");
	AddMenuItem(hMenu, "Lime", "Lime");
	AddMenuItem(hMenu, "Violet", "Violet");
	AddMenuItem(hMenu, "Lightblue", "Light Blue");
	AddMenuItem(hMenu, "none", "Remove Glow");
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public GlowMenu_Callback(Handle:functionMenu, MenuAction:action, client, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			decl String:sOption[17];
			GetMenuItem(functionMenu, param2, sOption, sizeof(sOption));
			ServerCommand("sm_glowset #%i %s", GetClientUserId(client), sOption);
		}
		case MenuAction_End:
		{
			CloseHandle(functionMenu);
		}
	}
}
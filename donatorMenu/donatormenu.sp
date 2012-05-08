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
#include <clientprefs>
#include <colors>
#include <loghelper>

#define ORANGEBOX

enum
{
 	cNone = 0,
	cTeamColor,
	cGreen,
	cOlive,
	#if defined ORANGEBOX
	cYellow,
	#endif
	cRandom,
	cMax
};

new String:szColorCodes[][] = {
	"\x01", "\x03", "\x04", "\x05"
	#if defined ORANGEBOX
	, "\x06"
	#endif
};

new const String:szColorNames[cMax][] = {
	"None",
	"Team Color",
	"Green",
	"Olive",
	#if defined ORANGEBOX
	"Yellow",
	#endif
	"Random"
};

new g_iColor[MAXPLAYERS + 1];
new bool:g_bIsDonator[MAXPLAYERS + 1];
new Handle:g_hColorCookie = INVALID_HANDLE;


public Plugin:myinfo = 
{
	name = "Donator Menu",
	author = "Goerge, Nut for the colored chat",
	description = "Puts donator features on a menu",
	version = "1.0",
	url = "http://tf2tmng.googlecode.com/"
};


public Action:SayCallback(iClient, const String:szCommand[], iArgc)
{
	if (!iClient) return Plugin_Continue;
	if (!g_bIsDonator[iClient]) return Plugin_Continue;
	if(!IsClientInGame(iClient)) return Plugin_Continue;
	
	decl String:szArg[255], String:szChatMsg[255];
	GetCmdArgString(szArg, sizeof(szArg));

	StripQuotes(szArg);
	TrimString(szArg);

	if(szArg[0] == '/' || szArg[0] == '!' || szArg[0] == '@')	return Plugin_Continue;

	new iColor = g_iColor[iClient];
	if (!iColor) return Plugin_Continue;
	
	if (iColor == cRandom)
		iColor = GetRandomInt(cNone+1, cRandom-1);
	
	PrintToServer("%N: %s", iClient, szArg);
	
	if (StrEqual(szCommand, "say", true))
	{
		LogPlayerEvent(iClient, "say_team", szArg);
		FormatEx(szChatMsg, 255, "\x03%N\x01 :  %c%s", iClient, szColorCodes[iColor], szArg);
		CPrintToChatAllEx(iClient, szChatMsg);
	}
	else
	{
		LogPlayerEvent(iClient, "say", szArg);
		FormatEx(szChatMsg, 255, "(TEAM) \x03%N\x01 :  %c%s", iClient, szColorCodes[iColor], szArg);
		
		new iTeam = GetClientTeam(iClient);
		for(new i = 1; i <= MaxClients; i++)
		{
			if(!IsClientInGame(i)) continue;
			if(iTeam == GetClientTeam(i))
			CPrintToChatEx(i, iClient, szChatMsg);
		}
	}
	return Plugin_Handled;
}

public OnClientCookiesCached(client)
{
	if (!IsClientInGame(client)) return;
	if (!CheckCommandAccess(client, "sm_donator", ADMFLAG_GENERIC)) return;	
	g_iColor[client] = cNone;
	g_bIsDonator[client] = true;

	new String:szBuffer[2];
	GetClientCookie(client, g_hColorCookie, szBuffer, sizeof(szBuffer));

	if (strlen(szBuffer) > 0)
		g_iColor[client] = StringToInt(szBuffer);
}

public OnClientDisconnect(iClient)
{
	g_iColor[iClient] = cNone;
	g_bIsDonator[iClient] = false;
}

public OnPluginStart()
{
	RegAdminCmd("sm_donator", CMD_DONATOR, ADMFLAG_GENERIC);
	
	AddCommandListener(SayCallback, "say");
	AddCommandListener(SayCallback, "say_team");
	
	g_hColorCookie = RegClientCookie("donator_colorcookie", "Chat color for donators.", CookieAccess_Private);
}

public Action:CMD_DONATOR(client, args)
{
	if (!client)
	{
		return Plugin_Handled;
	}
	ShowDonatorMenu(client);
	return Plugin_Handled;
}

ShowDonatorMenu(client)
{
	new Handle:hMenu = INVALID_HANDLE;
	hMenu = CreateMenu(DonatorMenu_Callback);
	SetMenuTitle(hMenu, "Donator Menu");
	SetMenuExitButton(hMenu, true);
	AddMenuItem(hMenu, "0", "Set Gravity");
	AddMenuItem(hMenu, "1", "Set Invisibility");
	AddMenuItem(hMenu, "2", "Set Glow");
	AddMenuItem(hMenu, "3", "Explode Myself");
	AddMenuItem(hMenu, "4", "Set Your Color");
	AddMenuItem(hMenu, "5", "Set Chat Color");
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
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
					ServerCommand("sm_timebomb #%i", GetClientUserId(client));
				case 4:
					ShowPlayerColorMenu(client);
				case 5:
					ShowChatColorMenu(client);
			}
		}	
		case MenuAction_End:
			CloseHandle(functionMenu);
	}
}

ShowChatColorMenu(client)
{
	new Handle:hMenu = INVALID_HANDLE;
	hMenu = CreateMenu(ColorChatMenu_Callback);
	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);
	SetMenuTitle(hMenu, "Set Chat Color");
	decl String:szItem[4];
	for (new i = 0; i < cMax; i++)
	{
		FormatEx(szItem, sizeof(szItem), "%i", i);
		if (g_iColor[client] == i)
			AddMenuItem(hMenu, szItem, szColorNames[i], ITEMDRAW_DISABLED);
		else
			AddMenuItem(hMenu, szItem, szColorNames[i], ITEMDRAW_DEFAULT);
	}
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public ColorChatMenu_Callback(Handle:functionMenu, MenuAction:action, client, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			new iColor = param2;			
			g_iColor[client] = iColor;
			
			decl String:szColor[5];
			FormatEx(szColor, sizeof(szColor), "%i", iColor);
			SetClientCookie(client, g_hColorCookie, szColor);
			if (iColor == cRandom)
				CPrintToChat(client, "[SM]: Your new chat color is {olive}random{default}.");
			else
				CPrintToChatEx(client, client, "[SM]: %cThis is your new chat color.", szColorCodes[param2]);
		}		
		case MenuAction_End:
		{
			CloseHandle(functionMenu);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack )
				ShowDonatorMenu(client);
		}
	}
}
/*
ShowJetpackMenu(client)
{
	new Handle:hMenu = INVALID_HANDLE;
	hMenu = CreateMenu(JetpackMenu_Callback);
	SetMenuExitButton(hMenu, true);
	SetMenuExitBackButton(hMenu, true);
	SetMenuTitle(hMenu, "Turn Jetpack On/Off");
	AddMenuItem(hMenu, "0", "Toggle ON");
	AddMenuItem(hMenu, "1", "Toggle OFF");
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}


public JetpackMenu_Callback(Handle:functionMenu, MenuAction:action, client, param2)
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
					FakeClientCommand(client, "+jetpack");
				case 1:
					FakeClientCommand(client, "-jetpack");
			}
		}		
		case MenuAction_End:
		{
			CloseHandle(functionMenu);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack )
				ShowDonatorMenu(client);
		}
	}
}*/
	
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
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack )
				ShowDonatorMenu(client);
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
				case 0:
					ServerCommand("sm_makemeinvis_toggle #%i", GetClientUserId(client));
				case 1:
					ServerCommand("sm_makemenormal #%i", GetClientUserId(client));
				case 2:
					ServerCommand("sm_makemecolored #%i 0 0 0", GetClientUserId(client));
			}
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack )
				ShowDonatorMenu(client);
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
					ServerCommand("sm_makemenormal #%i", GetClientUserId(client));
			}
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack )
				ShowDonatorMenu(client);
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
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack )
				ShowDonatorMenu(client);
		}
	}
}
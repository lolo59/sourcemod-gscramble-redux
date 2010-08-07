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

new Handle:g_hEnabled;
new Handle:g_hDetailedLog;
new Handle:g_hForceTeamBalance;
new Handle:g_hForceTeamScramble;
new Handle:g_hRememberDisconnects;
new Handle:g_hMenuIntegration;

new bool:g_bLoading;

stock CreateConVars()
{
	MyLogMessage("Creating ConVars");
	
	g_hEnabled	= CreateConVar("tf2tmng_enabled", "1", "If set to 0, will totally disable every automatic aspect of the plugin", true, 0.0, true, 1.0);			
	g_hDetailedLog = CreateConVar("tf2tmng_detailed_log", "1", "Enables logging in detail what the plugin is doing", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hForceTeamScramble = CreateConVar("tf2tmng_force_team_after_scramble", "1", "If set it 1, the plugin will attempt to force players to stay on their teams after scramble", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hForceTeamBalance = CreateConVar("tf2tmng_force_team_after_balance", "1", "If set to 1, the plugin will attempt to force players to stay on their teams after balance", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hRememberDisconnects = CreateConVar("tf2tmng_remember_disconnects", "0", "If set to 1, the plugin will remember the disconnect time if someone leaves while they are blocked from changing teams, and will force them back to their team if they reconnect", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hMenuIntegration = CreateConVar("tf2tmng_menu_integration", "1", "If set to 1, the plugin will auto-integrate into the SM admin menu", FCVAR_PLUGIN, true, 0.0, true, 1.0);

}
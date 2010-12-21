#include <sourcemod>
#include <gscramble>

public OnPluginStart()
{
	RegConsoleCmd("test", Callback);
}

public Action:Callback(client, args)
{
	PrintToChat(client, "%i", TF2_GetRoundTimeLeft());
}
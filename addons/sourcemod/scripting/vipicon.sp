#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_AUTHOR "Hypr"
#define PLUGIN_VERSION "1.1"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <condostocks>
#include <autoexecconfig>

ConVar gc_sVipFlag;
ConVar gc_sIconPath;

int g_iIcon[MAXPLAYERS +1] = {-1, ...};

char g_sIconPath[256];

public Plugin myinfo = {
	name = "VIP Icon",
	author = PLUGIN_AUTHOR,
	description = "Puts a VIP-icon above the player models",
	version = PLUGIN_VERSION,
	url = "https://github.com/condolent/vip-icon"
};

public void OnPluginStart() {
	AutoExecConfig_SetFile("vipicon"); // What's the configs name and location?
	AutoExecConfig_SetCreateFile(true); // Create config if it does not exist
	
	AutoExecConfig_CreateConVar("sm_vipicon_version", PLUGIN_VERSION, "Current version running of viptag", FCVAR_DONTRECORD);
	gc_sVipFlag = AutoExecConfig_CreateConVar("sm_vipicon_flag", "a", "The flag needed for getting the VIP-icon.", FCVAR_NOTIFY);
	gc_sIconPath = AutoExecConfig_CreateConVar("sm_vipicon_path", "decals/vipicon/vip", "The path and filename for the icon", FCVAR_NOTIFY);
	
	AutoExecConfig_ExecuteFile(); // Execute the config
	AutoExecConfig_CleanFile(); // Clean the .cfg from spaces etc.
	
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	
	GetConVarString(gc_sIconPath, g_sIconPath, sizeof(g_sIconPath));
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	char admflag[64];
	GetConVarString(gc_sVipFlag, admflag, sizeof(admflag));
	
	if(IsValidClient(client)) {
		if((GetUserFlagBits(client) & ReadFlagString(admflag) == ReadFlagString(admflag))) { // Make sure the user has the correct flag(s) for the tag
			CreateIcon(client); // Sets the tag on top of the client
		}
	}
}

public void CreateIcon(int client) {
	if(!IsValidClient(client))
		return;
	
	RemoveIcon(client);
	
	char iTarget[16];
	Format(iTarget, 16, "client%d", client);
	DispatchKeyValue(client, "targetname", iTarget);
	
	g_iIcon[client] = CreateEntityByName("env_sprite");
	
	if (!g_iIcon[client]) 
		return;
	
	char iconbuffer[256];
	
	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconPath);
	
	DispatchKeyValue(g_iIcon[client], "model", iconbuffer);
	DispatchKeyValue(g_iIcon[client], "classname", "env_sprite");
	DispatchKeyValue(g_iIcon[client], "spawnflags", "1");
	DispatchKeyValue(g_iIcon[client], "scale", "0.3");
	DispatchKeyValue(g_iIcon[client], "rendermode", "1");
	DispatchKeyValue(g_iIcon[client], "rendercolor", "255 255 255");
	DispatchSpawn(g_iIcon[client]);
	
	float origin[3];
	GetClientAbsOrigin(client, origin);
	origin[2] = origin[2] + 90.0;
	
	TeleportEntity(g_iIcon[client], origin, NULL_VECTOR, NULL_VECTOR);
	SetVariantString(iTarget);
	AcceptEntityInput(g_iIcon[client], "SetParent", g_iIcon[client], g_iIcon[client], 0);
	
	SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitW);
}

public void RemoveIcon(int client) {
	if(g_iIcon[client] > 0 && IsValidEdict(g_iIcon[client])) {
		AcceptEntityInput(g_iIcon[client], "Kill");
		g_iIcon[client] = -1;
	}
}

public Action Should_TransmitW(int entity, int client) {
	char m_ModelName[PLATFORM_MAX_PATH];
	char iconbuffer[256];

	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconPath);

	GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));

	if (StrEqual(iconbuffer, m_ModelName))
	{
		return Plugin_Continue;
	}

	return Plugin_Handled;
}
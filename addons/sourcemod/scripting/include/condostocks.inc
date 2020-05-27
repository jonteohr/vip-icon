/**
* Checks several parameters to see if the specified client is a valid user.
*
* @param client				Client index
* @param bAllowBots			Allow bots?
* @param bAllowDead			Allow dead?
* @return true if valid
*/
stock bool IsValidClient(int client, bool bAllowBots = false, bool bAllowDead = false) {
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bAllowDead && !IsPlayerAlive(client))) {
		return false;
	}
	return true;
}

/**
* Downloads and precaches models/icons
*
* @param path				Path to file
*/
stock void PrecacheModelAnyDownload(char[] path) {
	if (strlen(path) == 0)
		return;

	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "materials/%s.vmt", path);
	AddFileToDownloadsTable(sBuffer);
	PrecacheModel(sBuffer, true);
	Format(sBuffer, sizeof(sBuffer), "materials/%s.vtf", path);
	AddFileToDownloadsTable(sBuffer);
	PrecacheModel(sBuffer, true);
}

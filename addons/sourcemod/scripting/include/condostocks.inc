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
* Downloads and precaches material files (icons..)
*
* @param path				Path to file in /materials/
*/
stock void PrecacheMaterialAnyDownload(char[] path) {
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

/**
* Downloads and precaches sounds
*
* @param path				Path to file in /materials/
*/
stock void PrecacheSoundAnyDownload(char[] path) {
	if (strlen(path) == 0)
		return;

	char sBuffer[256];
	PrecacheSoundAny(path);
	Format(sBuffer, sizeof(sBuffer), "sound/%s", path);
	AddFileToDownloadsTable(sBuffer);
}
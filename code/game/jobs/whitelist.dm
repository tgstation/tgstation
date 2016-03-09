<<<<<<< HEAD:code/modules/jobs/whitelist.dm
#define WHITELISTFILE "data/whitelist.txt"

var/list/whitelist

/proc/load_whitelist()
	whitelist = file2list(WHITELISTFILE)
	if(!whitelist.len)
		whitelist = null

/proc/check_whitelist(mob/M /*, var/rank*/)
	if(!whitelist)
		return 0
	return ("[M.ckey]" in whitelist)

=======
#define WHITELISTFILE "data/whitelist.txt"

var/list/whitelist

/proc/load_whitelist()
	whitelist = file2list(WHITELISTFILE)
	if(!whitelist.len)	whitelist = null

/proc/check_whitelist(mob/M /*, var/rank*/)
	if(!whitelist)
		return 0
	return ("[M.ckey]" in whitelist)

>>>>>>> dbd4169c0e4c4afad12aa45d35bc095f56f20461:code/game/jobs/whitelist.dm
#undef WHITELISTFILE
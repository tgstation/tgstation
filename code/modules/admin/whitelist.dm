#define WHITELISTFILE "[global.config.directory]/whitelist.txt"

GLOBAL_LIST_INIT(whitelist,world.file2list("config/whitelist.txt")) 
GLOBAL_PROTECT(whitelist)


/proc/check_whitelist(var/ckey)
	if(!GLOB.whitelist)
		return FALSE
	. = (ckey in GLOB.whitelist)

#undef WHITELISTFILE

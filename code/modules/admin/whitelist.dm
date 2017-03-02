#define WHITELISTFILE "config/whitelist.txt"

var/list/whitelist

/proc/load_whitelist()
	whitelist = list()
	for(var/line in file2list(WHITELISTFILE))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		whitelist += line

	if(!whitelist.len)
		whitelist = null

/proc/check_whitelist(var/ckey)
	if(!whitelist)
		return FALSE
	. = (ckey in whitelist)

#undef WHITELISTFILE

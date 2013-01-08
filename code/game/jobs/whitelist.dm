#define WHITELISTFILE "data/whitelist.txt"

var/list/whitelist = list()

/proc/load_whitelist()
	whitelist = file2list(WHITELISTFILE)
	if(!whitelist.len)	whitelist = null

/proc/check_whitelist(mob/M /*, var/rank*/)
	if(!whitelist)
		return 0
	return ("[M.ckey]" in whitelist)

var/list/alien_whitelist = list()

proc/load_alienwhitelist()
	var/text = file2text("config/alienwhitelist.txt")
	if (!text)
		diary << "Failed to load config/alienwhitelist.txt\n"
	else
		alien_whitelist = text2list(text, "\n")

//todo: admin aliens
/proc/is_alien_whitelisted(mob/M, var/species)
	if(!alien_whitelist)
		return 0
	if(M && species)
		for (var/s in alien_whitelist)
			if(findtext(s,"[M.ckey] - [species]"))
				return 1
			if(findtext(s,"[M.ckey] - All"))
				return 1

	return 0

#undef WHITELISTFILE
var/list/whitelist

#define WHITELISTFILE "data/whitelist.txt"
/proc/load_whitelist()
	var/text = file2text(WHITELISTFILE)
	if (!text)
		diary << "Failed to [WHITELISTFILE]\n"
	else
		whitelist = dd_text2list(text, "\n")

/proc/check_whitelist(mob/M /*, var/rank*/)
	if(!whitelist)
		return 0
	return ("[M.ckey]" in whitelist)

#undef WHITELISTFILE

proc/load_alienwhitelist()
	var/text = file2text("config/alienwhitelist.txt")
	if (!text)
		diary << "Failed to load config/alienwhitelist.txt\n"
	else
		alien_whitelist = dd_text2list(text, "\n")

/proc/is_alien_whitelisted(mob/M, var/species)
	if(!alien_whitelist)
		return
	if((M.client) && (M.client.holder) && (M.client.holder.level) && (M.client.holder.level >= 5))
		return 1
	if(M && species)
		for (var/s in alien_whitelist)
			if(findtext(s,"[M.ckey] - [species]"))
				return 1
		return 0

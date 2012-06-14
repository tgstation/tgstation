#define WHITELISTFILE "data/whitelist.txt"

var/list/whitelist

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
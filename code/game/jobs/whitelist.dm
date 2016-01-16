#define WHITELISTFILE "data/whitelist.txt"

var/list/whitelist = list()

/proc/load_whitelist()
	whitelist = file2list(WHITELISTFILE)
	if(!whitelist.len)	whitelist = null

/proc/check_whitelist(mob/M /*, var/rank*/)
	if(!whitelist)
		return 0
	return ("[M.ckey]" in whitelist)

// species = list("ckey","ckey")
var/global/list/alien_whitelist = list()

/proc/load_alienwhitelist()
	alien_whitelist=list()
	alien_whitelist["all"]=list()
	var/text = file2text("config/alienwhitelist.txt")
	if (!text)
		diary << "Failed to load config/alienwhitelist.txt\n"
	else
		for(var/line in text2list(text, "\n"))
			if(dd_hasprefix(line,"#"))
				continue
			if(!findtext(line,"-"))
				continue
			var/list/parts=text2list(line,"-")
			var/ckey=trim(lowertext(parts[1]))
			var/specieslist=text2list(parts[2],",")
			for(var/species in specieslist)
				species=lowertext(trim(species))
				if(!(species in alien_whitelist))
					alien_whitelist[species]=list()
				if(!(ckey in alien_whitelist[species]))
					alien_whitelist[species] += ckey
	//for(var/species in alien_whitelist)
	//	for(var/ckey in alien_whitelist[species])
	//		testing("[ckey] - [species]")

//todo: admin aliens
/proc/is_alien_whitelisted(mob/M, var/species)
	if(!config.usealienwhitelist)
		return 1

	species=lowertext(species)

	if(species == "human")
		return 1

	if(check_rights(R_ADMIN, 0))
		return 1

	if(!alien_whitelist)
		return 0

	// Species is in whitelist
	if("*" in alien_whitelist[species])
		return 1

	// CKey is in whitelist
	if(M.ckey in alien_whitelist[species] || M.ckey in alien_whitelist["all"])
		return 1

	// Occupation is in whitelist (for lizard janitors :V)
	if("job=[lowertext(M.mind.assigned_role)]" in alien_whitelist[species]\
	|| "job=[lowertext(M.mind.assigned_role)]" in alien_whitelist["all"])
		return 1

	return 0

/proc/has_whitelist_entries(var/species)
	if(!config.usealienwhitelist)
		return 1
	species=lowertext(species)
	return species in alien_whitelist

#undef WHITELISTFILE
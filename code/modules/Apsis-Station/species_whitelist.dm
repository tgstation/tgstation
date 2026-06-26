// Apsis-Station DOWNSTREAM - per-species ckey whitelists
// Whitelisted species are blacklisted for everyone except approved ckeys
// Whitelist files live in config/ and are hot-reloadable between rounds
//Refer to species_overrides.dm for the whitelist file names.

// Cache so config files are only read once per round startup
GLOBAL_LIST_EMPTY(species_whitelist_cache)

//Reads a config whitelist file and returns an assoc list of ckeys.
//Returns empty list if file doesn't exist (safe default = all blocked).
//Cache is populated once and reused for the round.
/proc/get_species_whitelist(filename)
	var/list/cache = GLOB.species_whitelist_cache
	if(cache[filename])
		return cache[filename]

	var/list/allowed = list()
	var/filepath = "config/[filename]"

	if(fexists(filepath))
		var/file_data = file2text(filepath)
		for(var/line in splittext(file_data, "\n"))
			line = trim(line)
			if(!line || text2ascii(line, 1) == 35)
				continue
			allowed[ckey(line)] = TRUE
	cache[filename] = allowed
	return allowed

//Returns TRUE if the given client's ckey is in the given whitelist file.
//Safe to call with null client (returns FALSE).
/proc/ckey_in_species_whitelist(client/C, filename)
	if(!C)
		return FALSE
	var/list/whitelist = get_species_whitelist(filename)
	var/result = (ckey(C.ckey) in whitelist)
	return result

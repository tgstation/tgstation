// Apsis-Station DOWNSTREAM - per-species ckey whitelists
// Whitelisted species are blacklisted for everyone except approved ckeys
// Whitelist files live in config/ and are hot-reloadable between rounds

/// Cache so config files are only read once per round startup
var/list/GLOB.species_whitelist_cache = list()

/**
 * Reads a config whitelist file and returns an assoc list of ckeys.
 * Returns empty list if file doesn't exist (safe default = all blocked).
 * Cache is populated once and reused for the round.
 */
 /proc/get_species_whitelist(filename)
 	if(GLOB.species_whitelist_cache[filename])
 		return GLOB.species_whitelist_cache[filename]

 	var/list/allowed = list()
	var/filepath = "config/[filename]"

	if(fexists(filepath))
		var/file_data = file2text(filepath)
		for(var/line in splittext(file_data, "\n"))
			line = trim(line)
			// Skip blank lines and # comments
			if(!line || (length(line) > 0 && text2ascii(line, 1) == 35))
				continue
			allowed[ckey(line)] = TRUE

	GLOB.species_whitelist_cache[filename] = allowed
	return allowed

/**
 * Returns TRUE if the player mob's ckey is in the given whitelist file.
 * Safe to call with null client (returns FALSE).
 */
/proc/ckey_in_species_whitelist(mob/living/carbon/human/player, filename)
	if(!player?.client)
		return FALSE
	var/list/whitelist = get_species_whitelist(filename)
	return (ckey(player.client.ckey) in whitelist)

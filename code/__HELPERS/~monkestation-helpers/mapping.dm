/proc/are_zs_connected(atom/a, atom/b)
	a = get_turf(a)
	b = get_turf(b)
	if(a.z == b.z)
		return TRUE
	return (b.z in SSmapping.get_connected_levels(a))

/// Trims "directional/dir" suffixes from typepaths.
/proc/trim_directional_helper_suffix(typepath)
	if(!ispath(typepath))
		CRASH("Passed non-typepath [typepath] to trim_directional_helper_suffix")
	var/static/regex/directional_helper_regex
	if(!directional_helper_regex)
		directional_helper_regex = new(@"\/directional\/(north|south|east|west)$")
	var/replaced = replacetext("[typepath]", directional_helper_regex, "")
	return text2path(replaced) || typepath

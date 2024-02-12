/*
	This replaces area names that contain nautical terms (fore, port, aft, starboard) with the corresponding cardinal directions,
	so that the map can be more easily navigated. It also combines cardinal directions that are next to each other into a single word.
	"[dir] Bow" and "[dir] Quarter" are also replaced with the corresponding ordinal directions.
*/
/area
	var/auto_renamed

/area/New()
	// using unicode (x_char) procs here bc I'm scared of how the normal versions might interact with \improper and such
	var/static/regex/check_regex = regex(@"Fore|Port|Aft|Starboard|Quarter|Bow")
	var/static/regex/combine_regex = regex(@"(North|South|West|East) (North|South|West|East)", "ig")
	if(check_regex.Find(name))
		// corners first
		name = replacetextEx_char(name, "Port Bow", "Northwest")
		name = replacetextEx_char(name, "Starboard Bow", "Northeast")
		name = replacetextEx_char(name, "Port Quarter", "Southwest")
		name = replacetextEx_char(name, "Starboard Quarter", "Southeast")
		// then the rest
		name = replacetextEx_char(name, "Fore", "North")
		name = replacetextEx_char(name, "Aft", "South")
		name = replacetextEx_char(name, "Port", "West")
		name = replacetextEx_char(name, "Starboard", "East")
		// change stuff like "North East" to "Northeast"
		name = combine_regex.Replace_char(name, GLOBAL_PROC_REF(combine_area_names))
		auto_renamed = name
	return ..()

/area/get_original_area_name()
	if(auto_renamed)
		if(name == auto_renamed)
			return name
		return "[name] ([auto_renamed])"
	return ..()

/proc/combine_area_names(match, a, b)
	return "[a][lowertext(b)]"

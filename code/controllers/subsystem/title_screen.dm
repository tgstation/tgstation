var/datum/subsystem/title/SStitle

/datum/subsystem/title
	name = "Title Screen"
	init_order = INFINITY //It's the very first thing you see, don't make it wait!
	flags = SS_NO_FIRE
	var/turf/closed/indestructible/splashscreen/title_screen


/datum/subsystem/title/New()
	NEW_SS_GLOBAL(SStitle)

/datum/subsystem/title/Initialize()
	var/list/provisional_title_screens = flist("config/title_screens/images/")
	var/list/title_screens = list()
	var/use_rare_screens = FALSE

	if(!title_screen)
		return

	if(prob(1))
		use_rare_screens = TRUE

	for(var/S in provisional_title_screens)
		var/list/L = splittext(S,"+")
		if((L.len == 1 && L[1] != "blank.png")|| (L.len > 1 && ((use_rare_screens && lowertext(L[1]) == "rare") || (lowertext(L[1]) == lowertext(MAP_NAME)))))
			title_screens += S

	if(!isemptylist(title_screens))
		if(length(title_screens) > 1)
			for(var/S in title_screens)
				var/list/L = splittext(S,".")
				if(L.len != 2 || L[1] != "default")
					continue
				title_screens -= S
				break

		var/path_string = "config/title_screens/images/[pick(title_screens)]"
		var/icon/screen_to_use = new(path_string)

		title_screen.icon = screen_to_use
var/datum/controller/subsystem/title/SStitle

/datum/controller/subsystem/title
	name = "Title Screen"
	init_order = 15
	flags = SS_NO_FIRE
	var/turf/closed/indestructible/splashscreen/title_screen

/datum/controller/subsystem/title/New()
	NEW_SS_GLOBAL(SStitle)

/datum/controller/subsystem/title/Initialize()
	var/list/provisional_title_screens = flist("config/title_screens/images/")
	var/list/title_screens = list()
	var/use_rare_screens = FALSE

	if(title_screen)
		if(prob(1))
			use_rare_screens = TRUE

		for(var/S in provisional_title_screens)
			var/list/L = splittext(S,"+")
			if((L.len == 1 && L[1] != "blank.png")|| (L.len > 1 && ((use_rare_screens && lowertext(L[1]) == "rare") || (lowertext(L[1]) == lowertext(SSmapping.config.map_name)))))
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
	..()
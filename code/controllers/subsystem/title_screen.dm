var/datum/subsystem/title/SStitle

/datum/subsystem/title
	name = "Title Screen"
	init_order = INFINITY //It's the very first thing you see, don't make it wait!
	flags = SS_NO_FIRE
	var/turf/closed/indestructible/splashscreen/title_screen


/datum/subsystem/title/New()
	NEW_SS_GLOBAL(SStitle)

/datum/subsystem/title/Initialize()
	var/list/provisional_title_screens = icon_states(icon('config/title_screens/title_screens.dmi'))
	var/list/title_screens = list()
	var/use_rare_screens = FALSE

	if(!title_screen)
		return

	if(prob(1))
		use_rare_screens = TRUE

	for(var/S in provisional_title_screens)
		var/list/L = splittext(S,"+")
		if(L.len == 1 || (L.len > 1 && ((use_rare_screens && lowertext(L[1]) == "rare") || (lowertext(L[1]) == lowertext(MAP_NAME)))))
			title_screens += S

	if(!isemptylist(title_screens))
		if(length(title_screens) > 1 && "default" in title_screens)
			title_screens -= "default"
		title_screen.icon_state = pick(title_screens)
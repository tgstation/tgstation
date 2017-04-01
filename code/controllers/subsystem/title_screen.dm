var/datum/controller/subsystem/title/SStitle

/datum/controller/subsystem/title
	name = "Title Screen"
	flags = SS_NO_FIRE|SS_NO_INIT

	var/file_path
	var/icon/icon
	var/icon/previous_icon
	var/turf/closed/indestructible/splashscreen/splash_turf

/datum/controller/subsystem/title/New()
	NEW_SS_GLOBAL(SStitle)

	if(file_path && icon)
		return

	if(fexists("data/previous_title.dat"))
		previous_icon = new("data/previous_title.dat")
		fdel("data/previous_title.dat")	//linger not

	var/list/provisional_title_screens = flist("config/title_screens/images/")
	var/list/title_screens = list()
	var/use_rare_screens = prob(1)

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

		file_path = "config/title_screens/images/[pick(title_screens)]"
		icon = new(file_path)

		if(splash_turf)
			splash_turf.icon = icon

/datum/controller/subsystem/title/Shutdown()
	if(file_path)
		fcopy(file_path, "data/previous_title.dat")

/datum/controller/subsystem/title/Recover()
	icon = SStitle.icon
	splash_turf = SStitle.splash_turf
	file_path = SStitle.file_path
	previous_icon = SStitle.previous_icon
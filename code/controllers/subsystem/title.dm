SUBSYSTEM_DEF(title)
	name = "Title Screen"
	flags = SS_NO_FIRE|SS_NO_INIT

	var/file_path
	var/icon/icon
	var/turf/closed/indestructible/splashscreen/splash_turf

/datum/controller/subsystem/title/PreInit()
	if(file_path && icon)
		return

	var/list/provisional_title_screens = flist("[global.config.directory]/title_screens/images/")
	var/list/title_screens = list()
	var/use_rare_screens = prob(1)

	for(var/S in provisional_title_screens)
		var/list/L = splittext(S,"+")
		if((L.len == 1 && L[1] != "blank.png")|| (L.len > 1 && ((use_rare_screens && lowertext(L[1]) == "rare") || (lowertext(L[1]) == lowertext(SSmapping.config.map_name)))))
			title_screens += S

	if(length(title_screens))
		file_path = "[global.config.directory]/title_screens/images/[pick(title_screens)]"
	
	if(!file_path)
		file_path = "icons/default_title.dmi"

	ASSERT(fexists(file_path))

	icon = new(fcopy_rsc(file_path))

	if(splash_turf)
		splash_turf.icon = icon

/datum/controller/subsystem/title/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, icon))
				if(splash_turf)
					splash_turf.icon = icon
				for(var/I in GLOB.lobby_players)
					var/mob/living/carbon/human/lobby/player = I
					player.splash_screen.icon = icon

/datum/controller/subsystem/title/Shutdown()
	for(var/thing in GLOB.clients)
		if(!thing)
			continue
		var/obj/screen/splash/S = new(thing, FALSE)
		S.Fade(FALSE,FALSE)

/datum/controller/subsystem/title/Recover()
	icon = SStitle.icon
	splash_turf = SStitle.splash_turf
	file_path = SStitle.file_path

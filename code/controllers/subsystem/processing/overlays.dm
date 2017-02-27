var/datum/subsystem/processing/overlays/SSoverlays

/datum/subsystem/processing/overlays
	name = "Overlay"
	flags = SS_TICKER|SS_FIRE_IN_LOBBY
	wait = 1
	priority = 500
	init_order = -6

	stat_tag = "Ov"
	delegate = /atom/.proc/compile_overlays
	fire_if_empty = TRUE

	var/list/overlay_icon_state_caches
	var/initialized = FALSE

/datum/subsystem/processing/overlays/New()
	NEW_SS_GLOBAL(SSoverlays)
	LAZYINITLIST(overlay_icon_state_caches)

/datum/subsystem/processing/overlays/Initialize()
	initialized = TRUE
	for(var/I in processing_list)
		var/atom/A = I
		A.compile_overlays()
		CHECK_TICK
	processing_list.Cut()
	..()

/datum/subsystem/processing/overlays/Recover()
	overlay_icon_state_caches = SSoverlays.overlay_icon_state_caches
	..(SSoverlays)

/datum/subsystem/processing/overlays/fire(resumed)
	if(run_cache.len)
		run_cache += processing_list
		processing_list.Cut()
	else
		run_cache = processing_list
		processing_list = list()
	..(TRUE)

/atom/proc/compile_overlays()
	if(LAZYLEN(priority_overlays) && LAZYLEN(our_overlays))
		overlays = our_overlays + priority_overlays
	else if(LAZYLEN(our_overlays))
		overlays = our_overlays
	else if(LAZYLEN(priority_overlays))
		overlays = priority_overlays
	else
		overlays.Cut()
	return PROCESS_KILL

/atom/proc/iconstate2appearance(iconstate)
	var/static/image/stringbro = new()
	var/list/icon_states_cache = SSoverlays.overlay_icon_state_caches 
	var/list/cached_icon = icon_states_cache[icon]
	if (cached_icon)
		var/cached_appearance = cached_icon["[iconstate]"]
		if (cached_appearance)
			return cached_appearance
	stringbro.icon = icon
	stringbro.icon_state = iconstate
	if (!cached_icon) //not using the macro to save an associated lookup
		cached_icon = list()
		icon_states_cache[icon] = cached_icon
	var/cached_appearance = stringbro.appearance
	cached_icon["[iconstate]"] = cached_appearance
	return cached_appearance

/atom/proc/cut_overlays(priority = FALSE)
	var/list/cached_overlays = our_overlays
	var/list/cached_priority = priority_overlays
	
	var/need_compile = FALSE

	if(LAZYLEN(cached_overlays)) //don't queue empty lists, don't cut priority overlays
		cached_overlays.Cut()  //clear regular overlays
		need_compile = TRUE

	if(priority && LAZYLEN(cached_priority))
		cached_priority.Cut()
		need_compile = TRUE

	if(need_compile)
		SSoverlays.start_processing(src)

/atom/proc/cut_overlay(list/overlays, priority)
	var/static/image/appearance_bro = new()
	if(!overlays)
		return

	if (!islist(overlays))
		overlays = list(overlays)
	else
		listclearnulls(overlays)
	for (var/i in 1 to length(overlays))
		if (istext(overlays[i]))
			overlays[i] = iconstate2appearance(overlays[i])
		else
			var/image/I = overlays[i]
			appearance_bro.appearance = overlays[i]
			appearance_bro.dir = I.dir
			overlays[i] = appearance_bro.appearance

	var/list/cached_overlays = our_overlays	//sanic
	var/list/cached_priority = priority_overlays
	var/init_o_len = LAZYLEN(cached_overlays)
	var/init_p_len = LAZYLEN(cached_priority)  //starter pokemon

	LAZYREMOVE(cached_overlays, overlays)
	if(priority)
		LAZYREMOVE(cached_priority, overlays)

	if((init_o_len != LAZYLEN(cached_priority)) || (init_p_len != LAZYLEN(cached_overlays)))
		SSoverlays.start_processing(src)

/atom/proc/add_overlay(list/overlays, priority = FALSE)
	var/static/image/appearance_bro = new()
	if(!overlays)
		return

	if (!islist(overlays))
		overlays = list(overlays)
	else
		listclearnulls(overlays)
	for (var/i in 1 to length(overlays))
		if (istext(overlays[i]))
			overlays[i] = iconstate2appearance(overlays[i])
		else
			var/image/I = overlays[i]
			appearance_bro.appearance = overlays[i]
			appearance_bro.dir = I.dir
			overlays[i] = appearance_bro.appearance

	LAZYINITLIST(our_overlays)	//always initialized after this point
	LAZYINITLIST(priority_overlays)

	var/list/cached_overlays = our_overlays	//sanic
	var/list/cached_priority = priority_overlays
	var/init_o_len = cached_overlays.len
	var/init_p_len = cached_priority.len  //starter pokemon
	var/need_compile

	if(priority)
		cached_priority += overlays  //or in the image. Can we use [image] = image?
		need_compile = init_p_len != cached_priority.len
	else
		cached_overlays += overlays
		need_compile = init_o_len != cached_overlays.len

	if(need_compile) //have we caught more pokemon?
		SSoverlays.start_processing(src)

/atom/proc/copy_overlays(atom/other, cut_old = FALSE)	//copys our_overlays from another atom
	if(!other)
		if(cut_old)
			cut_overlays()
		return
	
	var/list/cached_other = other.our_overlays
	if(cached_other)
		if(cut_old)
			our_overlays = cached_other.Copy()
		else
			our_overlays |= cached_other
		SSoverlays.start_processing(src)
	else if(cut_old)
		cut_overlays()

//TODO: Better solution for these?
/image/proc/add_overlay(x)
	overlays += x

/image/proc/cut_overlay(x)
	overlays -= x

/image/proc/cut_overlays(x)
	overlays.Cut()

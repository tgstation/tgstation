var/datum/subsystem/processing/overlays/SSoverlays

/datum/subsystem/processing/overlays
	name = "Overlay"
	flags = SS_TICKER|SS_FIRE_IN_LOBBY
	wait = 1
	priority = 500
	init_order = -6

	stat_tag = "Ov"
	currentrun = null
	var/list/overlay_icon_state_caches
	var/initialized = FALSE

/datum/subsystem/processing/overlays/New()
	NEW_SS_GLOBAL(SSoverlays)
	LAZYINITLIST(overlay_icon_state_caches)

/datum/subsystem/processing/overlays/Initialize()
	initialized = TRUE
	for(var/I in processing)
		var/atom/A = I
		A.compile_overlays()
		CHECK_TICK
	..()

/datum/subsystem/processing/overlays/Recover()
	overlay_icon_state_caches = SSoverlays.overlay_icon_state_caches
	processing = SSoverlays.processing

/datum/subsystem/processing/overlays/fire()
	while(processing.len)
		var/atom/thing = processing[processing.len]
		processing.len--
		if(thing)
			thing.compile_overlays(FALSE)
		if(MC_TICK_CHECK)
			break

/atom/proc/compile_overlays()
	if(LAZYLEN(priority_overlays) && LAZYLEN(our_overlays))
		overlays = our_overlays + priority_overlays
	else if(LAZYLEN(our_overlays))
		overlays = our_overlays
	else if(LAZYLEN(priority_overlays))
		overlays = priority_overlays
	else
		overlays.Cut()
	flags &= ~OVERLAY_QUEUED

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

#define NOT_QUEUED_ALREADY (!(flags & OVERLAY_QUEUED))
#define QUEUE_FOR_COMPILE flags |= OVERLAY_QUEUED; SSoverlays.processing += src; 
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

	if(NOT_QUEUED_ALREADY && need_compile)
		QUEUE_FOR_COMPILE

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

	if(NOT_QUEUED_ALREADY && ((init_o_len != LAZYLEN(cached_priority)) || (init_p_len != LAZYLEN(cached_overlays))))
		QUEUE_FOR_COMPILE

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

	if(NOT_QUEUED_ALREADY && need_compile) //have we caught more pokemon?
		QUEUE_FOR_COMPILE

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
		if(NOT_QUEUED_ALREADY)
			QUEUE_FOR_COMPILE
	else if(cut_old)
		cut_overlays()

#undef NOT_QUEUED_ALREADY
#undef QUEUE_FOR_COMPILE

//TODO: Better solution for these?
/image/proc/add_overlay(x)
	overlays += x

/image/proc/cut_overlay(x)
	overlays -= x

/image/proc/cut_overlays(x)
	overlays.Cut()
PROCESSING_SUBSYSTEM_DEF(overlays)
	name = "Overlay"
	flags = SS_TICKER
	wait = 1
	priority = 500
	init_order = INIT_ORDER_OVERLAY
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_SETUP

	stat_tag = "Ov"
	currentrun = null
	var/list/overlay_icon_state_caches
	var/list/overlay_icon_cache
	var/initialized = FALSE

/datum/controller/subsystem/processing/overlays/PreInit()
	LAZYINITLIST(overlay_icon_state_caches)
	LAZYINITLIST(overlay_icon_cache)

/datum/controller/subsystem/processing/overlays/Initialize()
	initialized = TRUE
	Flush()
	..()

/datum/controller/subsystem/processing/overlays/Recover()
	overlay_icon_state_caches = SSoverlays.overlay_icon_state_caches
	overlay_icon_cache = SSoverlays.overlay_icon_cache
	processing = SSoverlays.processing

/datum/controller/subsystem/processing/overlays/fire(resumed = FALSE, mc_check = TRUE)
	var/list/processing = src.processing
	while(processing.len)
		var/atom/thing = processing[processing.len]
		processing.len--
		if(thing)
			thing.compile_overlays()
		if(mc_check)
			if(MC_TICK_CHECK)
				break
		else
			CHECK_TICK

/datum/controller/subsystem/processing/overlays/proc/Flush()
	if(processing.len)
		testing("Flushing [processing.len] overlays")
		fire(mc_check = FALSE)	//pair this thread up with the MC to get extra compile time

/atom/proc/compile_overlays()
	var/list/oo = our_overlays
	var/list/po = priority_overlays
	if(LAZYLEN(po) && LAZYLEN(oo))
		overlays = oo + po
	else if(LAZYLEN(oo))
		overlays = oo
	else if(LAZYLEN(po))
		overlays = po
	else
		overlays.Cut()
	flags &= ~OVERLAY_QUEUED

/proc/iconstate2appearance(icon, iconstate)
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

/proc/icon2appearance(icon)
	var/static/image/iconbro = new()
	var/list/icon_cache = SSoverlays.overlay_icon_cache
	. = icon_cache[icon]
	if (!.)
		iconbro.icon = icon
		. = iconbro.appearance
		icon_cache[icon] = .

/atom/proc/build_appearance_list(new_overlays)
	var/static/image/appearance_bro = new()
	if (!islist(new_overlays))
		new_overlays = list(new_overlays)
	else
		listclearnulls(new_overlays)
	for (var/i in 1 to length(new_overlays))
		var/image/cached_overlay = new_overlays[i]
		if (istext(cached_overlay))
			new_overlays[i] = iconstate2appearance(icon, cached_overlay)
		else if(isicon(cached_overlay))
			new_overlays[i] = icon2appearance(cached_overlay)
		else	//image/mutable_appearance probable
			appearance_bro.appearance = cached_overlay
			if(!ispath(cached_overlay))
				appearance_bro.dir = cached_overlay.dir
			new_overlays[i] = appearance_bro.appearance
	return new_overlays

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
	if(!overlays)
		return

	overlays = build_appearance_list(overlays)

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
	if(!overlays)
		return

	overlays = build_appearance_list(overlays)

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

/atom/proc/copy_overlays(atom/other, cut_old)	//copys our_overlays from another atom
	if(!other)
		if(cut_old)
			cut_overlays()
		return

	var/list/cached_other = other.our_overlays
	if(cached_other)
		if(cut_old || !LAZYLEN(our_overlays))
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

/image/proc/copy_overlays(atom/other, cut_old)
	if(!other)
		if(cut_old)
			cut_overlays()
		return

	var/list/cached_other = other.our_overlays
	if(cached_other)
		if(cut_old || !overlays.len)
			overlays = cached_other.Copy()
		else
			overlays |= cached_other
	else if(cut_old)
		cut_overlays()

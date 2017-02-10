var/datum/subsystem/processing/overlays/SSoverlays

/datum/subsystem/processing/overlays
	name = "Overlays"
	flags = SS_TICKER|SS_NO_INIT|SS_FIRE_IN_LOBBY
	wait = 1
	priority = 500
	can_fire = FALSE

	stat_tag = "Ov"
	currentrun = null
	var/list/overlay_icon_state_caches

/datum/subsystem/processing/overlays/New()
	NEW_SS_GLOBAL(SSoverlays)
	LAZYINITLIST(overlay_icon_state_caches)

/datum/subsystem/processing/overlays/Recover()
	overlay_icon_state_caches = SSoverlays.overlay_icon_state_caches
	processing = SSoverlays.processing

/datum/subsystem/processing/overlays/fire()
	while(processing.len)
		var/atom/thing = processing[processing.len]
		processing.len--
		if(thing)
			if(LAZYLEN(thing.priority_overlays) && LAZYLEN(thing.our_overlays))
				thing.overlays = (thing.our_overlays | thing.priority_overlays)
			else if(LAZYLEN(thing.our_overlays))
				thing.overlays = thing.our_overlays
			else if(LAZYLEN(thing.priority_overlays))			//Do these two have to be copied? We don't want assignments to them to trigger overlay updates. But, idk, bruh, BYOND. - Cyberboss
				thing.overlays = thing.priority_overlays
			else
				thing.overlays.Cut()
			thing.flags &= ~OVERLAY_QUEUED
		if(MC_TICK_CHECK)
			break
	can_fire = processing.len > 0

/atom/proc/extract_overlay_appearance(image_atom_or_string)
	if (istext(image_atom_or_string))
		var/static/image/stringbro = new()
		var/list/icon_states_cache = SSoverlays.overlay_icon_state_caches 
		var/list/cached_icon = icon_states_cache[icon]
		if (cached_icon)
			var/cached_appearance = cached_icon["[image_atom_or_string]"]
			if (cached_appearance)
				return cached_appearance
		stringbro.icon = icon
		stringbro.icon_state = image_atom_or_string
		if (!cached_icon) //not using the macro to save an associated lookup
			cached_icon = list()
			icon_states_cache[icon] = cached_icon
		var/cached_appearance = stringbro.appearance
		cached_icon["[image_atom_or_string]"] = cached_appearance
		return cached_appearance
	else if (istype(image_atom_or_string, /image) || istype(image_atom_or_string, /atom))
		var/image/I = image_atom_or_string
		return I.appearance
#if DM_VERSION >= 511
	else if (istype(image_atom_or_string, /mutable_appearance/))
		var/mutable_appearance/MA = image_atom_or_string
		return MA.appearance
#endif

#define NOT_QUEUED_ALREADY (!(flags & OVERLAY_QUEUED))
#define QUEUE_FOR_COMPILE flags |= OVERLAY_QUEUED; SSoverlays.processing += src; SSoverlays.can_fire = TRUE
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

/atom/proc/cut_overlay(image, priority)
	if(!image)
		return
	var/list/cached_overlays = our_overlays	//sanic
	var/list/cached_priority = priority_overlays
	var/init_o_len = LAZYLEN(cached_overlays)
	var/init_p_len = LAZYLEN(cached_priority)  //starter pokemon
	
	image = extract_overlay_appearance(image)

	LAZYREMOVE(cached_overlays, image)
	if(priority)
		LAZYREMOVE(cached_priority, image)

	if(NOT_QUEUED_ALREADY && ((init_o_len != LAZYLEN(cached_priority)) || (init_p_len != LAZYLEN(cached_overlays))))
		QUEUE_FOR_COMPILE

/atom/proc/add_overlay(image, priority = FALSE)
	if(!image)
		return
	if(islist(image))
		for(var/I in image)
			add_overlay(image)
	LAZYINITLIST(our_overlays)	//always initialized after this point
	LAZYINITLIST(priority_overlays)

	image = extract_overlay_appearance(image)

	var/list/cached_overlays = our_overlays	//sanic
	var/list/cached_priority = priority_overlays
	var/init_o_len = cached_overlays.len
	var/init_p_len = cached_priority.len  //starter pokemon
	var/need_compile

	if(priority)
		cached_priority |= image  //or in the image. Can we use [image] = image?
		need_compile = init_p_len != cached_priority.len
	else
		cached_overlays |= image
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

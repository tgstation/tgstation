SUBSYSTEM_DEF(overlays)
	name = "Overlay"
	flags = SS_TICKER
	wait = 1
	priority = FIRE_PRIORITY_OVERLAYS
	init_order = INIT_ORDER_OVERLAY

	var/list/queue
	var/list/stats
	var/list/overlay_icon_state_caches
	var/list/overlay_icon_cache

/datum/controller/subsystem/overlays/PreInit()
	overlay_icon_state_caches = list()
	overlay_icon_cache = list()
	queue = list()
	stats = list()

/datum/controller/subsystem/overlays/Initialize()
	initialized = TRUE
	fire(mc_check = FALSE)
	..()


/datum/controller/subsystem/overlays/stat_entry()
	..("Ov:[length(queue)]")


/datum/controller/subsystem/overlays/Shutdown()
	text2file(render_stats(stats), "[GLOB.log_directory]/overlay.log")


/datum/controller/subsystem/overlays/Recover()
	overlay_icon_state_caches = SSoverlays.overlay_icon_state_caches
	overlay_icon_cache = SSoverlays.overlay_icon_cache
	queue = SSoverlays.queue


/datum/controller/subsystem/overlays/fire(resumed = FALSE, mc_check = TRUE)
	var/list/queue = src.queue
	var/static/count = 0
	if (count)
		var/c = count
		count = 0 //so if we runtime on the Cut, we don't try again.
		queue.Cut(1,c+1)

	for (var/thing in queue)
		count++
		if(thing)
			STAT_START_STOPWATCH
			var/atom/A = thing
			COMPILE_OVERLAYS(A)
			STAT_STOP_STOPWATCH
			STAT_LOG_ENTRY(stats, A.type)
		if(mc_check)
			if(MC_TICK_CHECK)
				break
		else
			CHECK_TICK

	if (count)
		queue.Cut(1,count+1)
		count = 0

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

#define BUILD_APPEARANCE(the_list, thing)\
	if(thing) {\
		if(istext(thing)) {the_list += iconstate2appearance(icon, thing);}\
		else if(isicon(thing)) {the_list += icon2appearance(thing);}\
		else {\
			if(isloc(thing)) {\
				var/atom/A = thing;\
				if (A.flags_1 & OVERLAY_QUEUED_1) {\
					COMPILE_OVERLAYS(A)\
					}\
				}\
			appearance_bro.appearance = thing;\
			if(!ispath(thing)) {\
				var/image/I = thing;\
				appearance_bro.dir = I.dir;\
				}\
			the_list += appearance_bro.appearance;\
			}\
		}

/atom/proc/build_appearance_list(old_overlays)
	if(!old_overlays)
		return list()
	var/static/image/appearance_bro = new
	var/list/new_overlays = list()
	if (!islist(old_overlays))
		BUILD_APPEARANCE(new_overlays, old_overlays)
	else
		for (var/overlay in old_overlays)
			BUILD_APPEARANCE(new_overlays, overlay)
	return new_overlays

#undef BUILD_APPEARANCE

#define NOT_QUEUED_ALREADY (!(flags_1 & OVERLAY_QUEUED_1))
#define QUEUE_FOR_COMPILE flags_1 |= OVERLAY_QUEUED_1; SSoverlays.queue += src;
/atom/proc/cut_overlays(priority = FALSE)
	if(overlays.len)
		remove_overlays = overlays.Copy()

	LAZYCLEARLIST(add_overlays)

	if(priority)
		LAZYCLEARLIST(priority_overlays)

	//If not already queued for work and there are overlays to remove
	if(NOT_QUEUED_ALREADY && LAZYLEN(remove_overlays))
		QUEUE_FOR_COMPILE

/atom/proc/cut_overlay(list/_overlays, priority)
	if(!_overlays && (!islist(_overlays) || !_overlays.len))
		return
	_overlays = build_appearance_list(_overlays)
	if(!_overlays.len)
		return
	LAZYREMOVE(add_overlays, _overlays)
	if(priority)
		LAZYREMOVE(priority_overlays, _overlays)
	_overlays &= overlays
	if(!_overlays.len)
		return
	_overlays -= remove_overlays
	if(!_overlays.len)
		return
	LAZYADD(remove_overlays, _overlays)
	if(NOT_QUEUED_ALREADY)
		QUEUE_FOR_COMPILE

/atom/proc/add_overlay(list/_overlays, priority = FALSE)
	if(!_overlays && (!islist(_overlays) || !_overlays.len))
		return
	_overlays = build_appearance_list(_overlays)
	if(!_overlays.len)
		return
	LAZYREMOVE(remove_overlays, _overlays)
	_overlays -= priority? priority_overlays : add_overlays
	if(!_overlays.len)
		return
	_overlays -= overlays
	if(!_overlays.len)
		return
	if(priority)
		LAZYADD(priority_overlays, _overlays)  //or in the image. Can we use [image] = image?
		if(NOT_QUEUED_ALREADY)
			QUEUE_FOR_COMPILE
	else
		LAZYADD(add_overlays, _overlays)
		if(NOT_QUEUED_ALREADY)
			QUEUE_FOR_COMPILE

/atom/proc/copy_overlays(atom/other, cut_old)	//copys overlays from another atom
	if(cut_old)
		cut_overlays()
	if(!other)
		return
	var/list/cached_other = other.overlays
	if(other.add_overlays)
		cached_other |= other.add_overlays
	var/list/cached_other_priority = other.priority_overlays.Copy()
	if(cached_other_priority.len)
		add_overlay(cached_other_priority, TRUE)
	if(cached_other.len)
		add_overlay(cached_other)

#undef NOT_QUEUED_ALREADY
#undef QUEUE_FOR_COMPILE

//TODO: Better solution for these?
/image/proc/add_overlay(x)
	overlays |= x

/image/proc/cut_overlay(x)
	overlays -= x

/image/proc/cut_overlays(x)
	overlays.Cut()

/image/proc/copy_overlays(atom/other, cut_old)
	if(!other)
		if(cut_old)
			cut_overlays()
		return

	var/list/cached_other = other.overlays.Copy()
	if(cached_other)
		if(cut_old || !overlays.len)
			overlays = cached_other
		else
			overlays |= cached_other
	else if(cut_old)
		cut_overlays()

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
	return ..()


/datum/controller/subsystem/overlays/stat_entry(msg)
	msg = "Ov:[length(queue)]"
	return ..()


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
			var/atom/A = thing
			if(A.overlays.len >= MAX_ATOM_OVERLAYS)
				//Break it real GOOD
				stack_trace("Too many overlays on [A.type] - [A.overlays.len], refusing to update and cutting")
				A.overlays.Cut()
				continue
			STAT_START_STOPWATCH
			COMPILE_OVERLAYS(A)
			UNSETEMPTY(A.add_overlays)
			UNSETEMPTY(A.remove_overlays)
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

/atom/proc/build_appearance_list(old_overlays)
	var/static/image/appearance_bro = new()
	var/list/new_overlays = list()
	if (!islist(old_overlays))
		old_overlays = list(old_overlays)
	for (var/overlay in old_overlays)
		if(!overlay)
			continue
		if (istext(overlay))
			new_overlays += iconstate2appearance(icon, overlay)
		else if(isicon(overlay))
			new_overlays += icon2appearance(overlay)
		else
			if(isloc(overlay))
				var/atom/A = overlay
				if (A.flags_1 & OVERLAY_QUEUED_1)
					COMPILE_OVERLAYS(A)
			appearance_bro.appearance = overlay //this works for images and atoms too!
			if(!ispath(overlay))
				var/image/I = overlay
				appearance_bro.dir = I.dir
			new_overlays += appearance_bro.appearance
	return new_overlays

#define NOT_QUEUED_ALREADY (!(flags_1 & OVERLAY_QUEUED_1))
#define QUEUE_FOR_COMPILE flags_1 |= OVERLAY_QUEUED_1; SSoverlays.queue += src;
/atom/proc/cut_overlays()
	LAZYINITLIST(remove_overlays)
	remove_overlays = overlays.Copy()
	add_overlays = null

	//If not already queued for work and there are overlays to remove
	if(NOT_QUEUED_ALREADY && remove_overlays.len)
		QUEUE_FOR_COMPILE

/atom/proc/cut_overlay(list/overlays)
	if(!overlays)
		return
	overlays = build_appearance_list(overlays)
	LAZYINITLIST(add_overlays)
	LAZYINITLIST(remove_overlays)
	var/a_len = add_overlays.len
	var/r_len = remove_overlays.len
	remove_overlays += overlays
	add_overlays -= overlays

	var/fa_len = add_overlays.len
	var/fr_len = remove_overlays.len

	//If not already queued and there is work to be done
	if(NOT_QUEUED_ALREADY && (fa_len != a_len || fr_len != r_len ))
		QUEUE_FOR_COMPILE
	UNSETEMPTY(add_overlays)

/atom/proc/add_overlay(list/overlays)
	if(!overlays)
		return

	overlays = build_appearance_list(overlays)

	LAZYINITLIST(add_overlays) //always initialized after this point
	var/a_len = add_overlays.len

	add_overlays += overlays
	var/fa_len = add_overlays.len
	if(NOT_QUEUED_ALREADY && fa_len != a_len)
		QUEUE_FOR_COMPILE

/atom/proc/copy_overlays(atom/other, cut_old)	//copys our_overlays from another atom
	if(!other)
		if(cut_old)
			cut_overlays()
		return

	var/list/cached_other = other.overlays.Copy()
	if(cached_other)
		if(cut_old || !LAZYLEN(overlays))
			remove_overlays = overlays
		add_overlays = cached_other
		if(NOT_QUEUED_ALREADY)
			QUEUE_FOR_COMPILE
	else if(cut_old)
		cut_overlays()

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

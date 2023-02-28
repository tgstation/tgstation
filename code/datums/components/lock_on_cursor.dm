#define LOCKON_AIMING_MAX_CURSOR_RADIUS 7
#define LOCKON_IGNORE_RESULT "ignore_my_result"
#define LOCKON_RANGING_BREAK_CHECK if(current_ranging_id != this_id){return LOCKON_IGNORE_RESULT}

/**
 * ### Lock on Cursor component
 *
 * Finds the nearest target to your cursor and passes it into a callback, also drawing an icon on top of them.
 */
/datum/component/lock_on_cursor
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/lock_icon
	var/lock_icon_state
	var/mutable_appearance/lock_appearance
	var/list/image/lock_images
	var/list/target_typecache
	var/list/immune_weakrefs //list(weakref = TRUE)
	var/mob_stat_check = TRUE //if a potential target is a mob make sure it's conscious!
	var/lock_amount = 1
	var/lock_cursor_range
	var/list/locked_weakrefs
	var/update_disabled = FALSE
	var/current_ranging_id = 0
	var/list/last_location
	var/datum/callback/on_lock
	var/datum/callback/can_target_callback
	var/atom/movable/screen/fullscreen/cursor_catcher/lock_on/mouse_tracker

/datum/component/lock_on_cursor/Initialize(range = 5, list/typecache = list(), amount = 1, list/immune = list(), icon = 'icons/mob/silicon/cameramob.dmi', icon_state = "marker", datum/callback/when_locked, datum/callback/target_callback)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	lock_cursor_range = range
	target_typecache = typecache
	lock_amount = amount
	immune_weakrefs = list(WEAKREF(parent) = TRUE) //Manually take this out if you want..
	for(var/immune_thing in immune)
		if(isweakref(immune_thing))
			immune_weakrefs[immune_thing] = TRUE
		else if(isatom(immune_thing))
			immune_weakrefs[WEAKREF(immune_thing)] = TRUE
	on_lock = when_locked
	can_target_callback = target_callback ? target_callback : CALLBACK(src, PROC_REF(can_target))
	lock_icon = icon
	lock_icon_state = icon_state
	generate_lock_visuals()
	var/mob/owner = parent
	mouse_tracker = owner.overlay_fullscreen("lock_on", /atom/movable/screen/fullscreen/cursor_catcher/lock_on, 0)
	mouse_tracker.assign_to_mob(owner)
	START_PROCESSING(SSfastprocess, src)

/datum/component/lock_on_cursor/Destroy()
	clear_visuals()
	STOP_PROCESSING(SSfastprocess, src)
	mouse_tracker = null
	var/mob/owner = parent
	owner.clear_fullscreen("lock_on")
	return ..()

/datum/component/lock_on_cursor/proc/show_visuals()
	LAZYINITLIST(lock_images)
	var/mob/owner = parent
	if(!owner.client)
		return
	for(var/datum/weakref/weak_target as anything in locked_weakrefs)
		var/atom/target = weak_target.resolve()
		if(!target)
			continue //It'll be cleared by processing.
		var/image/target_overlay = new
		target_overlay.appearance = lock_appearance
		target_overlay.loc = target
		owner.client.images |= target_overlay
		lock_images |= target_overlay

/datum/component/lock_on_cursor/proc/clear_visuals()
	var/mob/owner = parent
	if(!owner.client)
		return
	if(!lock_images)
		return
	for(var/image in lock_images)
		owner.client.images -= image
		qdel(image)
	lock_images.Cut()

/datum/component/lock_on_cursor/proc/refresh_visuals()
	clear_visuals()
	show_visuals()

/datum/component/lock_on_cursor/proc/generate_lock_visuals()
	lock_appearance = mutable_appearance(icon = lock_icon, icon_state = lock_icon_state, layer = FLOAT_LAYER)

/datum/component/lock_on_cursor/proc/unlock_all(refresh_vis = TRUE)
	LAZYCLEARLIST(locked_weakrefs)
	if(refresh_vis)
		refresh_visuals()

/datum/component/lock_on_cursor/proc/unlock(atom/target, refresh_vis = TRUE)
	LAZYREMOVE(locked_weakrefs, WEAKREF(target))
	if(refresh_vis)
		refresh_visuals()

/datum/component/lock_on_cursor/proc/lock(atom/target, refresh_vis = TRUE)
	LAZYOR(locked_weakrefs, WEAKREF(target))
	if(refresh_vis)
		refresh_visuals()

/datum/component/lock_on_cursor/proc/add_immune_atom(atom/target)
	var/datum/weakref/weak_target = WEAKREF(target)
	if(immune_weakrefs && (immune_weakrefs[weak_target]))
		return
	LAZYSET(immune_weakrefs, weak_target, TRUE)

/datum/component/lock_on_cursor/proc/remove_immune_atom(atom/target)
	LAZYREMOVE(immune_weakrefs, WEAKREF(target))

/datum/component/lock_on_cursor/process()
	if(update_disabled)
		return
	if(!last_location)
		return
	var/changed = FALSE
	for(var/i in locked_weakrefs)
		var/datum/weakref/R = i
		if(istype(R))
			var/atom/thing = R.resolve()
			if(!istype(thing) || (get_dist(thing, locate(last_location[1], last_location[2], last_location[3])) > lock_cursor_range))
				unlock(R)
				changed = TRUE
		else
			unlock(R)
			changed = TRUE
	if(changed)
		autolock()

/datum/component/lock_on_cursor/proc/autolock()
	var/mob/M = parent
	if(!M.client)
		return FALSE
	var/datum/position/current = mouse_absolute_datum_map_position_from_client(M.client)
	var/turf/target = current.return_turf()
	var/list/atom/targets = get_nearest(target, target_typecache, lock_amount, lock_cursor_range)
	if(targets == LOCKON_IGNORE_RESULT)
		return
	unlock_all(FALSE)
	for(var/i in targets)
		if(immune_weakrefs[WEAKREF(i)])
			continue
		lock(i, FALSE)
	refresh_visuals()
	on_lock.Invoke(locked_weakrefs)

/datum/component/lock_on_cursor/proc/can_target(atom/A)
	var/mob/M = A
	return is_type_in_typecache(A, target_typecache) && !(ismob(A) && mob_stat_check && M.stat != CONSCIOUS) && !immune_weakrefs[WEAKREF(A)]

/datum/component/lock_on_cursor/proc/get_nearest(turf/T, list/typecache, amount, range)
	current_ranging_id++
	var/this_id = current_ranging_id
	var/list/L = list()
	var/turf/center = get_turf(T)
	if(amount < 1 || range < 0 || !istype(center) || !islist(typecache))
		return
	if(range == 0)
		return typecache_filter_list(T.contents + T, typecache)
	var/x = 0
	var/y = 0
	var/cd = 0
	while(cd <= range)
		x = center.x - cd + 1
		y = center.y + cd
		LOCKON_RANGING_BREAK_CHECK
		for(x in x to center.x + cd)
			T = locate(x, y, center.z)
			if(T)
				L |= special_list_filter(T.contents, can_target_callback)
				if(L.len >= amount)
					L.Cut(amount+1)
					return L
		LOCKON_RANGING_BREAK_CHECK
		y = center.y + cd - 1
		x = center.x + cd
		for(y in center.y - cd to y)
			T = locate(x, y, center.z)
			if(T)
				L |= special_list_filter(T.contents, can_target_callback)
				if(L.len >= amount)
					L.Cut(amount+1)
					return L
		LOCKON_RANGING_BREAK_CHECK
		y = center.y - cd
		x = center.x + cd - 1
		for(x in center.x - cd to x)
			T = locate(x, y, center.z)
			if(T)
				L |= special_list_filter(T.contents, can_target_callback)
				if(L.len >= amount)
					L.Cut(amount+1)
					return L
		LOCKON_RANGING_BREAK_CHECK
		y = center.y - cd + 1
		x = center.x - cd
		for(y in y to center.y + cd)
			T = locate(x, y, center.z)
			if(T)
				L |= special_list_filter(T.contents, can_target_callback)
				if(L.len >= amount)
					L.Cut(amount+1)
					return L
		LOCKON_RANGING_BREAK_CHECK
		cd++
		CHECK_TICK

/atom/movable/screen/fullscreen/cursor_catcher/lock_on
	icon_state = "oxydamageoverlay"

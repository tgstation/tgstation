#define LOCKON_IGNORE_RESULT "ignore_my_result"
#define LOCKON_RANGING_BREAK_CHECK if(current_ranging_id != this_id){return LOCKON_IGNORE_RESULT}

/**
 * ### Lock on Cursor component
 *
 * Finds the nearest targets to your cursor and passes them into a callback, also drawing an icon on top of them.
 */
/datum/component/lock_on_cursor
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// Appearance to overlay onto whatever we are targetting
	var/mutable_appearance/lock_appearance
	/// Current images we are displaying to the client
	var/list/image/lock_images
	/// Typecache of things we are allowed to target
	var/list/target_typecache
	/// Cache of weakrefs to ignore targetting formatted as `list(weakref = TRUE)`
	var/list/immune_weakrefs
	/// Number of things we can target at once
	var/lock_amount
	/// Range to search for targets from the cursor position
	var/lock_cursor_range
	/// Weakrefs to current locked targets
	var/list/locked_weakrefs
	/// Callback to call when we have decided on our targets, is passed the list of final targets
	var/datum/callback/on_lock
	/// Callback to call in order to validate a potential target
	var/datum/callback/can_target_callback
	/// Full screen overlay which is used to track mouse position
	var/atom/movable/screen/fullscreen/cursor_catcher/lock_on/mouse_tracker
	/// Ranging ID for some kind of tick check safety calculation
	var/current_ranging_id = 0

/datum/component/lock_on_cursor/Initialize(
	lock_cursor_range = 5,
	lock_amount = 1,
	list/target_typecache = list(),
	list/immune = list(),
	icon = 'icons/mob/silicon/cameramob.dmi',
	icon_state = "marker",
	datum/callback/on_lock,
	datum/callback/can_target_callback,
)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	if (lock_amount < 1 || lock_cursor_range < 0)
		CRASH("Invalid range or amount argument")
	src.lock_cursor_range = lock_cursor_range
	src.target_typecache = target_typecache
	src.lock_amount = lock_amount
	src.on_lock = on_lock
	src.can_target_callback = can_target_callback ? can_target_callback : CALLBACK(src, PROC_REF(can_target))
	immune_weakrefs = list(WEAKREF(parent) = TRUE) //Manually take this out if you want..
	for(var/immune_thing in immune)
		if(isweakref(immune_thing))
			immune_weakrefs[immune_thing] = TRUE
		else if(isatom(immune_thing))
			immune_weakrefs[WEAKREF(immune_thing)] = TRUE
	lock_appearance = mutable_appearance(icon = icon, icon_state = icon_state, layer = FLOAT_LAYER)
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

/// Adds overlays to all targets
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

/// Removes target overlays
/datum/component/lock_on_cursor/proc/clear_visuals()
	var/mob/owner = parent
	if(!owner.client)
		return
	if(!length(lock_images))
		return
	for(var/image/overlay as anything in lock_images)
		owner.client.images -= overlay
		qdel(overlay)
	lock_images.Cut()

/// Reset the overlays on all targets
/datum/component/lock_on_cursor/proc/refresh_visuals()
	clear_visuals()
	show_visuals()

/datum/component/lock_on_cursor/process()
	if(mouse_tracker.mouse_params)
		mouse_tracker.calculate_params()
	if(!mouse_tracker.given_turf)
		return
	clear_invalid_targets()
	if(length(locked_weakrefs) < lock_amount)
		find_targets()

/// Removes targets which are out of range or don't exist any more
/datum/component/lock_on_cursor/proc/clear_invalid_targets()
	for(var/datum/weakref/weak_target as anything in locked_weakrefs)
		var/atom/thing = weak_target.resolve()
		if(thing && (get_dist(thing, mouse_tracker.given_turf) > lock_cursor_range))
			continue
		LAZYREMOVE(locked_weakrefs, weak_target)

/// Replace our targets with new ones
/datum/component/lock_on_cursor/proc/find_targets()
	var/mob/owner = parent
	if(!owner.client)
		return
	var/list/atom/targets = get_nearest(mouse_tracker.given_turf, target_typecache, lock_amount, lock_cursor_range)
	if(targets == LOCKON_IGNORE_RESULT)
		return
	LAZYCLEARLIST(locked_weakrefs)
	for(var/atom/target as anything in targets)
		if(immune_weakrefs[WEAKREF(target)])
			continue
		LAZYOR(locked_weakrefs, WEAKREF(target))
	refresh_visuals()
	on_lock.Invoke(locked_weakrefs)

/// Returns true if target is a valid target
/datum/component/lock_on_cursor/proc/can_target(atom/target)
	var/mob/mob_target = target
	return is_type_in_typecache(target, target_typecache) && !(ismob(target) && mob_target.stat != CONSCIOUS) && !immune_weakrefs[WEAKREF(target)]

/// Returns the nearest targets to the current cursor position
/datum/component/lock_on_cursor/proc/get_nearest()
	current_ranging_id++
	var/this_id = current_ranging_id
	var/list/targets = list()
	var/turf/target_turf = mouse_tracker.given_turf
	var/turf/center = target_turf
	if(!length(target_typecache))
		return
	if(lock_cursor_range == 0)
		return typecache_filter_list(target_turf.contents + target_turf, target_typecache)
	var/x = 0
	var/y = 0
	var/cd = 0
	while(cd <= lock_cursor_range)
		x = center.x - cd + 1
		y = center.y + cd
		LOCKON_RANGING_BREAK_CHECK
		for(x in x to center.x + cd)
			target_turf = locate(x, y, center.z)
			if(target_turf)
				targets |= special_list_filter(target_turf.contents, can_target_callback)
				if(targets.len >= lock_amount)
					targets.Cut(lock_amount+1)
					return targets
		LOCKON_RANGING_BREAK_CHECK
		y = center.y + cd - 1
		x = center.x + cd
		for(y in center.y - cd to y)
			target_turf = locate(x, y, center.z)
			if(target_turf)
				targets |= special_list_filter(target_turf.contents, can_target_callback)
				if(targets.len >= lock_amount)
					targets.Cut(lock_amount+1)
					return targets
		LOCKON_RANGING_BREAK_CHECK
		y = center.y - cd
		x = center.x + cd - 1
		for(x in center.x - cd to x)
			target_turf = locate(x, y, center.z)
			if(target_turf)
				targets |= special_list_filter(target_turf.contents, can_target_callback)
				if(targets.len >= lock_amount)
					targets.Cut(lock_amount+1)
					return targets
		LOCKON_RANGING_BREAK_CHECK
		y = center.y - cd + 1
		x = center.x - cd
		for(y in y to center.y + cd)
			target_turf = locate(x, y, center.z)
			if(target_turf)
				targets |= special_list_filter(target_turf.contents, can_target_callback)
				if(targets.len >= lock_amount)
					targets.Cut(lock_amount+1)
					return targets
		LOCKON_RANGING_BREAK_CHECK
		cd++
		CHECK_TICK

/// Tracks cursor movement and passes clicks through to the turf under the cursor
/atom/movable/screen/fullscreen/cursor_catcher/lock_on

/atom/movable/screen/fullscreen/cursor_catcher/lock_on/Click(location, control, params)
	if(usr == owner)
		calculate_params()
	given_turf.Click(location, control, params)

#undef LOCKON_IGNORE_RESULT
#undef LOCKON_RANGING_BREAK_CHECK

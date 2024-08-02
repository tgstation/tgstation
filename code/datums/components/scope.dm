///Used to allow reaching the maximum offset range without exiting the boundaries of the game screen.
#define MOUSE_POINTER_OFFSET_MULT 1.1

///A component that allows players to use the item to zoom out. Mainly intended for firearms, but now works with other items too.
/datum/component/scope
	/// How far we can extend, with modifier of 1, up to our vision edge, higher numbers multiply.
	var/range_modifier = 1
	/// Fullscreen object we use for tracking.
	var/atom/movable/screen/fullscreen/cursor_catcher/scope/tracker
	/// The owner of the tracker's ckey. For comparing with the current owner mob, in case the client has left it (e.g. ghosted).
	var/tracker_owner_ckey
	/// The method which we zoom in and out
	var/zoom_method = ZOOM_METHOD_RIGHT_CLICK
	/// if not null, an item action will be added. Redundant if the mode is ZOOM_METHOD_RIGHT_CLICK or ZOOM_METHOD_WIELD.
	var/item_action_type

/datum/component/scope/Initialize(range_modifier = 1, zoom_method = ZOOM_METHOD_RIGHT_CLICK, item_action_type)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.range_modifier = range_modifier
	src.zoom_method = zoom_method
	src.item_action_type = item_action_type

/datum/component/scope/Destroy(force)
	if(tracker)
		stop_zooming(tracker.owner)
	return ..()

/datum/component/scope/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	switch(zoom_method)
		if(ZOOM_METHOD_RIGHT_CLICK)
			RegisterSignal(parent, COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM_SECONDARY, PROC_REF(do_secondary_zoom))
		if(ZOOM_METHOD_WIELD)
			RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_WIELDED), PROC_REF(on_wielded))
			RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_WIELDED), PROC_REF(on_unwielded))
	if(item_action_type)
		var/obj/item/parent_item = parent
		var/datum/action/item_action/scope = parent_item.add_item_action(item_action_type)
		RegisterSignal(scope, COMSIG_ACTION_TRIGGER, PROC_REF(on_action_trigger))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	if(isgun(parent))
		RegisterSignal(parent, COMSIG_GUN_TRY_FIRE, PROC_REF(on_gun_fire))

/datum/component/scope/UnregisterFromParent()
	if(item_action_type)
		var/obj/item/parent_item = parent
		var/datum/action/item_action/scope = locate(item_action_type) in parent_item.actions
		parent_item.remove_item_action(scope)
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM_SECONDARY,
		SIGNAL_ADDTRAIT(TRAIT_WIELDED),
		SIGNAL_REMOVETRAIT(TRAIT_WIELDED),
		COMSIG_GUN_TRY_FIRE,
		COMSIG_ATOM_EXAMINE,
	))

/datum/component/scope/process(seconds_per_tick)
	var/mob/user_mob = tracker.owner
	var/client/user_client = user_mob.client
	if(!user_client)
		stop_zooming(user_mob)
		return
	tracker.calculate_params()
	if(!user_client.intended_direction)
		user_mob.face_atom(tracker.given_turf)
	animate(user_client, world.tick_lag, pixel_x = tracker.given_x, pixel_y = tracker.given_y)

/datum/component/scope/proc/on_move(atom/movable/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER

	if(!tracker)
		return
	stop_zooming(tracker.owner)

/datum/component/scope/proc/do_secondary_zoom(datum/source, mob/user, atom/target, click_parameters)
	SIGNAL_HANDLER

	if(tracker)
		stop_zooming(user)
	else
		zoom(user)
	return ITEM_INTERACT_BLOCKING

/datum/component/scope/proc/on_action_trigger(datum/action/source)
	SIGNAL_HANDLER
	var/obj/item/item = source.target
	var/mob/living/user = item.loc
	if(tracker)
		stop_zooming(user)
	else
		zoom(user)

/datum/component/scope/proc/on_wielded(obj/item/source, trait)
	SIGNAL_HANDLER
	var/mob/living/user = source.loc
	zoom(user)

/datum/component/scope/proc/on_unwielded(obj/item/source, trait)
	SIGNAL_HANDLER
	var/mob/living/user = source.loc
	stop_zooming(user)

/datum/component/scope/proc/on_gun_fire(obj/item/gun/source, mob/living/user, atom/target, flag, params)
	SIGNAL_HANDLER

	if(!tracker?.given_turf || target == get_target(tracker.given_turf))
		return NONE
	INVOKE_ASYNC(source, TYPE_PROC_REF(/obj/item/gun, fire_gun), get_target(tracker.given_turf), user)
	return COMPONENT_CANCEL_GUN_FIRE

/datum/component/scope/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/scope = isgun(parent) ? "scope in" : "zoom out"
	switch(zoom_method)
		if(ZOOM_METHOD_RIGHT_CLICK)
			examine_list += span_notice("You can [scope] with <b>right-click</b>.")
		if(ZOOM_METHOD_WIELD)
			examine_list += span_notice("You can [scope] by wielding it with both hands.")

/**
 * We find and return the best target to hit on a given turf.
 *
 * Arguments:
 * * target_turf: The turf we are looking for targets on.
*/
/datum/component/scope/proc/get_target(turf/target_turf)
	var/list/object_targets = list()
	var/list/non_dense_targets = list()
	for(var/atom/movable/possible_target in target_turf)
		if(possible_target.layer <= PROJECTILE_HIT_THRESHHOLD_LAYER)
			continue
		if(possible_target.invisibility > tracker.owner.see_invisible)
			continue
		if(!possible_target.mouse_opacity)
			continue
		if(iseffect(possible_target))
			continue
		if(ismob(possible_target))
			if(possible_target == tracker.owner)
				continue
			return possible_target
		if(!possible_target.density)
			non_dense_targets += possible_target
			continue
		object_targets += possible_target
	for(var/obj/important_object as anything in object_targets)
		return important_object
	for(var/obj/unimportant_object as anything in non_dense_targets)
		return unimportant_object
	return target_turf

/**
 * We start zooming by adding our tracker overlay and starting our processing.
 *
 * Arguments:
 * * user: The mob we are starting zooming on.
*/
/datum/component/scope/proc/zoom(mob/user)
	if(isnull(user.client))
		return
	if(HAS_TRAIT(user, TRAIT_USER_SCOPED))
		user.balloon_alert(user, "already zoomed!")
		return
	user.playsound_local(parent, 'sound/weapons/scope.ogg', 75, TRUE)
	tracker = user.overlay_fullscreen("scope", /atom/movable/screen/fullscreen/cursor_catcher/scope, isgun(parent))
	tracker.assign_to_mob(user, range_modifier)
	tracker_owner_ckey = user.ckey
	if(user.is_holding(parent))
		RegisterSignals(user, list(COMSIG_MOB_SWAP_HANDS, COMSIG_QDELETING), PROC_REF(stop_zooming))
	else // The item is likely worn (eg. mothic cap)
		RegisterSignal(user, COMSIG_QDELETING, PROC_REF(stop_zooming))
		var/static/list/capacity_signals = list(
			COMSIG_LIVING_STATUS_KNOCKDOWN,
			COMSIG_LIVING_STATUS_PARALYZE,
			COMSIG_LIVING_STATUS_STUN,
		)
		RegisterSignals(user, capacity_signals, PROC_REF(on_incapacitated))
	START_PROCESSING(SSprojectiles, src)
	ADD_TRAIT(user, TRAIT_USER_SCOPED, REF(src))
	return TRUE

/datum/component/scope/proc/on_incapacitated(mob/living/source, amount = 0, ignore_canstun = FALSE)
	SIGNAL_HANDLER

	if(amount > 0)
		stop_zooming(source)

/**
 * We stop zooming, canceling processing, resetting stuff back to normal and deleting our tracker.
 *
 * Arguments:
 * * user: The mob we are canceling zooming on.
*/
/datum/component/scope/proc/stop_zooming(mob/user)
	SIGNAL_HANDLER

	if(!HAS_TRAIT(user, TRAIT_USER_SCOPED))
		return

	STOP_PROCESSING(SSprojectiles, src)
	UnregisterSignal(user, list(
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_MOB_SWAP_HANDS,
		COMSIG_QDELETING,
	))
	REMOVE_TRAIT(user, TRAIT_USER_SCOPED, REF(src))

	user.playsound_local(parent, 'sound/weapons/scope.ogg', 75, TRUE, frequency = -1)
	user.clear_fullscreen("scope")

	// if the client has ended up in another mob, find that mob so we can fix their cursor
	var/mob/true_user
	if(user.ckey != tracker_owner_ckey)
		true_user = get_mob_by_ckey(tracker_owner_ckey)

	if(!isnull(true_user))
		user = true_user

	if(user.client)
		animate(user.client, 0.2 SECONDS, pixel_x = 0, pixel_y = 0)
	tracker = null
	tracker_owner_ckey = null

/atom/movable/screen/fullscreen/cursor_catcher/scope
	icon_state = "scope"
	/// Multiplier for given_X an given_y.
	var/range_modifier = 1

/atom/movable/screen/fullscreen/cursor_catcher/scope/assign_to_mob(mob/new_owner, range_modifier)
	src.range_modifier = range_modifier
	return ..()

/atom/movable/screen/fullscreen/cursor_catcher/scope/Click(location, control, params)
	if(usr == owner)
		calculate_params()
	return ..()

/atom/movable/screen/fullscreen/cursor_catcher/scope/calculate_params()
	var/list/modifiers = params2list(mouse_params)
	var/icon_x = text2num(LAZYACCESS(modifiers, VIS_X))
	if(isnull(icon_x))
		icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
		if(isnull(icon_x))
			icon_x = view_list[1]*world.icon_size/2
	var/icon_y = text2num(LAZYACCESS(modifiers, VIS_Y))
	if(isnull(icon_y))
		icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
		if(isnull(icon_y))
			icon_y = view_list[2]*world.icon_size/2
	var/x_cap = range_modifier * view_list[1]*world.icon_size / 2
	var/y_cap = range_modifier * view_list[2]*world.icon_size / 2
	var/uncapped_x = round(range_modifier * (icon_x - view_list[1]*world.icon_size/2) * MOUSE_POINTER_OFFSET_MULT)
	var/uncapped_y = round(range_modifier * (icon_y - view_list[2]*world.icon_size/2) * MOUSE_POINTER_OFFSET_MULT)
	given_x = clamp(uncapped_x, -x_cap, x_cap)
	given_y = clamp(uncapped_y, -y_cap, y_cap)
	given_turf = locate(owner.x+round(given_x/world.icon_size, 1),owner.y+round(given_y/world.icon_size, 1),owner.z)

#undef MOUSE_POINTER_OFFSET_MULT

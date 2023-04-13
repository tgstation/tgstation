/datum/component/scope
	/// How far we can extend, with modifier of 1, up to our vision edge, higher numbers multiply.
	var/range_modifier = 1
	/// Fullscreen object we use for tracking the shots.
	var/atom/movable/screen/fullscreen/cursor_catcher/scope/tracker

/datum/component/scope/Initialize(range_modifier)
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	src.range_modifier = range_modifier

/datum/component/scope/Destroy(force, silent)
	if(tracker)
		stop_zooming(tracker.owner)
	return ..()

/datum/component/scope/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK_SECONDARY, PROC_REF(on_secondary_afterattack))
	RegisterSignal(parent, COMSIG_GUN_TRY_FIRE, PROC_REF(on_gun_fire))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/scope/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_ITEM_AFTERATTACK_SECONDARY,
		COMSIG_GUN_TRY_FIRE,
		COMSIG_PARENT_EXAMINE,
	))

/datum/component/scope/process(delta_time)
	var/mob/user_mob = tracker.owner
	var/client/user_client = user_mob.client
	if(!user_client)
		stop_zooming(user_mob)
		return
	tracker.calculate_params()
	if(!length(user_client.keys_held & user_client.movement_keys))
		user_mob.face_atom(tracker.given_turf)
	animate(user_client, world.tick_lag, pixel_x = tracker.given_x, pixel_y = tracker.given_y)

/datum/component/scope/proc/on_move(atom/movable/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER

	if(!tracker)
		return
	stop_zooming(tracker.owner)

/datum/component/scope/proc/on_secondary_afterattack(datum/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(tracker)
		stop_zooming(user)
	else
		start_zooming(user)
	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/datum/component/scope/proc/on_gun_fire(obj/item/gun/source, mob/living/user, atom/target, flag, params)
	SIGNAL_HANDLER

	if(!tracker?.given_turf || target == get_target(tracker.given_turf))
		return NONE
	INVOKE_ASYNC(source, TYPE_PROC_REF(/obj/item/gun, fire_gun), get_target(tracker.given_turf), user)
	return COMPONENT_CANCEL_GUN_FIRE

/datum/component/scope/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("You can scope in with <b>right-click</b>.")

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
 * We start zooming by hiding the mouse pointer, adding our tracker overlay and starting our processing.
 *
 * Arguments:
 * * user: The mob we are starting zooming on.
*/
/datum/component/scope/proc/start_zooming(mob/user)
	if(!user.client)
		return
	user.client.mouse_override_icon = 'icons/effects/mouse_pointers/scope_hide.dmi'
	user.update_mouse_pointer()
	user.playsound_local(parent, 'sound/weapons/scope.ogg', 75, TRUE)
	tracker = user.overlay_fullscreen("scope", /atom/movable/screen/fullscreen/cursor_catcher/scope, 0)
	tracker.assign_to_mob(user, range_modifier)
	RegisterSignal(user, COMSIG_MOB_SWAP_HANDS, PROC_REF(stop_zooming))
	START_PROCESSING(SSprojectiles, src)

/**
 * We stop zooming, canceling processing, resetting stuff back to normal and deleting our tracker.
 *
 * Arguments:
 * * user: The mob we are canceling zooming on.
*/
/datum/component/scope/proc/stop_zooming(mob/user)
	SIGNAL_HANDLER

	STOP_PROCESSING(SSprojectiles, src)
	UnregisterSignal(user, COMSIG_MOB_SWAP_HANDS)
	if(user.client)
		animate(user.client, 0.2 SECONDS, pixel_x = 0, pixel_y = 0)
		user.client.mouse_override_icon = null
		user.update_mouse_pointer()
	user.playsound_local(parent, 'sound/weapons/scope.ogg', 75, TRUE, frequency = -1)
	tracker = null
	user.clear_fullscreen("scope")

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
	var/icon_x = text2num(LAZYACCESS(modifiers, VIS_X)) || view_list[1]*world.icon_size/2
	var/icon_y = text2num(LAZYACCESS(modifiers, VIS_Y)) || view_list[2]*world.icon_size/2
	given_x = round(range_modifier * (icon_x - view_list[1]*world.icon_size/2))
	given_y = round(range_modifier * (icon_y - view_list[2]*world.icon_size/2))
	given_turf = locate(owner.x+round(given_x/world.icon_size, 1),owner.y+round(given_y/world.icon_size, 1),owner.z)

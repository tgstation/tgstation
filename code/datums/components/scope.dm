/datum/component/scope
	/// How far we can extend, with modifier of 1, up to our vision edge, higher numbers multiply.
	var/range_modifier = 1
	/// Fullscreen object we use for tracking the shots.
	var/atom/movable/screen/fullscreen/scope/tracker

/datum/component/scope/Initialize(range_modifier)
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	src.range_modifier = range_modifier

/datum/component/scope/Destroy(force, silent)
	if(tracker)
		stop_zooming(tracker.marksman)
	return ..()

/datum/component/scope/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/on_move)
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK_SECONDARY, .proc/on_secondary_afterattack)
	RegisterSignal(parent, COMSIG_GUN_TRY_FIRE, .proc/on_gun_fire)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/component/scope/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_ITEM_AFTERATTACK_SECONDARY,
		COMSIG_GUN_TRY_FIRE,
		COMSIG_PARENT_EXAMINE,
	))

/datum/component/scope/process(delta_time)
	if(!tracker.marksman.client)
		stop_zooming(tracker.marksman)
		return
	if(!length(tracker.marksman.client.keys_held & tracker.marksman.client.movement_keys))
		tracker.marksman.face_atom(tracker.given_turf)
	animate(tracker.marksman.client, 0.2 SECONDS, easing = SINE_EASING, flags = EASE_OUT, pixel_x = tracker.given_x, pixel_y = tracker.given_y)

/datum/component/scope/proc/on_move(atom/movable/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER

	if(!tracker)
		return
	stop_zooming(tracker.marksman)

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
	INVOKE_ASYNC(source, /obj/item/gun.proc/fire_gun, get_target(tracker.given_turf), user)
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
		if(possible_target.invisibility > tracker.marksman.see_invisible)
			continue
		if(!possible_target.mouse_opacity)
			continue
		if(iseffect(possible_target))
			continue
		if(ismob(possible_target))
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
	tracker = user.overlay_fullscreen("scope", /atom/movable/screen/fullscreen/scope, 0)
	tracker.range_modifier = range_modifier
	tracker.marksman = user
	tracker.RegisterSignal(user, COMSIG_MOVABLE_MOVED, /atom/movable/screen/fullscreen/scope.proc/on_move)
	RegisterSignal(user, COMSIG_MOB_SWAP_HANDS, .proc/stop_zooming)
	START_PROCESSING(SSfastprocess, src)

/**
 * We stop zooming, canceling processing, resetting stuff back to normal and deleting our tracker.
 *
 * Arguments:
 * * user: The mob we are canceling zooming on.
*/
/datum/component/scope/proc/stop_zooming(mob/user)
	SIGNAL_HANDLER

	STOP_PROCESSING(SSfastprocess, src)
	UnregisterSignal(user, COMSIG_MOB_SWAP_HANDS)
	if(user.client)
		animate(user.client, 0.2 SECONDS, pixel_x = 0, pixel_y = 0)
		user.client.mouse_override_icon = null
		user.update_mouse_pointer()
	user.playsound_local(parent, 'sound/weapons/scope.ogg', 75, TRUE, frequency = -1)
	tracker = null
	user.clear_fullscreen("scope")

/atom/movable/screen/fullscreen/scope
	icon_state = "scope"
	plane = HUD_PLANE
	mouse_opacity = MOUSE_OPACITY_ICON
	/// Multiplier for given_X an given_y.
	var/range_modifier = 1
	/// The mob the scope is on.
	var/mob/marksman
	/// Pixel x we send to the scope component.
	var/given_x = 0
	/// Pixel y we send to the scope component.
	var/given_y = 0
	/// The turf we send to the scope component.
	var/turf/given_turf
	/// The coordinate on our mouseentered, for performance reasons.
	COOLDOWN_DECLARE(coordinate_cooldown)

/atom/movable/screen/fullscreen/scope/proc/on_move(atom/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER

	if(!given_turf)
		return
	var/x_offset = source.loc.x - oldloc.x
	var/y_offset = source.loc.y - oldloc.y
	given_turf = locate(given_turf.x+x_offset, given_turf.y+y_offset, given_turf.z)

/atom/movable/screen/fullscreen/scope/MouseEntered(location, control, params)
	. = ..()
	MouseMove(location, control, params)

/atom/movable/screen/fullscreen/scope/MouseMove(location, control, params)
	if(!marksman?.client || usr != marksman)
		return
	if(!COOLDOWN_FINISHED(src, coordinate_cooldown))
		return
	COOLDOWN_START(src, coordinate_cooldown, 0.2 SECONDS)
	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, VIS_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, VIS_Y))
	var/list/view = getviewsize(marksman.client.view)
	given_x = round(range_modifier * (icon_x - view[1]*world.icon_size/2))
	given_y = round(range_modifier * (icon_y - view[2]*world.icon_size/2))
	given_turf = locate(marksman.x+round(given_x/world.icon_size, 1),marksman.y+round(given_y/world.icon_size, 1),marksman.z)

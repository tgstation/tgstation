/obj/machinery/bofors
	name = "Naval Cannon"
	desc = "Yea, this will kill somebody."
	icon = 'icons/obj/weapons/naval_cannon.dmi' // ICON HERE
	icon_state = 'turret_bofors_8d'//ICON
	base_icon_state = 'turret_bofors_8d'//ICON
	can_buckle = TRUE
	anchored = FALSE
	density = TRUE
	max_integrity = 250
	buckle_lying = 0
	SET_BASE_PIXEL(-8, -8)
	layer = ABOVE_MOB_LAYER
	/// The extra range that this turret gives regarding viewrange.
	var/view_range = 2.5
	/// Sound to play when firing
	var/firesound = 'sound/items/weapons/gun/general/cannon.ogg'
	/// Our ammo box type.
	var/ammo_type = '/obj/item/ammo_casing/mm20x138'
	/// A reference to our current user.
	var/mob/living/current_user
	/// The delay between each shot that is sent downrange.
	var/fire_delay = 0.2 SECONDS
	/// The current timer to fire the next round.
	var/nextshot_timer_id
	/// How much spread we have for projectiles.
	var/spread = 5

	COOLDOWN_DECLARE(trigger_cooldown)

/obj/machinery/bofors/Destroy()
	QDEL_NULL(ammo)
	QDEL_NULL(particles)
	QDEL_NULL(last_target_atom)
	if(current_user)
		unregister_mob(current_user)
		current_user = null
	return ..()

//BUCKLE HOOKS
/obj/machinery/bofors/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	playsound(src,'sound/vehicles/mecha/mechmove01.ogg', 50, TRUE)
	for(var/obj/item/iterating_item in buckled_mob.held_items)
		if(istype(iterating_item, /obj/item/gun_control))
			qdel(iterating_item)
	if(istype(buckled_mob))
		buckled_mob.pixel_x = buckled_mob.base_pixel_x
		buckled_mob.pixel_y = buckled_mob.base_pixel_y
		buckled_mob?.client?.view_size.resetToDefault()
	set_anchored(FALSE)
	unregister_mob(current_user)
	current_user = null
	. = ..()

/obj/machinery/bofors/user_buckle_mob(mob/living/user_to_buckle, mob/buckling_user, check_loc = TRUE)
	if(user_to_buckle.incapacitated || !istype(user_to_buckle))
		return
	user_to_buckle.forceMove(get_turf(src))
	. = ..()
	if(!.)
		return

	register_user(user_to_buckle)

	layer = ABOVE_MOB_LAYER
	setDir(SOUTH)
	playsound(src,'sound/vehicles/mecha/mechmove01.ogg', 50, TRUE)
	set_anchored(TRUE)

	update_positioning()

/obj/machinery/bofors/click_alt(mob/user)
	toggle_cover(user)
	return CLICK_ACTION_SUCCESS

/// Registers all the required signals and sets up the client to work with the turret.
/obj/machinery/bofors/proc/register_user(mob/living/user_to_buckle)
	current_user = user_to_buckle

	for(var/hand_item in user_to_buckle.held_items)
		var/obj/item/item = hand_item
		if(istype(item))
			if(user_to_buckle.dropItemToGround(item))
				var/obj/item/gun_control/turret_control = new(src)
				user_to_buckle.put_in_hands(turret_control)
		else //Entries in the list should only ever be items or null, so if it's not an item, we can assume it's an empty hand
			var/obj/item/gun_control/turret_control = new(src)
			user_to_buckle.put_in_hands(turret_control)

	if(!current_user.client) // I hate byond.
		return

	RegisterSignal(current_user, COMSIG_MOB_LOGIN, PROC_REF(reregister_trigger)) // I really really hate byond.
	RegisterSignal(current_user.client, COMSIG_CLIENT_MOUSEDOWN, PROC_REF(trigger_pulled))
	RegisterSignal(current_user.client, COMSIG_CLIENT_MOUSEUP, PROC_REF(trigger_released))
	RegisterSignal(current_user.client, COMSIG_CLIENT_MOUSEDRAG, PROC_REF(update_target_drag))

	user_to_buckle.client?.view_size.setTo(view_range)
	user_to_buckle.pixel_y = 14

/obj/machinery/bofors/proc/update_target_drag(client/shooting_client, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	if(!istype(over_object))
		return
	if(istype(over_object, /atom/movable/screen))
		return
	last_target_atom = WEAKREF(over_object)

/obj/machinery/bofors/proc/unregister_mob(mob/living/user)
	UnregisterSignal(user, COMSIG_MOB_LOGIN)
	UnregisterSignal(user.client, COMSIG_CLIENT_MOUSEDOWN)
	UnregisterSignal(user.client, COMSIG_CLIENT_MOUSEUP)
	UnregisterSignal(user.client, COMSIG_CLIENT_MOUSEDRAG)

/obj/machinery/bofors/proc/trigger_pulled(client/shooting_client, atom/_target, turf/location, control, params)
	SIGNAL_HANDLER
	if(!check_click_modifiers(params2list(params)))
		return

	if(current_user.throw_mode)
		return

	if(istype(_target, /atom/movable/screen))
		return

	if(nextshot_timer_id) // To prevent spamming timers.
		return

	if(!COOLDOWN_FINISHED(src, trigger_cooldown)) // Prevents spam clicking.
		return

	if(current_user != shooting_client.mob)
		return

	shooting_client.mouse_override_icon = 'icons/effects/mouse_pointers/weapon_pointer.dmi'
	shooting_client.mouse_pointer_icon = shooting_client.mouse_override_icon

	last_target_atom = WEAKREF(_target)

	INVOKE_ASYNC(src, PROC_REF(process_fire), shooting_client, params)

/obj/machinery/bofors/proc/process_fire(client/shooting_client, params)
	if(!shooting_client)
		return

	if(!fire_at(shooting_client, params))
		return

	nextshot_timer_id = addtimer(CALLBACK(src, PROC_REF(process_fire), shooting_client), fire_delay, TIMER_STOPPABLE)

/obj/machinery/bofors/proc/fire_at(client/shooting_client, params)
	if(!current_user)
		return FALSE
	if(!shooting_client)
		return FALSE
	var/atom/target_atom = last_target_atom?.resolve()
	if(QDELETED(target_atom) || !target_atom || !get_turf(target_atom) || istype(target_atom, /atom/movable/screen) || target_atom == src)
		return FALSE
	update_positioning(target_atom)
	if(!can_fire())
		return FALSE
	var/obj/item/ammo_casing/casing = ammo.get_round()
	if(!casing)
		return FALSE

	if(!casing.fire_casing(target_atom, current_user, params, 0, suppressed, null, spread, src))// Actually firing the gun.
		return

	COOLDOWN_START(src, trigger_cooldown, fire_delay)

	playsound(src, firesound, 100)
	casing.forceMove(drop_location()) //Eject casing onto ground.
	casing.bounce_away(TRUE)

	return TRUE

// Used to stop firing after the trigger is released.
/obj/machinery/bofors/proc/trigger_released(client/shooting_client, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	if(nextshot_timer_id)
		deltimer(nextshot_timer_id)
		nextshot_timer_id = null
	shooting_client.mouse_override_icon = null
	shooting_client.mouse_pointer_icon = shooting_client.mouse_override_icon

// Re-registers the required signals to the client after they reconnect.
/obj/machinery/bofors/proc/reregister_trigger(mob/source_mob)
	SIGNAL_HANDLER
	RegisterSignal(source_mob, COMSIG_CLIENT_MOUSEDOWN, PROC_REF(trigger_pulled), TRUE)
	RegisterSignal(source_mob.client, COMSIG_CLIENT_MOUSEUP, PROC_REF(trigger_released), TRUE)
	RegisterSignal(current_user.client, COMSIG_CLIENT_MOUSEDRAG, PROC_REF(update_target_drag), TRUE)

/obj/machinery/bofors/proc/check_click_modifiers(modifiers)
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		return FALSE
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		return FALSE
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		return FALSE
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		return FALSE
	if(LAZYACCESS(modifiers, ALT_CLICK))
		return FALSE
	return TRUE

/obj/machinery/bofors/proc/update_positioning(atom/target_atom)
	if(!current_user)
		return FALSE

	var/client/controlling_client = current_user.client
	if(controlling_client)
		if(!target_atom)
			target_atom = controlling_client.mouse_object_ref?.resolve()
		var/turf/target_turf = get_turf(target_atom)
		if(istype(target_turf)) //They're hovering over something in the map.
			direction_track(current_user, target_turf)

/obj/machinery/bofors/proc/direction_track(mob/user, atom/targeted)
	if(user.incapacitated)
		return
	setDir(get_dir(src, targeted))
	user.setDir(dir)
	switch(dir)
		if(NORTH)
			layer = BELOW_MOB_LAYER
			plane = GAME_PLANE
			user.pixel_x = 0
			user.pixel_y = -14
		if(NORTHEAST)
			layer = BELOW_MOB_LAYER
			plane = GAME_PLANE
			user.pixel_x = -18
			user.pixel_y = -8
		if(EAST)
			layer = ABOVE_MOB_LAYER
			user.pixel_x = -22
			user.pixel_y = 0
		if(SOUTHEAST)
			layer = BELOW_MOB_LAYER
			plane = GAME_PLANE
			user.pixel_x = -18
			user.pixel_y = 14
		if(SOUTH)
			layer = ABOVE_MOB_LAYER
			user.pixel_x = 0
			user.pixel_y = 22
		if(SOUTHWEST)
			layer = BELOW_MOB_LAYER
			plane = GAME_PLANE
			user.pixel_x = 18
			user.pixel_y = 14
		if(WEST)
			layer = ABOVE_MOB_LAYER
			user.pixel_x = 22
			user.pixel_y = 0
		if(NORTHWEST)
			layer = BELOW_MOB_LAYER
			plane = GAME_PLANE
			user.pixel_x = 18
			user.pixel_y = -8


/// DEPLOYABLE TURRET (FORMERLY MANNED TURRET)
//All of this file is five year old shitcode, and I'm too scared to touch more than I have to

/obj/machinery/deployable_turret
	name = "machine gun turret"
	desc = "While the trigger is held down, this gun will redistribute recoil to allow its user to easily shift targets."
	icon = 'icons/obj/weapons/turrets.dmi'
	icon_state = "machinegun"
	can_buckle = TRUE
	anchored = FALSE
	density = TRUE
	max_integrity = 100
	buckle_lying = 0
	layer = ABOVE_MOB_LAYER
	var/view_range = 2.5
	var/cooldown = 0
	/// The projectile that the turret fires
	var/projectile_type = /obj/projectile/bullet/manned_turret
	/// Delay between shots in a burst
	var/rate_of_fire = 1
	/// Number of shots fired from one click
	var/number_of_shots = 40
	/// How long it takes for the gun to allow firing after a burst
	var/cooldown_duration = 9 SECONDS
	var/atom/target
	var/turf/target_turf
	var/warned = FALSE
	var/list/calculated_projectile_vars
	/// Sound to play at the end of a burst
	var/overheatsound = 'sound/items/weapons/sear.ogg'
	/// Sound to play when firing
	var/firesound = 'sound/items/weapons/gun/smg/shot.ogg'
	/// If using a wrench on the turret will start undeploying it
	var/can_be_undeployed = FALSE
	/// What gets spawned if the object is undeployed
	var/obj/spawned_on_undeploy
	/// How long it takes for a wrench user to undeploy the object
	var/undeploy_time = 3 SECONDS
	/// If TRUE, the turret will not become unanchored when not mounted
	var/always_anchored = FALSE

/obj/machinery/deployable_turret/Initialize(mapload)
	. = ..()
	if(always_anchored)
		set_anchored(TRUE)

/obj/machinery/deployable_turret/Destroy()
	target = null
	target_turf = null
	return ..()

/// Undeploying, for when you want to move your big dakka around
/obj/machinery/deployable_turret/wrench_act(mob/living/user, obj/item/wrench/used_wrench)
	if(!can_be_undeployed)
		return ITEM_INTERACT_SKIP_TO_ATTACK
	if(!ishuman(user))
		return ITEM_INTERACT_SKIP_TO_ATTACK
	used_wrench.play_tool_sound(user)
	user.balloon_alert(user, "undeploying...")
	if(!do_after(user, undeploy_time))
		return ITEM_INTERACT_BLOCKING
	var/obj/undeployed_object = new spawned_on_undeploy()
	//Keeps the health the same even if you redeploy the gun
	undeployed_object.modify_max_integrity(max_integrity)
	if(!user.put_in_hands(undeployed_object))
		undeployed_object.forceMove(loc)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

//BUCKLE HOOKS

/obj/machinery/deployable_turret/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	playsound(src,'sound/vehicles/mecha/mechmove01.ogg', 50, TRUE)
	for(var/obj/item/I in buckled_mob.held_items)
		if(istype(I, /obj/item/gun_control))
			qdel(I)
	if(istype(buckled_mob))
		buckled_mob.pixel_x = buckled_mob.base_pixel_x
		buckled_mob.pixel_y = buckled_mob.base_pixel_y
		if(buckled_mob.client)
			buckled_mob.client.view_size.resetToDefault()
	if(!always_anchored)
		set_anchored(FALSE)
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)

/obj/machinery/deployable_turret/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(user.incapacitated || !istype(user))
		return
	M.forceMove(get_turf(src))
	. = ..()
	if(!.)
		return
	for(var/V in M.held_items)
		var/obj/item/I = V
		if(istype(I))
			if(M.dropItemToGround(I))
				var/obj/item/gun_control/TC = new(src)
				M.put_in_hands(TC)
		else //Entries in the list should only ever be items or null, so if it's not an item, we can assume it's an empty hand
			var/obj/item/gun_control/TC = new(src)
			M.put_in_hands(TC)
	M.pixel_y = 14
	layer = ABOVE_MOB_LAYER
	setDir(SOUTH)
	playsound(src,'sound/vehicles/mecha/mechmove01.ogg', 50, TRUE)
	set_anchored(TRUE)
	if(M.client)
		M.client.view_size.setTo(view_range)
	START_PROCESSING(SSfastprocess, src)

/obj/machinery/deployable_turret/process()
	if (!update_positioning())
		return PROCESS_KILL

/obj/machinery/deployable_turret/proc/update_positioning()
	if (!LAZYLEN(buckled_mobs))
		return FALSE
	var/mob/living/controller = buckled_mobs[1]
	if(!istype(controller))
		return FALSE
	var/client/controlling_client = controller.client
	if(controlling_client)
		var/modifiers = params2list(controlling_client.mouseParams)
		var/atom/target_atom = controlling_client.mouse_object_ref?.resolve()
		var/turf/target_turf = get_turf(target_atom)
		if(istype(target_turf)) //They're hovering over something in the map.
			direction_track(controller, target_turf)
			calculated_projectile_vars = calculate_projectile_angle_and_pixel_offsets(controller, target_turf, modifiers)

/obj/machinery/deployable_turret/proc/direction_track(mob/user, atom/targeted)
	if(user.incapacitated)
		return
	setDir(get_dir(src,targeted))
	user.setDir(dir)
	switch(dir)
		if(NORTH)
			layer = BELOW_MOB_LAYER
			user.pixel_x = 0
			user.pixel_y = -14
		if(NORTHEAST)
			layer = BELOW_MOB_LAYER
			user.pixel_x = -8
			user.pixel_y = -4
		if(EAST)
			layer = ABOVE_MOB_LAYER
			user.pixel_x = -14
			user.pixel_y = 0
		if(SOUTHEAST)
			layer = BELOW_MOB_LAYER
			user.pixel_x = -8
			user.pixel_y = 4
		if(SOUTH)
			layer = ABOVE_MOB_LAYER
			user.pixel_x = 0
			user.pixel_y = 14
		if(SOUTHWEST)
			layer = BELOW_MOB_LAYER
			user.pixel_x = 8
			user.pixel_y = 4
		if(WEST)
			layer = ABOVE_MOB_LAYER
			user.pixel_x = 14
			user.pixel_y = 0
		if(NORTHWEST)
			layer = BELOW_MOB_LAYER
			user.pixel_x = 8
			user.pixel_y = -4

/obj/machinery/deployable_turret/proc/checkfire(atom/targeted_atom, mob/user)
	target = targeted_atom
	if(target == user || user.incapacitated || target == get_turf(src))
		return
	if(world.time < cooldown)
		if(!warned && world.time > (cooldown - cooldown_duration + rate_of_fire*number_of_shots)) // To capture the window where one is done firing
			warned = TRUE
			playsound(src, overheatsound, 100, TRUE)
		return
	else
		cooldown = world.time + cooldown_duration
		warned = FALSE
		volley(user)

/obj/machinery/deployable_turret/proc/volley(mob/user)
	target_turf = get_turf(target)
	for(var/i in 1 to number_of_shots)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/deployable_turret/, fire_helper), user), i*rate_of_fire)

/obj/machinery/deployable_turret/proc/fire_helper(mob/user)
	if(user.incapacitated || !(user in buckled_mobs))
		return
	update_positioning() //REFRESH MOUSE TRACKING!!
	var/turf/targets_from = get_turf(src)
	if(QDELETED(target))
		target = target_turf
	var/obj/projectile/projectile_to_fire = new projectile_type(targets_from)
	playsound(src, firesound, 75, TRUE)
	projectile_to_fire.aim_projectile(target, targets_from)
	projectile_to_fire.firer = user
	projectile_to_fire.fired_from = src
	projectile_to_fire.fire()

/obj/machinery/deployable_turret/ultimate  // Admin-only proof of concept for autoclicker automatics
	name = "Infinity Gun"
	view_range = 12

/obj/machinery/deployable_turret/ultimate/checkfire(atom/targeted_atom, mob/user)
	target = targeted_atom
	if(target == user || target == get_turf(src))
		return
	target_turf = get_turf(target)
	fire_helper(user)

/obj/machinery/deployable_turret/hmg
	name = "heavy machine gun turret"
	desc = "A heavy caliber machine gun commonly used by Nanotrasen forces, famed for its ability to give people on the receiving end more holes than normal."
	icon_state = "hmg"
	max_integrity = 250
	projectile_type = /obj/projectile/bullet/manned_turret/hmg
	anchored = TRUE
	number_of_shots = 3
	cooldown_duration = 2 SECONDS
	rate_of_fire = 2
	firesound = 'sound/items/weapons/gun/hmg/hmg.ogg'
	overheatsound = 'sound/items/weapons/gun/smg/smgrack.ogg'
	can_be_undeployed = TRUE
	spawned_on_undeploy = /obj/item/deployable_turret_folded

/obj/item/gun_control
	name = "turret controls"
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT | NOBLUDGEON | DROPDEL
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/obj/machinery/deployable_turret/turret

/obj/item/gun_control/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	turret = loc
	if(!istype(turret))
		return INITIALIZE_HINT_QDEL

/obj/item/gun_control/Destroy()
	turret = null
	return ..()

/obj/item/gun_control/CanItemAutoclick()
	return TRUE

/obj/item/gun_control/attack_atom(obj/O, mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	O.attacked_by(src, user)

/obj/item/gun_control/attack(mob/living/M, mob/living/user)
	M.lastattacker = user.real_name
	M.lastattackerckey = user.ckey
	M.attacked_by(src, user)
	add_fingerprint(user)

/obj/item/gun_control/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/obj/machinery/deployable_turret/E = user.buckled
	E.calculated_projectile_vars = calculate_projectile_angle_and_pixel_offsets(user, interacting_with, modifiers)
	E.direction_track(user, interacting_with)
	E.checkfire(interacting_with, user)

/obj/item/gun_control/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return ranged_interact_with_atom(interacting_with, user, modifiers)

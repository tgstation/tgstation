/////// MANNED TURRET ////////

/obj/machinery/manned_turret
	name = "machine gun turret"
	desc = "While the trigger is held down, this gun will redistribute recoil to allow its user to easily shift targets."
	icon = 'icons/obj/turrets.dmi'
	icon_state = "machinegun"
	can_buckle = TRUE
	density = TRUE
	max_integrity = 100
	obj_integrity = 100
	buckle_lying = 0
	layer = ABOVE_MOB_LAYER
	var/view_range = 10
	var/cooldown = 0
	var/projectile_type = /obj/item/projectile/bullet/weakbullet3
	var/rate_of_fire = 1
	var/number_of_shots = 40
	var/cooldown_duration = 90
	var/atom/target
	var/turf/target_turf
	var/warned = FALSE
	var/mouseparams

//BUCKLE HOOKS

/obj/machinery/manned_turret/unbuckle_mob(mob/living/buckled_mob,force = 0)
	playsound(src,'sound/mecha/mechmove01.ogg', 50, 1)
	for(var/obj/item/I in buckled_mob.held_items)
		if(istype(I, /obj/item/gun_control))
			qdel(I)
	if(istype(buckled_mob))
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
		if(buckled_mob.client)
			buckled_mob.client.change_view(world.view)
	anchored = FALSE
	. = ..()

/obj/machinery/manned_turret/user_buckle_mob(mob/living/M, mob/living/carbon/user)
	if(user.incapacitated() || !istype(user))
		return
	M.forceMove(get_turf(src))
	..()
	for(var/V in M.held_items)
		var/obj/item/I = V
		if(istype(I))
			if(M.dropItemToGround(I))
				var/obj/item/gun_control/TC = new /obj/item/gun_control(src)
				M.put_in_hands(TC)
		else	//Entries in the list should only ever be items or null, so if it's not an item, we can assume it's an empty hand
			var/obj/item/gun_control/TC = new /obj/item/gun_control(src)
			M.put_in_hands(TC)
	M.pixel_y = 14
	layer = ABOVE_MOB_LAYER
	setDir(SOUTH)
	playsound(src,'sound/mecha/mechmove01.ogg', 50, 1)
	anchored = TRUE
	if(user.client)
		user.client.change_view(view_range)

/obj/item/gun_control
	name = "turret controls"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	flags = ABSTRACT | NODROP | NOBLUDGEON
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/obj/machinery/manned_turret/turret

/obj/item/gun_control/New(obj/machinery/manned_turret/MT)
	if(MT)
		turret = MT
	else
		qdel(src)

/obj/item/gun_control/CanItemAutoclick()
	return 1

/obj/item/gun_control/attack_obj(obj/O, mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	O.attacked_by(src, user)

/obj/item/gun_control/attack(mob/living/M, mob/living/user)
	user.lastattacked = M
	M.lastattacker = user
	M.attacked_by(src, user)
	add_fingerprint(user)

/obj/item/gun_control/afterattack(atom/targeted_atom, mob/user, flag, params)
	..()
	var/obj/machinery/manned_turret/E = user.buckled
	E.setDir(get_dir(E,targeted_atom))
	user.setDir(E.dir)
	E.mouseparams = params
	switch(E.dir)
		if(NORTH)
			E.layer = BELOW_MOB_LAYER
			user.pixel_x = 0
			user.pixel_y = -14
		if(NORTHEAST)
			E.layer = BELOW_MOB_LAYER
			user.pixel_x = -8
			user.pixel_y = -4
		if(EAST)
			E.layer = ABOVE_MOB_LAYER
			user.pixel_x = -14
			user.pixel_y = 0
		if(SOUTHEAST)
			E.layer = BELOW_MOB_LAYER
			user.pixel_x = -8
			user.pixel_y = 4
		if(SOUTH)
			E.layer = ABOVE_MOB_LAYER
			user.pixel_x = 0
			user.pixel_y = 14
		if(SOUTHWEST)
			E.layer = BELOW_MOB_LAYER
			user.pixel_x = 8
			user.pixel_y = 4
		if(WEST)
			E.layer = ABOVE_MOB_LAYER
			user.pixel_x = 14
			user.pixel_y = 0
		if(NORTHWEST)
			E.layer = BELOW_MOB_LAYER
			user.pixel_x = 8
			user.pixel_y = -4
	E.checkfire(targeted_atom, user)

/obj/machinery/manned_turret/proc/checkfire(atom/targeted_atom, mob/user)
	target = targeted_atom
	if(target == user || target == get_turf(src))
		return
	if(world.time < cooldown)
		if(!warned && world.time > (cooldown - cooldown_duration + rate_of_fire*number_of_shots)) // To capture the window where one is done firing
			warned = TRUE
			playsound(src, 'sound/weapons/sear.ogg', 100, 1)
		return
	else
		cooldown = world.time + cooldown_duration
		warned = FALSE
		volley(user)

/obj/machinery/manned_turret/proc/volley(mob/user)
	target_turf = get_turf(target)
	for(var/i in 1 to number_of_shots)
		addtimer(CALLBACK(src, /obj/machinery/manned_turret/.proc/fire_helper, user), i*rate_of_fire)


/obj/machinery/manned_turret/proc/fire_helper(mob/user)
	if(!src)
		return
	var/turf/targets_from = get_turf(src)
	if(QDELETED(target))
		target = target_turf
	var/obj/item/projectile/P = new projectile_type(targets_from)
	P.current = targets_from
	P.starting = targets_from
	P.firer = user
	P.original = target
	playsound(src, 'sound/weapons/Gunshot_smg.ogg', 75, 1)
	P.preparePixelProjectile(target, target_turf, user, mouseparams, rand(-9, 9))
	P.fire()

/obj/machinery/manned_turret/ultimate  // Admin-only proof of concept for autoclicker automatics
	name = "Infinity Gun"
	view_range = 12
	projectile_type = /obj/item/projectile/bullet/weakbullet3

/obj/machinery/manned_turret/ultimate/checkfire(atom/targeted_atom, mob/user)
	target = targeted_atom
	if(target == user || target == get_turf(src))
		return
	target_turf = get_turf(target)
	fire_helper(user)

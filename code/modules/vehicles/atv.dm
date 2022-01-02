
/obj/vehicle/ridden/atv
	name = "all-terrain vehicle"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-Earth technologies that are still relevant on most planet-bound outposts."
	icon_state = "atv"
	max_integrity = 150
	armor = list(MELEE = 50, BULLET = 25, LASER = 20, ENERGY = 0, BOMB = 50, BIO = 0, FIRE = 60, ACID = 60)
	key_type = /obj/item/key/atv
	integrity_failure = 0.5
	var/static/mutable_appearance/atvcover

/obj/vehicle/ridden/atv/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/atv)
	if(!atvcover)
		atvcover = mutable_appearance(icon, "atvcover", MOB_LAYER + 0.1)

/obj/vehicle/ridden/atv/post_buckle_mob(mob/living/M)
	add_overlay(atvcover)
	return ..()

/obj/vehicle/ridden/atv/post_unbuckle_mob(mob/living/M)
	if(!has_buckled_mobs())
		cut_overlay(atvcover)
	return ..()

//TURRETS!
/obj/vehicle/ridden/atv/turret
	var/obj/machinery/porta_turret/syndicate/vehicle_turret/turret = null

/obj/machinery/porta_turret/syndicate/vehicle_turret
	name = "mounted turret"
	scan_range = 7
	density = FALSE

/obj/vehicle/ridden/atv/turret/Initialize(mapload)
	. = ..()
	turret = new(loc)
	turret.base = src

/obj/vehicle/ridden/atv/turret/Moved()
	. = ..()
	if(!turret)
		return
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	turret.forceMove(our_turf)
	switch(dir)
		if(NORTH)
			turret.pixel_x = base_pixel_x
			turret.pixel_y = base_pixel_y + 4
			turret.layer = ABOVE_MOB_LAYER
			turret.plane = ABOVE_FOV_PLANE
		if(EAST)
			turret.pixel_x = base_pixel_x - 12
			turret.pixel_y = base_pixel_y + 4
			turret.layer = OBJ_LAYER
			turret.plane = GAME_PLANE
		if(SOUTH)
			turret.pixel_x = base_pixel_x
			turret.pixel_y = base_pixel_y + 4
			turret.layer = OBJ_LAYER
			turret.plane = GAME_PLANE
		if(WEST)
			turret.pixel_x = base_pixel_x + 12
			turret.pixel_y = base_pixel_y + 4
			turret.layer = OBJ_LAYER
			turret.plane = GAME_PLANE

/obj/vehicle/ridden/atv/welder_act(mob/living/user, obj/item/I)
	if(atom_integrity >= max_integrity)
		return TRUE
	if(!I.use_tool(src, user, 0, volume=50, amount=1))
		return TRUE
	user.visible_message(span_notice("[user] repairs some damage to [name]."), span_notice("You repair some damage to \the [src]."))
	atom_integrity += min(10, max_integrity-atom_integrity)
	if(atom_integrity == max_integrity)
		to_chat(user, span_notice("It looks to be fully repaired now."))
	return TRUE

/obj/vehicle/ridden/atv/atom_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/atv/process(delta_time)
	if(atom_integrity >= integrity_failure * max_integrity)
		return PROCESS_KILL
	if(DT_PROB(10, delta_time))
		return
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, src)
	smoke.start()

/obj/vehicle/ridden/atv/bullet_act(obj/projectile/P)
	if(prob(50) || !buckled_mobs)
		return ..()
	for(var/m in buckled_mobs)
		var/mob/buckled_mob = m
		buckled_mob.bullet_act(P)
	return TRUE

/obj/vehicle/ridden/atv/atom_destruction()
	explosion(src, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	return ..()

/obj/vehicle/ridden/atv/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

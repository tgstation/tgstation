
/obj/vehicle/ridden/atv
	name = "all-terrain vehicle"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-Earth technologies that are still relevant on most planet-bound outposts."
	icon_state = "atv"
	max_integrity = 150
	armor = list(MELEE = 50, BULLET = 25, LASER = 20, ENERGY = 0, BOMB = 50, BIO = 0, RAD = 0, FIRE = 60, ACID = 60)
	key_type = /obj/item/key
	integrity_failure = 0.5
	var/static/mutable_appearance/atvcover

/obj/vehicle/ridden/atv/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = 1.5
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))
	D.set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	D.set_vehicle_dir_layer(EAST, OBJ_LAYER)
	D.set_vehicle_dir_layer(WEST, OBJ_LAYER)

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

/obj/vehicle/ridden/atv/turret/Initialize()
	. = ..()
	turret = new(loc)
	turret.base = src

/obj/vehicle/ridden/atv/turret/Moved()
	. = ..()
	if(!turret)
		return
	turret.forceMove(get_turf(src))
	switch(dir)
		if(NORTH)
			turret.pixel_x = 0
			turret.pixel_y = 4
			turret.layer = ABOVE_MOB_LAYER
		if(EAST)
			turret.pixel_x = -12
			turret.pixel_y = 4
			turret.layer = OBJ_LAYER
		if(SOUTH)
			turret.pixel_x = 0
			turret.pixel_y = 4
			turret.layer = OBJ_LAYER
		if(WEST)
			turret.pixel_x = 12
			turret.pixel_y = 4
			turret.layer = OBJ_LAYER

/obj/vehicle/ridden/atv/welder_act(mob/living/user, obj/item/I)
	if(obj_integrity >= max_integrity)
		return TRUE
	if(!I.use_tool(src, user, 0, volume=50, amount=1))
		return TRUE
	user.visible_message("<span class='notice'>[user] repairs some damage to [name].</span>", "<span class='notice'>You repair some damage to \the [src].</span>")
	obj_integrity += min(10, max_integrity-obj_integrity)
	if(obj_integrity == max_integrity)
		to_chat(user, "<span class='notice'>It looks to be fully repaired now.</span>")
	return TRUE

/obj/vehicle/ridden/secway/obj_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/atv/process(delta_time)
	if(obj_integrity >= integrity_failure * max_integrity)
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

/obj/vehicle/ridden/atv/obj_destruction()
	explosion(src, -1, 0, 2, 4, flame_range = 3)
	return ..()

/obj/vehicle/ridden/atv/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

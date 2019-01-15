/obj/vehicle/ridden/wheelchair
	name = "wheelchair"
	desc = "A chair with big wheels. It looks like you can move in this on your own."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "wheelchair"
	layer = OBJ_LAYER
	max_integrity = 100
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 30)
	legs_required = 0
<<<<<<< HEAD
	arms_required = 1
=======
	arms_required = 1
>>>>>>> ab43a03a21128f0ec5b9005898ecf5e32a4c6f40
	canmove = TRUE
	density = FALSE
	var/icon_overlay = "wheelchair_overlay"
	var/list/drive_sounds = list('sound/effects/roll.ogg')
	var/mob/living/carbon/human/H
	var/mob/living/user
	movedelay = 8

/obj/vehicle/ridden/wheelchair/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = 2.5
	D.set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
	D.set_vehicle_dir_layer(NORTH, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(EAST, OBJ_LAYER)
	D.set_vehicle_dir_layer(WEST, OBJ_LAYER)

/obj/vehicle/ridden/wheelchair/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE, CALLBACK(src, .proc/can_user_rotate),CALLBACK(src, .proc/can_be_rotated),null)

/obj/vehicle/ridden/wheelchair/Destroy()
	if(obj_integrity <= 0)
		new /obj/item/stack/rods(drop_location(), 1)
		new /obj/item/stack/sheet/plasteel(drop_location(), 1)
	if(has_buckled_mobs())
		var/mob/living/carbon/H = buckled_mobs[1]
		unbuckle_mob(H)
	H = null
	user = null
	. = ..()

/obj/vehicle/ridden/wheelchair/buckle_mob(mob/living/H, force = 0, check_loc = 1)
	if(!istype(H))
		return 0
	if(H.get_num_legs() < 2 && H.get_num_arms() <= 0)
		to_chat(H, "<span class='warning'>Your limbless body can't ride the [src].</span>")
		return 0
	. = ..()

/obj/vehicle/ridden/wheelchair/Move(mob/user)
	. = ..()
	overlays = null
	playsound(loc, pick(drive_sounds), 75, 1)
	if(has_buckled_mobs())
		handle_rotation_overlayed()


/obj/vehicle/ridden/wheelchair/post_buckle_mob(mob/user)
	. = ..()
	handle_rotation_overlayed()

/obj/vehicle/ridden/wheelchair/post_unbuckle_mob()
	. = ..()
	overlays = null

/obj/vehicle/ridden/wheelchair/setDir(newdir)
	..()
	handle_rotation(newdir)

/obj/vehicle/ridden/wheelchair/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/wrench))
		return
	else
		. = ..()

/obj/vehicle/ridden/wheelchair/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin to detach the wheels...</span>")
	if(I.use_tool(src, user, 40, volume=50))
		to_chat(user, "<span class='notice'>You detach the wheels and deconstruct the chair.</span>")
		new /obj/item/stack/rods(drop_location(), 6)
		new /obj/item/stack/sheet/plasteel(drop_location(), 4)
		if(has_buckled_mobs())
			var/mob/living/carbon/H = buckled_mobs[1]
			unbuckle_mob(H)
		qdel(src)
		return TRUE

/obj/vehicle/ridden/wheelchair/proc/handle_rotation(direction)
	if(has_buckled_mobs())
		handle_rotation_overlayed()
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(direction)

/obj/vehicle/ridden/wheelchair/proc/handle_rotation_overlayed()
	overlays = null
	var/image/O = image(icon = icon, icon_state = icon_overlay, layer = FLY_LAYER, dir = src.dir)
	overlays += O


/obj/vehicle/ridden/wheelchair/proc/stopmove()
	if(!canmove)	//To stop to_chat spam
		canmove = TRUE

/obj/vehicle/ridden/wheelchair/proc/can_be_rotated(mob/user)
	return TRUE

/obj/vehicle/ridden/wheelchair/proc/can_user_rotate(mob/user)
	var/mob/living/L = user

	if(istype(L))
		if(!user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
			return FALSE
		else
			return TRUE
	else if(isobserver(user) && CONFIG_GET(flag/ghost_interaction))
		return TRUE

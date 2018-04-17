/obj/vehicle/ridden/wheelchair
	name = "Wheelchair"
	desc = "A chair with big wheels. It looks like you can move in this on your own."
	icon = 'hippiestation/icons/obj/vehicles.dmi'
	icon_state = "wheelchair"
	layer = OBJ_LAYER
	max_integrity = 100
	var/icon_overlay = "wheelchair_overlay"
	var/list/drive_sounds = list('sound/effects/roll.ogg')
	var/mob/living/carbon/human/H
	var/mob/living/user
	legs_required = 0	//You'll probably be using this if you don't have legs
	arms_requires = 0	//We'll be doing our own checks
	canmove = TRUE
	density = FALSE		//Thought I couldn't fix this one easily, phew

/obj/vehicle/ridden/wheelchair/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = 0
	D.set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
	D.set_vehicle_dir_layer(NORTH, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(EAST, OBJ_LAYER)
	D.set_vehicle_dir_layer(WEST, OBJ_LAYER)

/obj/vehicle/ridden/wheelchair/ComponentInitialize()	//Since it's technically a chair I want it to have chair properties
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE, CALLBACK(src, .proc/can_user_rotate),CALLBACK(src, .proc/can_be_rotated),null)

/obj/vehicle/ridden/wheelchair/examine(mob/user)
	..()
	if(resistance_flags & ON_FIRE)
		to_chat(user, "<span class='warning'>It's on fire!</span>")
	var/healthpercent = obj_integrity/max_integrity * 100
	switch(healthpercent)
		if(50 to 99)
			to_chat(user,  "It looks slightly damaged.")
		if(25 to 50)
			to_chat(user,  "It appears heavily damaged.")
		if(0 to 25)
			to_chat(user,  "<span class='warning'>It's falling apart!</span>")

/obj/vehicle/ridden/wheelchair/Destroy()
	src = new(drop_location())
	new /obj/item/stack/rods(drop_location(), 1)
	new /obj/item/stack/sheet/metal(drop_location(), 1)
	qdel(src)

	..()


/obj/vehicle/ridden/wheelchair/driver_move(mob/user, direction)
	var/mob/living/carbon/human/H = user
	if(istype(H))
		if(!H.get_num_arms() && canmove)
			to_chat(H, "<span class='warning'>You can't move the wheels without arms!</span>")
			canmove = FALSE
			addtimer(CALLBACK(src, .proc/stopmove), 20)
			return FALSE
		else
			var/datum/component/riding/D = LoadComponent(/datum/component/riding)
			D.vehicle_move_delay = 10/H.get_num_arms()
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

/obj/vehicle/ridden/wheelchair/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin to detach the wheels...</span>")
	if(I.use_tool(src, user, 40, volume=50))
		var/obj/vehicle/ridden/wheelchair/W = src
		to_chat(user, "<span class='notice'>You detach the wheels and deconstruct the chair.</span>")
		src = new(drop_location())
		new /obj/item/stack/rods(drop_location(), 6)
		new /obj/item/stack/sheet/metal(drop_location(), 4)
		if(has_buckled_mobs())
			var/mob/living/carbon/H = buckled_mobs[1]
			unbuckle_mob(H)
		qdel(W)
	else
		return		//This should stop the wheelchair getting attacked if you move away prematurely

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
	return FALSE
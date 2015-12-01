
/turf/simulated/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0
	layer = 2
	dynamic_lighting = 1 //We dynamic lighting now

	soot_type = null
	melt_temperature = 0 // Doesn't melt.

/turf/simulated/shuttle/wall
	name = "wall"
	icon_state = "wall1"
	opacity = 1
	density = 1
	blocks_air = 1
	explosion_block = 2

/turf/simulated/shuttle/wall/shuttle_rotate(angle) //delete this when autosmooth is added
	src.transform = turn(src.transform, angle)

/turf/simulated/shuttle/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.delayNextAttack(8)
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(istype(W,/obj/item/weapon/solder) && bullet_marks)
		var/obj/item/weapon/solder/S = W
		if(!S.remove_fuel(bullet_marks*2,user))
			return
		playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		to_chat(user, "<span class='notice'>You remove the bullet marks with \the [W].</span>")
		bullet_marks = 0
		icon = initial(icon)
	..()

/turf/simulated/shuttle/wall/cultify()
	ChangeTurf(/turf/simulated/wall/cult)
	turf_animation('icons/effects/effects.dmi',"cultwall",0,0,MOB_LAYER-1)
	return

/turf/simulated/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/simulated/shuttle/floor/ex_act(severity)
	switch(severity)
		if(1.0)
			new/obj/effect/decal/cleanable/soot(src)
		if(2.0)
			if(prob(65))
				new/obj/effect/decal/cleanable/soot(src)
		if(3.0)
			if(prob(20))
				new/obj/effect/decal/cleanable/soot(src)
			return
	return

/turf/simulated/shuttle/floor/cultify()
	if((icon_state != "cult")&&(icon_state != "cult-narsie"))
		name = "engraved floor"
		icon_state = "cult"
		turf_animation('icons/effects/effects.dmi',"cultfloor",0,0,MOB_LAYER-1)
	return

/turf/simulated/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"

/turf/simulated/shuttle/floor4 // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "Brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"

/turf/simulated/shuttle/floor4/ex_act(severity)
	switch(severity)
		if(1.0)
			new/obj/effect/decal/cleanable/soot(src)
		if(2.0)
			if(prob(65))
				new/obj/effect/decal/cleanable/soot(src)
		if(3.0)
			if(prob(20))
				new/obj/effect/decal/cleanable/soot(src)
			return
	return

/turf/simulated/shuttle/floor4/cultify()
	if((icon_state != "cult")&&(icon_state != "cult-narsie"))
		name = "engraved floor"
		icon_state = "cult"
		turf_animation('icons/effects/effects.dmi',"cultfloor",0,0,MOB_LAYER-1)
	return

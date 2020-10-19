/obj/structure/cannon
	name = "cannon"
	density = TRUE
	anchored = FALSE
	icon_state = "falconet_patina"
	max_integrity = 300
	var/obj/item/stack/cannonball/loaded_cannonball = null
	var/charge_ignited = FALSE
	var/fire_delay = 15
	var/charge_size = 15

/obj/structure/cannon/Initialize()
	. = ..()
	create_reagents(15)

/obj/structure/cannon/wash(clean_types)
	. = ..()
	//if(clean_types & CLEAN_SCRUB)

/obj/structure/cannon/proc/fire()
	charge_ignited = FALSE
	for(var/mob/M in urange(10, src))
		if(!M.stat)
			shake_camera(M, 3, 1)

		playsound(src, break_sound, 50, TRUE)
	if(loaded_cannonball)
		var/obj/projectile/fired_projectile = new loaded_cannonball.projectile_type(get_turf(src))
		QDEL_NULL(loaded_cannonball)
		fired_projectile.firer = src
		fired_projectile.fired_from = src
		fired_projectile.fire(dir2angle(dir))
	//remove all reagent here

/obj/structure/cannon/attackby(obj/item/W, mob/user, params)
	var/ignition_message = W.ignition_effect(src, user)
	if(istype(W, /obj/item/stack/cannonball))
		if(loaded_cannonball)
			to_chat(user, "<span class='warning'>[src] is already loaded!</span>")
			return
		else
			var/obj/item/stack/cannonball/cannoneers_balls = W
			loaded_cannonball = new cannoneers_balls.type(src, 1)
			loaded_cannonball.copy_evidences(cannoneers_balls)
			to_chat(user, "<span class='notice'>You load a [cannoneers_balls.singular_name] into [src].</span>")
			cannoneers_balls.use(1, transfer = TRUE)
			return
	else if(ignition_message)
		visible_message(ignition_message)
		log_game("Cannon fired by [key_name(user)] in [AREACOORD(src)]")
		addtimer(CALLBACK(src, .proc/fire), fire_delay)
		charge_ignited = TRUE
		return

	else if(istype(W, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/powder_keg = W
		if(!(powder_keg.reagent_flags & OPENCONTAINER))
			return ..()
		if(istype(powder_keg, /obj/item/reagent_containers/glass/rag))
			return ..()

		else if(!powder_keg.reagents.total_volume)
			to_chat(user, "<span class='warning'>[powder_keg] is empty!</span>")
			return
		else if(reagents.total_volume == charge_size)
			to_chat(user, "<span class='warning'>[src] already contains a full charge of powder! It would be unwise to add more.</span>")
			return

		else
			powder_keg.reagents.trans_to(src, min(15-reagents.total_volume, powder_keg.reagents.total_volume))
			to_chat(user, "<span class='notice'>You load [src] with a charge of powder from [powder_keg].</span>")
			return
	..()

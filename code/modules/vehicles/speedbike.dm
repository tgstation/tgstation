/obj/vehicle/ridden/speedbike
	name = "Speedbike"
	icon = 'icons/obj/bike.dmi'
	icon_state = "speedbike_blue"
	layer = LYING_MOB_LAYER
	var/cover_iconstate = "cover_blue"

/obj/vehicle/ridden/speedbike/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, cover_iconstate, ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/speedbike)

/obj/vehicle/ridden/speedbike/Move(newloc,move_dir)
	if(has_buckled_mobs())
		new /obj/effect/temp_visual/dir_setting/speedbike_trail(loc,move_dir)
	return ..()

/obj/vehicle/ridden/speedbike/red
	icon_state = "speedbike_red"
	cover_iconstate = "cover_red"

//BM SPEEDWAGON

/obj/vehicle/ridden/speedwagon
	name = "BM Speedwagon"
	desc = "Push it to the limit, walk along the razor's edge."
	icon = 'icons/obj/car.dmi'
	icon_state = "speedwagon"
	layer = LYING_MOB_LAYER
	max_buckled_mobs = 4
	pixel_y = -48
	pixel_x = -48
	///Determines whether we throw all things away when ramming them or just mobs, varedit only
	var/crash_all = FALSE

/obj/vehicle/ridden/speedwagon/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "speedwagon_cover", ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/speedwagon)

/obj/vehicle/ridden/speedwagon/Bump(atom/A)
	. = ..()
	if(!A.density || !has_buckled_mobs())
		return

	if(crash_all)
		if(ismovable(A))
			var/atom/movable/AM = A
			AM.throw_at(get_edge_target_turf(A, dir), 4, 3)
		visible_message(span_danger("[src] crashes into [A]!"))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	if(!ishuman(A))
		return
	var/mob/living/carbon/human/rammed = A
	rammed.Paralyze(100)
	rammed.adjustStaminaLoss(30)
	rammed.apply_damage(rand(20,35), BRUTE)
	if(!crash_all)
		rammed.throw_at(get_edge_target_turf(A, dir), 4, 3)
		visible_message(span_danger("[src] crashes into [rammed]!"))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/vehicle/ridden/speedwagon/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!has_buckled_mobs())
		return
	for(var/atom/A in range(2, src))
		if(!(A in buckled_mobs))
			Bump(A)

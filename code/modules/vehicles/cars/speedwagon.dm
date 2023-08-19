/// Big 3x3 car only available to admins which can run people over
/obj/vehicle/sealed/car/speedwagon
	name = "BM Speedwagon"
	desc = "Push it to the limit, walk along the razor's edge."
	icon = 'icons/obj/toys/car.dmi'
	icon_state = "speedwagon"
	layer = LYING_MOB_LAYER
	max_occupants = 4
	pixel_y = -48
	pixel_x = -48
	enter_delay = 0 SECONDS
	escape_time = 0 SECONDS // Just get out dumbass
	vehicle_move_delay = 0
	///Determines whether we throw all things away when ramming them or just mobs, varedit only
	var/crash_all = FALSE

/obj/vehicle/sealed/car/speedwagon/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "speedwagon_cover", ABOVE_MOB_LAYER))

/obj/vehicle/sealed/car/speedwagon/Bump(atom/bumped)
	. = ..()
	if(!bumped.density || occupant_amount() == 0)
		return

	if(crash_all)
		if(ismovable(bumped))
			var/atom/movable/flying_debris = bumped
			flying_debris.throw_at(get_edge_target_turf(bumped, dir), 4, 3)
		visible_message(span_danger("[src] crashes into [bumped]!"))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	if(!ishuman(bumped))
		return
	var/mob/living/carbon/human/rammed = bumped
	rammed.Paralyze(100)
	rammed.adjustStaminaLoss(30)
	rammed.apply_damage(rand(20,35), BRUTE)
	if(!crash_all)
		rammed.throw_at(get_edge_target_turf(bumped, dir), 4, 3)
		visible_message(span_danger("[src] crashes into [rammed]!"))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/vehicle/sealed/car/speedwagon/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(occupant_amount() == 0)
		return
	for(var/atom/future_statistic in range(2, src))
		if(future_statistic == src)
			continue
		if(!LAZYACCESS(occupants, future_statistic))
			Bump(future_statistic)

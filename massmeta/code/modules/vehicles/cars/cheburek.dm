/// Big 3x3 car only available to admins which can run people over
/obj/vehicle/sealed/car/cheburek
	name = "Cheburek"
	desc = "The Bucket with bolts and nuts"
	icon = 'massmeta/icons/obj/toys/shaha.dmi'
	icon_state = "cheburek" // the name form gta 5 you know?
	layer = LYING_MOB_LAYER
	max_occupants = 4
	pixel_y = -48
	pixel_x = -48
	enter_delay = 0 SECONDS
	escape_time = 0 SECONDS // Just get out dumbass
	vehicle_move_delay = 0
	///Determines whether we throw all things away when ramming them or just mobs, varedit only
	var/crash_all = FALSE
	/// New gopnik-functions
	var/gopmode = FALSE
	var/gopgear = 3 // nowadays it has 3(actually 4) five-speed gearbox, someday it had 5... and also R-ocket one
	/// headlights of Cheburek, front white-yellow(Done but have some [BUG]'s to resolve!) and rear deep-red(TODO)
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 8
	light_power = 2
	light_on = FALSE
	var/headlight_colors = COLOR_YELLOW
	/// turns on and off sound and side lights on repeat
	var/isturnsound_on = FALSE

/obj/vehicle/sealed/car/cheburek/Initialize(mapload)
	. = ..()

/obj/vehicle/sealed/car/cheburek/process()
	if(light_on)
		set_light_color(headlight_colors)

/obj/vehicle/sealed/car/cheburek/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/gop_headlights, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/gopnik, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/gop_turn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/gopnik_gear_up, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/gopnik_gear_down, VEHICLE_CONTROL_DRIVE)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/blyat, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/cheburek/Bump(atom/bumped)
	. = ..()
	if(!bumped.density || occupant_amount() == 0)
		return

	if(crash_all)
		if(ismovable(bumped))
			var/atom/movable/flying_debris = bumped
			flying_debris.throw_at(get_edge_target_turf(bumped, dir), 4, 3)
		visible_message(span_danger("[src] crashes into [bumped]!"))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	if(!ishuman(bumped) || gopgear < 2) // also on low gear you can't bump anyone
		return
	var/mob/living/carbon/human/rammed = bumped
	rammed.Paralyze(100)
	rammed.adjustStaminaLoss(30)
	rammed.apply_damage(rand(15,30), BRUTE)
	if(!crash_all)
		rammed.throw_at(get_edge_target_turf(bumped, dir), 4, 3)
		visible_message(span_danger("[src] crashes into [rammed]!"))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/vehicle/sealed/car/cheburek/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(occupant_amount() == 0)
		return
	for(var/atom/future_statistic in range(2, src))
		if(future_statistic == src)
			continue
		if(!LAZYACCESS(occupants, future_statistic))
			Bump(future_statistic)


/obj/vehicle/sealed/car/cheburek/proc/toggle_gopmode(mob/user)

	if(gopmode) //gopmode activate, deactivate
		cut_overlay(image(icon, "car_stickers", ABOVE_MOB_LAYER))
		visible_message(span_danger("You removed that odd paint from [src]."))
		playsound(src, 'sound/effects/spray.ogg', 30)
		gopmode = FALSE
	else
		add_overlay(image(icon, "car_stickers", ABOVE_MOB_LAYER))
		visible_message(span_danger("You put some odd insulating tape on [src]."))
		playsound(src, 'sound/effects/spray.ogg', 30)
		gopmode = TRUE


/obj/vehicle/sealed/car/cheburek/proc/increase_gop_gear(mob/user)

	if(gopgear < 3)
		if(rand(1,10) >= 9)
			AddElement(/datum/element/waddling)
			playsound(src, pick('massmeta/sounds/vehicles/gear_blyat.ogg', 'massmeta/sounds/vehicles/gear_fault.ogg', 'massmeta/sounds/vehicles/gear_nah.ogg', 'massmeta/sounds/vehicles/gear_fault2.ogg', 'massmeta/sounds/vehicles/gear_fault3.ogg'), 50)
			addtimer(CALLBACK(src, PROC_REF(revert_waddling)), 1 SECONDS)
		else
			playsound(src, 'sound/mecha/mechmove04.ogg', 75)

		vehicle_move_delay -= 0.5
		gopgear += 1
	else
		visible_message(span_danger("[src] already on maximum gear!"))

/obj/vehicle/sealed/car/cheburek/proc/decrease_gop_gear(mob/user)

	if(gopgear > 0)
		if(rand(1,10) >= 8) // chance 3 of 10 to hear that funny noise
			AddElement(/datum/element/waddling) // your gears are juggling like a clown do
			playsound(src, pick('massmeta/sounds/vehicles/gear_blyat.ogg', 'massmeta/sounds/vehicles/gear_fault.ogg', 'massmeta/sounds/vehicles/gear_nah.ogg', 'massmeta/sounds/vehicles/gear_fault2.ogg', 'massmeta/sounds/vehicles/gear_fault3.ogg'), 50)
			addtimer(CALLBACK(src, PROC_REF(revert_waddling)), 1 SECONDS)
		else
			playsound(src, 'sound/mecha/mechmove04.ogg', 75)

		vehicle_move_delay += 0.5
		gopgear -= 1
	else
		visible_message(span_danger("[src] already on minumum gear!"))


/obj/vehicle/sealed/car/cheburek/proc/revert_waddling()

	visible_message(span_danger("Uhh, gear finnaly shifted on [src]..."))
	RemoveElement(/datum/element/waddling)


/obj/vehicle/sealed/car/cheburek/proc/car_lights_toggle(mob/user)

	if(!light_on)
		cut_overlay(image(icon, "car_headlights", LYING_MOB_LAYER))
	else
		add_overlay(image(icon, "car_headlights", LYING_MOB_LAYER))


/obj/vehicle/sealed/car/cheburek/proc/toggle_gop_turn(mob/user)

	isturnsound_on = !isturnsound_on
	// start point of endless tiks
	addtimer(CALLBACK(src, PROC_REF(endless_tik)), 0.5 SECONDS)


/obj/vehicle/sealed/car/cheburek/proc/endless_tik()

	if(isturnsound_on)
		playsound(src, 'massmeta/sounds/vehicles/car_turn_signal.ogg', 60)
		cut_overlay(image(icon, "car_blinkers", LYING_MOB_LAYER))
		addtimer(CALLBACK(src, PROC_REF(endless_tak)), 0.5 SECONDS)


/obj/vehicle/sealed/car/cheburek/proc/endless_tak()

	if(isturnsound_on)
		//playsound(src, 'sound/vehicles/car_turn_signal.ogg', 60) // too much noise without delay
		add_overlay(image(icon, "car_blinkers", LYING_MOB_LAYER))
		addtimer(CALLBACK(src, PROC_REF(endless_tik)), 0.5 SECONDS)

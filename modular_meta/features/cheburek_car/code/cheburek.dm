/*
Really big car with 4х4 sprite.

Can run people over.

Can run ALL over in "I DRIVE" mode.

Has gearbox, you can break it, and also fix it by yourself!

It can be used in minor events.

Some memes and gags included.
*/

/obj/vehicle/sealed/car/cheburek
	name = "Cheburek"
	desc = "The cheapest Bucket with bolts and nuts you can afford"
	icon = 'modular_meta/features/cheburek_car/icons/shaha.dmi'
	icon_state = "cheburek" // the name form gta 5, you know?
	layer = LYING_MOB_LAYER
	max_occupants = 4
	pixel_y = -48
	pixel_x = -48
	enter_delay = 1 SECONDS
	escape_time = 1 SECONDS
	vehicle_move_delay = 1.5
	/// It's like a fun-mode in clowncar
	var/gopmode = FALSE
	/// Gearbox fuctions
	var/gopgear = 1 // (0 = parking) nowadays it has 4 working gears in five-speed gearbox (aslo no R-ocket one, sorry), be carefull with it!
	var/gearbox_failure_count = 1 // value between 1..10, 10 - means fully broken
	/// Headlights of Cheburek, front white-yellow (Done, but have some [BUG]'s to resolve!)
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_range = 8
	light_power = 2
	light_on = FALSE
	var/headlight_color = COLOR_LIGHT_YELLOW
	/// Turns on and off sound and side lights on repeat
	var/isturnsound_on = FALSE
	var/blinkers_on = FALSE // aditional variable used for correct blinkers stop
	/// You need to open car bonnet to operate with gearbox
	var/bonnet_isopen = FALSE
	/// blood layer if you made a good Strike!!! [0..3]
	var/blood_layer_intensity = 0
	var/number_of_bumped_mobs = 0
	/// yea, some meme here
	var/last_chosen_meme


/obj/vehicle/sealed/car/cheburek/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/vehicle/sealed/car/cheburek/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "rear_lights", src, alpha=src.alpha)
	. += emissive_appearance(icon, "car_blinkers_emissive", src, alpha=src.alpha)

/obj/vehicle/sealed/car/cheburek/process()
	if(light_on)
		set_light_color(headlight_color)

/obj/vehicle/sealed/car/cheburek/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/blinkers, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/gear_up, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/gear_down, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/cheburek/Bump(atom/bumped)
	. = ..()
	if(!bumped.density || occupant_amount() == 0)
		return
	if(gopmode) // special feature for meme, looks bad but okayage
		if(ismovable(bumped))
			var/atom/movable/flying_debris = bumped
			flying_debris.throw_at(get_edge_target_turf(bumped, dir), 4, 3)
		visible_message(span_danger("[src] crashes into [bumped]!"))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	if(!ishuman(bumped) || gopgear < 3) // also on low gear [0-1-2] you can't bump anyone
		return
	if(gopgear >= 3) // if you bump too much - gear may switch down
		if(prob(20))
			visible_message(span_boldwarning("Gearbox randomly switched itself!"))
			decrease_gear()
	var/mob/living/carbon/human/rammed = bumped
	rammed.Paralyze(80)
	rammed.adjustStaminaLoss(30)
	rammed.apply_damage(rand(15,30), BRUTE)
	if(!gopmode)
		if(prob(5) && blood_layer_intensity < 3)
			if(blood_layer_intensity != 0)
				cut_overlay(image(icon, "blood_[blood_layer_intensity]", LYING_MOB_LAYER))
			blood_layer_intensity++
			add_overlay(image(icon, "blood_[blood_layer_intensity]", LYING_MOB_LAYER))
			if(blood_layer_intensity == 3)
				headlight_color = COLOR_RED_LIGHT // muhahahah
				visible_message(span_userdanger("А terrible roar you heard from the engine, but it was good"))
				gearbox_failure_count = 0
				// maybe here make some sort of an achivement?
		rammed.throw_at(get_edge_target_turf(bumped, dir), 4, 3)
		visible_message(span_danger("[src] crashes into [rammed]!"))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
		number_of_bumped_mobs++

/obj/vehicle/sealed/car/cheburek/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(occupant_amount() == 0)
		return
	for(var/atom/future_statistic in range(2, src))
		if(future_statistic == src)
			continue
		if(!LAZYACCESS(occupants, future_statistic))
			Bump(future_statistic)

/obj/vehicle/sealed/car/cheburek/atom_destruction(damage_flag)
	playsound(src, 'sound/vehicles/clowncar_fart.ogg', 100)
	STOP_PROCESSING(SSobj,src)
	if(gopmode)
		var/turf/distant_turf = get_ranged_target_turf(get_turf(src), src.dir, 15)
		new /obj/effect/immovablerod/driveshaft(
				get_turf(src),
				distant_turf,
				null,
				FALSE
		)
	return ..()

///////////////////////
/////Damage Events/////
///////////////////////

/obj/vehicle/sealed/car/cheburek/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(prob(50))
		switch(rand(1,3))
			if(1)
				visible_message(span_danger("[src] spews out a ton of oil!")) // engine oil leak (danger flammable!)
				RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(cover_in_oil))
				addtimer(CALLBACK(src, PROC_REF(stop_dropping_oil)), 1 SECONDS)
			if(2)
				visible_message(span_danger("Semki packet drops out of [src]."))
				new /obj/item/food/semki(loc)
			if(3)
				visible_message(span_danger("[src] spews out a ton of fuel!")) // fuel tank leak (danger really flammable!)
				RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(cover_in_fuel))
				addtimer(CALLBACK(src, PROC_REF(stop_dropping_fuel)), 1 SECONDS)

///Leak oil when the cheburek moves if was damaged
/obj/vehicle/sealed/car/cheburek/proc/cover_in_oil()
	SIGNAL_HANDLER
	new /obj/effect/decal/cleanable/oil/slippery(loc)

///Stops dropping oil after the time has run up
/obj/vehicle/sealed/car/cheburek/proc/stop_dropping_oil()
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

///Leak fuel when the cheburek moves if was damaged
/obj/vehicle/sealed/car/cheburek/proc/cover_in_fuel()
	SIGNAL_HANDLER
	new /obj/effect/decal/cleanable/fuel_pool(loc)

///Stops dropping fuel after the time has run up
/obj/vehicle/sealed/car/cheburek/proc/stop_dropping_fuel()
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

/obj/vehicle/sealed/car/cheburek/attacked_by(obj/item/item, mob/living/user)
	. = ..()
	if(istype(item, /obj/item/food/semki))
		var/obj/item/food/semki/semki = item
		atom_integrity += min(50, max_integrity-atom_integrity)
		to_chat(user, span_danger("You use the [semki] to repair [src]!"))
		qdel(semki)

//////////////////////////////////////////////////////
/////Actions with objects (emag, crowbar, wrench)/////
//////////////////////////////////////////////////////

/obj/vehicle/sealed/car/cheburek/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	add_overlay(image(icon, "car_stickers", ABOVE_MOB_LAYER)) // you can't rewert it
	if(bonnet_isopen)
		add_overlay(image(icon, "open_bonnet_stickers", ABOVE_MOB_LAYER))
	else
		add_overlay(image(icon, "close_bonnet_stickers", ABOVE_MOB_LAYER))
	playsound(src, 'modular_meta/features/cheburek_car/sound/gopnik_laught.ogg', 66)
	balloon_alert(user, "some odd insulating tape appeared on [src].")
	visible_message(span_userdanger("You hear a terrible roar from under the bottom of the car"))
	name = "Cheburek Chad"
	desc = "This is a verified Slavic Сar, that's all you need to know"
	initialize_controller_action_type(/datum/action/vehicle/sealed/gopnik, VEHICLE_CONTROL_DRIVE) // oh no...

/obj/vehicle/sealed/car/cheburek/crowbar_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return
	. = TRUE
	// add fov?

	if(tool.use_tool(src, user, 0.5 SECONDS, volume=20))
		if(bonnet_isopen)
			bonnet_isopen = !bonnet_isopen
			cut_overlay(image(icon, "car_openbonnet", LYING_MOB_LAYER))
			if(obj_flags & EMAGGED)
				cut_overlay(image(icon, "open_bonnet_stickers", ABOVE_MOB_LAYER))
				add_overlay(image(icon, "close_bonnet_stickers", ABOVE_MOB_LAYER))
			playsound(src, 'modular_meta/features/cheburek_car/sound/close_bonnet.ogg', 50)
		else
			bonnet_isopen = !bonnet_isopen
			add_overlay(image(icon, "car_openbonnet", LYING_MOB_LAYER))
			if(obj_flags & EMAGGED)
				cut_overlay(image(icon, "close_bonnet_stickers", ABOVE_MOB_LAYER))
				add_overlay(image(icon, "open_bonnet_stickers", ABOVE_MOB_LAYER))
			playsound(src, 'modular_meta/features/cheburek_car/sound/open_bonnet.ogg', 50)

/obj/vehicle/sealed/car/cheburek/wrench_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return
	. = TRUE
	if(DOING_INTERACTION(user, src))
		balloon_alert(user, "you're already repairing gearbox!")
		return
	if(!bonnet_isopen)
		balloon_alert(user, "open bonnet firstly")
		return
	if(gearbox_failure_count <= 1)
		balloon_alert(user, "it's not damaged!")
		return
	user.balloon_alert_to_viewers("started fixing gearbox of [src]", "started repairing [src]")
	audible_message(span_hear("You hear the bolts and nuts falling onto the floor."))
	var/did_the_thing
	while(gearbox_failure_count > 1)
		if(tool.use_tool(src, user, 2.5 SECONDS, volume=50))
			did_the_thing = TRUE
			gearbox_failure_count--
			canmove = TRUE
			audible_message(span_hear("You hear odd metal noises."))
			if(prob(5))
				user.visible_message(
					span_warning("[user] pinched his finger in gears"),
					span_userdanger("In a moment you feel extremly pain in you finger"),
					span_hear("You hear how idiot is screaming"),
				)
				user.apply_damage(20, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
				user.apply_damage(40, STAMINA)
				user.emote("scream")

		else
			break
	if(did_the_thing)
		user.balloon_alert_to_viewers("[(gearbox_failure_count <= 1) ? "fully" : "partially"] repaired [src]")
	else
		user.balloon_alert_to_viewers("stopped fixing gearbox of [src]", "interrupted the repair!")

////////////////////////////////
/////Some Meme (after emag)/////
////////////////////////////////

/obj/vehicle/sealed/car/cheburek/proc/toggle_gopmode(mob/user)
	if(gopmode)
		switch(last_chosen_meme)
			if(1)
				cut_overlay(image(icon, "some_meme_1", LYING_MOB_LAYER))
			if(2)
				cut_overlay(image(icon, "some_meme_2", LYING_MOB_LAYER))

		cut_overlay(image(icon, "i_drive", LYING_MOB_LAYER))
		visible_message(span_userdanger("I Not Drive."))
		RemoveElement(/datum/element/waddling)
		gopmode = FALSE
		vehicle_move_delay = 1.5

	else
		switch(rand(1,2))
			if(1)
				add_overlay(image(icon, "some_meme_1", LYING_MOB_LAYER))
				last_chosen_meme = 1
			if(2)
				add_overlay(image(icon, "some_meme_2", LYING_MOB_LAYER))
				last_chosen_meme = 2

		visible_message(span_userdanger("I Drive."))
		AddElement(/datum/element/waddling)
		gopmode = TRUE // oh fuck...
		vehicle_move_delay = 5 // too much lags on higher speed
		gopgear = 1

//////////////////////////////
/////Gearbox interactions/////
//////////////////////////////

/obj/vehicle/sealed/car/cheburek/proc/increase_gear(mob/user)
	if(gopmode)
		visible_message(span_boldwarning("RUN! RUN!"))
		return
	if(gopgear == 0 && gearbox_failure_count != 10)
		canmove = TRUE
		playsound(src, 'modular_meta/features/cheburek_car/sound/emergency_brake_release.ogg', 100)
		vehicle_move_delay -= 0.5
		gopgear++
		return
	if(gopgear < 4)
		if(prob(gearbox_failure_count * 10) || prob(33))
			if(gearbox_failure_count == 10)
				if(canmove)
					playsound(src, pick('modular_meta/features/cheburek_car/sound/gear_blyat.ogg', 'modular_meta/features/cheburek_car/sound/gear_nah.ogg'), 100)
					toggle_blinkers()
				canmove = FALSE
				balloon_alert(user, "gearbox broken")
			else
				gearbox_failure_count++
			AddElement(/datum/element/waddling)
			playsound(src, pick('modular_meta/features/cheburek_car/sound/gear_fault.ogg', 'modular_meta/features/cheburek_car/sound/gear_fault2.ogg', 'modular_meta/features/cheburek_car/sound/gear_fault3.ogg'), 50)
			addtimer(CALLBACK(src, PROC_REF(revert_waddling)), 1 SECONDS)
		else
			playsound(src, 'sound/vehicles/mecha/mechmove04.ogg', 75)

		vehicle_move_delay -= 0.5
		gopgear++
	else
		balloon_alert(user, "[src] already on maximum gear!")

/obj/vehicle/sealed/car/cheburek/proc/decrease_gear(mob/user)
	if(gopmode)
		visible_message(span_boldwarning("RUN! RUN!"))
		return
	if(gopgear == 1 && gearbox_failure_count != 10)
		canmove = FALSE
		playsound(src, 'modular_meta/features/cheburek_car/sound/emergency_brake_pull.ogg', 100)
		vehicle_move_delay += 0.5
		gopgear--
		return
	if(gopgear > 1)
		if(prob(gearbox_failure_count * 10) || prob(33))
			if(gearbox_failure_count == 10)
				if(canmove)
					playsound(src, pick('modular_meta/features/cheburek_car/sound/gear_blyat.ogg', 'modular_meta/features/cheburek_car/sound/gear_nah.ogg'), 100)
					toggle_blinkers()
				canmove = FALSE
				balloon_alert(user, "gearbox broken")
			else
				gearbox_failure_count++
			AddElement(/datum/element/waddling) // your gears are juggling like a clown do
			playsound(src, pick('modular_meta/features/cheburek_car/sound/gear_fault.ogg', 'modular_meta/features/cheburek_car/sound/gear_fault2.ogg', 'modular_meta/features/cheburek_car/sound/gear_fault3.ogg'), 50)
			addtimer(CALLBACK(src, PROC_REF(revert_waddling)), 1 SECONDS)
		else
			playsound(src, 'sound/vehicles/mecha/mechmove04.ogg', 75)

		vehicle_move_delay += 0.5
		gopgear--
	else
		balloon_alert(user, "[src] already on parking mode!")

/obj/vehicle/sealed/car/cheburek/proc/revert_waddling()
	visible_message(span_danger("Uhh, gear finnaly shifted on [src]..."))
	RemoveElement(/datum/element/waddling)

/////////////////////////////////
/////Headlights and Blinkers/////
/////////////////////////////////

/obj/vehicle/sealed/car/cheburek/proc/car_lights_toggle(mob/user)
	if(!light_on)
		cut_overlay(image(icon, "car_headlights", LYING_MOB_LAYER))
	else
		add_overlay(image(icon, "car_headlights", LYING_MOB_LAYER))

/obj/vehicle/sealed/car/cheburek/proc/toggle_blinkers(mob/user)
	isturnsound_on = !isturnsound_on
	// start point of endless tiks (blinkers)
	addtimer(CALLBACK(src, PROC_REF(endless_tik)), 0.5 SECONDS)

/obj/vehicle/sealed/car/cheburek/proc/endless_tik()
	if(isturnsound_on)
		playsound(src, 'modular_meta/features/cheburek_car/sound/car_turn_signal.ogg', 60)
		//update_overlays()
		cut_overlay(image(icon, "car_blinkers", LYING_MOB_LAYER))
		blinkers_on = FALSE
		addtimer(CALLBACK(src, PROC_REF(endless_tak)), 0.7 SECONDS)
	else
		if(blinkers_on)
			cut_overlay(image(icon, "car_blinkers", LYING_MOB_LAYER))
			blinkers_on = FALSE

/obj/vehicle/sealed/car/cheburek/proc/endless_tak()
	if(isturnsound_on)
		//playsound(src, 'sound/vehicles/car_turn_signal.ogg', 60) // too much noise without delay
		add_overlay(image(icon, "car_blinkers", LYING_MOB_LAYER))
		blinkers_on = TRUE
		addtimer(CALLBACK(src, PROC_REF(endless_tik)), 0.3 SECONDS)

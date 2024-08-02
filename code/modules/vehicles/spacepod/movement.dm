// brakes, or autostabilize if not driven
/obj/vehicle/sealed/space_pod/process()
	if(isnull(drift_handler))
		return

	var/list/drivers = return_drivers()

	if(drivers)
		var/braking = FALSE
		for(var/mob/driver as anything in drivers)
			if(driver.client?.keys_held["Shift"])
				braking = TRUE
				break

		if (!braking)
			return

	//braking without drivers is half as strong incase you put like a bomb in your trunk or something and jumped out
	drift_handler.stabilize_drift(target_force = 0, stabilization_force = !length(drivers) ? stabilizer_force / 2 : stabilizer_force)

/obj/vehicle/sealed/space_pod/has_gravity(turf/gravity_turf)
	return FALSE //this proc only exists so movement is better

/obj/vehicle/sealed/space_pod/newtonian_move(inertia_angle, instant = FALSE, start_delay = 0, drift_force = 1 NEWTONS, controlled_cap = null)
	return FALSE //no

/obj/vehicle/sealed/space_pod/Move(turf/newloc, direct, glide_size_override)
	if(!isturf(newloc))
		return ..()
	if(isasteroidturf(newloc) || is_space_or_openspace(newloc) || istype(newloc, /turf/open/floor/engine))
		return ..()

/obj/vehicle/sealed/space_pod/vehicle_move(direction)
	. = ..()
	if(!max_speed || !force_per_move || !COOLDOWN_FINISHED(src, cooldown_vehicle_move))
		return
	var/power_used = (STANDARD_BATTERY_CHARGE / 1000 * 3) * (force_per_move / (1 SECONDS))
	for(var/obj/item/pod_equipment/equip as anything in get_all_parts())
		power_used *= equip.movement_power_usage_mult
	if(!use_power(power_used))
		return
	setDir(direction)
	if(isnull(movement))
		movement = GLOB.move_manager.pod_move(src, subsystem = SSnewtonian_movement, flags = MOVEMENT_LOOP_NO_DIR_UPDATE|MOVEMENT_LOOP_IGNORE_GLIDE)
	var/list/coords = dir2offset(direction)
	var/mag = sqrt(coords[1]*coords[1] + coords[2]*coords[2])
	if(mag)
		coords[1] /= mag
		coords[2] /= mag
	movement.x_in = coords[1]
	movement.y_in = coords[2]
	var/acceleration = force_per_move / (1 SECONDS)
	movement.velocity_x	+= coords[1] * acceleration
	movement.velocity_y += coords[2] * acceleration
	movement.velocity_max = max_speed




	COOLDOWN_START(src, cooldown_vehicle_move, 1 DECISECONDS)
	trail.generate_effect()
	after_move(direction)

/obj/vehicle/sealed/space_pod/proc/onSetDir(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	transform = transform.Turn(dir2angle(new_dir) - dir2angle(old_dir))

/obj/vehicle/sealed/space_pod/atom_destruction(damage_flag)
	explosion(loc, heavy_impact_range = 2) //doesnt damage occupants, whether this is a good thing is debatable
	return ..()

/obj/vehicle/sealed/space_pod/Bump(atom/bumped)
	. = ..()
	if(isnull(drift_handler))
		return
	if(drift_handler.drift_force < 6 NEWTONS) // need to be moving at a decent speed for anything to happen
		return

	var/strength = 1 + (drift_handler.drift_force - 6 NEWTONS) * 0.2 // strength of the impact

	playsound(src, 'sound/effects/meteorimpact.ogg', min(40 * strength, 100), TRUE)

	for(var/mob/shake_it in get_hearers_in_range(3, src))
		if(shake_it.stat != DEAD && !isAI(shake_it))
			shake_camera(shake_it, 0.3 SECONDS, min(strength, 2.5))

	if(bumped.resistance_flags & INDESTRUCTIBLE) // damage handling goes past this point
		return

	qdel(drift_handler)

	if(isclosedturf(bumped))
		var/turf/closed/bumped_turf = bumped
		take_damage(strength * 50, BRUTE)
		if(strength > bumped_turf.explosive_resistance + 1) // normal walls have a resistance of 1 and rwalls 2, so you need a speed of at least 5.5 newtons to break a wall and 10.5 to break an rwall
			bumped_turf.ScrapeAway(1, CHANGETURF_INHERIT_AIR)
	else if(isobj(bumped))
		var/obj/bumped_atom = bumped
		take_damage(min(strength * 70, bumped_atom.get_integrity()), BRUTE)
		bumped_atom.take_damage(strength * 50, BRUTE, attack_dir = REVERSE_DIR(dir))
	else if(isliving(bumped))
		var/mob/living/poor_sap = bumped
		take_damage(strength * 40, BRUTE)
		poor_sap.apply_damage(strength * 20, BRUTE)
		var/our_turf = get_turf(src)
		var/throwtarget = get_edge_target_turf(our_turf, get_dir(our_turf, get_step_away(poor_sap, our_turf)))
		poor_sap.safe_throw_at(throwtarget, 3, max(1, strength*0.75), force = MOVE_FORCE_NORMAL*(strength/2))

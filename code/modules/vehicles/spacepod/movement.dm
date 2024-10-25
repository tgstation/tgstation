// brakes, or slow us down if we are not currently actually accelerating
/obj/vehicle/sealed/space_pod/process()
	process_huds()
	if(isnull(drift_handler))
		return

	var/list/drivers = return_drivers()
	var/braking = FALSE

	if(drivers)
		for(var/mob/driver as anything in drivers)
			if(driver.client?.keys_held["Shift"])
				braking = TRUE
				break

	if(drivers && braking)
		drift_handler.stabilize_drift(target_force = 0, stabilization_force = stabilizer_force)
		return // braking takes priority over slowing down

	var/desired_speed = max_speed / 3 * 2
	if(drift_handler.drift_force <= desired_speed || !COOLDOWN_FINISHED(src, passive_movement_cooldown)) //below 2/3rds or not actively accelerating
		return
	drift_handler.stabilize_drift(target_force = desired_speed, stabilization_force = 0.5 NEWTONS)

/obj/vehicle/sealed/space_pod/has_gravity(turf/gravity_turf)
	return FALSE // we need 0g to use space newtonian movement even onstation

/obj/vehicle/sealed/space_pod/Move(turf/newloc, direct, glide_size_override)
	if(!isturf(newloc) || newloc.density || ispodpassable(newloc) || (!newloc.has_gravity() && ispodpassable_nograv(newloc)))
		return ..()
	if(newloc.is_blocked_turf()) //weird silly hack to allow us to ram objects on inaccessible turfs
		var/atom/target
		for(var/atom/movable/thing as anything in newloc.contents)
			if(isnull(target) || ((thing.layer > target.layer || thing.flags_1 & ON_BORDER_1) && !(target.flags_1 & ON_BORDER_1)))
				target = thing
		Bump(target)

/obj/vehicle/sealed/space_pod/vehicle_move(direction)
	. = FALSE
	if(!max_speed || !force_per_move || !COOLDOWN_FINISHED(src, cooldown_vehicle_move))
		return
	var/power_used = (STANDARD_BATTERY_CHARGE / 2000) * (force_per_move / (1 SECONDS))
	for(var/obj/item/pod_equipment/equip as anything in get_all_parts())
		power_used *= equip.movement_power_usage_mult
	if(!use_power(power_used))
		return
	COOLDOWN_START(src, passive_movement_cooldown, 5 DECISECONDS)
	if(direction == UP || direction == DOWN)
		return try_step_multiz(direction)
	setDir(direction)
	if(isnull(drift_handler))
		new /datum/drift_handler(src, drift_force = 0)
	drift_handler.stabilize_drift(dir2angle(direction), target_force = max_speed, stabilization_force = force_per_move / (1 SECONDS))
	COOLDOWN_START(src, cooldown_vehicle_move, 1 DECISECONDS)
	trail.generate_effect()
	after_move(direction)
	return TRUE

/obj/vehicle/sealed/space_pod/setDir(new_dir)
	var/old_dir = dir
	transform = transform.Turn(dir2angle(new_dir) - dir2angle(old_dir))
	return ..()

/obj/vehicle/sealed/space_pod/atom_destruction(damage_flag)
	explosion(loc, heavy_impact_range = 2) //doesnt damage occupants, whether this is a good thing is debatable
	return ..()

/obj/vehicle/sealed/space_pod/Bump(atom/bumped)
	. = ..()
	if(isnull(drift_handler) || angle2dir(drift_handler.drifting_loop?.angle) != get_dir(src,bumped))
		return
	if(drift_handler.drift_force < 8 NEWTONS) // need to be moving at a decent speed for anything to happen
		return

	var/saved_force = drift_handler.drift_force
	var/strength = 1 + (drift_handler.drift_force - 8 NEWTONS) * 0.3 // strength of the impact

	playsound(src, 'sound/effects/meteorimpact.ogg', min(40 * strength, 100), TRUE)

	for(var/mob/shake_it in get_hearers_in_range(3, src))
		if(shake_it.stat != DEAD && !isAI(shake_it))
			shake_camera(shake_it, 0.3 SECONDS, min(strength, 2.5))

	if(bumped.resistance_flags & INDESTRUCTIBLE) // damage handling goes past this point
		return

	qdel(drift_handler)

	var/list/occupancy = occupants.Copy()

	if(isclosedturf(bumped))
		var/turf/closed/bumped_turf = bumped
		take_damage(strength * 50, BRUTE)
		if(strength > bumped_turf.explosive_resistance + 1) // normal walls have a resistance of 1 and rwalls 2, so you need a speed of at least 5.5 newtons to break a wall and 10.5 to break an rwall
			bumped_turf.ScrapeAway(1, CHANGETURF_INHERIT_AIR)
	else if(isobj(bumped))
		var/obj/bumped_atom = bumped
		take_damage(min(strength * 70, bumped_atom.get_integrity()), BRUTE)
		bumped_atom.take_damage(strength * 50, BRUTE, attack_dir = REVERSE_DIR(dir))
		//tiny delay for dramatics
		bumped_atom.newtonian_move(angle2dir(dir), instant=TRUE, start_delay=0.2 SECONDS, drift_force = saved_force)
	else if(isliving(bumped))
		var/mob/living/poor_sap = bumped
		take_damage(strength * 40, BRUTE)
		poor_sap.apply_damage(strength * 20, BRUTE)
		var/our_turf = get_turf(src)
		var/throwtarget = get_edge_target_turf(our_turf, get_dir(our_turf, get_step_away(poor_sap, our_turf)))
		poor_sap.safe_throw_at(throwtarget, 3, max(1, strength*0.75), force = MOVE_FORCE_NORMAL*(strength/2))

	if(saved_force > 23 NEWTONS && atom_integrity < 0)
		for(var/mob/living/occupant as anything in occupancy)
			occupant.gib()

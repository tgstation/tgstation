//
// space pods
//

// TODO:
// equipment variants (done? maybe a lock module, finish comms module, and maybe a few proper guns) and their research
// ONCE EVERYTHING IS DONE, add hangar bays, must have 1-3 pods idk, maybe t1 megacells + oxygen tanks, and a manual?? not sure
// research and print costs
// sprites
// replace spawn_equip or add new subtype, but probably the former; to have a more reasonable roundstart loadout
// ALSO DO NOT FORGET TO REMOVE THIS HUGE ASS COMMENT before finishing

// this is the iron variant
/obj/vehicle/sealed/space_pod
	name = "space pod"
	layer = ABOVE_MOB_LAYER
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon = 'icons/mob/rideables/spacepod/pod_small.dmi'
	icon_state = "cockpit_pod" //placeholder
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_on = FALSE
	light_range = 5
	light_power = 1.5
	max_occupants = 2
	max_integrity = 350
	/// Max count of a certain slot. If it is not defined here, it is assumed to be one (1). Use slot_max(slot) to access.
	var/list/slot_max = list(
		POD_SLOT_MISC = 3,
	)
	/// Equipment we have, slot = list(equipment)
	var/list/equipped = list()
	/// is our panel open? required for adding and removing parts
	var/panel_open = FALSE
	/// ion trail effect
	var/datum/effect_system/trail_follow/ion/trail
	// speed vars are here if someone wants to make their own turbo subtype pod or admin abuse
	/// max drift speed we can get via moving intentionally, modified by thrusters
	var/max_speed = 0
	/// Force per 1 second held down, modified by engine
	var/force_per_move = 0
	/// Force per process run to bring us to a halt, modified by thrusters
	var/stabilizer_force = 0

	/// our air tank, used to cycle cabin air
	var/obj/item/tank/internals/cabin_air_tank
	/// our air tank, used to cycle cabin air
	var/datum/gas_mixture/cabin_air = new(TANK_STANDARD_VOLUME * 5)
	/// our battery
	var/obj/item/stock_parts/power_store/battery/cell

	/// mob = list(action)
	var/list/list/equipment_actions = list()


/obj/vehicle/sealed/space_pod/Initialize(mapload, dont_equip)
	. = ..()
	if(!dont_equip)
		spawn_equip()
	trail = new
	trail.auto_process = FALSE
	trail.set_up(src)
	trail.start()
	START_PROCESSING(SSnewtonian_movement, src)
	update_appearance()
	RegisterSignal(src, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(onSetDir))

/// This proc is responsible for outfitting the pod when spawned (admin or otherwise)
/obj/vehicle/sealed/space_pod/proc/spawn_equip()
	equip_item(new /obj/item/pod_equipment/sensors)
	equip_item(new /obj/item/pod_equipment/comms)
	equip_item(new /obj/item/pod_equipment/thrusters/default)
	equip_item(new /obj/item/pod_equipment/engine/default)
	equip_item(new /obj/item/pod_equipment/primary/projectile_weapon/energy/kinetic_accelerator)
	equip_item(new /obj/item/pod_equipment/cargo_hold)
	equip_item(new /obj/item/pod_equipment/warp_drive)
	equip_item(new /obj/item/pod_equipment/lock/pin)
	cabin_air_tank = new /obj/item/tank/internals/oxygen(src)
	cell = new /obj/item/stock_parts/power_store/battery/high(src)

/obj/vehicle/sealed/space_pod/Destroy()
	. = ..()
	QDEL_NULL(trail)
	QDEL_NULL(cabin_air_tank)
	QDEL_LIST_ASSOC_VAL(equipment_actions)
	equipped = null // equipment gets deleted already because its in our contents

/obj/vehicle/sealed/space_pod/atom_destruction(damage_flag)
	explosion(loc, devastation_range = 1, heavy_impact_range = 2)
	return ..()

/obj/vehicle/sealed/space_pod/Bump(atom/bumped)
	. = ..()
	if(isnull(drift_handler))
		return
	if(drift_handler.drift_force < 3 NEWTONS) // need to be moving at a decent speed for anything to happen
		return

	var/strength = 1 + (drift_handler.drift_force - 3 NEWTONS) * 0.2 // strength of the impact

	playsound(src, 'sound/effects/meteorimpact.ogg', min(40 * strength, 100), TRUE)

	for(var/mob/shake_it in get_hearers_in_range(3, src))
		if(shake_it.stat != DEAD && !isAI(shake_it))
			shake_camera(shake_it, 0.3 SECONDS, min(strength, 2.5))

	if(bumped.resistance_flags & INDESTRUCTIBLE) // damage handling goes past this point
		return

	if(isclosedturf(bumped))
		var/turf/closed/bumped_turf = bumped
		take_damage(strength * 100, BRUTE)
		if(strength > bumped_turf.explosive_resistance + 0.5) // normal walls have a resistance of 1 and rwalls 2, so you need a speed of at least 5.5 newtons to break a wall and 10.5 to break an rwall
			bumped_turf.ScrapeAway(1, CHANGETURF_INHERIT_AIR)
	else if(isobj(bumped))
		var/obj/bumped_atom = bumped
		bumped_atom.take_damage(strength * 100, BRUTE, attack_dir = REVERSE_DIR(dir))
		take_damage(strength * 70, BRUTE)
	else if(isliving(bumped))
		var/mob/living/poor_sap = bumped
		take_damage(strength * 50, BRUTE) //weaker cuz i want to see someone ram a dude
		poor_sap.apply_damage(strength * 20, BRUTE)

/obj/vehicle/sealed/space_pod/proc/onSetDir(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	transform = transform.Turn(dir2angle(new_dir) - dir2angle(old_dir))

/obj/vehicle/sealed/space_pod/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/kick_out)
	initialize_controller_action_type(/datum/action/vehicle/sealed/pod_status, VEHICLE_CONTROL_DRIVE)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/climb_out/pod)

/obj/vehicle/sealed/space_pod/update_overlays()
	. = ..()
	. += "window"
	if(panel_open)
		. += "panel_open[!isnull(cabin_air_tank) ? "_t" : ""]"
	for(var/obj/item/pod_equipment/equipment as anything in get_all_parts())
		var/overlay = equipment.get_overlay()
		if(isnull(overlay))
			continue
		. += overlay

/obj/vehicle/sealed/space_pod/mob_try_enter(mob/rider)
	if(!istype(rider))
		return FALSE
	if(!allowed(rider) || !does_lock_permit_it(rider))
		balloon_alert(rider, "no access!")
		return FALSE
	if(!rider.can_perform_action(src, NEED_HANDS)) // you need hands to use the door handle buddy
		return ..()
	if(length(occupants) < max_occupants)
		return ..()
	rider.balloon_alert_to_viewers("kicking driver out!")
	if(!do_after(rider, 5 SECONDS, src))
		return
	for(var/mob/living/driver as anything in return_drivers())
		driver.Knockdown(1 SECONDS)
		mob_exit(driver, randomstep = TRUE)

/obj/vehicle/sealed/space_pod/mob_try_exit(mob/removing, mob/user, silent = FALSE, randomstep = FALSE)
	if(user != removing)
		return ..()
	if(!HAS_TRAIT(removing, TRAIT_RESTRAINED)) // you need hands to use the door handle buddy
		return ..()

/obj/vehicle/sealed/space_pod/container_resist_act(mob/living/user)
	. = ..()
	mob_try_exit(user, user)

/obj/vehicle/sealed/space_pod/mouse_drop_receive(mob/living/dropped, mob/living/dropper, params)
	. = ..()
	if(dropped == dropper || !istype(dropped) || !istype(dropper) || !dropper.can_interact_with(src))
		return
	if(length(occupants) >= max_occupants - max_drivers)
		balloon_alert(dropper, "not enough passenger spots!")
		return
	if(!does_lock_permit_it(dropper))
		return
	dropped.visible_message(span_warning("[dropper] begins forcing [dropped] into [src]!"), span_userdanger("[dropper] begins forcing you into [src]!"))
	if(!do_after(dropper, 4 SECONDS, dropped, extra_checks = CALLBACK(src, PROC_REF(enter_checks))))
		return
	if(!dropped.Adjacent(src))
		return
	mob_enter(dropped, flags = NONE) // force occupancy
	dropped.visible_message(span_warning("[dropped] is forced into [src] by [dropper]!"))


// brakes, or autostabilize if not driven
// figure out a way around it drifting off in space when it shouldnt, perhaps use the move loop directly
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

/obj/vehicle/sealed/space_pod/vehicle_move(direction)
	. = ..()
	if(!max_speed || !force_per_move)
		return
	if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
		return
	var/power_used = (STANDARD_BATTERY_CHARGE / 1000 * 3) * force_per_move
	for(var/obj/item/pod_equipment/equip as anything in get_all_parts())
		power_used *= equip.movement_power_usage_mult
	if(!use_power(power_used))
		return
	setDir(direction)
	if(has_gravity() || !newtonian_move(dir2angle(direction), instant = TRUE, drift_force = force_per_move / (1 SECONDS), controlled_cap = max_speed))
		COOLDOWN_START(src, cooldown_vehicle_move, istype(loc, /turf/open/floor/engine) ? 0.3 SECONDS : 2 SECONDS) //moves much better on engine tiles
		after_move(direction)
		return try_step_multiz(direction)
	COOLDOWN_START(src, cooldown_vehicle_move, 1 DECISECONDS)
	trail.generate_effect()
	after_move(direction)

// atmos
/obj/vehicle/sealed/space_pod/proc/cycle_tank_air(to_tank = FALSE)
	if(isnull(cabin_air_tank))
		return
	var/datum/gas_mixture/from = to_tank ? cabin_air : cabin_air_tank.return_air()
	var/datum/gas_mixture/target = to_tank ? cabin_air_tank.return_air() : cabin_air
	var/datum/gas_mixture/removed = from.remove(from.total_moles())
	if(!removed)
		return
	target.merge(removed)

/obj/vehicle/sealed/space_pod/remove_air(amount)
	return !isnull(cabin_air_tank) ? cabin_air.remove(amount) : ..()
/obj/vehicle/sealed/space_pod/return_air()
	return !isnull(cabin_air_tank) ? cabin_air : ..()
/obj/vehicle/sealed/space_pod/return_analyzable_air()
	return !isnull(cabin_air_tank) ? cabin_air : null // no internal air
/obj/vehicle/sealed/space_pod/return_temperature()
	var/datum/gas_mixture/air = return_air()
	return air?.return_temperature()


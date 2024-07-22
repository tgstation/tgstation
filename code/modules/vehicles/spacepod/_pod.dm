//
// space pods
//

// TODO:
// equipment variants (done? maybe a lock module, finish comms module, and maybe a few proper guns) and their research
// slots: comms (radio and something else), sensors(HUDs or something, mesons??), engine, 1 secondary slot (cargo and shit), 1 primary slot(tools or gun???), 3 misc modules (locks and shit), armor would either be added during construction or as a slot
// power costs, either only megacell or only cell, how would you charge this??
// although im not so sure about power costs i dont know why it would need them but ideally a space pod should be capable of functioning for 10-15 minutes of nonstop acceleration by default
// innate armor potentially, also actual armor and also figure out integrity and inertia_force_weight
// figure out whether this should use action buttons or an UI or a combination of both for equipment
// ALSO DO NOT FORGET TO REMOVE THIS HUGE ASS COMMENT before finishing

// this is the iron variant
/obj/vehicle/sealed/space_pod
	layer = ABOVE_MOB_LAYER
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon = 'icons/mob/rideables/spacepod/pod_small.dmi'
	icon_state = "cockpit_pod" //placeholder
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_on = FALSE
	max_occupants = 2
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
	/// Force per tick movement held down, modified by engine
	var/force_per_move = 0
	/// Force per process run to bring us to a halt, modified by thrusters
	var/stabilizer_force = 0

	/// our air tank, used to cycle cabin air
	var/obj/item/tank/internals/cabin_air_tank
	/// our air tank, used to cycle cabin air
	var/datum/gas_mixture/cabin_air = new(TANK_STANDARD_VOLUME * 5)
	/// our power cell (should this be a megacell only thing or cell only?)
	var/obj/item/stock_parts/power_store/cell/cell

	/// mob = list(action)
	var/list/list/equipment_actions = list()


/obj/vehicle/sealed/space_pod/Initialize(mapload)
	. = ..()
	trail = new
	trail.auto_process = FALSE
	trail.set_up(src)
	trail.start()
	START_PROCESSING(SSnewtonian_movement, src)

/obj/vehicle/sealed/space_pod/Destroy()
	. = ..()
	QDEL_NULL(trail)
	QDEL_NULL(cabin_air_tank)
	QDEL_LIST_ASSOC_VAL(equipment_actions)
	equipped = null // equipment gets deleted already because its in our contents

/obj/vehicle/sealed/space_pod/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/kick_out)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)
	return ..() //eject goes first

/obj/vehicle/sealed/space_pod/update_overlays()
	. = ..()
	var/image/window = iconstate2appearance(icon, "window") //this doesnt work i dont know why
	window.alpha = 200
	. += window
	for(var/obj/item/pod_equipment/equipment as anything in get_all_parts())
		var/overlay = equipment.get_overlay()
		if(isnull(overlay))
			continue
		. += overlay

/obj/vehicle/sealed/space_pod/mob_try_enter(mob/rider)
	if(!istype(rider))
		return FALSE
	if(!rider.can_perform_action(src, NEED_HANDS)) // you need hands to use the door handle buddy
		return ..()
	if(length(occupants) < max_occupants)
		return
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
	if(!istype(dropped) || !istype(dropper) || !dropper.can_interact_with(src))
		return
	if(length(occupants) >= max_occupants - max_drivers)
		balloon_alert(dropper, "not enough passenger spots!")
		return
	dropper.visible_message(span_warning("[dropper] begins forcing [dropped] into [src]!"), span_userdanger("[dropper] begins forcing you into [src]!"))
	if(!do_after(dropper, 4 SECONDS, dropped, extra_checks = CALLBACK(src, PROC_REF(enter_checks))))
		return
	if(!dropped.Adjacent(src))
		return
	mob_enter(dropped, flags = NONE) // force occupancy
	dropper.visible_message(span_warning("[dropped] is forced into [src] by [dropper]!"))


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


/obj/vehicle/sealed/space_pod/vehicle_move(direction)
	. = ..()
	if(!max_speed || !force_per_move)
		return
	if(has_gravity() || !newtonian_move(dir2angle(direction), instant = TRUE, drift_force = force_per_move, controlled_cap = max_speed))
		if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
			return
		COOLDOWN_START(src, cooldown_vehicle_move, istype(loc, /turf/open/floor/engine) ? 0.3 SECONDS : 2 SECONDS) //moves much better on engine tiles
		after_move(direction)
		return try_step_multiz(direction)
	setDir(direction)
	trail.generate_effect()
	after_move(direction)

/obj/vehicle/sealed/space_pod/after_add_occupant(mob/occupant)
	. = ..()
	if(length(occupants) == 1) //first occupant only
		panel_open = FALSE //automatic screws,,,, waow....
		cycle_tank_air()
	for(var/obj/item/pod_equipment/equipment as anything in get_all_parts())
		var/datum/action/action = equipment.create_occupant_actions(occupant, occupants[occupant])
		if(isnull(action))
			continue
		if(islist(action))
			var/list/as_list = action
			for(var/datum/action/actual_action as anything in as_list)
				actual_action.Grant(occupant)
		else
			action.Grant(occupant)
		equipment_actions[occupant] += islist(action) ? action : list(action)

/obj/vehicle/sealed/space_pod/after_remove_occupant(mob/former)
	. = ..()
	if(!length(occupants)) //when everyone exits
		cycle_tank_air(to_tank = TRUE)
	if(equipment_actions[former])
		QDEL_LIST(equipment_actions[former])
		equipment_actions -= former

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

/obj/vehicle/sealed/space_pod/debug_prebuilt/Initialize(mapload)//remove or improve later
	. = ..()
	equip_item(new /obj/item/pod_equipment/sensors)
	equip_item(new /obj/item/pod_equipment/comms)
	equip_item(new /obj/item/pod_equipment/thrusters/default)
	equip_item(new /obj/item/pod_equipment/engine/default)
	equip_item(new /obj/item/pod_equipment/primary/projectile_weapon/kinetic_accelerator)
	equip_item(new /obj/item/pod_equipment/cargo_hold)
	cabin_air_tank = new /obj/item/tank/internals/oxygen(src)
	cell = new /obj/item/stock_parts/power_store/battery/bluespace(src)


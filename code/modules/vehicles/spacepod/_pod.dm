//
// space pods
//

// TODO:
// proper space movement (maybe like 80% done??? they still get stuck on lattices)
// construction
// equipment
// control scheme/whatever idk how to drive these
// slots: comms (radio and something else), sensors(HUDs or something, mesons??), engine, 1 secondary slot (cargo and shit), 1 primary slot(tools or gun???), 3 misc modules (locks and shit), armor would either be added during construction or as a slot
// power costs, either only megacell or only cell, how would you charge this??
// although im not so sure about power costs i dont know why it would need them but ideally a space pod should be capable of functioning for 10-15 minutes of nonstop acceleration by default
// innate armor potentially, also actual armor and also figure out integrity and inertia_force_weight
// figure out whether this should use action buttons or an UI or a combination of both for equipment
// ALSO DO NOT FORGET TO REMOVE THIS HUGE ASS COMMENT before finishing

/obj/vehicle/sealed/space_pod
	layer = ABOVE_MOB_LAYER
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon = 'icons/mob/rideables/spacepod/pod.dmi'
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
	equipped = null // equipment gets deleted already because its in our contents

/obj/vehicle/sealed/space_pod/update_overlays()
	. = ..()
	for(var/obj/item/pod_equipment/equipment as anything in get_all_parts())
		var/overlay = equipment.get_overlay()
		if(isnull(overlay))
			continue
		. += overlay

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

	drift_handler.stabilize_drift(target_force = 0, stabilization_force = stabilizer_force)


/obj/vehicle/sealed/space_pod/vehicle_move(direction)
	. = ..()
	if(!max_speed || !force_per_move)
		return
	if(has_gravity())
		if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
			return
		COOLDOWN_START(src, cooldown_vehicle_move, istype(loc, /turf/open/floor/engine) ? 0.3 SECONDS : 2 SECONDS) //moves much better on engine tiles
		after_move(direction)
		return try_step_multiz(direction)
	setDir(direction)
	newtonian_move(dir2angle(direction), instant = TRUE, drift_force = force_per_move, controlled_cap = max_speed)
	trail.generate_effect()

/obj/vehicle/sealed/space_pod/mob_enter(mob/mob, silent)
	. = ..()
	if(!. || length(occupants) > 1) //first occupant only
		return
	panel_open = FALSE //automatic screws,,,, waow....
	cycle_tank_air()

/obj/vehicle/sealed/space_pod/mob_exit(mob/M, silent, randomstep = FALSE)
	. = ..()
	if(!. || length(occupants) != 0) //when everyone exits
		return
	cycle_tank_air(to_tank = TRUE)

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
	equip_item(new /obj/item/pod_equipment/thrusters)
	equip_item(new /obj/item/pod_equipment/engine)
	cabin_air_tank = new /obj/item/tank/internals/oxygen(src)
	cell = new /obj/item/stock_parts/power_store/battery/bluespace(src)


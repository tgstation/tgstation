//
// space pods
//

// TODO:
// proper space movement
// construction
// equipment
// make them move different onstation, perhaps restrict to engine tiles only
// control scheme/whatever idk how to drive these
// slots: comms (radio and something else), sensors(HUDs or something, mesons??), engine, 1 secondary slot (cargo and shit), 1 primary slot(tools or gun???), 3 misc modules (locks and shit), armor would either be added during construction or as a slot
// power costs, either only megacell or only cell, how would you charge this??
// although im not so sure about power costs i dont know why it would need them but ideally a space pod should be capable of functioning for 10-15 minutes of nonstop acceleration by default
// innate armor potentially, also actual armor and also figure out integrity and inertia_force_weight
// ALSO DO NOT FORGET TO REMOVE THIS HUGE ASS COMMENT before finishing

/obj/vehicle/sealed/space_pod
	layer = ABOVE_MOB_LAYER
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon = 'icons/mob/rideables/vehicles.dmi' //placeholder
	icon_state = "engineering_pod" //placeholder
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

	/// max drift speed we can get via moving intentionally, modified by thrusters
	var/max_speed = 0
	/// Force per tick movement held down, modified by engine
	var/force_per_move = 0
	/// Force per process run to bring us to a halt, modified by thrusters
	var/stabilizer_force = 0
	/// are stabilizers on
	var/stabilizers_on = FALSE

	/// our air tank, cabin air is this
	var/obj/item/tank/internals/cabin_air_tank


/obj/vehicle/sealed/space_pod/Initialize(mapload)
	. = ..()
	trail = new
	trail.auto_process = FALSE
	trail.set_up(src)
	trail.start()
	// todo
	//START_PROCESSING(SSnewtonian_movement, src)

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

/*
/obj/vehicle/sealed/space_pod/process()
	if (!stabilizers_on || isnull(user.drift_handler))
		return

	var/max_drift_force = (DEFAULT_INERTIA_SPEED / user.cached_multiplicative_slowdown - 1) / INERTIA_SPEED_COEF + 1
	drift_handler.stabilize_drift(dir2angle(dir), user.client.intended_direction ? max_drift_force : 0, stabilizer_force)
*/

/obj/vehicle/sealed/space_pod/vehicle_move(direction)
	. = ..()
	if(!max_speed || !force_per_move)
		return
	if(has_gravity())
		if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
			return
		COOLDOWN_START(src, cooldown_vehicle_move, 1 SECONDS) // INTENTIONALLY make it painful to use onstation
		after_move(direction)
		return try_step_multiz(direction)
	if(direction != dir)
		setDir(direction) //first press changes dir
		return
	trail.generate_effect()
// may or may not work havent tested
	newtonian_move(dir2angle(dir), drift_force = force_per_move, controlled_cap = max_speed)
	setDir(direction)

// atmos
/obj/vehicle/sealed/space_pod/remove_air(amount)
	return !isnull(cabin_air_tank) ? cabin_air_tank.remove_air(amount) : ..()
/obj/vehicle/sealed/space_pod/return_air()
	return !isnull(cabin_air_tank) ? cabin_air_tank.return_air() : ..()
/obj/vehicle/sealed/space_pod/return_analyzable_air()
	return !isnull(cabin_air_tank) ? cabin_air_tank.return_air() : null // no internal air
/obj/vehicle/sealed/space_pod/return_temperature()
	var/datum/gas_mixture/air = return_air()
	return air?.return_temperature()

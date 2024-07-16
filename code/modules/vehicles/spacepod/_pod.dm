// space pods
// TODO:
// proper space movement
// construction
// equipment
// make them move different onstation, perhaps restrict to engine tiles only
// control scheme/whatever idk how to drive these
// slots: comms (radio and something else), sensors(HUDs or something, mesons??), engine, 1 secondary slot (cargo and shit), 1 primary slot(tools or gun???), infinite misc modules (locks and shit), armor would either be added during construction or as a slot
// DONE: defines car.dm in defines
// ALSO DO NOT FORGET TO REMOVE THIS HUGE ASS COMMENT before finishing

/obj/vehicle/sealed/space_pod
	layer = ABOVE_MOB_LAYER
	move_resist = MOVE_FORCE_VERY_STRONG
	icon = 'icons/mob/rideables/vehicles.dmi'
	icon_state = "engineering_pod"
	/// Max count of a certain slot. If it is not defined here, it is assumed to be one (1)
	var/slot_max = list(
		POD_SLOT_MISC = 3,
	)

// these variables fucking suck fix later


	var/datum/effect_system/trail_follow/ion/trail
	var/max_speed = 10 NEWTONS //fucking balls value change this
	/// How much force out jetpack can output per tick
	var/force_per_move = 3 NEWTONS
	/// How much force this jetpack can output per tick to stabilize the user
	var/stabilizer_force = 1 NEWTONS
	/// are stabilizers on
	var/stabilizers_on = FALSE


/obj/vehicle/sealed/space_pod/Initialize(mapload)
	. = ..()
	trail = new
	trail.auto_process = FALSE
	trail.set_up(src)
	trail.start()
	// todo
	//START_PROCESSING(SSnewtonian_movement, src)

/*
/obj/vehicle/sealed/space_pod/process()
	if (!stabilizers_on || isnull(user.drift_handler))
		return

	var/max_drift_force = (DEFAULT_INERTIA_SPEED / user.cached_multiplicative_slowdown - 1) / INERTIA_SPEED_COEF + 1
	drift_handler.stabilize_drift(dir2angle(dir), user.client.intended_direction ? max_drift_force : 0, stabilizer_force)
*/

/obj/vehicle/sealed/space_pod/vehicle_move(direction)
	. = ..()
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

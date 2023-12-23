/datum/wires/canister
	holder_type = /obj/machinery/portable_atmospherics/canister
	proper_name = "Canister"

/datum/wires/canister/New(atom/holder)
	wires = list(WIRE_VALVE, WIRE_SHIELDING, WIRE_REGULATOR_MIN, WIRE_REGULATOR_MAX, WIRE_TANK_EJECT, WIRE_REACTION_SUPPRESSION)
	..()

/datum/wires/canister/on_pulse(wire)
	var/obj/machinery/portable_atmospherics/canister/the_canister = holder
	if(!the_canister.internal_cell)
		return
	switch(wire)
		if(WIRE_VALVE)
			the_canister.toggle_valve(usr, wire_pulsed = TRUE)
		if(WIRE_SHIELDING)
			the_canister.toggle_shielding(usr, wire_pulsed = TRUE)
		if(WIRE_TANK_EJECT)
			the_canister.eject_tank(usr, wire_pulsed = TRUE)
		if(WIRE_REGULATOR_MIN)
			the_canister.release_pressure = CAN_MIN_RELEASE_PRESSURE
			the_canister.investigate_log("was set to [the_canister.release_pressure] kPa by [key_name(usr)] via wire pulse.", INVESTIGATE_ATMOS)
		if(WIRE_REGULATOR_MAX)
			the_canister.release_pressure = CAN_MAX_RELEASE_PRESSURE
			the_canister.investigate_log("was set to [the_canister.release_pressure] kPa by [key_name(usr)] via wire pulse.", INVESTIGATE_ATMOS)
		if(WIRE_REACTION_SUPPRESSION)
			the_canister.toggle_reaction_suppression(usr, wire_pulsed = TRUE)

/datum/wires/canister/can_reveal_wires(mob/user)
	if(HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		return TRUE

	return ..()

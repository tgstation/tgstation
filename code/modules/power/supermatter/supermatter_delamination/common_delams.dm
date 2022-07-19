// Singulo, tesla, and explosive delam

/// WHen we have too much gas.
/datum/sm_delam_strat/singularity


/datum/sm_delam_strat/singularity/can_apply(obj/machinery/power/supermatter_crystal/sm)
	return (sm.absorbed_gasmix.total_moles() >= MOLE_PENALTY_THRESHOLD)
	
/// When we have too much power.
/datum/sm_delam_strat/tesla

/datum/sm_delam_strat/tesla/can_apply(obj/machinery/power/supermatter_crystal/sm)
	return (sm.power > POWER_PENALTY_THRESHOLD)

/// Default delam.
/datum/sm_delam_strat/explosive

/datum/sm_delam_strat/explosive/can_apply(obj/machinery/power/supermatter_crystal/sm)
	return TRUE
	
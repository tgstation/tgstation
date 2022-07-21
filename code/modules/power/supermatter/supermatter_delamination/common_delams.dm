// Singulo, tesla, and explosive delam

/// When we have too much gas.
/datum/sm_delam_strat/singularity

/datum/sm_delam_strat/singularity/can_select(obj/machinery/power/supermatter_crystal/sm)
	return (sm.absorbed_gasmix.total_moles() >= MOLE_PENALTY_THRESHOLD)

/datum/sm_delam_strat/singularity/delam_progress(obj/machinery/power/supermatter_crystal/sm)
	. = ..()
	if(!.)
		return FALSE
	sm.radio.talk_into(
		sm,
		"Warning: Critical coolant mass reached.", 
		sm.damage > sm.emergency_point ? sm.emergency_channel : sm.warning_channel
	)

/datum/sm_delam_strat/singularity/delaminate(obj/machinery/power/supermatter_crystal/sm)
	effect_irradiate(sm)
	effect_demoralize(sm)
	if(!effect_singulo(sm))
		effect_explosion(sm)
	if(sm.is_main_engine)
		effect_anomaly(sm)
	qdel(sm)

/// When we have too much power.
/datum/sm_delam_strat/tesla

/datum/sm_delam_strat/tesla/can_select(obj/machinery/power/supermatter_crystal/sm)
	return (sm.power > POWER_PENALTY_THRESHOLD)

/datum/sm_delam_strat/tesla/delam_progress(obj/machinery/power/supermatter_crystal/sm)
	. = ..()
	if(!.)
		return FALSE
	sm.radio.talk_into(
		sm,
		"DANGER: CHARGE INERTIA CHAIN REACTION IN PROGRESS.",
		sm.damage > sm.emergency_point ? sm.emergency_channel : sm.warning_channel
	)

/datum/sm_delam_strat/tesla/delaminate(obj/machinery/power/supermatter_crystal/sm)
	effect_irradiate(sm)
	effect_demoralize(sm)
	effect_tesla(sm)
	effect_explosion(sm)
	if(sm.is_main_engine)
		effect_anomaly(sm)
	qdel(sm)

/// Default delam.
/datum/sm_delam_strat/explosive

/datum/sm_delam_strat/explosive/can_select(obj/machinery/power/supermatter_crystal/sm)
	return TRUE

/datum/sm_delam_strat/explosive/delaminate(obj/machinery/power/supermatter_crystal/sm)
	effect_irradiate(sm)
	effect_demoralize(sm)
	effect_explosion(sm)
	if(sm.is_main_engine)
		effect_anomaly(sm)
	qdel(sm)

// Singulo, tesla, and explosive delam

/// When we have too much gas.
/datum/sm_delam/singularity

/datum/sm_delam/singularity/can_select(obj/machinery/power/supermatter_crystal/sm)
	return (sm.absorbed_gasmix.total_moles() >= MOLE_PENALTY_THRESHOLD)

/datum/sm_delam/singularity/delam_progress(obj/machinery/power/supermatter_crystal/sm)
	. = ..()
	if(!.)
		return FALSE
	sm.radio.talk_into(
		sm,
		"Warning: Critical coolant mass reached.",
		sm.damage > sm.emergency_point ? sm.emergency_channel : sm.warning_channel
	)

/datum/sm_delam/singularity/delaminate(obj/machinery/power/supermatter_crystal/sm)
	message_admins("Supermatter [sm] at [ADMIN_VERBOSEJMP(sm)] triggered a singularity delam.")
	sm.investigate_log("triggered a singularity delam.", INVESTIGATE_ENGINE)

	effect_irradiate(sm)
	effect_demoralize(sm)
	if(sm.is_main_engine)
		effect_anomaly(sm)
	if(!effect_singulo(sm))
		effect_explosion(sm)
	return ..()

/// When we have too much power.
/datum/sm_delam/tesla

/datum/sm_delam/tesla/can_select(obj/machinery/power/supermatter_crystal/sm)
	return (sm.power > POWER_PENALTY_THRESHOLD)

/datum/sm_delam/tesla/delam_progress(obj/machinery/power/supermatter_crystal/sm)
	. = ..()
	if(!.)
		return FALSE
	sm.radio.talk_into(
		sm,
		"DANGER: CHARGE INERTIA CHAIN REACTION IN PROGRESS.",
		sm.damage > sm.emergency_point ? sm.emergency_channel : sm.warning_channel
	)

/datum/sm_delam/tesla/delaminate(obj/machinery/power/supermatter_crystal/sm)
	message_admins("Supermatter [sm] at [ADMIN_VERBOSEJMP(sm)] triggered a tesla delam.")
	sm.investigate_log("triggered a tesla delam.", INVESTIGATE_ENGINE)

	effect_irradiate(sm)
	effect_demoralize(sm)
	if(sm.is_main_engine)
		effect_anomaly(sm)
	effect_tesla(sm)
	effect_explosion(sm)
	return ..()

/// Default delam.
/datum/sm_delam/explosive

/datum/sm_delam/explosive/can_select(obj/machinery/power/supermatter_crystal/sm)
	return TRUE

/datum/sm_delam/explosive/delaminate(obj/machinery/power/supermatter_crystal/sm)
	message_admins("Supermatter [sm] at [ADMIN_VERBOSEJMP(sm)] triggered a normal delam.")
	sm.investigate_log("triggered a normal delam.", INVESTIGATE_ENGINE)

	effect_irradiate(sm)
	effect_demoralize(sm)
	if(sm.is_main_engine)
		effect_anomaly(sm)
	effect_explosion(sm)
	return ..()

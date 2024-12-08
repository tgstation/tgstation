// Singulo, tesla, and explosive delam

/// When we have too much gas.

/proc/delam_singularity_can_select(obj/machinery/power/supermatter_crystal/sm)
	return (sm.absorbed_gasmix.total_moles() >= MOLE_PENALTY_THRESHOLD)

/datum/sm_delam/singularity

/datum/sm_delam/singularity/delam_progress()
	if(!..())
		return FALSE
	sm.radio.talk_into(
		sm,
		"Warning: Critical coolant mass reached.",
		sm.damage > sm.emergency_point ? sm.emergency_channel : sm.warning_channel
	)
	return TRUE

/datum/sm_delam/singularity/delaminate()
	message_admins("Supermatter [sm] at [ADMIN_VERBOSEJMP(sm)] triggered a singularity delam.")
	sm.investigate_log("triggered a singularity delam.", INVESTIGATE_ENGINE)

	effect_irradiate()
	effect_demoralize()
	if(sm.is_main_engine)
		effect_anomaly()
	if(!effect_singulo())
		effect_explosion()
	return ..()

/datum/sm_delam/singularity/filters()
	..()

	sm.modify_filter(name = "ray", new_params = list(
		color = SUPERMATTER_SINGULARITY_RAYS_COLOUR
	))

	sm.add_filter(name = "outline", priority = 2, params = list(
		type = "outline",
		size = 1,
		color = SUPERMATTER_SINGULARITY_LIGHT_COLOUR
	))

	if(sm.final_countdown)
		sm.add_filter(name = "icon", priority = 3, params = list(
			type = "layer",
			icon = new/icon('icons/effects/96x96.dmi', "singularity_s3", frame = rand(1,8)),
			flags = FILTER_OVERLAY
		))
	else
		sm.remove_filter("icon")

/datum/sm_delam/singularity/on_deselect()
	. = ..()
	sm.remove_filter(list("outline", "icon"))

/datum/sm_delam/singularity/overlays()
	return list()

/datum/sm_delam/singularity/lights()
	..()
	sm.set_light_color(SUPERMATTER_SINGULARITY_LIGHT_COLOUR)

/// When we have too much power.
/datum/sm_delam/tesla

/proc/delam_tesla_can_select(obj/machinery/power/supermatter_crystal/sm)
	return (sm.internal_energy > POWER_PENALTY_THRESHOLD)

/datum/sm_delam/tesla/delam_progress()
	if(!..())
		return FALSE
	sm.radio.talk_into(
		sm,
		"DANGER: CHARGE INERTIA CHAIN REACTION IN PROGRESS.",
		sm.damage > sm.emergency_point ? sm.emergency_channel : sm.warning_channel
	)
	return TRUE

/datum/sm_delam/tesla/delaminate()
	message_admins("Supermatter [sm] at [ADMIN_VERBOSEJMP(sm)] triggered a tesla delam.")
	sm.investigate_log("triggered a tesla delam.", INVESTIGATE_ENGINE)

	effect_irradiate()
	effect_demoralize()
	if(sm.is_main_engine)
		effect_anomaly()
	effect_tesla()
	effect_explosion()
	return ..()

/datum/sm_delam/tesla/filters()
	..()

	sm.modify_filter(name = "ray", new_params = list(
		color = SUPERMATTER_TESLA_COLOUR,
	))

	sm.add_filter(name = "icon", priority = 2, params = list(
		type = "layer",
		icon = new/icon('icons/obj/machines/engine/energy_ball.dmi', "energy_ball", frame = rand(1,12)),
		flags = FILTER_UNDERLAY
	))

/datum/sm_delam/tesla/on_deselect()
	. = ..()
	sm.remove_filter(list("icon"))

/datum/sm_delam/tesla/lights()
	..()
	sm.set_light_color(SUPERMATTER_TESLA_COLOUR)

/// Default delam.
/datum/sm_delam/explosive

/proc/delam_explosive_can_select(obj/machinery/power/supermatter_crystal/sm)
	return TRUE

/datum/sm_delam/explosive/delaminate()
	message_admins("Supermatter [sm] at [ADMIN_VERBOSEJMP(sm)] triggered a normal delam.")
	sm.investigate_log("triggered a normal delam.", INVESTIGATE_ENGINE)

	effect_irradiate(sm)
	effect_demoralize(sm)
	if(sm.is_main_engine)
		effect_anomaly(sm)
	effect_explosion(sm)
	return ..()

/datum/round_event_control/anomaly/anomaly_ectoplasm
	name = "Anomaly: Ectoplasmic Outburst"
	typepath = /datum/round_event/anomaly/anomaly_ectoplasm
	min_players = 30
	max_occurrences = 2
	weight = 4 //Rare because of it's wacky and silly nature
	category = EVENT_CATEGORY_ANOMALIES
	description = "Anomaly that produces an effect of varying intensity based on how many ghosts are orbiting it."
	///The admin-set impact effect override
	var/effect_override
	///The admin-set number of ghosts, for use in calculating impact size.
	var/ghost_override

/datum/round_event_control/anomaly/anomaly_ectoplasm/admin_setup(mob/admin)
	. = ..()

	if(!check_rights(R_FUN))
		return ADMIN_CANCEL_EVENT

	var/list/power_values = list("Minor", "Moderate", "Major")
	var/effect

	if(tgui_alert(usr, "Override the anomaly effect and power?", "You'll be ruining the authenticity.", list("Yes", "No")) == "Yes")
		effect = tgui_input_list(usr, "Provide effect override", "Criiiiinge.", power_values)
		ghost_override = tgui_input_number(usr, "How many ghosts do you want simulate orbiting your anomaly? (determines the effect radius).", "Seriously, CRINGE.", 0, 20, 1)

		if(!effect || !ghost_override)
			return ADMIN_CANCEL_EVENT

		switch(effect)
			if("Minor")
				effect_override = 10
			if("Moderate")
				effect_override = 35
			if("Major")
				effect_override = 60

/datum/round_event/anomaly/anomaly_ectoplasm
	anomaly_path = /obj/effect/anomaly/ectoplasm
	start_when = 3
	announce_when = 20

/datum/round_event/anomaly/anomaly_ectoplasm/start()
	var/datum/round_event_control/anomaly/anomaly_ectoplasm/anomaly_event = control

	if(!anomaly_event.effect_override)
		..() //If we provide no override, just run the usual startup.
	else
		var/turf/anomaly_turf = placer.findValidTurf(impact_area)
		var/obj/effect/anomaly/ectoplasm/newAnomaly
		if(anomaly_turf)
			newAnomaly = new anomaly_path(anomaly_turf)
			newAnomaly.override_ghosts = TRUE
			newAnomaly.effect_power = anomaly_event.effect_override
			newAnomaly.ghosts_orbiting = anomaly_event.ghost_override
			if(newAnomaly.effect_power >= 60) //Otherwise it won't update because anomalyEffect is overridden and blocked
				newAnomaly.icon_state = "ectoplasm_heavy"
				newAnomaly.update_appearance(UPDATE_ICON_STATE)
		if (newAnomaly)
			announce_to_ghosts(newAnomaly)

	anomaly_event.effect_override = null //Clean up for future use.
	anomaly_event.ghost_override = null

/datum/round_event/anomaly/anomaly_ectoplasm/announce(fake)
	priority_announce("Localized ectoplasmic outburst detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert")

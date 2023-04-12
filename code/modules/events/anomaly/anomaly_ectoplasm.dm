#define ANOMALY_INTENSITY_MINOR "Minor Intensity"
#define ANOMALY_INTENSITY_MODERATE "Moderate Intensity"
#define ANOMALY_INTENSITY_MAJOR "Major Intensity"

/datum/round_event_control/anomaly/anomaly_ectoplasm
	name = "Anomaly: Ectoplasmic Outburst"
	description = "Anomaly that produces an effect of varying intensity based on how many ghosts are orbiting it."
	typepath = /datum/round_event/anomaly/anomaly_ectoplasm
	min_players = 30
	max_occurrences = 2
	weight = 4 //Rare because of it's wacky and silly nature
	category = EVENT_CATEGORY_ANOMALIES
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 3
	admin_setup = list(/datum/event_admin_setup/set_location/anomaly, /datum/event_admin_setup/anomaly_ectoplasm)

/datum/round_event/anomaly/anomaly_ectoplasm
	anomaly_path = /obj/effect/anomaly/ectoplasm
	start_when = ANOMALY_START_HARMFUL_TIME
	announce_when = ANOMALY_ANNOUNCE_HARMFUL_TIME
	///The admin-set impact effect intensity override
	var/effect_override
	///The admin-set number of ghosts, for use in calculating impact size.
	var/orbit_override

/datum/round_event/anomaly/anomaly_ectoplasm/start()
	if(!effect_override || !orbit_override)
		return ..() //If we provide no override, just run the usual startup.

	var/turf/anomaly_turf = placer.findValidTurf(impact_area)
	var/obj/effect/anomaly/ectoplasm/newAnomaly
	if(anomaly_turf)
		newAnomaly = new anomaly_path(anomaly_turf)
		newAnomaly.override_ghosts = TRUE
		newAnomaly.effect_power = effect_override
		newAnomaly.ghosts_orbiting = orbit_override
		newAnomaly.intensity_update()
	if(newAnomaly)
		announce_to_ghosts(newAnomaly)

/datum/round_event/anomaly/anomaly_ectoplasm/announce(fake)
	priority_announce("Paranormal ectoplasmic outburst detected on [ANOMALY_ANNOUNCE_HARMFUL_TEXT] [impact_area.name].", "Anomaly Alert")

/datum/event_admin_setup/anomaly_ectoplasm
	///The admin-selected intensity
	var/chosen_effect
	///The number of ghosts the admin has selected to simulate orbiting the anomaly.
	var/ghost_override

/datum/event_admin_setup/anomaly_ectoplasm/prompt_admins()
	if(tgui_alert(usr, "Override the anomaly effect and power?", "You'll be ruining the authenticity.", list("Yes", "No")) == "Yes")
		var/list/power_values = list(ANOMALY_INTENSITY_MINOR, ANOMALY_INTENSITY_MODERATE, ANOMALY_INTENSITY_MAJOR)
		chosen_effect = tgui_input_list(usr, "Provide effect override", "Criiiiinge.", power_values)
		if(!chosen_effect)
			return ADMIN_CANCEL_EVENT

		ghost_override = tgui_input_number(usr, "How many ghosts do you want simulate orbiting your anomaly? (determines the effect radius).", "Seriously, CRINGE.", 0, 20, 1)
		if(!ghost_override)
			return ADMIN_CANCEL_EVENT

	switch(chosen_effect) //Converts the text choice into a number for the anomaly to use
		if(ANOMALY_INTENSITY_MINOR)
			chosen_effect = 10
		if(ANOMALY_INTENSITY_MODERATE)
			chosen_effect = 35
		if(ANOMALY_INTENSITY_MAJOR)
			chosen_effect = 50

/datum/event_admin_setup/anomaly_ectoplasm/apply_to_event(datum/round_event/anomaly/anomaly_ectoplasm/event)
	event.effect_override = chosen_effect
	event.orbit_override = ghost_override

#undef ANOMALY_INTENSITY_MINOR
#undef ANOMALY_INTENSITY_MODERATE
#undef ANOMALY_INTENSITY_MAJOR

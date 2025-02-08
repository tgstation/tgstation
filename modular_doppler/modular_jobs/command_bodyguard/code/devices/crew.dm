/*
*	Trimmed and modified copy of ".../machinery/computer/crew.dm"
*	for the sake of modularity.
*/

#define SENSORS_UPDATE_PERIOD (10 SECONDS)

GLOBAL_DATUM_INIT(bodyguard_crewmonitor, /datum/crewmonitor/bodyguard, new)

//list of all Command/CC jobs
/datum/crewmonitor/bodyguard
	var/list/jobs_command = list(
		JOB_CAPTAIN = 00,
		JOB_HEAD_OF_SECURITY = 10,
		JOB_CHIEF_MEDICAL_OFFICER = 20,
		JOB_RESEARCH_DIRECTOR = 30,
		JOB_CHIEF_ENGINEER = 40,
		JOB_QUARTERMASTER = 50,
		JOB_HEAD_OF_PERSONNEL = 60,
		JOB_CENTCOM_ADMIRAL = 200,
		JOB_CENTCOM = 201,
		JOB_CENTCOM_OFFICIAL = 210,
		JOB_CENTCOM_COMMANDER = 211,
		JOB_CENTCOM_BARTENDER = 212,
		JOB_CENTCOM_CUSTODIAN = 213,
		JOB_CENTCOM_MEDICAL_DOCTOR = 214,
		JOB_CENTCOM_RESEARCH_OFFICER = 215,
		JOB_ERT_COMMANDER = 220,
		JOB_ERT_OFFICER = 221,
		JOB_ERT_ENGINEER = 222,
		JOB_ERT_MEDICAL_DOCTOR = 223,
		JOB_ERT_CLOWN = 224,
		JOB_ERT_CHAPLAIN = 225,
		JOB_ERT_JANITOR = 226,
		JOB_ERT_DEATHSQUAD = 227,
		JOB_COMMAND_BODYGUARD = 230,
	)

/datum/crewmonitor/bodyguard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CrewConsoleBodyguard")
		ui.open()

/*
*	Override of crewmonitor/update_data(z)
* 	- "trim_assignment" is now iterated for command-only jobs
*	- "if (id_card)" now encapsulates all the remaining checks to avoid showing unknowns
*/
/datum/crewmonitor/bodyguard/update_data(z)
	if(data_by_z["[z]"] && last_update["[z]"] && world.time <= last_update["[z]"] + SENSORS_UPDATE_PERIOD)
		return data_by_z["[z]"]

	var/list/results = list()
	for(var/tracked_mob in GLOB.suit_sensors_list)
		if(!tracked_mob)
			stack_trace("Null entry in suit sensors list.")
			continue

		var/mob/living/tracked_living_mob = tracked_mob

		var/turf/pos = get_turf(tracked_living_mob)

		if(!pos)
			stack_trace("Tracked mob has no loc and is likely in nullspace: [tracked_living_mob] ([tracked_living_mob.type])")
			continue

		if(pos.z != z && (!is_station_level(pos.z) || !is_station_level(z)) && !HAS_TRAIT(tracked_living_mob, TRAIT_MULTIZ_SUIT_SENSORS))
			continue

		var/mob/living/carbon/human/tracked_human = tracked_living_mob

		if(!ishuman(tracked_human))
			stack_trace("Non-human mob is in suit_sensors_list: [tracked_living_mob] ([tracked_living_mob.type])")
			continue

		var/obj/item/clothing/under/uniform = tracked_human.w_uniform
		if (!istype(uniform))
			stack_trace("Human without a suit sensors compatible uniform is in suit_sensors_list: [tracked_human] ([tracked_human.type]) ([uniform?.type])")
			continue

		if((uniform.has_sensor <= NO_SENSORS) || !uniform.sensor_mode)
			stack_trace("Human without active suit sensors is in suit_sensors_list: [tracked_human] ([tracked_human.type]) ([uniform.type])")
			continue

		var/sensor_mode = uniform.sensor_mode
		var/list/entry = list()

		var/obj/item/card/id/id_card = tracked_living_mob.get_idcard(hand_first = FALSE)
		if (id_card)

			entry["name"] = id_card.registered_name
			entry["assignment"] = id_card.assignment
			var/trim_assignment = id_card.get_trim_assignment()

			//Check if they are command
			if (jobs_command[trim_assignment] != null)
				entry["ijob"] = jobs_command[trim_assignment]
			else
				continue

			if (isandroid(tracked_human))
				var/datum/species/android/energy_holder = tracked_human.dna.species
				entry["is_robot"] = TRUE
				entry["charge"] = "[round((energy_holder.core_energy/1000000), 0.1)]MJ"

			if (sensor_mode >= SENSOR_LIVING)
				entry["life_status"] = (tracked_living_mob.stat != DEAD)

			if (sensor_mode >= SENSOR_VITALS)
				entry += list(
					"oxydam" = round(tracked_living_mob.getOxyLoss(), 1),
					"toxdam" = round(tracked_living_mob.getToxLoss(), 1),
					"burndam" = round(tracked_living_mob.getFireLoss(), 1),
					"brutedam" = round(tracked_living_mob.getBruteLoss(), 1),
					"health" = round(tracked_living_mob.health, 1),
				)

			if (sensor_mode >= SENSOR_COORDS)
				entry["area"] = get_area_name(tracked_living_mob, format_text = TRUE)

			entry["can_track"] = tracked_living_mob.can_track()

		else
			continue

		results[++results.len] = entry

	data_by_z["[z]"] = results
	last_update["[z]"] = world.time

	return results

#undef SENSORS_UPDATE_PERIOD

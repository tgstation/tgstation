#define SENSORS_UPDATE_PERIOD 100 //How often the sensor data updates.

/obj/machinery/computer/crew
	name = "crew monitoring console"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	use_power = IDLE_POWER_USE
	idle_power_usage = 250
	active_power_usage = 500
	circuit = /obj/item/circuitboard/computer/crew

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/crew/syndie
	icon_keyboard = "syndie_key"

/obj/machinery/computer/crew/interact(mob/user)
	GLOB.crewmonitor.show(user,src)

GLOBAL_DATUM_INIT(crewmonitor, /datum/crewmonitor, new)

/datum/crewmonitor
	var/list/ui_sources = list() //List of user -> ui source
	var/list/data_by_z = list()
	var/list/last_update = list()
	var/list/jobs = list(
		//Note that jobs divisible by 10 are considered heads of staff, and bolded
		//00: Captain
		"Captain" = 00,
		//10-19: Security
		"Head of Security" = 10,
		"Warden" = 11,
		"Security Officer" = 12,
		"Detective" = 13,
		//20-29: Medbay
		"Chief Medical Officer" = 20,
		"Chemist" = 21,
		"Virologist" = 22,
		"Medical Doctor" = 23,
		"Paramedic" = 24,
		//30-39: Science
		"Research Director" = 30,
		"Scientist" = 31,
		"Roboticist" = 32,
		"Geneticist" = 33,
		//40-49: Engineering
		"Chief Engineer" = 40,
		"Station Engineer" = 41,
		"Atmospheric Technician" = 42,
		//50-59: Cargo
		"Head of Personnel" = 50,
		"Quartermaster" = 51,
		"Shaft Miner" = 52,
		"Cargo Technician" = 53,
		//60+: Civilian/other
		"Bartender" = 61,
		"Cook" = 62,
		"Botanist" = 63,
		"Curator" = 64,
		"Chaplain" = 65,
		"Clown" = 66,
		"Mime" = 67,
		"Janitor" = 68,
		"Lawyer" = 69,
		"Psychologist" = 71,
		//ANYTHING ELSE = 81  //Unknowns/custom jobs will appear after civilians, and before assistants
		"Assistant" = 999,

		//200-229: Centcom
		"Admiral" = 200,
		"CentCom Commander" = 210,
		"Custodian" = 211,
		"Medical Officer" = 212,
		"Research Officer" = 213,
		"Emergency Response Team Commander" = 220,
		"Security Response Officer" = 221,
		"Engineer Response Officer" = 222,
		"Medical Response Officer" = 223
	)

/datum/crewmonitor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CrewConsole")
		ui.open()

/datum/crewmonitor/proc/show(mob/M, source)
	ui_sources[M] = source
	ui_interact(M)

/datum/crewmonitor/ui_host(mob/user)
	return ui_sources[user]

/datum/crewmonitor/ui_data(mob/user)
	var/z = user.z
	if(!z)
		var/turf/T = get_turf(user)
		z = T.z
	var/list/zdata = update_data(z)
	. = list()
	.["sensors"] = zdata
	.["link_allowed"] = isAI(user)

/datum/crewmonitor/proc/update_data(z)
	if(data_by_z["[z]"] && last_update["[z]"] && world.time <= last_update["[z]"] + SENSORS_UPDATE_PERIOD)
		return data_by_z["[z]"]

	var/list/results = list()
	var/obj/item/clothing/under/uniform
	var/obj/item/card/id/id_card
	var/turf/pos
	var/ijob
	var/name
	var/assignment
	var/oxydam
	var/toxdam
	var/burndam
	var/brutedam
	var/area
	var/pos_x
	var/pos_y
	var/life_status

	for(var/i in GLOB.nanite_sensors_list)
		var/mob/living/carbon/human/H = i
		// Check if their z-level is correct
		// Accept H.z==0 as well in case the mob is inside an object.
		if(H.z == 0 || H.z == z)
			pos = get_turf(H)

			// Special case: If the mob is inside an object confirm the z-level on turf level.
			if (H.z == 0 && (!pos || pos.z != z))
				continue

			id_card = H.wear_id ? H.wear_id.GetID() : null

			if (id_card)
				name = id_card.registered_name
				assignment = id_card.assignment
				ijob = jobs[id_card.assignment]
			else
				name = "Unknown"
				assignment = ""
				ijob = 81

			life_status = (!H.stat ? TRUE : FALSE)

			oxydam = round(H.getOxyLoss(),1)
			toxdam = round(H.getToxLoss(),1)
			burndam = round(H.getFireLoss(),1)
			brutedam = round(H.getBruteLoss(),1)

			area = get_area_name(H, TRUE)
			pos_x = pos.x
			pos_y = pos.y

			results[++results.len] = list("name" = name, "assignment" = assignment, "ijob" = ijob, "life_status" = life_status, "oxydam" = oxydam, "toxdam" = toxdam, "burndam" = burndam, "brutedam" = brutedam, "area" = area, "pos_x" = pos_x, "pos_y" = pos_y, "can_track" = H.can_track(null))

	for(var/i in GLOB.suit_sensors_list)
		var/mob/living/carbon/human/H = i
		// Check if their z-level is correct and if they are wearing a uniform.
		// Accept H.z==0 as well in case the mob is inside an object.
		// Also exclude people already listed due to nanite sensors (which will always be at maximum detail)
		if((H.z == 0 || H.z == z) && (istype(H.w_uniform, /obj/item/clothing/under)) && !(H in GLOB.nanite_sensors_list))
			uniform = H.w_uniform

			// Are the suit sensors on?
			if (((uniform.has_sensor > 0) && uniform.sensor_mode))
				pos = get_turf(H)

				// Special case: If the mob is inside an object confirm the z-level on turf level.
				if (H.z == 0 && (!pos || pos.z != z))
					continue

				id_card = H.wear_id ? H.wear_id.GetID() : null

				if (id_card)
					name = id_card.registered_name
					assignment = id_card.assignment
					ijob = jobs[id_card.assignment]
				else
					name = "Unknown"
					assignment = ""
					ijob = 81

				if (uniform.sensor_mode >= SENSOR_LIVING)
					life_status = (!H.stat ? TRUE : FALSE)
				else
					life_status = null

				if (uniform.sensor_mode >= SENSOR_VITALS)
					oxydam = round(H.getOxyLoss(),1)
					toxdam = round(H.getToxLoss(),1)
					burndam = round(H.getFireLoss(),1)
					brutedam = round(H.getBruteLoss(),1)
				else
					oxydam = null
					toxdam = null
					burndam = null
					brutedam = null

				if (pos && uniform.sensor_mode >= SENSOR_COORDS)
					area = get_area_name(H, TRUE)
					pos_x = pos.x
					pos_y = pos.y
				else
					area = null
					pos_x = null
					pos_y = null

				results[++results.len] = list("name" = name, "assignment" = assignment, "ijob" = ijob, "life_status" = life_status, "oxydam" = oxydam, "toxdam" = toxdam, "burndam" = burndam, "brutedam" = brutedam, "area" = area, "pos_x" = pos_x, "pos_y" = pos_y, "can_track" = H.can_track(null))

	data_by_z["[z]"] = sortTim(results,/proc/sensor_compare)
	last_update["[z]"] = world.time

	return results

/proc/sensor_compare(list/a,list/b)
	return a["ijob"] - b["ijob"]

/datum/crewmonitor/ui_act(action,params)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	if(!istype(AI))
		return
	switch (action)
		if ("select_person")
			AI.ai_camera_track(params["name"])

#undef SENSORS_UPDATE_PERIOD

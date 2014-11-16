/*
 * Data HUDs are now passive in order to reduce lag.
 * Add then to a mob using add_data_hud.
 * Update them when needed with the appropriate proc. (see below)
 */

var/list/med_hud_users = list()
var/list/sec_hud_users = list()

/***********************************************
 GENERIC HUD PROCS: These apply to all data HUDs
************************************************/

/*
 * THESE SHOULD BE CALLED BY THE MOB SEEING THE HUD
 */

//Deletes all current HUD images
/mob/proc/reset_all_data_huds()
	if(client)
		for(var/image/hud in client.images)
			if(findtext(hud.icon_state,"hud",1,4))
				client.images -= hud
	med_hud_users -= src
	sec_hud_users -= src

//Adds one set of data hud images
/mob/proc/add_data_hud(var/hud_type, var/hud_mode)
	if(!client)
		return

	for(var/mob/living/carbon/human/H in mob_list)
		switch(hud_type)
			if(DATA_HUD_MEDICAL)
				med_hud_users[src] = hud_mode
				add_single_med_hud(H)
			if(DATA_HUD_SECURITY)
				sec_hud_users[src] = hud_mode
				add_single_sec_hud(H)

/*
 * THESE SHOULD BE CALLED BY THE MOB SHOWING THE HUD
 */

/mob/living/carbon/human/proc/add_to_all_data_huds()
	add_to_data_hud(DATA_HUD_MEDICAL)
	add_to_data_hud(DATA_HUD_SECURITY)

//Add a mob's HUD to all HUD users
/mob/living/carbon/human/proc/add_to_data_hud(var/hud_type)
	switch(hud_type)
		if(DATA_HUD_MEDICAL)
			for(var/mob/M in med_hud_users)
				M.add_single_med_hud(src)
		if(DATA_HUD_SECURITY)
			for(var/mob/M in sec_hud_users)
				M.add_single_sec_hud(src)

/mob/living/carbon/human/proc/remove_from_all_data_huds()
	remove_from_data_hud(DATA_HUD_MEDICAL)
	remove_from_data_hud(DATA_HUD_SECURITY)

//Removes a mob's HUD from all HUD users
/mob/living/carbon/human/proc/remove_from_data_hud(var/hud_type)
	switch(hud_type)
		if(DATA_HUD_MEDICAL)
			for(var/mob/M in med_hud_users)
				M.remove_single_med_hud(src)
		if(DATA_HUD_SECURITY)
			for(var/mob/M in sec_hud_users)
				M.remove_single_sec_hud(src)

/***********************************************
 Medical HUD! Basic mode needs suit sensors on.
************************************************/

/*
 * THESE SHOULD BE CALLED BY THE MOB SEEING THE HUD
 */

//Adds a single mob's med HUD to view
/mob/proc/add_single_med_hud(var/mob/living/carbon/human/H)
	var/mode = med_hud_users[src]
	if(!mode || !client)
		return
	if(mode == DATA_HUD_BASIC) //Used for the AI's MedHUD, only works if the patient has activated suit sensors.
		if(!H.w_uniform)	return
		var/obj/item/clothing/under/U = H.w_uniform
		if(U.sensor_mode <= 2)	return
	client.images += H.hud_list[HEALTH_HUD]
	client.images += H.hud_list[STATUS_HUD]

//Deletes a single mob's med HUD from view
/mob/proc/remove_single_med_hud(var/mob/living/carbon/human/H)
	if(!client)
		return
	client.images -= H.hud_list[HEALTH_HUD]
	client.images -= H.hud_list[STATUS_HUD]


/*
 * THESE SHOULD BE CALLED BY THE MOB SHOWING THE HUD
 */

//called when a human changes suit sensors
/mob/living/carbon/human/proc/update_suit_sensors(var/obj/item/clothing/under/w_uniform)
	var/sensor_level = 0
	if(w_uniform)	sensor_level = w_uniform.sensor_mode
	update_med_hud_suit_sensors(sensor_level)
	..()

//called when a human changes suit sensors
/mob/living/carbon/human/proc/update_med_hud_suit_sensors(sensor_level)
	for(var/mob/M in med_hud_users)
		if(med_hud_users[M] == DATA_HUD_BASIC)
			sensor_level > 2 ? M.add_single_med_hud(src) : M.remove_single_med_hud(src)

//called when a human changes virus
/mob/living/carbon/human/proc/check_virus()
	for(var/datum/disease/D in viruses)
		if((!(D.visibility_flags & HIDDEN_SCANNER)) && (D.severity != NONTHREAT))
			return 1
	return 0

//helper for getting the appropriate health status
/proc/RoundHealth(health)
	switch(health)
		if(100 to INFINITY)
			return "health100"
		if(70 to 100)
			return "health80"
		if(50 to 70)
			return "health60"
		if(30 to 50)
			return "health40"
		if(18 to 30)
			return "health25"
		if(5 to 18)
			return "health10"
		if(1 to 5)
			return "health1"
		if(-99 to 0)
			return "health0"
		else
			return "health-100"
	return "0"

//called when a human changes health
/mob/living/carbon/human/proc/med_hud_set_health()
	var/image/holder = hud_list[HEALTH_HUD]
	if(stat == 2)
		holder.icon_state = "hudhealth-100"
	else
		holder.icon_state = "hud[RoundHealth(health)]"

//called when a human changes stat, virus or XENO_HOST
/mob/living/carbon/human/proc/med_hud_set_status()
	var/image/holder = hud_list[STATUS_HUD]
	if(stat == 2)
		holder.icon_state = "huddead"
	else if(status_flags & XENO_HOST)
		holder.icon_state = "hudxeno"
	else if(check_virus())
		holder.icon_state = "hudill"
	else
		holder.icon_state = "hudhealthy"


/***********************************************
 Security HUDs! Basic mode shows only the job.
************************************************/

/*
 * THESE SHOULD BE CALLED BY THE MOB SEEING THE HUD
 */
//Adds a single mob's sec HUD to view
/mob/proc/add_single_sec_hud(var/mob/living/carbon/human/H)
	var/mode = sec_hud_users[src]
	if(!mode || !client)
		return
	client.images += H.hud_list[ID_HUD]
	if(mode == DATA_HUD_ADVANCED) //If not set to DATA_HUD_ADVANCED, the Sec HUD will only display the job.
		client.images += H.hud_list[IMPTRACK_HUD]
		client.images += H.hud_list[IMPLOYAL_HUD]
		client.images += H.hud_list[IMPCHEM_HUD]
		client.images += H.hud_list[WANTED_HUD]

//Deletes a single mob's sec HUD from view
/mob/proc/remove_single_sec_hud(var/mob/living/carbon/human/H)
	if(!client)
		return
	client.images -= H.hud_list[ID_HUD]
	client.images -= H.hud_list[IMPTRACK_HUD]
	client.images -= H.hud_list[IMPLOYAL_HUD]
	client.images -= H.hud_list[IMPCHEM_HUD]
	client.images -= H.hud_list[WANTED_HUD]

/*
 * THESE SHOULD BE CALLED BY THE MOB SHOWING THE HUD
 */

//These should only be called when necessary in order to reduce lag
/mob/living/carbon/human/proc/sec_hud_set_ID()
	var/image/holder = hud_list[ID_HUD]
	holder.icon_state = "hudno_id"
	if(wear_id)
		holder.icon_state = "hud[ckey(wear_id.GetJobName())]"

/mob/living/carbon/human/proc/sec_hud_set_implants()
	var/image/holder
	for(var/I in list(IMPTRACK_HUD, IMPLOYAL_HUD, IMPCHEM_HUD))
		holder = hud_list[I]
		holder.icon_state = null
	for(var/obj/item/weapon/implant/I in src)
		if(I.implanted)
			if(istype(I,/obj/item/weapon/implant/tracking))
				holder = hud_list[IMPTRACK_HUD]
				holder.icon_state = "hud_imp_tracking"
			else if(istype(I,/obj/item/weapon/implant/loyalty))
				holder = hud_list[IMPLOYAL_HUD]
				holder.icon_state = "hud_imp_loyal"
			else if(istype(I,/obj/item/weapon/implant/chem))
				holder = hud_list[IMPCHEM_HUD]
				holder.icon_state = "hud_imp_chem"
			else
				continue

/mob/living/carbon/human/proc/sec_hud_set_security_status()
	var/image/holder
	var/perpname = get_face_name(get_id_name(""))
	if(perpname)
		var/datum/data/record/R = find_record("name", perpname, data_core.security)
		if(R)
			holder = hud_list[WANTED_HUD]
			switch(R.fields["criminal"])
				if("*Arrest*")		holder.icon_state = "hudwanted"
				if("Incarcerated")	holder.icon_state = "hudincarcerated"
				if("Parolled")		holder.icon_state = "hudparolled"
				if("Discharged")	holder.icon_state = "huddischarged"
				else			holder.icon_state = null


			/*
 * Data HUDs are now passive in order to reduce lag.
 * Add then to a mob using add_data_hud.
 * Update them when needed with the appropriate proc. (see below)
 */

/* HUD DATUMS */

var/datum/hud/huds = list( \
	DATA_HUD_SECURITY_BASIC = new/datum/hud/data/security/basic(), \
	DATA_HUD_SECURITY_ADVANCED = new/datum/hud/data/security/advanced(), \
	DATA_HUD_MEDICAL_BASIC = new/datum/hud/data/medical/basic(), \
	DATA_HUD_MEDICAL_ADVANCED = new/datum/hud/data/medical/advanced() \
	)

/atom/proc/add_to_all_huds()
	for(var/datum/hud/hud in huds) hud.add_to_hud(src)

/atom/proc/remove_from_all_huds()
	for(var/datum/hud/hud in huds) hud.remove_from_hud(src)

//this is ugly
//don't use these if you don't need to
/proc/get_data_hud_datum(hud_type, hud_level)
	var/myhud = 0
	switch(hud_type)
		if(DATA_HUD_SECURITY)
			switch(hud_level)
				if(DATA_HUD_BASIC)
					myhud = DATA_HUD_SECURITY_BASIC
				if(DATA_HUD_ADVANCED)
					myhud = DATA_HUD_SECURITY_ADVANCED
		if(DATA_HUD_MEDICAL)
			switch(hud_level)
				if(DATA_HUD_BASIC)
					myhud = DATA_HUD_MEDICAL_BASIC
				if(DATA_HUD_ADVANCED)
					myhud = DATA_HUD_MEDICAL_ADVANCED
	return myhud

/mob/proc/access_data_hud(hud_type, hud_level)
	var/myhud = get_data_hud_datum(hud_type, hud_level)
	if(myhud)
		var/datum/hud/data/H = huds[myhud]
		H.add_hud_to(src)

/mob/proc/reset_data_hud(hud_type, hud_level)
	var/myhud = get_data_hud_datum(hud_type, hud_level)
	if(myhud)
		var/datum/hud/data/H = huds[myhud]
		H.remove_hud_from(src)

/datum/hud
	var/list/image/hudimages = list() //list of all hud image overlays
	var/list/mob/hudusers = list() //list with all mobs who can see the hud
	var/hud_type = 0 //hud_list[hud_type] will have icons to be shown. see __DEFINES/misc.dm for a list of the available types
	var/list/hud_icons = list() //these will be the indexes for hud_list[hud_type][]

/datum/hud/proc/remove_hud_from(var/mob/M)
	if(!M.client)
		return
	M.client.images -= hudimages
	hudusers -= M

/datum/hud/proc/remove_from_hud(var/atom/A)
	for(var/image/I in hudimages)
		if(I.loc == A)
			hudimages -= I
			for(var/mob/M in hudusers)
				M.client.images -= I

/datum/hud/proc/remove_from_single_hud(var/mob/M, var/atom/A)
	if(!M.client || !(hud_type in A.hud_list) || !(M in hudusers))
		return
	for(var/icontype in hud_icons)
		M.client.images -= A.hud_list[hud_type][hud_icons]

/datum/hud/proc/add_hud_to(var/mob/M)
	if(!M.client)
		return
	hudusers |= M
	add_images_to(M)

/datum/hud/proc/add_images_to(var/mob/M)
	M.client.images += hudimages

/datum/hud/proc/add_to_hud(var/atom/A)
	if(hud_type in A.hud_list)
		for(var/icontype in hud_icons)
			var/list/image/AH = A.hud_list[hud_type][hud_icons]
			hudimages += AH
			for(var/mob/M in hudusers)
				if(M.client)
					M.client.images += AH

/datum/hud/proc/add_to_single_hud(var/mob/M, var/atom/A)
	if(!M.client || !(hud_type in A.hud_list) || !(M in hudusers))
		return
	for(var/icontype in hud_icons)
		M.client.images |= A.hud_list[hud_type][hud_icons]

/datum/hud/data

/datum/hud/data/medical
	hud_type = DATA_HUD_MEDICAL
	hud_icons = list(HEALTH_HUD, STATUS_HUD)

/datum/hud/data/medical/basic

/datum/hud/data/medical/basic/add_images_to(var/mob/M)
	for(var/image/I in hudimages)
		var/mob/living/carbon/human/H = I.loc
		var/obj/item/clothing/under/U = H.w_uniform
		if(!istype(U)) continue
		if(U.sensor_mode <= 2) continue
		M.client.images += I

/datum/hud/data/medical/basic/proc/update_suit_sensors(var/mob/living/carbon/human/H, sensor_level)
	if(!istype(H)) return
	var/list/image/Himages = list()
	for(var/image/I in hudimages)
		if(I.loc == H) Himages |= I
	for(var/mob/M in hudusers)
		if(!M.client) continue
		if(sensor_level <= 2)
			M.client.images -= Himages
		else
			M.client.images |= Himages

/datum/hud/data/medical/advanced

/datum/hud/data/security
	hud_type = DATA_HUD_SECURITY

/datum/hud/data/security/basic
	hud_icons = list(ID_HUD)

/datum/hud/data/security/advanced
	hud_icons = list(ID_HUD, IMPTRACK_HUD, IMPLOYAL_HUD, IMPCHEM_HUD, WANTED_HUD)

/* MED/SEC HUD HOOKS */

/*
 * THESE HOOKS SHOULD BE CALLED BY THE MOB SHOWING THE HUD
 */

/***********************************************
 Medical HUD! Basic mode needs suit sensors on.
************************************************/

//HELPERS

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

//HOOKS

//called when a human changes suit sensors
/mob/living/carbon/human/proc/update_suit_sensors(var/obj/item/clothing/under/w_uniform)
	var/sensor_level = 0
	if(w_uniform)	sensor_level = w_uniform.sensor_mode
	var/datum/hud/data/medical/basic/B = huds[DATA_HUD_MEDICAL_BASIC]
	B.update_suit_sensors(src, sensor_level)

//called when a human changes health
/mob/living/carbon/human/proc/med_hud_set_health()
	var/image/holder = hud_list[DATA_HUD_MEDICAL][HEALTH_HUD]
	if(stat == 2)
		holder.icon_state = "hudhealth-100"
	else
		holder.icon_state = "hud[RoundHealth(health)]"

//called when a human changes stat, virus or XENO_HOST
/mob/living/carbon/human/proc/med_hud_set_status()
	var/image/holder = hud_list[DATA_HUD_MEDICAL][STATUS_HUD]
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

//HOOKS

/mob/living/carbon/human/proc/sec_hud_set_ID()
	var/image/holder = hud_list[DATA_HUD_SECURITY][ID_HUD]
	holder.icon_state = "hudno_id"
	if(wear_id)
		holder.icon_state = "hud[ckey(wear_id.GetJobName())]"

/mob/living/carbon/human/proc/sec_hud_set_implants()
	var/image/holder
	for(var/I in list(IMPTRACK_HUD, IMPLOYAL_HUD, IMPCHEM_HUD))
		holder = hud_list[DATA_HUD_SECURITY][I]
		holder.icon_state = null
	for(var/obj/item/weapon/implant/I in src)
		if(I.implanted)
			if(istype(I,/obj/item/weapon/implant/tracking))
				holder = hud_list[DATA_HUD_SECURITY][IMPTRACK_HUD]
				holder.icon_state = "hud_imp_tracking"
			else if(istype(I,/obj/item/weapon/implant/loyalty))
				holder = hud_list[DATA_HUD_SECURITY][IMPLOYAL_HUD]
				holder.icon_state = "hud_imp_loyal"
			else if(istype(I,/obj/item/weapon/implant/chem))
				holder = hud_list[DATA_HUD_SECURITY][IMPCHEM_HUD]
				holder.icon_state = "hud_imp_chem"

/mob/living/carbon/human/proc/sec_hud_set_security_status()
	var/image/holder
	var/perpname = get_face_name(get_id_name(""))
	if(perpname)
		var/datum/data/record/R = find_record("name", perpname, data_core.security)
		if(R)
			holder = hud_list[DATA_HUD_SECURITY][WANTED_HUD]
			switch(R.fields["criminal"])
				if("*Arrest*")		holder.icon_state = "hudwanted"
				if("Incarcerated")	holder.icon_state = "hudincarcerated"
				if("Parolled")		holder.icon_state = "hudparolled"
				if("Discharged")	holder.icon_state = "huddischarged"
				else				holder.icon_state = null

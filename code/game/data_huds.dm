/*
 * Data HUDs have been rewritten in a more generic way.
 * In short, they now use an observer-listener pattern.
 * See code/datum/hud.dm for the generic hud datum.
 * Update the HUD icons when needed with the appropriate hook. (see below)
 */

/* DATA HUD DATUMS */

/atom/proc/add_to_all_data_huds()
	for(var/datum/atom_hud/data/hud in huds) hud.add_to_hud(src)

/atom/proc/remove_from_all_data_huds()
	for(var/datum/atom_hud/data/hud in huds) hud.remove_from_hud(src)

/datum/atom_hud/data

/datum/atom_hud/data/medical
	hud_icons = list(HEALTH_HUD, STATUS_HUD)

/datum/atom_hud/data/medical/basic

/datum/atom_hud/data/medical/basic/proc/check_sensors(var/mob/living/carbon/human/H)
	if(!istype(H)) return 0
	var/obj/item/clothing/under/U = H.w_uniform
	if(!istype(U)) return 0
	if(U.sensor_mode <= 2) return 0
	return 1

/datum/atom_hud/data/medical/basic/add_to_single_hud(var/mob/M, var/mob/living/carbon/H)
	if(check_sensors(H))
		..()

/datum/atom_hud/data/medical/basic/proc/update_suit_sensors(var/mob/living/carbon/H)
	check_sensors(H) ? add_to_hud(H) : remove_from_hud(H)

/datum/atom_hud/data/medical/advanced

/datum/atom_hud/data/security

/datum/atom_hud/data/security/basic
	hud_icons = list(ID_HUD)

/datum/atom_hud/data/security/advanced
	hud_icons = list(ID_HUD, IMPTRACK_HUD, IMPLOYAL_HUD, IMPCHEM_HUD, WANTED_HUD)

/* MED/SEC HUD HOOKS */

/*
 * THESE HOOKS SHOULD BE CALLED BY THE MOB SHOWING THE HUD
 */

/***********************************************
 Medical HUD! Basic mode needs suit sensors on.
************************************************/

//HELPERS

//called when a carbon changes virus
/mob/living/carbon/proc/check_virus()
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
/mob/living/carbon/proc/update_suit_sensors()
	var/datum/atom_hud/data/medical/basic/B = huds[DATA_HUD_MEDICAL_BASIC]
	B.update_suit_sensors(src)

//called when a carbon changes health
/mob/living/carbon/proc/med_hud_set_health()
	var/image/holder = hud_list[HEALTH_HUD]
	if(stat == 2)
		holder.icon_state = "hudhealth-100"
	else
		holder.icon_state = "hud[RoundHealth(health)]"

//called when a carbon changes stat, virus or XENO_HOST
/mob/living/carbon/proc/med_hud_set_status()
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

//HOOKS

/mob/living/carbon/human/proc/sec_hud_set_ID()
	var/image/holder = hud_list[ID_HUD]
	holder.icon_state = "hudno_id"
	if(wear_id)
		holder.icon_state = "hud[ckey(wear_id.GetJobName())]"

/mob/living/carbon/human/proc/sec_hud_set_implants()
	var/image/holder
	for(var/i in list(IMPTRACK_HUD, IMPLOYAL_HUD, IMPCHEM_HUD))
		holder = hud_list[i]
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
				else				holder.icon_state = null


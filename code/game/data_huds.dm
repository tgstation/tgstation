/* Using the HUD procs is simple. Call these procs in the life.dm of the intended mob.
Use the regular_hud_updates() proc before process_med_hud(mob) or process_sec_hud(mob) so
the HUD updates properly! */

//Deletes the current HUD images so they can be refreshed with new ones.
mob/proc/regular_hud_updates() //Used in the life.dm of mobs that can use HUDs.
	if(client)
		for(var/image/hud in client.images)
			if(copytext(hud.icon_state,1,4) == "hud")
				client.images -= hud
	med_hud_users -= src
	sec_hud_users -= src


//Medical HUD procs

proc/RoundHealth(health)

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

/*Called by the Life() proc of the mob using it, usually. Items can call it as well.
Called with this syntax: (The user mob, the type of hud in use, the advanced or basic version of the hud,eye object in the case of an AI) */

proc/process_data_hud(var/mob/M, var/hud_type, var/hud_mode, var/mob/eye)
	#define DATA_HUD_MEDICAL	1
	#define DATA_HUD_SECURITY	2

	#define DATA_HUD_BASIC		1
	#define DATA_HUD_ADVANCED	2

	if(!M)
		return
	if(!M.client)
		return

	var/turf/T
	if(eye)
		T = get_turf(eye)
	else
		T = get_turf(M)


	for(var/mob/living/carbon/human/H in mob_list)
		if(get_dist(H, T) > M.client.view) //Ignores any humans outside of the user's view distance.
			continue

		switch(hud_type)
			if(DATA_HUD_MEDICAL)
				med_hud_users |= M
				process_med_hud(M,hud_mode,T,H)

			if(DATA_HUD_SECURITY)
				sec_hud_users |= M //Used for Security HUD alerts.
				process_sec_hud(M,hud_mode,T,H)

/***********************************************
Medical HUD outputs! Advanced mode ignores suit sensors.
************************************************/
proc/process_med_hud(var/mob/M, var/mode, var/turf/T, var/mob/living/carbon/human/patient)

	var/client/C = M.client

	if(mode == DATA_HUD_BASIC && !med_hud_suit_sensors(patient)) //Used for the AI's MedHUD, only works if the patient has activated suit sensors.
		return


	var/foundVirus = med_hud_find_virus(patient) //Detects non-hidden diseases in a patient, returns as a binary value.

	C.images += med_hud_get_health(patient) //Generates a patient's health bar.
	C.images += med_hud_get_status(patient, foundVirus) //Determines the type of status icon to show.


proc/med_hud_suit_sensors(var/mob/living/carbon/human/patient)
	if(istype(patient.w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = patient.w_uniform
		if(U.sensor_mode > 2)
			return 1
	else
		return 0

proc/med_hud_find_virus(var/mob/living/carbon/human/patient)
	for(var/datum/disease/D in patient.viruses)
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			if(D.severity != NONTHREAT)
				return 1

proc/med_hud_get_health(var/mob/living/carbon/human/patient)
	var/image/holder = patient.hud_list[HEALTH_HUD]
	if(patient.stat == 2)
		holder.icon_state = "hudhealth-100"
	else
		holder.icon_state = "hud[RoundHealth(patient.health)]"
	return holder

proc/med_hud_get_status(var/mob/living/carbon/human/patient, var/foundVirus)
	var/image/holder = patient.hud_list[STATUS_HUD]
	if(patient.stat == 2)
		holder.icon_state = "huddead"
	else if(patient.status_flags & XENO_HOST)
		holder.icon_state = "hudxeno"
	else if(foundVirus)
		holder.icon_state = "hudill"
	else
		holder.icon_state = "hudhealthy"
	return holder


/***********************************************
 Security HUDs.
 Pass a value for the second argument to enable implant viewing or other special features.
************************************************/
proc/process_sec_hud(var/mob/M, var/mode, var/turf/T, var/mob/living/carbon/human/perp)

	var/client/C = M.client

	sec_hud_get_ID(C, perp) //Provides the perp's job icon.

	if(mode == DATA_HUD_ADVANCED) //If not set to "DATA_HUD_ADVANCED, the Sec HUD will only display the job.
		sec_hud_get_implants(C, perp) //Returns the perp's implants, if any.
		sec_hud_get_security_status(C, perp) //Gives the perp's arrest record, if there is one.


proc/sec_hud_get_ID(var/client/C, var/mob/living/carbon/human/perp)
	var/image/holder
	holder = perp.hud_list[ID_HUD]
	holder.icon_state = "hudno_id"
	if(perp.wear_id)
		holder.icon_state = "hud[ckey(perp.wear_id.GetJobName())]"
	C.images += holder

proc/sec_hud_get_implants(var/client/C, var/mob/living/carbon/human/perp)
	var/image/holder
	for(var/obj/item/weapon/implant/I in perp)
		if(I.implanted)
			if(istype(I,/obj/item/weapon/implant/tracking))
				holder = perp.hud_list[IMPTRACK_HUD]
				holder.icon_state = "hud_imp_tracking"
			else if(istype(I,/obj/item/weapon/implant/loyalty))
				holder = perp.hud_list[IMPLOYAL_HUD]
				holder.icon_state = "hud_imp_loyal"
			else if(istype(I,/obj/item/weapon/implant/chem))
				holder = perp.hud_list[IMPCHEM_HUD]
				holder.icon_state = "hud_imp_chem"
			else
				continue
			C.images += holder
			break

proc/sec_hud_get_security_status(var/client/C, var/mob/living/carbon/human/perp)
	var/image/holder
	var/perpname = perp.get_face_name(perp.get_id_name(""))
	if(perpname)
		var/datum/data/record/R = find_record("name", perpname, data_core.security)
		if(R)
			holder = perp.hud_list[WANTED_HUD]
			switch(R.fields["criminal"])
				if("*Arrest*")		holder.icon_state = "hudwanted"
				if("Incarcerated")	holder.icon_state = "hudincarcerated"
				if("Parolled")		holder.icon_state = "hudparolled"
				if("Discharged")		holder.icon_state = "huddischarged"
				else
					return
			C.images += holder
/mob/living/silicon/pai/proc/regular_hud_updates()
	if(client)
		for(var/image/hud in client.images)
			if(copytext(hud.icon_state,1,4) == "hud")
				client.images -= hud

/mob/living/silicon/pai/proc/securityHUD()
	if(client)
		var/image/holder
		var/turf/T = get_turf(src.loc)
		for(var/mob/living/carbon/human/perp in view(T))
			holder = perp.hud_list[ID_HUD]
			holder.icon_state = "hudno_id"
			if(perp.wear_id)
				holder.icon_state = "hud[ckey(perp:wear_id:GetJobName())]"
			client.images += holder

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
							continue
					client.images += holder

/mob/living/silicon/pai/proc/medicalHUD()
	if(client)
		var/image/holder
		var/turf/T = get_turf(src.loc)
		for(var/mob/living/carbon/human/patient in view(T))

			var/foundVirus = 0
			for(var/datum/disease/D in patient.viruses)
				if(!D.hidden[SCANNER])
					foundVirus = 1

			holder = patient.hud_list[HEALTH_HUD]
			if(patient.stat == 2)
				holder.icon_state = "hudhealth-100"
				client.images += holder
			else
				holder.icon_state = "hud[RoundHealth(patient.health)]"
				client.images += holder

			holder = patient.hud_list[STATUS_HUD]
			if(patient.stat == 2)
				holder.icon_state = "huddead"
			else if(patient.status_flags & XENO_HOST)
				holder.icon_state = "hudxeno"
			else if(foundVirus)
				holder.icon_state = "hudill"
			else
				holder.icon_state = "hudhealthy"
			client.images += holder

/mob/living/silicon/pai/proc/RoundHealth(health)
	switch(health)
		if(100 to INFINITY)
			return "health100"
		if(70 to 100)
			return "health80"
		if(50 to 70)
			return "health60"
		if(30 to 50)
			return "health40"
		if(20 to 30)
			return "health25"
		if(5 to 15)
			return "health10"
		if(1 to 5)
			return "health1"
		if(-99 to 0)
			return "health0"
		else
			return "health-100"
	return "0"

/mob/living/silicon/pai/proc/regular_hud_updates()
	if(client)
		for(var/image/hud in client.images)
			if(copytext(hud.icon_state,1,4) == "hud")
				client.images -= hud

/mob/living/silicon/pai/proc/securityHUD()
	if(client)
		var/turf/T = get_turf_or_move(src.loc)
		for(var/mob/living/carbon/human/perp in view(T))
			if(perp.wear_id)
				perp.sec_img.icon_state = "hud[ckey(perp:wear_id:GetJobName())]"
				client.images += perp.sec_img
				var/perpname = "wot no name?"
				if(istype(perp.wear_id,/obj/item/weapon/card/id))
					perpname = perp.wear_id:registered_name
				else if(istype(perp.wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = perp.wear_id
					perpname = tempPda.owner
				for (var/datum/data/record/E in data_core.general)
					if (E.fields["name"] == perpname)
						for (var/datum/data/record/R in data_core.security)
							if ((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
								perp.sec2_img.icon_state = "hudwanted"
								client.images += perp.sec2_img
								break
							else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Incarcerated"))
								perp.sec2_img.icon_state = "hudprisoner"
								client.images += perp.sec2_img
								break
			else
				perp.sec_img.icon_state = "hudunknown"
				client.images += perp.sec_img

/mob/living/silicon/pai/proc/medicalHUD()
	if(client)
		var/turf/T = get_turf_or_move(src.loc)
		for(var/mob/living/carbon/human/patient in view(T))

			var/foundVirus = 0
			for(var/datum/disease/D in patient.viruses)
				if(!D.hidden[SCANNER])
					foundVirus = 1

			patient.health_img.icon_state = "hud[RoundHealth(patient.health)]"
			client.images += patient.health_img
			if(patient.stat == 2)
				patient.med_img.icon_state = "huddead"
			else if(patient.alien_egg_flag)
				patient.med_img.icon_state = "hudxeno"
			else if(foundVirus)
				patient.med_img.icon_state = "hudill"
			else
				patient.med_img.icon_state = "hudhealthy"
			client.images += patient.med_img

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
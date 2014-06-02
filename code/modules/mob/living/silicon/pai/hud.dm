/mob/living/silicon/pai/proc/regular_hud_updates()
	if(client)
		for(var/image/hud in client.images)
			if(copytext(hud.icon_state,1,4) == "hud")
				client.images -= hud

/mob/living/silicon/pai/proc/securityHUD()
	if(client)
		var/image/holder
		var/turf/T = get_turf_or_move(src.loc)
		for(var/mob/living/carbon/human/perp in view(T))
			if(src.see_invisible < perp.invisibility)
				continue
			var/perpname = "wot"
			holder = perp.hud_list[ID_HUD]
			if(perp.wear_id)
				var/obj/item/weapon/card/id/I = perp.wear_id.GetID()
				if(I)
					perpname = I.registered_name
					holder.icon_state = "hud[ckey(perp:wear_id:GetJobName())]"
					client.images += holder
				else
					perpname = perp.name
					holder.icon_state = "hudunknown"
					client.images += holder
			else
				holder.icon_state = "hudunknown"
				client.images += holder

			for(var/datum/data/record/E in data_core.general)
				if(E.fields["name"] == perpname)
					holder = perp.hud_list[WANTED_HUD]
					for(var/datum/data/record/R in data_core.security)
						if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
							holder.icon_state = "hudwanted"
							client.images += holder
							break
						else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Incarcerated"))
							holder.icon_state = "hudprisoner"
							client.images += holder
							break
						else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Parolled"))
							holder.icon_state = "hudparolled"
							client.images += holder
							break
						else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Released"))
							holder.icon_state = "hudreleased"
							client.images += holder
							break

/mob/living/silicon/pai/proc/medicalHUD()
	if(client)
		var/image/holder
		var/turf/T = get_turf_or_move(src.loc)
		for(var/mob/living/carbon/human/patient in view(T))
			if(src.see_invisible < patient.invisibility)
				continue
			var/foundVirus = 0
			for(var/datum/disease/D in patient.viruses)
				if(!D.hidden[SCANNER])
					foundVirus++

			for (var/ID in patient.virus2)
				if (ID in virusDB)
					foundVirus = 1
					break

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
			else if(patient.has_brain_worms())
				var/mob/living/simple_animal/borer/B = patient.has_brain_worms()
				if(B.controlling)
					holder.icon_state = "hudbrainworm"
				else
					holder.icon_state = "hudhealthy"
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
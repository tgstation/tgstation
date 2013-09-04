/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = null //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"
	var/list/icon/current = list() //the current hud icons

	proc
		process_hud(var/mob/M)	return



/obj/item/clothing/glasses/hud/health
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"
	proc
		RoundHealth(health)


	RoundHealth(health)
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


	process_hud(var/mob/M)
		if(!M)	return
		if(!M.client)	return
		var/client/C = M.client
		var/image/holder
		for(var/mob/living/carbon/human/patient in view(get_turf(M)))
			if(M.see_invisible < patient.invisibility)
				continue
			var/foundVirus = 0
			for(var/datum/disease/D in patient.viruses)
				if(!D.hidden[SCANNER])
					foundVirus++
			for (var/ID in patient.virus2)
				if (ID in virusDB)
					foundVirus = 1
					break
			if(!C) continue

			holder = patient.hud_list[HEALTH_HUD]
			if(patient.stat == 2)
				holder.icon_state = "hudhealth-100"
			else
				holder.icon_state = "hud[RoundHealth(patient.health)]"
			C.images += holder

			holder = patient.hud_list[STATUS_HUD]
			if(patient.stat == 2)
				holder.icon_state = "huddead"
			else if(patient.status_flags & XENO_HOST)
				holder.icon_state = "hudxeno"
			else if(foundVirus)
				holder.icon_state = "hudill"
			else
				holder.icon_state = "hudhealthy"
			C.images += holder


/obj/item/clothing/glasses/hud/security
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"

/obj/item/clothing/glasses/hud/security/jensenshades
	name = "Augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "jensenshades"
	item_state = "jensenshades"
	vision_flags = SEE_MOBS
	invisa_view = 2

/obj/item/clothing/glasses/hud/security/process_hud(var/mob/M)
	if(!M)	return
	if(!M.client)	return
	var/client/C = M.client
	var/image/holder
	for(var/mob/living/carbon/human/perp in view(get_turf(M)))
		if(M.see_invisible < perp.invisibility)
			continue
		if(!C) continue
		var/perpname = perp.name
		holder = perp.hud_list[ID_HUD]
		if(perp.wear_id)
			var/obj/item/weapon/card/id/I = perp.wear_id.GetID()
			if(I)
				perpname = I.registered_name
				holder.icon_state = "hud[ckey(I.GetJobName())]"
				C.images += holder
			else
				perpname = perp.name
				holder.icon_state = "hudunknown"
				C.images += holder
		else
			perpname = perp.name
			holder.icon_state = "hudunknown"
			C.images += holder

		for(var/datum/data/record/E in data_core.general)
			if(E.fields["name"] == perpname)
				holder = perp.hud_list[WANTED_HUD]
				for (var/datum/data/record/R in data_core.security)
					if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
						holder.icon_state = "hudwanted"
						C.images += holder
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Incarcerated"))
						holder.icon_state = "hudprisoner"
						C.images += holder
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Parolled"))
						holder.icon_state = "hudparolled"
						C.images += holder
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Released"))
						holder.icon_state = "hudreleased"
						C.images += holder
						break
		for(var/obj/item/weapon/implant/I in perp)
			if(I.implanted)
				if(istype(I,/obj/item/weapon/implant/tracking))
					holder = perp.hud_list[IMPTRACK_HUD]
					holder.icon_state = "hud_imp_tracking"
					C.images += holder
				if(istype(I,/obj/item/weapon/implant/loyalty))
					holder = perp.hud_list[IMPLOYAL_HUD]
					holder.icon_state = "hud_imp_loyal"
					C.images += holder
				if(istype(I,/obj/item/weapon/implant/chem))
					holder = perp.hud_list[IMPCHEM_HUD]
					holder.icon_state = "hud_imp_chem"
					C.images += holder
/obj/mecha/medical/odysseus
	desc = "Odysseus Medical Exosuit"
	name = "Odysseus"
	icon_state = "placeholder-1"
	step_in = 2
	max_temperature = 1500
	health = 120
	wreckage = null
	internal_damage_threshold = 35
	deflect_chance = 15
	step_energy_drain = 6
	var/obj/item/clothing/glasses/hud/health/mech/hud

	New()
		..()
		hud = new /obj/item/clothing/glasses/hud/health/mech(src)
		return

	moved_inside(var/mob/living/carbon/human/H as mob)
		if(..())
			if(H.glasses)
				occupant_message("<font color='red'>[H.glasses] prevent you from using [src] [hud]</font>")
			else
				H.glasses = hud
			return 1
		else
			return 0

	go_out()
		if(ishuman(occupant))
			var/mob/living/carbon/human/H = occupant
			if(H.glasses == hud)
				H.glasses = null
		..()
		return
/*
	verb/set_perspective()
		set name = "Set client perspective."
		set category = "Exosuit Interface"
		set src = usr.loc
		var/perspective = input("Select a perspective type.",
                      "Client perspective",
                      occupant.client.perspective) in list(MOB_PERSPECTIVE,EYE_PERSPECTIVE)
		world << "[perspective]"
		occupant.client.perspective = perspective
		return

	verb/toggle_eye()
		set name = "Toggle eye."
		set category = "Exosuit Interface"
		set src = usr.loc
		if(occupant.client.eye == occupant)
			occupant.client.eye = src
		else
			occupant.client.eye = occupant
		world << "[occupant.client.eye]"
		return
*/

//TODO - Check documentation for client.eye and client.perspective...
/obj/item/clothing/glasses/hud/health/mech
	name = "Integrated Medical Hud"


	process_hud(var/mob/M)
/*
		world<< "view(M)"
		for(var/mob/mob in view(M))
			world << "[mob]"
		world<< "view(M.client)"
		for(var/mob/mob in view(M.client))
			world << "[mob]"
		world<< "view(M.loc)"
		for(var/mob/mob in view(M.loc))
			world << "[mob]"
*/

		if(!M || M.stat || !(M in view(M)))	return
		if(!M.client)	return
		var/client/C = M.client
		var/icon/tempHud = 'hud.dmi'
		for(var/mob/living/carbon/human/patient in view(M.loc))
			if(M.see_invisible < patient.invisibility)
				continue
			var/foundVirus = 0
			for(var/datum/disease/D in patient.viruses)
				if(!D.hidden[SCANNER])
					foundVirus++
			if(patient.virus2)
				foundVirus++
			C.images += image(tempHud,patient,"hud[RoundHealth(patient.health)]")
			if(patient.stat == 2)
				C.images += image(tempHud,patient,"huddead")
			else if(patient.alien_egg_flag)
				C.images += image(tempHud,patient,"hudxeno")
			else if(foundVirus)
				C.images += image(tempHud,patient,"hudill")
			else
				C.images += image(tempHud,patient,"hudhealthy")

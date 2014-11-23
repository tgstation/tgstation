/obj/mecha/medical/odysseus
	desc = "These exosuits are developed and produced by Vey-Med. (&copy; All rights reserved)."
	name = "\improper Odysseus"
	icon_state = "odysseus"
	step_in = 3
	max_temperature = 15000
	health = 120
	wreckage = /obj/structure/mecha_wreckage/odysseus
	internal_damage_threshold = 35
	deflect_chance = 15
	step_energy_drain = 6
	var/obj/item/clothing/glasses/hud/health/mech/hud

/obj/mecha/medical/odysseus/New()
	..()
	hud = new /obj/item/clothing/glasses/hud/health/mech(src)
	return

/obj/mecha/medical/odysseus/moved_inside(var/mob/living/carbon/human/H as mob)
	if(..())
		if(H.glasses)
			occupant_message("<font color='red'>[H.glasses] prevent you from using [src] [hud]</font>")
		else
			H.glasses = hud
		return 1
	else
		return 0

/obj/mecha/medical/odysseus/go_out()
	if(ishuman(occupant))
		var/mob/living/carbon/human/H = occupant
		if(H.glasses == hud)
			H.glasses = null
	..()
	return
/*
/obj/mecha/medical/odysseus/verb/set_perspective()
	set name = "Set client perspective."
	set category = "Exosuit Interface"
	set src = usr.loc
	var/perspective = input("Select a perspective type.",
                      "Client perspective",
                      occupant.client.perspective) in list(MOB_PERSPECTIVE,EYE_PERSPECTIVE)
	world << "[perspective]"
	occupant.client.perspective = perspective
	return

/obj/mecha/medical/odysseus/verb/toggle_eye()
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
	name = "integrated medical Hud"


/obj/item/clothing/glasses/hud/health/mech/process_hud(var/mob/M)
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
	var/image/holder
	for(var/mob/living/carbon/human/patient in view(M.loc))
		if(M.see_invisible < patient.invisibility)
			continue
		var/foundVirus = 0
		for(var/datum/disease/D in patient.viruses)
			if(!(D.visibility_flags & HIDDEN_SCANNER))
				if(D.severity != NONTHREAT)
					foundVirus++
		//if(patient.virus2)
		//	foundVirus++

		holder = patient.hud_list[HEALTH_HUD]
		if(patient.stat == 2)
			holder.icon_state = "hudhealth-100"
			C.images += holder
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

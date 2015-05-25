/obj/machinery/abductor/experiment
	name = "Experimental machinery"
	desc = "A human-sized coffin sporting wide array of automatic surgery tools"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "experiment-open"
	density = 0
	anchored = 1
	state_open = 1
	var/points = 0
	var/list/history = new
	var/flash = " - || - "
	var/obj/machinery/abductor/console/console

/obj/machinery/abductor/experiment/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !target.Adjacent(user) || !ishuman(target))
		return
	if(IsAbductor(target))
		return
	close_machine(target)

/obj/machinery/abductor/experiment/attack_hand(mob/user)
	if(..())
		return

	experimentUI(user)

/obj/machinery/abductor/experiment/open_machine()
	if(!state_open && !panel_open)
		..()

/obj/machinery/abductor/experiment/close_machine(mob/target)
	for(var/mob/living/carbon/C in loc)
		if(IsAbductor(C))
			return
	if(state_open && !panel_open)
		..(target)

/obj/machinery/abductor/experiment/proc/dissection_icon(var/mob/living/carbon/human/H)
	var/icon/photo = null
	var/g = (H.gender == FEMALE) ? "f" : "m"
	if(!config.mutant_races || H.dna.species.use_skintones)
		photo = icon("icon" = 'icons/mob/human.dmi', "icon_state" = "[H.skin_tone]_[g]_s")
	else
		photo = icon("icon" = 'icons/mob/human.dmi', "icon_state" = "[H.dna.species.id]_[g]_s")
		photo.Blend("#[H.dna.mutant_color]", ICON_MULTIPLY)

	var/icon/eyes_s
	if(EYECOLOR in H.dna.species.specflags)
		eyes_s = icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[H.dna.species.eyes]_s")
		eyes_s.Blend("#[H.eye_color]", ICON_MULTIPLY)

	var/datum/sprite_accessory/S
	S = hair_styles_list[H.hair_style]
	if(S && (HAIR in H.dna.species.specflags))
		var/icon/hair_s = icon("icon" = S.icon, "icon_state" = "[S.icon_state]_s")
		hair_s.Blend("#[H.hair_color]", ICON_MULTIPLY)
		eyes_s.Blend(hair_s, ICON_OVERLAY)

	S = facial_hair_styles_list[H.facial_hair_style]
	if(S && (FACEHAIR in H.dna.species.specflags))
		var/icon/facial_s = icon("icon" = S.icon, "icon_state" = "[S.icon_state]_s")
		facial_s.Blend("#[H.facial_hair_color]", ICON_MULTIPLY)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

	if(eyes_s)
		photo.Blend(eyes_s, ICON_OVERLAY)

	var/icon/splat = icon("icon" = 'icons/mob/dam_human.dmi',"icon_state" = "chest30")
	photo.Blend(splat,ICON_OVERLAY)

	return photo

/obj/machinery/abductor/experiment/proc/experimentUI(mob/user)
	var/dat
	dat += "<h3> Experiment </h3>"
	if(occupant)
		var/obj/item/weapon/photo/P = new
		P.photocreate(null, icon(dissection_icon(occupant), dir = SOUTH))
		user << browse_rsc(P.img, "dissection_img")
		dat += "<table><tr><td>"
		dat += "<img src=dissection_img height=80 width=80>" //Avert your eyes
		dat += "</td><td>"
		dat += "<a href='?src=\ref[src];experiment=1'>Probe</a><br>"
		dat += "<a href='?src=\ref[src];experiment=2'>Dissect</a><br>"
		dat += "<a href='?src=\ref[src];experiment=3'>Analyze</a><br>"
		dat += "</td></tr></table>"
	else
		dat += "<span class='linkOff'> Experiment </span>"

	if(!occupant)
		dat += "<h3>Machine Unoccupied</h3>"
	else
		dat += "<h3>Subject Status : </h3>"
		dat += "[occupant.name] => "
		switch(occupant.stat)
			if(0)
				dat += "<span class='good'>Conscious</span>"
			if(1)
				dat += "<span class='average'>Unconscious</span>"
			else
				dat += "<span class='bad'>DEAD</span>"
	dat += "<br>"
	dat += "[flash]"
	dat += "<br>"
	dat += "<a href='?src=\ref[src];refresh=1'>Scan</a>"
	dat += "<a href='?src=\ref[src];[state_open ? "close=1'>Close</a>" : "open=1'>Open</a>"]"
	var/datum/browser/popup = new(user, "experiment", "Probing Console", 300, 300)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.set_content(dat)
	popup.open()

/obj/machinery/abductor/experiment/Topic(href, href_list)
	if(..() || usr == occupant)
		return
	usr.set_machine(src)
	if(href_list["refresh"])
		updateUsrDialog()
		return
	if(href_list["open"])
		open_machine()
		return
	if(href_list["close"])
		close_machine()
		return
	if(occupant && occupant.stat != DEAD)
		if(href_list["experiment"])
			flash = Experiment(occupant,href_list["experiment"])
	updateUsrDialog()
	add_fingerprint(usr)

/obj/machinery/abductor/experiment/proc/Experiment(var/mob/occupant,var/type)
	var/mob/living/carbon/human/H = occupant
	var/point_reward = 0
	if(H in history)
		return "<span class='bad'>Specimen already in the database</span>"
	if(H.stat == DEAD)
		say("Specimen deceased - please provide fresh sample.")
		return "<span class='bad'>Specimen Deceased</span>"
	var/obj/item/gland/GlandTest = locate() in H
	if(!GlandTest)
		say("Experimental dissection not detected!")
		return "<span class='bad'>No glands detected!</span>"
	if(H.mind != null && H.ckey != null)
		history += H
		say("Processing Specimen...")
		sleep(5)
		switch(text2num(type))
			if(1)
				H << "<span class='warning'>You feel violated.</span>"
			if(2)
				H << "<span class='warning'>You feel being sliced and put back together.</span>"
			if(3)
				H << "<span class='warning'>You feel under intense scrutiny.</span>"
		sleep(5)
		H << "<span class='warning'>Your mind snaps!</span>"
		var/objtype = pick(typesof(/datum/objective/abductee/) - /datum/objective/abductee/)
		var/datum/objective/abductee/O = new objtype()
		H.mind.objectives += O
		var/obj_count = 1
		H << "<span class='notice'>Your current objectives:</span>"
		for(var/datum/objective/objective in H.mind.objectives)
			H << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++

		for(var/obj/item/gland/G in H)
			G.Start()
			point_reward++
		if(point_reward > 0)
			open_machine()
			SendBack(H)
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			points += point_reward
			return "<span class='good'>Experiment Successfull! [point_reward] new data-points collected.</span>"
		else
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 1)
			return "<span class='bad'>Experiment Failed! No replacement organ detected.</span>"
	else
		say("Brain Activity Nonexistant - Disposing Sample...")
		open_machine()
		SendBack(H)
		return "<span class='bad'>Specimen Braindead - Disposed</span>"
	return "<span class='bad'>ERROR</span>"


/obj/machinery/abductor/experiment/proc/SendBack(var/mob/living/carbon/human/H)
	H.Sleeping(8)
	var/area/A
	if(console && console.pad && console.pad.teleport_target)
		A = console.pad.teleport_target
		if(A.safe) // right now crew areas are safe - being locked behind closed doors is not fun
			TeleportToArea(H,A)
	//Area not chosen / It's not safe area - teleport to arrivals
	H.forceMove(pick(latejoin))


/obj/machinery/abductor/experiment/update_icon()
	if(state_open)
		icon_state = "experiment-open"
	else
		icon_state = "experiment"

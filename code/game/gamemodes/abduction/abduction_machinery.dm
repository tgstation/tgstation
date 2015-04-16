/obj/machinery/abductor
	var/team = 0

/obj/machinery/abductor/console
	name = "Abductor console"
	desc = "Ship command center."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "console"
	density = 1
	anchored = 1.0
	var/obj/item/device/abductor/gizmo/gizmo
	var/obj/item/clothing/suit/armor/abductor/vest/vest
	var/obj/machinery/abductor/experiment/experiment
	var/obj/machinery/abductor/pad/pad
	var/list/datum/icon_snapshot/disguises = list()

/obj/machinery/abductor/console/attack_hand(var/mob/user as mob)
	if(..())
		return
	if(!IsAbductor(user))
		return
	user.set_machine(src)
	var/dat = ""
	dat += "<H3> Abductsoft 3000 </H3>"

	if(experiment != null)
		var/points = experiment.points
		dat += "Collected Samples : [points] <br>"
	else
		dat += "<span class='bad'>NO EXPERIMENT MACHINE DETECTED</span> <br>"

	if(pad!=null)
		dat += "<a href='?src=\ref[src];teleporter_send=1'>Activate Teleporter</A><br>"
		dat += "<a href='?src=\ref[src];teleporter_set=1'>Set Teleporter</A><br>"
		if(gizmo!=null && gizmo.marked!=null)
			dat += "<a href='?src=\ref[src];teleporter_retrieve=1'>Retrieve Mark</A><br>"
		else
			dat += "<span class='linkOff'>Retrieve Mark</span><br>"
	else
		dat += "<span class='bad'>NO TELEPAD DETECTED</span></br>"

	if(vest!=null)
		dat += "<h4> Agent Vest Mode </h4><br>"
		var/mode = vest.mode
		if(mode == VEST_STEALTH)
			dat += "<a href='?src=\ref[src];flip_vest=1'>Combat</A>"
			dat += "<span class='linkOff'>Stealth</span>"
		else
			dat += "<span class='linkOff'>Combat</span>"
			dat += "<a href='?src=\ref[src];flip_vest=1'>Stealth</A>"

		dat+="<br>"
		dat += "<a href='?src=\ref[src];select_disguise=1'>Select Agent Vest Disguise</a><br>"
	else
		dat += "<span class='bad'>NO AGENT VEST DETECTED</span>"
	var/datum/browser/popup = new(user, "computer", "Abductor Console", 400, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/abductor/console/Topic(href, href_list)
	if(..())
		return
	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
		if(href_list["teleporter_set"])
			TeleporterSet()
		else if(href_list["teleporter_send"])
			TeleporterSend()
		else if(href_list["teleporter_retrieve"])
			TeleporterRetrieve()
		else if(href_list["flip_vest"])
			FlipVest()
		else if(href_list["select_disguise"])
			SelectDisguise()
		src.updateUsrDialog()

/obj/machinery/abductor/console/proc/TeleporterSet()
	var/A = null
	A = input("Select area to teleport to", "Teleport", A) in teleportlocs
	if(pad!=null)
		pad.teleport_target = teleportlocs[A]
	return

/obj/machinery/abductor/console/proc/TeleporterRetrieve()
	if(gizmo!=null && pad!=null && gizmo.marked)
		pad.Retrieve(gizmo.marked)
	return

/obj/machinery/abductor/console/proc/TeleporterSend()
	if(pad!=null)
		pad.Send()
	return

/obj/machinery/abductor/console/proc/FlipVest()
	if(vest!=null)
		vest.flip_mode()
	return

/obj/machinery/abductor/console/proc/SelectDisguise()
	var/list/entries = list()
	var/tempname
	var/datum/icon_snapshot/temp
	for(var/i = 1; i <= disguises.len; i++)
		temp = disguises[i]
		tempname = temp.name
		entries["[tempname]"] = disguises[i]
	var/entry_name = input( "Choose Disguise", "Disguise") in entries
	var/datum/icon_snapshot/chosen = entries[entry_name]
	if(chosen)
		vest.SetDisguise(chosen)
	return

/obj/machinery/abductor/console/proc/Initialize()

	for(var/obj/machinery/abductor/pad/p in machines)
		if(p.team == team)
			pad = p
			break

	for(var/obj/machinery/abductor/experiment/e in machines)
		if(e.team == team)
			experiment = e
			e.console = src

/obj/machinery/abductor/console/proc/AddSnapshot(var/mob/living/carbon/human/target)
	var/datum/icon_snapshot/entry = new
	entry.name = target.name
	entry.icon = target.icon
	entry.icon_state = target.icon_state
	entry.overlays = target.get_overlays_copy(list(L_HAND_LAYER,R_HAND_LAYER))
	for(var/i=1,i<=disguises.len,i++)
		var/datum/icon_snapshot/temp = disguises[i]
		if(temp.name == entry.name)
			disguises[i] = entry
			return
	disguises.Add(entry)
	return

/obj/machinery/abductor/pad
	name = "Alien Telepad"
	desc = "Use this to transport to and from human habitat"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "alien-pad-idle"
	anchored = 1
	var/area/teleport_target

/obj/machinery/abductor/proc/IsAbductor(var/mob/living/carbon/human/H)
	if(!H.dna)
		return 0
	return H.dna.species.id == "abductor"

/obj/machinery/abductor/proc/IsAgent(var/mob/living/carbon/human/H)
	if(H.dna.species.id == "abductor")
		var/datum/species/abductor/S = H.dna.species
		return S.agent
	return 0

/obj/machinery/abductor/proc/IsScientist(var/mob/living/carbon/human/H)
	if(H.dna.species.id == "abductor")
		var/datum/species/abductor/S = H.dna.species
		return S.scientist
	return 0

/obj/machinery/abductor/proc/TeleportToArea(var/mob/living/target,var/area/thearea)
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T
	if(!L.len)
		return

	if(target && target.buckled)
		target.buckled.unbuckle_mob()

	var/list/tempL = L
	var/attempt = null
	var/success = 0
	while(tempL.len)
		attempt = pick(tempL)
		target.Move(attempt)
		if(get_turf(target) == attempt)
			success = 1
			break
		else
			tempL.Remove(attempt)
	if(!success)
		target.loc = pick(L)

/obj/machinery/abductor/pad/proc/Warp(var/mob/living/target)
	target.Move(src.loc)

/obj/machinery/abductor/pad/proc/Send()
	flick("alien-pad", src)
	for(var/mob/living/target in src.loc)
		TeleportToArea(target,teleport_target)
		spawn(0)
			anim(target.loc,target,'icons/mob/mob.dmi',,"uncloak",,target.dir)

/obj/machinery/abductor/pad/proc/Retrieve(var/mob/living/carbon/human/target)
	flick("alien-pad", src)
	spawn(0)
		anim(target.loc,target,'icons/mob/mob.dmi',,"uncloak",,target.dir)
	Warp(target)

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

/obj/machinery/abductor/experiment/allow_drop()
	return 0

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
	if(H.mind != null || H.ckey != null)
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
	else
		A = teleportlocs[pick(teleportlocs)]
	TeleportToArea(H,A)

/obj/machinery/abductor/experiment/update_icon()
	if(state_open)
		icon_state = "experiment-open"
	else
		icon_state = "experiment"

/obj/machinery/abductor/experiment/say_quote(text)
	return "beeps, \"[text]\""


/obj/machinery/abductor/gland_dispenser
	name = "Replacement Organ Storage"
	desc = "A tank filled with replacement organs"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "dispenser"
	density = 1
	anchored = 1
	var/list/gland_types
	var/list/gland_colors
	var/list/amounts

/obj/machinery/abductor/gland_dispenser/proc/random_color()
	//TODO : replace with presets or spectrum
	return rgb(rand(0,255),rand(0,255),rand(0,255))

/obj/machinery/abductor/gland_dispenser/New()
	gland_types = typesof(/obj/item/gland) - /obj/item/gland
	gland_types = shuffle(gland_types)
	gland_colors = new/list(gland_types.len)
	amounts = new/list(gland_types.len)
	for(var/i=1,i<=gland_types.len,i++)
		gland_colors[i] = random_color()
		amounts[i] = rand(1,5)

/obj/machinery/abductor/gland_dispenser/attack_hand(var/mob/user as mob)
	if(..())
		return
	if(!IsAbductor(user))
		return
	user.set_machine(src)
	var/box_css = {"
	<style>
	a.box.gland {
		float: left;
		width: 20px;
		height: 20px;
		margin: 5px;
		border-width: 1px;
		border-style: solid;
		border-color: rgba(0,0,0,.2);
		text-align: center;
		}
	</style>"}
	var/dat = ""
	var/item_count = 0
	for(var/i=1,i<=gland_colors.len,i++)
		item_count++
		var/g_color = gland_colors[i]
		var/amount = amounts[i]
		dat += "<a class='box gland' style='background-color:[g_color]' href='?src=\ref[src];dispense=[i]'>[amount]</a>"
		if(item_count == 3) // Three boxes per line
			dat +="</br></br>"
			item_count = 0
	var/datum/browser/popup = new(user, "glands", "Gland Dispenser", 200, 200)
	popup.add_head_content(box_css)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/abductor/gland_dispenser/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/gland))
		user.drop_item()
		W.loc = src
		for(var/i=1,i<=gland_colors.len,i++)
			if(gland_types[i] == W.type)
				amounts[i]++

/obj/machinery/abductor/gland_dispenser/Topic(href, href_list)
	if(..())
		return
	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
		if(href_list["dispense"])
			Dispense(text2num(href_list["dispense"]))
		src.updateUsrDialog()

/obj/machinery/abductor/gland_dispenser/proc/Dispense(var/count)
	if(amounts[count]>0)
		amounts[count]--
		var/T = gland_types[count]
		new T(get_turf(src))
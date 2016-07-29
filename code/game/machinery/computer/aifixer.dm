<<<<<<< HEAD
/obj/machinery/computer/aifixer
	name = "\improper AI system integrity restorer"
	desc = "Used with intelliCards containing nonfunctioning AIs to restore them to working order."
	req_access = list(access_captain, access_robotics, access_heads)
	var/mob/living/silicon/ai/occupier = null
	var/active = 0
	circuit = /obj/item/weapon/circuitboard/computer/aifixer
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"

/obj/machinery/computer/aifixer/attackby(obj/I, mob/user, params)
	if(occupier && istype(I, /obj/item/weapon/screwdriver))
		if(stat & (NOPOWER|BROKEN))
			user << "<span class='warning'>The screws on [name]'s screen won't budge.</span>"
		else
			user << "<span class='warning'>The screws on [name]'s screen won't budge and it emits a warning beep.</span>"
	else
		return ..()

/obj/machinery/computer/aifixer/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/aifixer/interact(mob/user)

	var/dat = ""

	if (src.occupier)
		var/laws
		dat += "<h3>Stored AI: [src.occupier.name]</h3>"
		dat += "<b>System integrity:</b> [(src.occupier.health+100)/2]%<br>"

		if (src.occupier.laws.zeroth)
			laws += "<b>0:</b> [src.occupier.laws.zeroth]<BR>"

		for (var/index = 1, index <= src.occupier.laws.ion.len, index++)
			var/law = src.occupier.laws.ion[index]
			if (length(law) > 0)
				var/num = ionnum()
				laws += "<b>[num]:</b> [law]<BR>"

		var/number = 1
		for (var/index = 1, index <= src.occupier.laws.inherent.len, index++)
			var/law = src.occupier.laws.inherent[index]
			if (length(law) > 0)
				laws += "<b>[number]:</b> [law]<BR>"
				number++

		for (var/index = 1, index <= src.occupier.laws.supplied.len, index++)
			var/law = src.occupier.laws.supplied[index]
			if (length(law) > 0)
				laws += "<b>[number]:</b> [law]<BR>"
				number++

		dat += "<b>Laws:</b><br>[laws]<br>"

		if (src.occupier.stat == 2)
			dat += "<span class='bad'>AI non-functional</span>"
		else
			dat += "<span class='good'>AI functional</span>"
		if (!src.active)
			dat += {"<br><br><A href='byond://?src=\ref[src];fix=1'>Begin Reconstruction</A>"}
		else
			dat += "<br><br>Reconstruction in process, please wait.<br>"
	dat += {"<br><A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	//user << browse(dat, "window=computer;size=400x500")
	//onclose(user, "computer")
	var/datum/browser/popup = new(user, "computer", "AI System Integrity Restorer", 400, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/aifixer/process()
	if(..())
		src.updateDialog()
		return

/obj/machinery/computer/aifixer/Topic(href, href_list)
	if(..())
		return
	if(href_list["fix"])
		active = 1
		while (occupier.health < 100)
			occupier.adjustOxyLoss(-1, 0)
			occupier.adjustFireLoss(-1, 0)
			occupier.adjustToxLoss(-1, 0)
			occupier.adjustBruteLoss(-1, 0)
			occupier.updatehealth()
			if(occupier.health >= 0 && occupier.stat == DEAD)
				occupier.revive()
			updateUsrDialog()
			update_icon()
			sleep(10)
		active = 0
		add_fingerprint(usr)
	updateUsrDialog()
	update_icon()


/obj/machinery/computer/aifixer/update_icon()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	else
		if(active)
			add_overlay("ai-fixer-on")
		if (occupier)
			switch (occupier.stat)
				if (0)
					add_overlay("ai-fixer-full")
				if (2)
					add_overlay("ai-fixer-404")
		else
			add_overlay("ai-fixer-empty")

/obj/machinery/computer/aifixer/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/device/aicard/card)
	if(!..())
		return
	//Downloading AI from card to terminal.
	if(interaction == AI_TRANS_FROM_CARD)
		if(stat & (NOPOWER|BROKEN))
			user << "[src] is offline and cannot take an AI at this time!"
			return
		AI.forceMove(src)
		occupier = AI
		AI.control_disabled = 1
		AI.radio_enabled = 0
		AI << "You have been uploaded to a stationary terminal. Sadly, there is no remote access from here."
		user << "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed."
		card.AI = null
		update_icon()

	else //Uploading AI from terminal to card
		if(occupier && !active)
			occupier << "You have been downloaded to a mobile storage device. Still no remote access."
			user << "<span class='boldnotice'>Transfer successful</span>: [occupier.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory."
			occupier.loc = card
			card.AI = occupier
			occupier = null
			update_icon()
		else if (active)
			user << "<span class='boldannounce'>ERROR</span>: Reconstruction in progress."
		else if (!occupier)
			user << "<span class='boldannounce'>ERROR</span>: Unable to locate artificial intelligence."
=======
/obj/machinery/computer/aifixer
	name = "AI System Integrity Restorer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "ai-fixer"
	req_access = list(access_captain, access_robotics, access_heads)
	var/mob/living/silicon/ai/occupant = null
	var/active = 0

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/aifixer/New()
	..()
	update_icon()

/obj/machinery/computer/aifixer/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/device/aicard))
		if(stat & (NOPOWER|BROKEN))
			to_chat(user, "This terminal isn't functioning right now, get it working!")
			return
		I:transfer_ai("AIFIXER","AICARD",src,user)
		return
	return ..()

/obj/machinery/computer/aifixer/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/aifixer/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/aifixer/attack_hand(var/mob/user as mob)
	if(..())
		return

	var/dat = "<h3>AI System Integrity Restorer</h3><br><br>"

	if (src.occupant)
		var/laws
		dat += "Stored AI: [src.occupant.name]<br>System integrity: [src.occupant.system_integrity()]%<br>"

		if (src.occupant.laws.zeroth)
			laws += "0: [src.occupant.laws.zeroth]<BR>"

		var/number = 1
		for (var/index = 1, index <= src.occupant.laws.inherent.len, index++)
			var/law = src.occupant.laws.inherent[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		for (var/index = 1, index <= src.occupant.laws.supplied.len, index++)
			var/law = src.occupant.laws.supplied[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		dat += "Laws:<br>[laws]<br>"

		if (src.occupant.stat == 2)
			dat += "<b>AI nonfunctional</b>"
		else
			dat += "<b>AI functional</b>"
		if (!src.active)
			dat += {"<br><br><A href='byond://?src=\ref[src];fix=1'>Begin Reconstruction</A>"}
		else
			dat += "<br><br>Reconstruction in process, please wait.<br>"
	dat += {" <A href='?src=\ref[user];mach_close=computer'>Close</A>"}


	user.set_machine(src)

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/aifixer/process()
	if(..())
		src.updateUsrDialog()
		return

/obj/machinery/computer/aifixer/Topic(href, href_list)
	if(..())
		return
	if (href_list["fix"])
		src.active = 1
		src.overlays += image('icons/obj/computer.dmi', "ai-fixer-on")
		while (src.occupant.health < 100)
			src.occupant.adjustOxyLoss(-1)
			src.occupant.adjustFireLoss(-1)
			src.occupant.adjustToxLoss(-1)
			src.occupant.adjustBruteLoss(-1)
			src.occupant.updatehealth()
			if (src.occupant.health >= 0 && src.occupant.stat == 2)
				src.occupant.stat = 0
				src.occupant.lying = 0
				src.occupant.resurrect()
				src.overlays -= image('icons/obj/computer.dmi', "ai-fixer-404")
				src.overlays += image('icons/obj/computer.dmi', "ai-fixer-full")
			src.updateUsrDialog()
			sleep(10)
		src.active = 0
		src.overlays -= image('icons/obj/computer.dmi', "ai-fixer-on")


		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/computer/aifixer/update_icon()
	..()
	overlays = 0
	// Broken / Unpowered
	if(stat & (BROKEN | NOPOWER))
		return

	if (occupant)
		switch (occupant.stat)
			if (0)
				overlays += image('icons/obj/computer.dmi', "ai-fixer-full")
			if (2)
				overlays += image('icons/obj/computer.dmi', "ai-fixer-404")
	else
		overlays += image('icons/obj/computer.dmi', "ai-fixer-empty")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

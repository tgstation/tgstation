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
	var/datum/browser/popup = new(user, "computer", "AI System Integrity Restorer", 400, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/aifixer/proc/Fix()
	use_power(1000)
	occupier.adjustOxyLoss(-1, 0)
	occupier.adjustFireLoss(-1, 0)
	occupier.adjustToxLoss(-1, 0)
	occupier.adjustBruteLoss(-1, 0)
	occupier.updatehealth()
	occupier.updatehealth()
	if(occupier.health >= 0 && occupier.stat == DEAD)
		occupier.revive()
	return occupier.health < 100

/obj/machinery/computer/aifixer/process()
	if(..())
		if(active)
			active = Fix()
		updateDialog()
		update_icon()

/obj/machinery/computer/aifixer/Topic(href, href_list)
	if(..())
		return
	if(href_list["fix"])
		usr << "<span class='notice'>Reconstruction in progress. This will take several minutes.</span>"
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 25, 0)
		active = TRUE
		add_fingerprint(usr)

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

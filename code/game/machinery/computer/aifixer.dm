/obj/machinery/computer/aifixer
	name = "AI System Integrity Restorer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "ai-fixer"
	req_access = list(access_captain, access_robotics, access_heads)
	var/mob/living/silicon/ai/occupant = null
	var/active = 0
	circuit = /obj/item/weapon/circuitboard/aifixer

/obj/machinery/computer/aifixer/New()
	src.overlays += image('icons/obj/computer.dmi', "ai-fixer-empty")
	..()


/obj/machinery/computer/aifixer/attackby(I as obj, user as mob)

	if(istype(I, /obj/item/device/aicard))
		var/obj/item/device/aicard/AIcard = I
		if(stat & (NOPOWER|BROKEN))
			user << "This terminal isn't functioning right now, get it working!"
			return
		AIcard.transfer_ai("AIFIXER","AICARD",src,user)
	else
		..()
	return

/obj/machinery/computer/aifixer/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.set_machine(src)
	var/dat = ""

	if (src.occupant)
		var/laws
		dat += "<h3>Stored AI: [src.occupant.name]</h3>"
		dat += "<b>System integrity:</b> [(src.occupant.health+100)/2]%<br>"

		if (src.occupant.laws.zeroth)
			laws += "<b>0:</b> [src.occupant.laws.zeroth]<BR>"

		var/number = 1
		for (var/index = 1, index <= src.occupant.laws.inherent.len, index++)
			var/law = src.occupant.laws.inherent[index]
			if (length(law) > 0)
				laws += "<b>[number]:</b> [law]<BR>"
				number++

		for (var/index = 1, index <= src.occupant.laws.supplied.len, index++)
			var/law = src.occupant.laws.supplied[index]
			if (length(law) > 0)
				laws += "<b>[number]:</b> [law]<BR>"
				number++

		dat += "<b>Laws:</b><br>[laws]<br>"

		if (src.occupant.stat == 2)
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
				dead_mob_list -= src.occupant
				living_mob_list += src.occupant
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
	// Broken / Unpowered
	if((stat & BROKEN) || (stat & NOPOWER))
		overlays.Cut()

	// Working / Powered
	else
		if (occupant)
			switch (occupant.stat)
				if (0)
					overlays += image('icons/obj/computer.dmi', "ai-fixer-full")
				if (2)
					overlays += image('icons/obj/computer.dmi', "ai-fixer-404")
		else
			overlays += image('icons/obj/computer.dmi', "ai-fixer-empty")

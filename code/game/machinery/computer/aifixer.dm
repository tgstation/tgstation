/obj/machinery/computer/aifixer
	name = "\improper AI system integrity restorer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "ai-fixer"
	req_access = list(access_captain, access_robotics, access_heads)
	var/mob/living/silicon/ai/occupier = null
	var/active = 0
	circuit = /obj/item/weapon/circuitboard/aifixer

/obj/machinery/computer/aifixer/New()
	src.overlays += image('icons/obj/computer.dmi', "ai-fixer-empty")
	..()


/obj/machinery/computer/aifixer/attackby(I as obj, user as mob)
	if(occupier && istype(I, /obj/item/weapon/screwdriver))
		if(stat & (NOPOWER|BROKEN))
			user << "<span class='warning'>The screws on [name]'s screen won't budge.</span>"
		else
			user << "<span class='warning'>The screws on [name]'s screen won't budge and it emits a warning beep.</span>"
		return

	if(istype(I, /obj/item/device/aicard))
		var/obj/item/device/aicard/AIcard = I
		if(stat & (NOPOWER|BROKEN))
			if(occupier)
				AIcard.transfer_ai("AIFIXER","AICARD",src,user)
				overlays.Cut()
				return
			user << "This terminal isn't functioning right now, get it working!"
			return
		AIcard.transfer_ai("AIFIXER","AICARD",src,user)
	else
		..()
	return

/obj/machinery/computer/aifixer/attack_hand(var/mob/user as mob)
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
	if (href_list["fix"])
		src.active = 1
		src.overlays += image('icons/obj/computer.dmi', "ai-fixer-on")
		while (src.occupier.health < 100)
			src.occupier.adjustOxyLoss(-1)
			src.occupier.adjustFireLoss(-1)
			src.occupier.adjustToxLoss(-1)
			src.occupier.adjustBruteLoss(-1)
			src.occupier.updatehealth()
			if (src.occupier.health >= 0 && src.occupier.stat == 2)
				src.occupier.stat = 0
				src.occupier.lying = 0
				dead_mob_list -= src.occupier
				living_mob_list += src.occupier
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
		if (occupier)
			switch (occupier.stat)
				if (0)
					overlays += image('icons/obj/computer.dmi', "ai-fixer-full")
				if (2)
					overlays += image('icons/obj/computer.dmi', "ai-fixer-404")
		else
			overlays += image('icons/obj/computer.dmi', "ai-fixer-empty")

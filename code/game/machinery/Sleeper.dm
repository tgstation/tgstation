/obj/machinery/sleep_console
	name = "sleeper console"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "console"
	anchored = 1	//About time someone fixed this.
	density = 1
	var/obj/machinery/sleeper/connected = null


/obj/machinery/sleep_console/New()
	try_connect()

/obj/machinery/sleep_console/initialize()
	try_connect()


/obj/machinery/sleep_console/proc/try_connect()
	connected = locate(/obj/machinery/sleeper, get_step(src, dir))
	return connected


/obj/machinery/sleep_console/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/sleep_console/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/sleep_console/attack_hand(mob/user)
	if(..())
		return
	if(connected)
		var/mob/living/occupant = connected.occupant
		var/dat = "<h3>Sleeper Status</h3>"

		dat += "<div class='statusDisplay'>"
		if(!occupant)
			dat += "Sleeper Unoccupied"
		else
			dat += "[occupant.name] => "
			switch(occupant.stat)	//obvious, see what their status is
				if(0)
					dat += "<span class='good'>Conscious</span>"
				if(1)
					dat += "<span class='average'>Unconscious</span>"
				else
					dat += "<span class='bad'>DEAD</span>"

			dat += "<br />"

			dat +=  "<div class='line'><div class='statusLabel'>Health:</div><div class='progressBar'><div style='width: [occupant.health]%;' class='progressFill good'></div></div><div class='statusValue'>[occupant.health]%</div></div>"
			dat +=  "<div class='line'><div class='statusLabel'>\> Brute Damage:</div><div class='progressBar'><div style='width: [occupant.getBruteLoss()]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.getBruteLoss()]%</div></div>"
			dat +=  "<div class='line'><div class='statusLabel'>\> Resp. Damage:</div><div class='progressBar'><div style='width: [occupant.getOxyLoss()]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.getOxyLoss()]%</div></div>"
			dat +=  "<div class='line'><div class='statusLabel'>\> Toxin Content:</div><div class='progressBar'><div style='width: [occupant.getToxLoss()]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.getToxLoss()]%</div></div>"
			dat +=  "<div class='line'><div class='statusLabel'>\> Burn Severity:</div><div class='progressBar'><div style='width: [occupant.getFireLoss()]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.getFireLoss()]%</div></div>"

			dat += "<HR><div class='line'><div class='statusLabel'>Paralysis Summary:</div><div class='statusValue'>[round(occupant.paralysis)]% [occupant.paralysis ? "([round(occupant.paralysis / 4)] seconds left)" : ""]</div></div>"
			if(occupant.reagents)
				//Left the text()s for readability.
				dat += text("<div class='line'><div class='statusLabel'>Inaprovaline:</div><div class='statusValue'>[] units</div></div>", round(occupant.reagents.get_reagent_amount("inaprovaline"), 0.1))
				dat += text("<div class='line'><div class='statusLabel'>Sleep Toxin:</div><div class='statusValue'>[] units</div></div>", round(occupant.reagents.get_reagent_amount("stoxin"), 0.1))
				dat += text("<div class='line'><div class='statusLabel'>Dermaline:</div><div class='statusValue'>[] units</div></div>", round(occupant.reagents.get_reagent_amount("dermaline"), 0.1))
				dat += text("<div class='line'><div class='statusLabel'>Bicaridine:</div><div class='statusValue'>[] units</div></div>", round(occupant.reagents.get_reagent_amount("bicaridine"), 0.1))
				dat += text("<div class='line'><div class='statusLabel'>Dexalin:</div><div class='statusValue'>[] units</div></div>", round(occupant.reagents.get_reagent_amount("dexalin"), 0.1))
		dat += "</div>"

		dat += "<A href='?src=\ref[src];refresh=1'>Scan</A>"

		dat += "<A href='?src=\ref[src];eject=1'>Eject occupant</A>"

		dat += "<h3>Injector</h3>"
		if(occupant)
			dat += "<A href='?src=\ref[src];inap=1'>Inject Inaprovaline</A>"
		else
			dat += "<span class='linkOff'>Inject Inaprovaline</span>"
		if(occupant && occupant.health > 0)
			dat += {"<BR><A href='?src=\ref[src];stox=1'>Inject Sleep Toxin</A>
					<BR><A href='?src=\ref[src];derm=1'>Inject Dermaline</A>
					<BR><A href='?src=\ref[src];bic=1'>Inject Bicaridine</A>
					<BR><A href='?src=\ref[src];dex=1'>Inject Dexalin</A>"}
		else
			dat += {"<BR><span class='linkOff'>Inject Sleep Toxin</span>
					<BR><span class='linkOff'>Inject Dermaline</span>
					<BR><span class='linkOff'>Inject Bicaridine</span>
					<BR><span class='linkOff'>Inject Dexalin</span>"}

		var/datum/browser/popup = new(user, "sleeper", "Sleeper Console", 520, 540)	//Set up the popup browser window
		popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
		popup.set_content(dat)
		popup.open()


/obj/machinery/sleep_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	if(connected && connected.occupant)
		if(href_list["eject"])
			connected.eject()
			updateUsrDialog()
			return
		else if(connected.occupant.health > 0)
			if(href_list["inap"])
				connected.inject_inap(usr)
			if(href_list["stox"])
				connected.inject_stox(usr)
			if(href_list["derm"])
				connected.inject_dermaline(usr)
			if(href_list["bic"])
				connected.inject_bicaridine(usr)
			if(href_list["dex"])
				connected.inject_dexalin(usr)
		else
			if(connected.occupant.health > -100)
				if(href_list["inap"])
					connected.inject_inap(usr)
				if(href_list["stox"] || href_list["derm"] || href_list["bic"] || href_list["dex"])
					usr << "<span class='notice'>ERROR: Subject is not in stable condition for auto-injection.</span>"
			else
				usr << "<span class='notice'>ERROR: Subject cannot metabolise chemicals.</span>"
	if(href_list["refresh"])
		updateUsrDialog()
	add_fingerprint(usr)


/obj/machinery/sleep_console/process()
	if(stat & (NOPOWER|BROKEN))
		return
	updateUsrDialog()


/obj/machinery/sleep_console/power_change()
	return
	//no change - sleeper works without power (you just can't inject more)



/obj/machinery/sleeper
	name = "sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper-open"
	density = 1
	anchored = 1
	var/mob/living/occupant = null


/obj/machinery/sleeper/allow_drop()
	return 0


/obj/machinery/sleeper/process()
	updateDialog()


/obj/machinery/sleeper/blob_act()
	if(prob(75))
		for(var/atom/movable/A in src)
			A.loc = loc
			A.blob_act()
		del(src)


/obj/machinery/sleeper/attackby(obj/item/I, mob/user)
	if(!istype(I, /obj/item/weapon/grab))
		return
	var/obj/item/weapon/grab/G = I

	if(!ismob(G.affecting))
		return

	if(occupant)
		user << "<span class='notice'>[src] is already occupied.</span>"
		return

	for(var/mob/living/carbon/slime/M in range(1, G.affecting))
		if(M.Victim == G.affecting)
			user << "[G.affecting] will not fit into [src] because they have [M] latched onto their head."
			return

	visible_message("<span class='notice'>[user] starts putting [G.affecting] into the sleeper.</span>")

	if(do_after(user, 20))
		if(occupant)
			user << "<span class='notice'>[src] is already occupied!</span>"
			return
		if(!G || !G.affecting) return
		var/mob/M = G.affecting
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		occupant = M
		icon_state = "sleeper"

		M << "\blue <b>You feel cool air surround you. You go numb as your senses turn inward.</b>"

		for(var/obj/O in src)
			O.loc = loc
		add_fingerprint(user)
		del(G)


/obj/machinery/sleeper/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A in src)
				A.loc = loc
				ex_act(severity)
			del(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A in src)
					A.loc = loc
					ex_act(severity)
				del(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A in src)
					A.loc = loc
					ex_act(severity)
				del(src)


/obj/machinery/sleeper/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..(severity)


/obj/machinery/sleeper/alter_health(mob/living/M)
	if(M.health > 0)
		if(M.getOxyLoss() >= 10)
			var/amount = max(0.15, 1)
			M.adjustOxyLoss(-amount)
		else
			M.adjustOxyLoss(-12)
		M.updatehealth()
	M.AdjustParalysis(-4)
	M.AdjustWeakened(-4)
	M.AdjustStunned(-4)
	M.Paralyse(1)
	M.Weaken(1)
	M.Stun(1)
	if(M.reagents.get_reagent_amount("inaprovaline") < 5)
		M.reagents.add_reagent("inaprovaline", 5)


/obj/machinery/sleeper/proc/go_out()
	if(!occupant)
		return
	for(var/atom/movable/O in src)
		O.loc = loc
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant = null
	icon_state = "sleeper-open"


/obj/machinery/sleeper/proc/inject_inap(mob/user)
	if(occupant && occupant.reagents)
		if(occupant.reagents.get_reagent_amount("inaprovaline") + 30 < 61)
			occupant.reagents.add_reagent("inaprovaline", 30)
		var/units = round(occupant.reagents.get_reagent_amount("inaprovaline"))
		user << "<span class='notice'>Occupant now has [units] unit\s of inaprovaline in their bloodstream.</span>"


/obj/machinery/sleeper/proc/inject_stox(mob/user)
	if(occupant && occupant.reagents)
		if(occupant.reagents.get_reagent_amount("stoxin") + 20 < 41)
			occupant.reagents.add_reagent("stoxin", 20)
		var/units = round(occupant.reagents.get_reagent_amount("stoxin"))
		user << "<span class='notice'>Occupant now has [units] unit\s of sleep toxins in their bloodstream.</span>"


/obj/machinery/sleeper/proc/inject_dermaline(mob/user)
	if(occupant && occupant.reagents)
		if(occupant.reagents.get_reagent_amount("dermaline") + 20 < 41)
			occupant.reagents.add_reagent("dermaline", 20)
		var/units = round(occupant.reagents.get_reagent_amount("dermaline"))
		user << "<span class='notice'>Occupant now has [units] unit\s of dermaline in their bloodstream.</span>"


/obj/machinery/sleeper/proc/inject_bicaridine(mob/user)
	if(occupant && occupant.reagents)
		if(occupant.reagents.get_reagent_amount("bicaridine") + 10 < 21)
			occupant.reagents.add_reagent("bicaridine", 10)
		var/units = round(occupant.reagents.get_reagent_amount("bicaridine"))
		user << "<span class='notice'>Occupant now has [units] unit\s of bicaridine in their bloodstream.</span>"


/obj/machinery/sleeper/proc/inject_dexalin(mob/user)
	if(occupant && occupant.reagents)
		if(occupant.reagents.get_reagent_amount("dexalin") + 20 < 41)
			occupant.reagents.add_reagent("dexalin", 20)
		var/units = round(occupant.reagents.get_reagent_amount("dexalin"))
		user << "<span class='notice'>Occupant now has [units] unit\s of dexalin in their bloodstream.</span>"

/obj/machinery/sleeper/container_resist()
	eject()

/obj/machinery/sleeper/proc/eject()
	go_out()
	add_fingerprint(usr)


/obj/machinery/sleeper/verb/move_inside()
	set name = "Enter sleeper"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || (!ishuman(usr) && !ismonkey(usr)))
		return

	if(occupant)
		usr << "<span class='notice'>[src] is already occupied.</span>"
		return

	for(var/mob/living/carbon/slime/M in range(1, usr))
		if(M.Victim == usr)
			usr << "<span class='notice'>You're too busy getting your life sucked out of you.</span>"
			return

	visible_message("<span class='notice'>[usr] starts climbing into the sleeper.</span>")
	if(do_after(usr, 20))
		if(occupant)
			usr << "<span class='notice'>The sleeper is already occupied!</span>"
			return

		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.loc = src
		occupant = usr
		icon_state = "sleeper"

		for(var/obj/O in src)
			del(O)
		add_fingerprint(usr)

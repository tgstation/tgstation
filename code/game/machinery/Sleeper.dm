/////////////////////////////////////////
// SLEEPER CONSOLE
/////////////////////////////////////////

/obj/machinery/sleep_console
	name = "Sleeper Console"
	icon = 'Cryogenic2.dmi'
	icon_state = "sleeperconsole"
	var/obj/machinery/sleeper/connected = null
	anchored = 1 //About time someone fixed this.
	density = 1
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"


/obj/machinery/sleep_console/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		else
	return

/obj/machinery/sleep_console/New()
	..()
	spawn( 5 )
		if(orient == "RIGHT")
			icon_state = "sleeperconsole-r"
			src.connected = locate(/obj/machinery/sleeper, get_step(src, EAST))
		else
			src.connected = locate(/obj/machinery/sleeper, get_step(src, WEST))

		return
	return

/obj/machinery/sleep_console/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/sleep_console/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/sleep_console/attack_hand(mob/user as mob)
	if(..())
		return
	if (src.connected)
		var/mob/occupant = src.connected.occupant
		var/dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>"
		if (occupant)
			var/t1
			switch(occupant.stat)
				if(0)
					t1 = "Conscious"
				if(1)
					t1 = "<font color='blue'>Unconscious</font>"
				if(2)
					t1 = "<font color='red'>*dead*</font>"
				else
			dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
			dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getBruteLoss())
			dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getOxyLoss())
			dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getToxLoss())
			dat += text("[]\t-Burn Severity %: []</FONT><BR>", (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getFireLoss())
			dat += text("<HR>Paralysis Summary %: [] ([] seconds left!)<BR>", occupant.paralysis, round(occupant.paralysis / 4))
			dat += text("Inaprovaline units: [] units<BR>", occupant.reagents.get_reagent_amount("inaprovaline"))
			dat += text("Soporific (Sleep Toxin): [] units<BR>", occupant.reagents.get_reagent_amount("stoxin"))
			dat += text("[]\tDermaline: [] units</FONT><BR>", (occupant.reagents.get_reagent_amount("dermaline") < 30 ? "<font color='black'>" : "<font color='red'>"), occupant.reagents.get_reagent_amount("dermaline"))
			dat += text("[]\tBicaridine: [] units<BR>", (occupant.reagents.get_reagent_amount("bicaridine") < 30 ? "<font color='black'>" : "<font color='red'>"), occupant.reagents.get_reagent_amount("bicaridine"))
			dat += text("[]\tDexalin: [] units<BR>", (occupant.reagents.get_reagent_amount("dexalin") < 30 ? "<font color='black'>" : "<font color='red'>"), occupant.reagents.get_reagent_amount("dexalin"))
			dat += text("<HR><A href='?src=\ref[];refresh=1'>Refresh meter readings each second</A><BR><A href='?src=\ref[];inap=1'>Inject Inaprovaline</A><BR><A href='?src=\ref[];stox=1'>Inject Soporific</A><BR><A href='?src=\ref[];derm=1'>Inject Dermaline</A><BR><A href='?src=\ref[];bic=1'>Inject Bicaridine</A><BR><A href='?src=\ref[];dex=1'>Inject Dexalin</A>", src, src, src, src, src, src)
		else
			dat += "The sleeper is empty."
		dat += text("<BR><BR><A href='?src=\ref[];mach_close=sleeper'>Close</A>", user)
		user << browse(dat, "window=sleeper;size=400x500")
		onclose(user, "sleeper")
	return

/obj/machinery/sleep_console/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.machine = src
		if (src.connected)
			if (src.connected.occupant)
				if(src.connected.occupant.health > 0)
					if (href_list["inap"])
						src.connected.inject_inap(usr)
					if (href_list["stox"])
						src.connected.inject_stox(usr)
					if (href_list["derm"])
						src.connected.inject_dermaline(usr)
					if (href_list["bic"])
						src.connected.inject_bicaridine(usr)
					if (href_list["dex"])
						src.connected.inject_dexalin(usr)
				else
					if(src.connected.occupant.health > -100)
						if (href_list["inap"])
							src.connected.inject_inap(usr)
						if (href_list["stox"] || href_list["derm"] || href_list["bic"] || href_list["dex"])
							usr << "\red \b this person is not in good enough condition for sleepers to be effective! Use another means of treatment, such as cryogenics!"
					else
						usr << "\red \b This person has no life for to preserve anymore. Take them to a department capable of reanimating them."
		if (href_list["refresh"])
			src.updateUsrDialog()
		src.add_fingerprint(usr)
	return

/obj/machinery/sleep_console/process()
	if(stat & (NOPOWER|BROKEN))
		return
	src.updateUsrDialog()
	return

/obj/machinery/sleep_console/power_change()
	return
	// no change - sleeper works without power (you just can't inject more)







/////////////////////////////////////////
// THE SLEEPER ITSELF
/////////////////////////////////////////

/obj/machinery/sleeper
	name = "Sleeper"
	icon = 'Cryogenic2.dmi'
	icon_state = "sleeper_0"
	density = 1
	anchored = 1
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"
	var/mob/occupant = null


	New()
		..()
		spawn( 5 )
			if(orient == "RIGHT")
				if(!istype(src,/obj/machinery/sleeper/syndicate))
					icon_state = "sleeper_0-r"
				else
					icon_state = "syndipod_0-r"
			return
		return


	allow_drop()
		return 0


	process()
		src.updateDialog()
		return


	blob_act()
		if(prob(75))
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				A.blob_act()
			del(src)
		return


	attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
		if((!( istype(G, /obj/item/weapon/grab)) || !( ismob(G.affecting))))
			return
		if(src.occupant)
			user << "\blue <B>The [src.name] is already occupied!</B>"
			return

		for(var/mob/living/carbon/metroid/M in range(1,G.affecting))
			if(M.Victim == G.affecting)
				usr << "[G.affecting.name] will not fit into the [src.name] because they have a Metroid latched onto their head."
				return

		for (var/mob/V in viewers(user))
			V.show_message("[user] starts putting [G.affecting.name] into the [src.name].", 3)

		if(do_after(user, 20))
			if(src.occupant)
				user << "\blue <B>The [src.name] is already occupied!</B>"
				return
			if(!G || !G.affecting) return
			var/mob/M = G.affecting
			if(M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.loc = src
			src.occupant = M
			if(!istype(src,/obj/machinery/sleeper/syndicate))
				src.icon_state = "sleeper_1"
				if(orient == "RIGHT")
					icon_state = "sleeper_1-r"
			else
				src.icon_state = "syndipod_1"
				if(orient == "RIGHT")
					icon_state = "syndipod_1-r"

			M << "\blue <b>You feel cool air surround you. You go numb as your senses turn inward.</b>"

			for(var/obj/O in src)
				O.loc = src.loc
			src.add_fingerprint(user)
			del(G)
			return
		return


	ex_act(severity)
		switch(severity)
			if(1.0)
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
			if(2.0)
				if(prob(50))
					for(var/atom/movable/A as mob|obj in src)
						A.loc = src.loc
						ex_act(severity)
					del(src)
					return
			if(3.0)
				if(prob(25))
					for(var/atom/movable/A as mob|obj in src)
						A.loc = src.loc
						ex_act(severity)
					del(src)
					return
		return


	alter_health(mob/living/M as mob)
		if (M.health > 0)
			if (M.getOxyLoss() >= 10)
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
		if (M:reagents.get_reagent_amount("inaprovaline") < 5)
			M:reagents.add_reagent("inaprovaline", 5)
		return


	proc/go_out()
		if(!src.occupant)
			return
		for(var/obj/O in src)
			O.loc = src.loc
		if(src.occupant.client)
			src.occupant.client.eye = src.occupant.client.mob
			src.occupant.client.perspective = MOB_PERSPECTIVE
		src.occupant.loc = src.loc
		src.occupant = null
		if(orient == "RIGHT")
			if(!istype(src,/obj/machinery/sleeper/syndicate))
				icon_state = "sleeper_0-r"
			else
				icon_state = "syndipod_0-r"
		return


	proc/inject_inap(mob/user as mob)
		if(src.occupant)
			if(src.occupant.reagents.get_reagent_amount("inaprovaline") + 30 <= 60)
				src.occupant.reagents.add_reagent("inaprovaline", 30)
			user << text("Occupant now has [] units of Inaprovaline in his/her bloodstream.", src.occupant.reagents.get_reagent_amount("inaprovaline"))
		else
			user << "No occupant!"
		return


	proc/inject_stox(mob/user as mob)
		if(src.occupant)
			if(src.occupant.reagents.get_reagent_amount("stoxin") + 10 <= 40)
				src.occupant.reagents.add_reagent("stoxin", 10)
			user << text("Occupant now has [] units of soporifics in his/her bloodstream.", src.occupant.reagents.get_reagent_amount("stoxin"))
		else
			user << "No occupant!"
		return


	proc/inject_dermaline(mob/user as mob)
		if (src.occupant)
			if(src.occupant.reagents.get_reagent_amount("dermaline") + 10 <= 40)
				src.occupant.reagents.add_reagent("dermaline", 10)
			user << text("Occupant now has [] units of Dermaline in his/her bloodstream.", src.occupant.reagents.get_reagent_amount("dermaline"))
		else
			user << "No occupant!"
		return


	proc/inject_bicaridine(mob/user as mob)
		if(src.occupant)
			if(src.occupant.reagents.get_reagent_amount("bicaridine") + 10 <= 40)
				src.occupant.reagents.add_reagent("bicaridine", 10)
			user << text("Occupant now has [] units of Bicaridine in his/her bloodstream.", src.occupant.reagents.get_reagent_amount("bicaridine"))
		else
			user << "No occupant!"
		return


	proc/inject_dexalin(mob/user as mob)
		if(src.occupant)
			if(src.occupant.reagents.get_reagent_amount("dexalin") + 10 <= 40)
				src.occupant.reagents.add_reagent("dexalin", 10)
			user << text("Occupant now has [] units of Dexalin in his/her bloodstream.", src.occupant.reagents.get_reagent_amount("dexalin"))
		else
			user << "No occupant!"
		return


	proc/check(mob/user as mob)
		if(src.occupant)
			user << text("\blue <B>Occupant ([]) Statistics:</B>", src.occupant)
			var/t1
			switch(src.occupant.stat)
				if(0.0)
					t1 = "Conscious"
				if(1.0)
					t1 = "Unconscious"
				if(2.0)
					t1 = "*dead*"
				else
			user << text("[]\t Health %: [] ([])", (src.occupant.health > 50 ? "\blue " : "\red "), src.occupant.health, t1)
			user << text("[]\t -Core Temperature: []&deg;C ([]&deg;F)</FONT><BR>", (src.occupant.bodytemperature > 50 ? "<font color='blue'>" : "<font color='red'>"), src.occupant.bodytemperature-T0C, src.occupant.bodytemperature*1.8-459.67)
			user << text("[]\t -Brute Damage %: []", (src.occupant.getBruteLoss() < 60 ? "\blue " : "\red "), src.occupant.getBruteLoss())
			user << text("[]\t -Respiratory Damage %: []", (src.occupant.getOxyLoss() < 60 ? "\blue " : "\red "), src.occupant.getOxyLoss())
			user << text("[]\t -Toxin Content %: []", (src.occupant.getToxLoss() < 60 ? "\blue " : "\red "), src.occupant.getToxLoss())
			user << text("[]\t -Burn Severity %: []", (src.occupant.getFireLoss() < 60 ? "\blue " : "\red "), src.occupant.getFireLoss())
			user << "\blue Expected time till occupant can safely awake: (note: If health is below 20% these times are inaccurate)"
			user << text("\blue \t [] second\s (if around 1 or 2 the sleeper is keeping them asleep.)", src.occupant.paralysis / 5)
		else
			user << "\blue There is no one inside!"
		return


	verb/eject()
		set name = "Eject Sleeper"
		set category = "Object"
		set src in oview(1)
		if(usr.stat != 0)
			return
		if(!istype(src,/obj/machinery/sleeper/syndicate))
			if(orient == "RIGHT")
				icon_state = "sleeper_0-r"
			src.icon_state = "sleeper_0"
		else
			if(orient == "RIGHT")
				icon_state = "syndipod_0-r"
			src.icon_state = "syndipod_0"
		src.go_out()
		add_fingerprint(usr)
		return


	verb/move_inside()
		set name = "Enter Sleeper"
		set category = "Object"
		set src in oview(1)

		if(usr.stat != 0)
			return
		if(istype(src,/obj/machinery/sleeper/syndicate))
			usr << "\red You really want to get into an illegal stasis pod? Are you dumb?"
			return
		if(src.occupant)
			usr << "\blue <B>The [src.name] is already occupied!</B>"
			return

		for(var/mob/living/carbon/metroid/M in range(1,usr))
			if(M.Victim == usr)
				usr << "You're too busy getting your life sucked out of you."
				return
		for(var/mob/V in viewers(usr))
			V.show_message("[usr] starts climbing into the [src.name].", 3)
		if(do_after(usr, 20))
			if(src.occupant)
				usr << "\blue <B>The [src.name] is already occupied!</B>"
				return
			usr.pulling = null
			usr.client.perspective = EYE_PERSPECTIVE
			usr.client.eye = src
			usr.loc = src
			src.occupant = usr
			if(!istype(src,/obj/machinery/sleeper/syndicate))
				src.icon_state = "sleeper_1"
				if(orient == "RIGHT")
					icon_state = "sleeper_1-r"
			else
				src.icon_state = "syndipod_1"
				if(orient == "RIGHT")
					icon_state = "syndipod_1-r"

			for(var/obj/O in src)
				del(O)
			src.add_fingerprint(usr)
			return
		return



/obj/machinery/sleeper/syndicate
	name = "Illegal Stasis Pod"
	icon = 'Cryogenic2.dmi'
	icon_state = "syndi_0"
	density = 1
	anchored = 1

	process()
		if(src.occupant)
			src.occupant.sleeping = 5
		return


/////////////////////////////////////////
// SLEEPER CONSOLE
/////////////////////////////////////////

/obj/machinery/sleep_console
	name = "Sleeper Console"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeperconsole"
	var/obj/machinery/sleeper/connected = null
	anchored = 1 //About time someone fixed this.
	density = 1
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"

/obj/machinery/sleep_console/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				qdel(src)
				return
		else
	return

/obj/machinery/sleep_console/New()
	..()
	spawn( 5 )
		update_icon()
		if(orient == "RIGHT")
			src.connected = locate(/obj/machinery/sleeper, get_step(src, EAST))
		else
			src.connected = locate(/obj/machinery/sleeper, get_step(src, WEST))
	return

/obj/machinery/sleep_console/update_icon()
	if((stat & BROKEN)||(!powered()))
		if(orient == "LEFT")
			icon_state = "sleeperconsole-p"
		else
			icon_state = "sleeperconsole-p-r"
	else
		if(orient == "LEFT")
			icon_state = "sleeperconsole"
		else
			icon_state = "sleeperconsole-r"

/obj/machinery/sleep_console/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/sleep_console/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/sleep_console/attack_hand(mob/user as mob)
	if(..())
		return
	if (src.connected)
		var/mob/living/occupant = src.connected.occupant
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
			if(iscarbon(occupant))
				var/mob/living/carbon/C = occupant
				dat += text("[]\t-Pulse, bpm: []</FONT><BR>", (C.pulse == PULSE_NONE || C.pulse == PULSE_THREADY ? "<font color='red'>" : "<font color='blue'>"), C.get_pulse(GETPULSE_TOOL))
			dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getBruteLoss())
			dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getOxyLoss())
			dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getToxLoss())
			dat += text("[]\t-Burn Severity %: []</FONT><BR>", (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getFireLoss())
			dat += text("<HR>Paralysis Summary %: [] ([] seconds left!)<BR>", occupant.paralysis, round(occupant.paralysis / 4))
			if(occupant.reagents)
				for(var/chemical in connected.available_chemicals)
					dat += "[connected.available_chemicals[chemical]]: [occupant.reagents.get_reagent_amount(chemical)] units<br>"
			dat += "<HR><A href='?src=\ref[src];refresh=1'>Refresh meter readings each second</A><BR>"
			for(var/chemical in connected.available_chemicals)
				dat += "Inject [connected.available_chemicals[chemical]]: "
				for(var/amount in connected.amounts)
					dat += "<a href ='?src=\ref[src];chemical=[chemical];amount=[amount]'>[amount] units</a> "
				dat += "<br>"
		else
			dat += "The sleeper is empty."
		dat += text("<BR><BR><A href='?src=\ref[];mach_close=sleeper'>Close</A>", user)
		user << browse(dat, "window=sleeper;size=400x500")
		onclose(user, "sleeper")
	return

/obj/machinery/sleep_console/Topic(href, href_list)
	if(..())
		return 1
	else
		usr.set_machine(src)
		if (href_list["chemical"])
			if (src.connected)
				if (src.connected.occupant)
					if (src.connected.occupant.stat == DEAD)
						usr << "<span class='danger'>This person has no life for to preserve anymore. Take them to a department capable of reanimating them.</span>"
					else if(src.connected.occupant.health > 0 || href_list["chemical"] == "inaprovaline")
						src.connected.inject_chemical(usr,href_list["chemical"],text2num(href_list["amount"]))
					else
						usr << "<span class='danger'>This person is not in good enough condition for sleepers to be effective! Use another means of treatment, such as cryogenics!</span>"
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
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper_0"
	density = 1
	anchored = 1
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"
	var/mob/living/occupant = null
	var/available_chemicals = list("inaprovaline" = "Inaprovaline", "stoxin" = "Soporific", "dermaline" = "Dermaline", "bicaridine" = "Bicaridine", "dexalin" = "Dexalin")
	var/amounts = list(5, 10)
	var/obj/machinery/sleep_console/connected = null
	machine_flags = SCREWTOGGLE | CROWDESTROY
	component_parts = newlist(
		/obj/item/weapon/circuitboard/sleeper,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator
	)
	l_color = "#7BF9FF"
	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)) && occupant)
			SetLuminosity(2)
		else
			SetLuminosity(0)

/obj/machinery/sleeper/New()
	..()
	RefreshParts()
	spawn( 5 )
		update_icon()
		if(orient == "RIGHT")
			generate_console(get_step(get_turf(src), WEST))
		else
			generate_console(get_step(get_turf(src), EAST))
		return
	return

/obj/machinery/sleeper/Destroy()
	..()
	qdel(connected)

/obj/machinery/sleeper/update_icon()
	if(occupant)
		if(orient == "LEFT")
			icon_state = "sleeper_1"
		else
			icon_state = "sleeper_1-r"
	else
		if(orient == "LEFT")
			icon_state = "sleeper_0"
		else
			icon_state = "sleeper_0-r"

/obj/machinery/sleeper/proc/generate_console(turf/T as turf)
	if(connected)
		qdel(connected)
	if(!T.density)
		connected = new /obj/machinery/sleep_console(T)
		connected.orient = src.orient
		connected.update_icon()
		return 1
	else
		return 0

/obj/machinery/sleeper/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		T += SP.rating

	if(T >= 6 && T<9)
		available_chemicals = list("inaprovaline" = "Inaprovaline", "stoxin" = "Soporific", "dermaline" = "Dermaline", "bicaridine" = "Bicaridine", "dexalin" = "Dexalin", "phalanximine" = "Phalanximine")
	else if(T < 6)
		available_chemicals = list("inaprovaline" = "Inaprovaline", "stoxin" = "Soporific", "dermaline" = "Dermaline", "bicaridine" = "Bicaridine", "dexalin" = "Dexalin")
	else
		available_chemicals = list("inaprovaline" = "Inaprovaline", "stoxin" = "Soporific", "dermaline" = "Dermaline", "bicaridine" = "Bicaridine", "dexalin" = "Dexalin", "phalanximine" = "Phalanximine", "spaceacillin" = "Spaceacillin")


/obj/machinery/sleeper/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(!ismob(O)) //mobs only
		return
	if(O.loc == user || !isturf(O.loc) || !isturf(user.loc)) //no you can't pull things out of your ass
		return
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.resting) //are you cuffed, dying, lying, stunned or other
		return
	if(O.anchored || !Adjacent(user) || !user.Adjacent(src) || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robutts dont fit
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(occupant)
		user << "<span class='notice'>\The [src] is already occupied!</span>"
		return
	if(isrobot(user))
		if(!istype(user:module, /obj/item/weapon/robot_module/medical))
			user << "<span class='warning'>You do not have the means to do this!</span>"
			return
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic())
		user << "<span class='notice'><B>Subject cannot have abiotic items on.</B></span>"
		return
	for(var/mob/living/carbon/slime/M in range(1,L))
		if(M.Victim == L)
			usr << "[L.name] will not fit into the sleeper because they have a slime latched onto their head."
			return
	if(L == user)
		visible_message("[user] starts climbing into the sleeper.", 3)
	else
		visible_message("[user] starts putting [L.name] into the sleeper.", 3)

	if(do_after(user, 20))
		if(src.occupant)
			user << "<span class='notice'><B>The sleeper is already occupied!</B></span>"
			return
		if(!L || L.buckled) return

		if(L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src
		L.loc = src
		src.occupant = L
		update_icon()
		L << "<span class='notice'><b>You feel cool air surround you. You go numb as your senses turn inward.</b></span>"
		for(var/obj/OO in src)
			OO.loc = src.loc
		src.add_fingerprint(user)
		if(user.pulling == L)
			user.stop_pulling()
		return
	return

/obj/machinery/sleeper/allow_drop()
	return 0


/obj/machinery/sleeper/process()
	src.updateDialog()
	return


/obj/machinery/sleeper/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
			A.blob_act()
		del(src)
	return


/obj/machinery/sleeper/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iscrowbar(W) && occupant)
		return ..()
	if(iswrench(W)&&!occupant)
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		if(orient == "RIGHT")
			orient = "LEFT"
			if(generate_console(get_step(get_turf(src), EAST)))
				update_icon()
			else
				orient = "RIGHT"
				visible_message("<span class='warning'>There is no space!</span>","<span class='warning'>[user] wants to be hardcore, but his CMO won't let him.</span>")
		else
			orient = "RIGHT"
			if(generate_console(get_step(get_turf(src), WEST)))
				update_icon()
			else
				orient = "LEFT"
				visible_message("<span class='warning'>There is no space!</span>","<span class='warning'>[user] wants to be hardcore, but his CMO won't let him.</span>")
		return
	if(!istype(W, /obj/item/weapon/grab))
		return ..()
	var/obj/item/weapon/grab/G = W
	if(!(ismob(G.affecting)) || G.affecting.buckled) return
	if(src.occupant)
		user << "<span class='notice'><B>The sleeper is already occupied!</B></span>"
		return

	for(var/mob/living/carbon/slime/M in range(1,G.affecting))
		if(M.Victim == G.affecting)
			usr << "[G.affecting.name] will not fit into the sleeper because they have a slime latched onto their head."
			return

	visible_message("[user] starts putting [G.affecting.name] into the sleeper.", 3)

	if(do_after(user, 20))
		if(src.occupant)
			user << "<span class='notice'><B>The sleeper is already occupied!</B></span>"
			return
		if(!G || !G.affecting) return
		var/mob/M = G.affecting
		if(!isliving(M) || M.buckled)
			return
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		src.occupant = M
		update_icon()

		M << "<span class='notice'><b>You feel cool air surround you. You go numb as your senses turn inward.</b></span>"

		for(var/obj/O in src)
			O.loc = src.loc
		src.add_fingerprint(user)
		del(G)
		return
	return


/obj/machinery/sleeper/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
	return
/obj/machinery/sleeper/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..(severity)

/obj/machinery/sleeper/alter_health(mob/living/M as mob)
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


/obj/machinery/sleeper/proc/go_out()
	if(!src.occupant)
		return
	for(var/obj/O in src)
		O.loc = src.loc
	if(src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	update_icon()
	return


/obj/machinery/sleeper/proc/inject_chemical(mob/living/user as mob, chemical, amount)
	if(src.occupant && src.occupant.reagents)
		if(src.occupant.reagents.get_reagent_amount(chemical) + amount <= 20)
			src.occupant.reagents.add_reagent(chemical, amount)
			user << "Occupant now has [src.occupant.reagents.get_reagent_amount(chemical)] units of [available_chemicals[chemical]] in his/her bloodstream."
			return
	user << "There's no occupant in the sleeper or the subject has too many chemicals!"
	return

/obj/machinery/sleeper/proc/check(mob/living/user as mob)
	if(src.occupant)
		user << text("<span class='notice'><B>Occupant ([]) Statistics:</B></span>", src.occupant)
		var/t1
		switch(src.occupant.stat)
			if(0.0)
				t1 = "Conscious"
			if(1.0)
				t1 = "Unconscious"
			if(2.0)
				t1 = "*dead*"
			else
		user << text("[]\t Health %: [] ([])</span>", (src.occupant.health > 50 ? "<span class='notice'>" : "<span class='warning'> "), src.occupant.health, t1)
		user << text("[]\t -Core Temperature: []&deg;C ([]&deg;F)</FONT><BR></span>", (src.occupant.bodytemperature > 50 ? "<font color='blue'>" : "<font color='red'>"), src.occupant.bodytemperature-T0C, src.occupant.bodytemperature*1.8-459.67)
		user << text("[]\t -Brute Damage %: []</span>", (src.occupant.getBruteLoss() < 60 ? "<span class='notice'>" : "<span class='warning'> "), src.occupant.getBruteLoss())
		user << text("[]\t -Respiratory Damage %: []</span>", (src.occupant.getOxyLoss() < 60 ? "<span class='notice'>" : "<span class='warning'> "), src.occupant.getOxyLoss())
		user << text("[]\t -Toxin Content %: []</span>", (src.occupant.getToxLoss() < 60 ? "<span class='notice'>" : "<span class='warning'> "), src.occupant.getToxLoss())
		user << text("[]\t -Burn Severity %: []</span>", (src.occupant.getFireLoss() < 60 ? "<span class='notice'>" : "<span class='warning'> "), src.occupant.getFireLoss())
		user << "<span class='notice'>Expected time till occupant can safely awake: (note: If health is below 20% these times are inaccurate)</span>"
		user << text("<span class='notice'>\t [] second\s (if around 1 or 2 the sleeper is keeping them asleep.)</span>", src.occupant.paralysis / 5)
	else
		user << "<span class='notice'>There is no one inside!</span>"
	return


/obj/machinery/sleeper/verb/eject()
	set name = "Eject Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0 || (usr.status_flags & FAKEDEATH))
		return
	src.go_out()
	add_fingerprint(usr)
	return


/obj/machinery/sleeper/verb/move_inside()
	set name = "Enter Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0 || !(ishuman(usr) || ismonkey(usr)) || (usr.status_flags & FAKEDEATH))
		return

	if(src.occupant)
		usr << "<span class='notice'><B>The sleeper is already occupied!</B></span>"
		return
	if(usr.restrained() || usr.stat || usr.weakened || usr.stunned || usr.paralysis || usr.resting || (usr.status_flags & FAKEDEATH)) //are you cuffed, dying, lying, stunned or other
		return
	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			usr << "You're too busy getting your life sucked out of you."
			return
	if(usr.buckled)
		return
	visible_message("[usr] starts climbing into the sleeper.", 3)
	if(do_after(usr, 20))
		if(src.occupant)
			usr << "<span class='notice'><B>The sleeper is already occupied!</B></span>"
			return
		if(usr.buckled)
			return
		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.loc = src
		src.occupant = usr
		update_icon()

		for(var/obj/O in src)
			del(O)
		src.add_fingerprint(usr)
		return
	return
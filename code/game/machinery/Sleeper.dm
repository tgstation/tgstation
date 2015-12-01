#define SLEEPER_SOPORIFIC_DELAY 30

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
	icon_state = "sleeperconsole[stat & NOPOWER ? "-p" : null][orient == "LEFT" ? null : "-r"]"

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
						to_chat(usr, "<span class='danger'>This person has no life for to preserve anymore. Take them to a department capable of reanimating them.</span>")
					else if(href_list["chemical"] == "stoxin" && src.connected.sedativeblock)
						if(src.connected.sedativeblock < 3)
							to_chat(usr, "<span class='warning'>Sedative injections not yet ready. Please try again in a few seconds.</span>")
						else //if this guy is seriously just mashing the soporific button...
							to_chat(usr, "[pick( \
							"<span class='warning'>This guy just got jammed into the machine, give them a breath before trying to pump them full of drugs.</span>", \
							"<span class='warning'>Give it a rest.</span>", \
							"<span class='warning'>Aren't you going to tuck them in before putting them to sleep?</span>", \
							"<span class='warning'>Slow down just a second, they aren't going anywhere... right?</span>", \
							"<span class='warning'>Just got to make sure you're not tripping the fuck out of an innocent bystander, stay tight.</span>", \
							"<span class='warning'>The occupant is still moving around!</span>", \
							"<span class='warning'>Sorry pal, safety procedures.</span>", \
							"<span class='warning'>But it's not bedtime yet!</span>")]")
						src.connected.sedativeblock++
					else if(src.connected.occupant.health < 0 && href_list["chemical"] != "inaprovaline")
						to_chat(usr, "<span class='danger'>This person is not in good enough condition for sleepers to be effective! Use another means of treatment, such as cryogenics!</span>")
					else
						src.connected.inject_chemical(usr,href_list["chemical"],text2num(href_list["amount"]))
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
	var/sedativeblock = 0 //To prevent people from being surprisesoporific'd
	machine_flags = SCREWTOGGLE | CROWDESTROY
	component_parts = newlist(
		/obj/item/weapon/circuitboard/sleeper,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator
	)
	light_color = LIGHT_COLOR_CYAN
	light_range_on = 3
	light_power_on = 2
	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)) && occupant)
			set_light(light_range_on, light_power_on)
		else
			set_light(0)

/obj/machinery/sleeper/New()
	..()
	RefreshParts()
	spawn( 5 )
		var/turf/t
		world.log << "DEBUG: Beginning sleeper console checking/auto-generation for sleeper [src] at [src.loc.x],[src.loc.y],[src.loc.z]..."
		if(orient == "RIGHT")
			update_icon() // Only needs to update if it's orientation isn't default
			t = get_step(get_turf(src), WEST)
			// generate_console(get_step(get_turf(src), WEST))
		else
			t = get_step(get_turf(src), EAST)
			// generate_console(get_step(get_turf(src), EAST))
		ASSERT(t)
		var/obj/machinery/sleep_console/c = locate() in t.contents
		if(c)
			connected = c
			c.connected = src
		else
			world.log << "DEBUG: generating console at [t.loc.x],[t.loc.y],[t.loc.z] for sleeper at [src.loc.x],[src.loc.y],[src.loc.z]"
			generate_console(t)
		return
	return

/obj/machinery/sleeper/Destroy()

	go_out() //Eject everything

	. = ..()

	if(connected)
		connected.connected = null
		qdel(connected)
		connected = null

/obj/machinery/sleeper/update_icon()
	icon_state = "sleeper_[occupant ? "1" : "0"][orient == "LEFT" ? null : "-r"]"

/obj/machinery/sleeper/proc/generate_console(turf/T as turf)
	if(connected)
		connected.orient = src.orient
		connected.update_icon()
		return 1
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
	switch(T)
		if(0 to 5)
			available_chemicals = list("inaprovaline" = "Inaprovaline", "stoxin" = "Soporific", "dermaline" = "Dermaline", "bicaridine" = "Bicaridine", "dexalin" = "Dexalin")
		if(6 to 8)
			available_chemicals = list("inaprovaline" = "Inaprovaline", "stoxin" = "Soporific", "dermaline" = "Dermaline", "bicaridine" = "Bicaridine", "dexalin" = "Dexalin", "phalanximine" = "Phalanximine")
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
		to_chat(user, "<span class='notice'>\The [src] is already occupied!</span>")
		return
	if(isrobot(user))
		var/mob/living/silicon/robot/robit = usr
		if(istype(robit) && !istype(robit.module, /obj/item/weapon/robot_module/medical))
			to_chat(user, "<span class='warning'>You do not have the means to do this!</span>")
			return
	var/mob/living/L = O
	if(!istype(L) || L.locked_to)
		return
	if(L.abiotic())
		to_chat(user, "<span class='notice'><B>Subject cannot have abiotic items on.</B></span>")
		return
	for(var/mob/living/carbon/slime/M in range(1,L))
		if(M.Victim == L)
			to_chat(usr, "[L.name] will not fit into the sleeper because they have a slime latched onto their head.")
			return

	if(L == user)
		visible_message("[user] climbs into \the [src].", 3)
	else
		visible_message("[user] places [L.name] into \the [src].", 3)

	L.forceMove(src)
	L.reset_view()
	src.occupant = L
	update_icon()
	to_chat(L, "<span class='notice'><b>You feel cool air surround you. You go numb as your senses turn inward.</b></span>")
	for(var/obj/OO in src)
		OO.loc = src.loc
	src.add_fingerprint(user)
	if(user.pulling == L)
		user.stop_pulling()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(light_range_on, light_power_on)
	sedativeblock = 1
	sleep(SLEEPER_SOPORIFIC_DELAY)
	sedativeblock = 0
	return


/obj/machinery/sleeper/MouseDrop(over_object, src_location, var/turf/over_location, src_control, over_control, params)
	if(!ishuman(usr) && !isrobot(usr))
		return
	if(!occupant)
		to_chat(usr, "<span class='warning'>The sleeper is unoccupied!</span>")
		return
	if(isrobot(usr))
		var/mob/living/silicon/robot/robit = usr
		if(istype(robit) && !istype(robit.module, /obj/item/weapon/robot_module/medical))
			to_chat(usr, "<span class='warning'>You do not have the means to do this!</span>")
			return
	if(!istype(over_location) || over_location.density)
		return
	if(!Adjacent(over_location))
		return
	if(!(occupant == usr) && (!Adjacent(usr) || !usr.Adjacent(over_location)))
		return
	for(var/atom/movable/A in over_location.contents)
		if(A.density)
			if((A == src) || istype(A, /mob))
				continue
			return
	if(occupant == usr)
		visible_message("[usr] climbs out of \the [src].", 3)
	else
		visible_message("[usr] removes [occupant.name] from \the [src].", 3)
	go_out(over_location)

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
		qdel(src)
	return

/obj/machinery/sleeper/crowbarDestroy(mob/user)
	if(occupant)
		to_chat(user, "<span class='warning'>You cannot disassemble \the [src], it's occupado.</span>")
		return
	return ..()

/obj/machinery/sleeper/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswrench(W)&&!occupant)
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		if(orient == "RIGHT")
			orient = "LEFT"
			if(generate_console(get_step(get_turf(src), EAST)))
				update_icon()
			else
				orient = "RIGHT"
				to_chat(user, "<span class='warning'>There is no space!</span>")
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
	if(!(ismob(G.affecting)) || G.affecting.locked_to) return
	if(src.occupant)
		to_chat(user, "<span class='notice'><B>The sleeper is already occupied!</B></span>")
		return

	for(var/mob/living/carbon/slime/M in range(1,G.affecting))
		if(M.Victim == G.affecting)
			to_chat(usr, "[G.affecting.name] will not fit into the sleeper because they have a slime latched onto their head.")
			return

	visible_message("[user] places [G.affecting.name] into the sleeper.", 3)

	var/mob/M = G.affecting
	if(!isliving(M) || M.locked_to)
		return
	M.forceMove(src)
	M.reset_view()
	src.occupant = M
	update_icon()

	to_chat(M, "<span class='notice'><b>You feel cool air surround you. You go numb as your senses turn inward.</b></span>")

	for(var/obj/O in src)
		O.loc = src.loc
	src.add_fingerprint(user)
	qdel(G)
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(light_range_on, light_power_on)
	sedativeblock = 1
	spawn(SLEEPER_SOPORIFIC_DELAY)
	sedativeblock = 0
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


/obj/machinery/sleeper/proc/go_out(var/exit = src.loc)
	if(!occupant)
		return 0
	for(var/obj/O in src)
		O.loc = src.loc
	occupant.forceMove(exit)
	occupant.reset_view()
	occupant = null
	update_icon()
	return 1


/obj/machinery/sleeper/proc/inject_chemical(mob/living/user as mob, chemical, amount)
	if(!src.occupant)
		to_chat(user, "<span class='warning'>There's no occupant in the sleeper!</span>")
		return
	if(isnull(src.occupant.reagents))
		to_chat(user, "<span class='warning'>The occupant appears to somehow lack a bloodstream. Please consult a shrink.</span>")
		return
	if(src.occupant.reagents.get_reagent_amount(chemical) + amount > 20)
		to_chat(user, "<span class='warning'>Overdose Prevention System: The occupant already has enough [available_chemicals[chemical]] in their system.</span>")
		return
	src.occupant.reagents.add_reagent(chemical, amount)
	to_chat(user, "<span class='notice'>Occupant now has [src.occupant.reagents.get_reagent_amount(chemical)] units of [available_chemicals[chemical]] in their bloodstream.</span>")
	return

/obj/machinery/sleeper/proc/check(mob/living/user as mob)
	if(src.occupant)
		to_chat(user, text("<span class='notice'><B>Occupant ([]) Statistics:</B></span>", src.occupant))
		var/t1
		switch(src.occupant.stat)
			if(0.0)
				t1 = "Conscious"
			if(1.0)
				t1 = "Unconscious"
			if(2.0)
				t1 = "*dead*"
			else
		to_chat(user, text("[]\t Health %: [] ([])</span>", (src.occupant.health > 50 ? "<span class='notice'>" : "<span class='warning'> "), src.occupant.health, t1))
		to_chat(user, text("[]\t -Core Temperature: []&deg;C ([]&deg;F)</FONT><BR></span>", (src.occupant.bodytemperature > 50 ? "<font color='blue'>" : "<font color='red'>"), src.occupant.bodytemperature-T0C, src.occupant.bodytemperature*1.8-459.67))
		to_chat(user, text("[]\t -Brute Damage %: []</span>", (src.occupant.getBruteLoss() < 60 ? "<span class='notice'>" : "<span class='warning'> "), src.occupant.getBruteLoss()))
		to_chat(user, text("[]\t -Respiratory Damage %: []</span>", (src.occupant.getOxyLoss() < 60 ? "<span class='notice'>" : "<span class='warning'> "), src.occupant.getOxyLoss()))
		to_chat(user, text("[]\t -Toxin Content %: []</span>", (src.occupant.getToxLoss() < 60 ? "<span class='notice'>" : "<span class='warning'> "), src.occupant.getToxLoss()))
		to_chat(user, text("[]\t -Burn Severity %: []</span>", (src.occupant.getFireLoss() < 60 ? "<span class='notice'>" : "<span class='warning'> "), src.occupant.getFireLoss()))
		to_chat(user, "<span class='notice'>Expected time till occupant can safely awake: (note: If health is below 20% these times are inaccurate)</span>")
		to_chat(user, text("<span class='notice'>\t [] second\s (if around 1 or 2 the sleeper is keeping them asleep.)</span>", src.occupant.paralysis / 5))
	else
		to_chat(user, "<span class='notice'>There is no one inside!</span>")
	return


/obj/machinery/sleeper/verb/eject()
	set name = "Eject Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0 || (usr.status_flags & FAKEDEATH))
		return
	src.go_out()
	add_fingerprint(usr)
	set_light(0)
	return


/obj/machinery/sleeper/verb/move_inside()
	set name = "Enter Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0 || !(ishuman(usr) || ismonkey(usr)) || (usr.status_flags & FAKEDEATH))
		return

	if(src.occupant)
		to_chat(usr, "<span class='notice'><B>The sleeper is already occupied!</B></span>")
		return
	if(usr.restrained() || usr.stat || usr.weakened || usr.stunned || usr.paralysis || usr.resting || (usr.status_flags & FAKEDEATH)) //are you cuffed, dying, lying, stunned or other
		return
	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			to_chat(usr, "You're too busy getting your life sucked out of you.")
			return
	if(usr.locked_to)
		return
	visible_message("[usr] starts climbing into the sleeper.", 3)
	if(do_after(usr, src, 20))
		if(src.occupant)
			to_chat(usr, "<span class='notice'><B>The sleeper is already occupied!</B></span>")
			return
		if(usr.locked_to)
			return
		usr.stop_pulling()
		usr.loc = src
		usr.reset_view()
		src.occupant = usr
		update_icon()

		for(var/obj/O in src)
			qdel(O)
		src.add_fingerprint(usr)
		if(!(stat & (BROKEN|NOPOWER)))
			set_light(light_range_on, light_power_on)
		return
	return

#undef SLEEPER_SOPORIFIC_DELAY

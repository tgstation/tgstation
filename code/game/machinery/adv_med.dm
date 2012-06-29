// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/bodyscanner
	var/mob/living/carbon/occupant
	var/locked
	name = "Body Scanner"
	icon = 'Cryogenic2.dmi'
	icon_state = "body_scanner_0"
	density = 1
	anchored = 1

/*/obj/machinery/bodyscanner/allow_drop()
	return 0*/

/obj/machinery/bodyscanner/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Body Scanner"

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Body Scanner"

	if (usr.stat != 0)
		return
	if (src.occupant)
		usr << "\blue <B>The scanner is already occupied!</B>"
		return
	if (usr.abiotic())
		usr << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	usr.pulling = null
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.loc = src
	src.occupant = usr
	src.icon_state = "body_scanner_1"
	for(var/obj/O in src)
		//O = null
		del(O)
		//Foreach goto(124)
	src.add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/proc/go_out()
	if ((!( src.occupant ) || src.locked))
		return
	for(var/obj/O in src)
		O.loc = src.loc
		//Foreach goto(30)
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	src.icon_state = "body_scanner_0"
	return

/obj/machinery/bodyscanner/attackby(obj/item/weapon/grab/G as obj, user as mob)
	if ((!( istype(G, /obj/item/weapon/grab) ) || !( ismob(G.affecting) )))
		return
	if (src.occupant)
		user << "\blue <B>The scanner is already occupied!</B>"
		return
	if (G.affecting.abiotic())
		user << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	var/mob/M = G.affecting
	if (M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.loc = src
	src.occupant = M
	src.icon_state = "body_scanner_1"
	for(var/obj/O in src)
		O.loc = src.loc
		//Foreach goto(154)
	src.add_fingerprint(user)
	//G = null
	del(G)
	return

/obj/machinery/bodyscanner/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
				//Foreach goto(35)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(108)
				//SN src = null
				del(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(181)
				//SN src = null
				del(src)
				return
		else
	return

/obj/machinery/bodyscanner/blob_act()
	if(prob(50))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/machinery/body_scanconsole/ex_act(severity)

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

/obj/machinery/body_scanconsole/blob_act()

	if(prob(50))
		del(src)

/obj/machinery/body_scanconsole/power_change()
	if(stat & BROKEN)
		icon_state = "body_scannerconsole-p"
	else if(powered())
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			src.icon_state = "body_scannerconsole-p"
			stat |= NOPOWER

/obj/machinery/body_scanconsole
	var/obj/machinery/bodyscanner/connected
	var/delete
	var/temphtml
	name = "Body Scanner Console"
	icon = 'Cryogenic2.dmi'
	icon_state = "body_scannerconsole"
	density = 1
	anchored = 1


/obj/machinery/body_scanconsole/New()
	..()
	spawn( 5 )
		src.connected = locate(/obj/machinery/bodyscanner, get_step(src, WEST))
		return
	return

/obj/machinery/body_scanconsole/process() //not really used right now
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(250) // power stuff

//	var/mob/M //occupant
//	if (!( src.status )) //remove this
//		return
//	if ((src.connected && src.connected.occupant)) //connected & occupant ok
//		M = src.connected.occupant
//	else
//		if (istype(M, /mob))
//		//do stuff
//		else
///			src.temphtml = "Process terminated due to lack of occupant in scanning chamber."
//			src.status = null
//	src.updateDialog()
//	return


/obj/machinery/body_scanconsole/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/body_scanconsole/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/body_scanconsole/attack_hand(user as mob)
	if(..())
		return
	if(!ishuman(connected.occupant))
		user << "\red This device can only scan compatible lifeforms."
		return
	var/dat
	if (src.delete && src.temphtml) //Window in buffer but its just simple message, so nothing
		src.delete = src.delete
	else if (!src.delete && src.temphtml) //Window in buffer - its a menu, dont add clear message
		dat = text("[]<BR><BR><A href='?src=\ref[];clear=1'>Main Menu</A>", src.temphtml, src)
	else
		if (src.connected) //Is something connected?
			var/mob/living/carbon/human/occupant = src.connected.occupant
			dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>" //Blah obvious
			if (istype(occupant)) //is there REALLY someone in there?
				var/t1
				switch(occupant.stat) // obvious, see what their status is
					if(0)
						t1 = "Conscious"
					if(1)
						t1 = "Unconscious"
					else
						t1 = "*dead*"
				if (!istype(occupant,/mob/living/carbon/human))
					dat += "<font color='red'>This device can only scan human occupants.</FONT>"
				else
					dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)

					dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getBruteLoss())
					dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getOxyLoss())
					dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getToxLoss())
					dat += text("[]\t-Burn Severity %: []</FONT><BR><BR>", (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getFireLoss())

					dat += text("[]\tRadiation Level %: []</FONT><BR>", (occupant.radiation < 10 ?"<font color='blue'>" : "<font color='red'>"), occupant.radiation)
					dat += text("[]\tGenetic Tissue Damage %: []</FONT><BR>", (occupant.getCloneLoss() < 1 ?"<font color='blue'>" : "<font color='red'>"), occupant.getCloneLoss())
					dat += text("[]\tApprox. Brain Damage %: []</FONT><BR>", (occupant.getBrainLoss() < 1 ?"<font color='blue'>" : "<font color='red'>"), occupant.getBrainLoss())
					dat += text("Paralysis Summary %: [] ([] seconds left!)<BR>", occupant.paralysis, round(occupant.paralysis / 4))
					dat += text("Body Temperature: [occupant.bodytemperature-T0C]&deg;C ([occupant.bodytemperature*1.8-459.67]&deg;F)<BR><HR>")

					if(occupant.vessel)
						var/blood_volume = round(occupant.vessel.get_reagent_amount("blood"))
						var/blood_percent =  blood_volume / 560
						blood_percent *= 100
						dat += text("[]\tBlood Level %: [] ([blood_volume] units)</FONT><BR>", (blood_volume > 448 ?"<font color='blue'>" : "<font color='red'>"), blood_volume)
					if(occupant.reagents)
						dat += text("Inaprovaline units: [] units<BR>", occupant.reagents.get_reagent_amount("inaprovaline"))
						dat += text("Soporific (Sleep Toxin): [] units<BR>", occupant.reagents.get_reagent_amount("stoxin"))
						dat += text("[]\tDermaline: [] units</FONT><BR>", (occupant.reagents.get_reagent_amount("dermaline") < 30 ? "<font color='black'>" : "<font color='red'>"), occupant.reagents.get_reagent_amount("dermaline"))
						dat += text("[]\tBicaridine: [] units<BR>", (occupant.reagents.get_reagent_amount("bicaridine") < 30 ? "<font color='black'>" : "<font color='red'>"), occupant.reagents.get_reagent_amount("bicaridine"))
						dat += text("[]\tDexalin: [] units<BR>", (occupant.reagents.get_reagent_amount("dexalin") < 30 ? "<font color='black'>" : "<font color='red'>"), occupant.reagents.get_reagent_amount("dexalin"))

					for(var/datum/disease/D in occupant.viruses)
						if(!D.hidden[SCANNER])
							dat += text("<font color='red'><B>Warning: [D.form] Detected</B>\nName: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]</FONT><BR>")

					if (occupant.virus2 || occupant.reagents.reagent_list.len > 0)
						dat += text("<font color='red'>Warning: Foreign substances detected in bloodstream.</FONT>")

					dat += "<HR><table border='1'>"
					dat += "<tr>"
					dat += "<th>Organ</th>"
					dat += "<th>Burn Damage</th>"
					dat += "<th>Brute Damage</th>"
					dat += "<th>Other Wounds</th>"
					dat += "</tr>"

					for(var/name in occupant.organs)
						var/datum/organ/external/e = occupant.organs[name]
						dat += "<tr>"
						var/AN = ""
						var/open = ""
						var/infected = ""
						var/imp = ""
						var/bled = ""
						var/splint = ""
						if(e.status & SPLINTED)
							splint = "Splinted:"
						if(e.status & BLEEDING)
							bled = "Bleeding:"
						if(e.status & BROKEN)
							AN = "[e.broken_description]:"
						if(e.open)
							open = "Open:"
						if(e.implant && e.implant.len)
							imp = "Implanted:"
						if(!AN && !open && !infected & !imp)
							AN = "None"
						if(!(e.status & DESTROYED))
							dat += "<td>[e.display_name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[bled][AN][splint][open][infected][imp]</td>"
						else
							dat += "<td>[e.display_name]</td><td>-</td><td>-</td><td>Not Found</td>"
						dat += "</tr>"
					dat += "</table>"
			else
				dat += "\The [src] is empty."
		else
			dat = "<font color='red'> Error: No Body Scanner connected.</font>"
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=scanconsole'>Close</A>", user)
	user << browse(dat, "window=scanconsole;size=430x600")
	return
// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/heps
	name = "High Energy Particle Scatterer"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "heps_0"
	density = 1

	anchored = 1
	idle_power_usage = 125
	active_power_usage = 600

	var/mob/living/carbon/occupant
	var/locked

/obj/machinery/heps/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.resting) //are you cuffed, dying, lying, stunned or other
		return
	if(O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ismob(O)) //humans only
		return
	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robutts dont fit
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(occupant)
		user << "\blue <B>The H.E.P.S. is already occupied!</B>"
		return
	if(isrobot(user))
		if(!istype(user:module, /obj/item/weapon/robot_module/medical))
			user << "<span class='warning'>You do not have the means to do this!</span>"
			return
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic())
		user << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	for(var/mob/living/carbon/slime/M in range(1,L))
		if(M.Victim == L)
			usr << "[L.name] will not fit into the H.E.P.S. because they have a slime latched onto their head."
			return
	if(L == user)
		visible_message("[user] climbs into the H.E.P.S.", 3)
	else
		visible_message("[user] puts [L.name] into the H.E.P.S.", 3)

	if (L.client)
		L.client.perspective = EYE_PERSPECTIVE
		L.client.eye = src
	L.loc = src
	src.occupant = L
	src.icon_state = "heps_1"
	for(var/obj/OO in src)
		OO.loc = src.loc
		//Foreach goto(154)
	src.add_fingerprint(user)
	return

/*/obj/machinery/heps/allow_drop()
	return 0*/

/obj/machinery/heps/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/heps/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject H.E.P.S."

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/heps/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter H.E.P.S."

	if (usr.stat != 0)
		return
	if (src.occupant)
		usr << "\blue <B>The H.E.P.S. is already occupied!</B>"
		return
	if (usr.abiotic())
		usr << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	usr.pulling = null
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.loc = src
	src.occupant = usr
	src.icon_state = "heps_1"
	for(var/obj/O in src)
		//O = null
		del(O)
		//Foreach goto(124)
	src.add_fingerprint(usr)
	return

/obj/machinery/heps/proc/go_out()
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
	src.icon_state = "heps_0"
	return

/obj/machinery/heps/attackby(obj/item/weapon/grab/G as obj, user as mob)
	if ((!( istype(G, /obj/item/weapon/grab) ) || !( ismob(G.affecting) )))
		return
	if (src.occupant)
		user << "\blue <B>The H.E.P.S. is already occupied!</B>"
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
	src.icon_state = "heps_1"
	for(var/obj/O in src)
		O.loc = src.loc
		//Foreach goto(154)
	src.add_fingerprint(user)
	//G = null
	del(G)
	return

/obj/machinery/heps/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
				//Foreach goto(35)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(108)
				//SN src = null
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(181)
				//SN src = null
				qdel(src)
				return
		else
	return

/obj/machinery/heps/blob_act()
	if(prob(50))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/machinery/heps_scanconsole/ex_act(severity)

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

/obj/machinery/heps_scanconsole/blob_act()

	if(prob(50))
		del(src)

/obj/machinery/heps_scanconsole/power_change()
	if(stat & BROKEN)
		icon_state = "hepsconsole-p"
	else if(powered())
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			src.icon_state = "hepsconsole-p"
			stat |= NOPOWER

/obj/machinery/heps_scanconsole
	var/obj/machinery/heps/connecteda
	var/deletea
	var/temphtmla
	name = "H.E.P.S. Console"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "hepsconsole"
	density = 1
	anchored = 1
	var/last_used


/obj/machinery/heps_scanconsole/New()
	..()
	spawn( 5 )
		src.connecteda = locate(/obj/machinery/heps, get_step(src, EAST))
		return
	return

/obj/machinery/heps_scanconsole/process()
	if (stat & (BROKEN | NOPOWER | MAINT | EMPED))
		use_power = 0
		return

	if (connecteda && connecteda.occupant)
		use_power = 2
	else
		use_power = 1

/*
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(250) // power stuff

	var/mob/M //occupant
	if (!( src.status )) //remove this
		return
	if ((src.connecteda && src.connecteda.occupant)) //connecteda & occupant ok
		M = src.connecteda.occupant
	else
		if (istype(M, /mob))
		//do stuff
		else
			src.temphtmla = "Process terminated due to lack of occupant in scanning chamber."
			src.status = null
	src.updateDialog()
	return
*/





/obj/machinery/heps_scanconsole/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/heps_scanconsole/attack_ai(user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/heps_scanconsole/attack_hand(user as mob)
	if(..())
		return
	if(!ishuman(connecteda.occupant))
		user << "\red This device can only scan compatible lifeforms."
		return
	var/dat
	if (src.deletea && src.temphtmla) //Window in buffer but its just simple message, so nothing
		src.deletea = src.deletea
	else if (!src.deletea && src.temphtmla) //Window in buffer - its a menu, dont add clear message
		dat = text("[]<BR><BR><A href='?src=\ref[]; clear=1'>Main Menu</A>", src.temphtmla, src)
	else
		if (src.connecteda) //Is something connecteda?
			var/mob/living/carbon/human/occupant = src.connecteda.occupant

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

					dat += text("Body Temperature: [occupant.bodytemperature-T0C]&deg;C ([occupant.bodytemperature*1.8-459.67]&deg;F)<BR><HR>")

					if(occupant.vessel)
						var/blood_volume = round(occupant.vessel.get_reagent_amount("blood"))
						var/blood_percent =  blood_volume / 560
						blood_percent *= 100
						dat += text("[]\tBlood Level %: [] ([] units)</FONT><BR>", (blood_volume > 448 ?"<font color='blue'>" : "<font color='red'>"), blood_percent, blood_volume)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\adv_med.dm:269: dat += "<HR><table border='1'>"
					dat += {"<HR><table border='1'>
						<tr>
						<th>Organ</th>
						<th>Abnormalities</th>
						</tr>"}
					// END AUTOFIX
					for(var/datum/organ/external/e in occupant.organs)
						dat += "<tr>"
						var/AN = ""
						var/imp = ""

						if(e.implants.len)
							imp = "Unknown body present: <A href='?src=\ref[src];target=[e.name];'>Activate</A>"
							dat += "<td>[e.display_name]</td><td>[imp]</td>"
						if(!e.implants.len)
							AN = "None: <A href='?src=\ref[src];target=[e.name];'>Activate</A>"
							dat += "<td>[e.display_name]</td><td>[AN]</td>"

						if(!e)
							dat += "<td>[e.display_name]</td><td>Not Found</td>"
						dat += "</tr>"
					dat += "<tr></tr>"


				//	for(var/organ_name in occupant.internal_organs)
				//		var/datum/organ/internal/i = occupant.internal_organs[organ_name]

						// AUTOFIXED BY fix_string_idiocy.py
						// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\adv_med.dm:311: dat += "<tr>"

						//dat += {"<tr>
						//	<td>[i.name]</td><td>None</td>
						//	</tr>"}


						// END AUTOFIX
						//////////////////////////////////////////retained for expansion
			else
				dat += "\The [src] is empty."
		else
			dat = "<font color='red'> Error: No H.E.P.S. connected.</font>"
	user << browse(dat, "window=scanconsole;size=430x600")
	return

/obj/machinery/heps_scanconsole/Topic(href, href_list)
	if(..()) return
	if(usr) usr.set_machine(src)
	if (href_list["target"])
		var/time_now = world.timeofday
		if((last_used+30) >= time_now)
			usr << "<span class ='warning'>The charging light flashes in annoyance!</span>"
			return
		else
			last_used = world.timeofday
		var/mob/living/carbon/human/dudeinside = connecteda.occupant
		var/hepsaim = href_list["target"]
		var/obj/item/weapon/implant/objh = null
		var/datum/organ/external/affected = dudeinside.get_organ(hepsaim)
		if(affected.implants.len)
			objh = affected.implants[1]
		playsound(get_turf(src), "sound/machines/heps.ogg", 100, 1)
		affected.take_damage(burn = 5, used_weapon = "tachyon beam")
		dudeinside << "<span class ='warning'>The tachyon stream burns your [affected.display_name]!</span>"
		src.use_power(1000)
		var/rads = 3

		if(istype(objh,/obj/item/weapon/implant/cancer))
			if(prob(70))
				affected.implants -= objh
				dudeinside.contents -= objh
		else if(istype(objh,/obj/item/weapon/implant))
			rads += 3
		for(var/mob/living/carbon/O in viewers(src, null))
			if(O != dudeinside)
				O << "<span class ='warning'>You feel a mild stinging sensation as the tachyon beam activates.</span>"
				O.apply_effect(rads,IRRADIATE,0)
				if(rads > 3)
					O << "<span class ='warning'>The tachyon refraction alarm goes off!</span>"
	src.updateUsrDialog()
	return

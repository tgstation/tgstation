


/obj/machinery/detector
	name = "Mr. V.A.L.I.D. Portable Threat Detector"
	desc = "This state of the art unit allows NT security personnel to contain a situation or secure an area better and faster."
	icon = 'icons/obj/detector.dmi'
	icon_state = "detector1"
	var/id_tag = null
	var/range = 3
	var/disable = 0
	var/last_read = 0
	var/base_state = "detector"
	anchored = 0
	ghost_read=0
	ghost_write=0
	density = 1
	var/idmode = 0
	var/scanmode = 0
	var/senset = 0

	req_access = list(access_security)

	flags = FPRINT | PROXMOVE
	machine_flags = WRENCHMOVE | FIXED2WORK

	//List of weapons that metaldetector will not flash for, also copypasted in secbot.dm and ed209bot.dm
	var/safe_weapons = list(
		/obj/item/weapon/gun/energy/laser/bluetag,
		/obj/item/weapon/gun/energy/laser/redtag,
		/obj/item/weapon/gun/energy/laser/practice,
		/obj/item/weapon/gun/hookshot,
		/obj/item/weapon/gun/energy/floragun,
		/obj/item/weapon/melee/defibrillator
		)

//THIS CODE IS COPYPASTED IN ed209bot.dm AND secbot.dm, with slight variations
/obj/machinery/detector/proc/assess_perp(mob/living/carbon/human/perp as mob)
	var/threatcount = 0 //If threat >= 4 at the end, they get arrested
	if(!(istype(perp, /mob/living/carbon)) || isalien(perp) || isbrain(perp))
		return -1

	if(!src.allowed(perp)) //cops can do no wrong, unless set to arrest

		if(!wpermit(perp))
			if(istype(perp.l_hand, /obj/item/weapon/gun) || istype(perp.l_hand, /obj/item/weapon/melee))
				if(!(perp.l_hand.type in safe_weapons))
					threatcount += 4

			if(istype(perp.r_hand, /obj/item/weapon/gun) || istype(perp.r_hand, /obj/item/weapon/melee))
				if(!(perp.r_hand.type in safe_weapons))
					threatcount += 4

			if(istype(perp.back, /obj/item/weapon/gun) || istype(perp.back, /obj/item/weapon/melee))
				if(!(perp.back.type in safe_weapons))
					threatcount += 2

			if(ishuman(perp))
				if(istype(perp.belt, /obj/item/weapon/gun) || istype(perp.belt, /obj/item/weapon/melee))
					if(!(perp.belt.type in safe_weapons))
						threatcount += 2

				if(istype(perp.s_store, /obj/item/weapon/gun) || istype(perp.s_store, /obj/item/weapon/melee))
					if(!(perp.s_store.type in safe_weapons))
						threatcount += 2

			if(scanmode)
				if(istype(perp.l_store, /obj/item/weapon/gun) || istype(perp.l_store, /obj/item/weapon/melee))
					if(!(perp.l_store.type in safe_weapons))
						threatcount += 2


				if(istype(perp.r_store, /obj/item/weapon/gun) || istype(perp.r_store, /obj/item/weapon/melee))
					if(!(perp.r_store.type in safe_weapons))
						threatcount += 2



				if (perp.back && istype(perp.back, /obj/item/weapon/storage/backpack))
					var/obj/item/weapon/storage/backpack/B = perp.back
					for(var/obj/item/weapon/thing in B.contents)
						if(istype(thing, /obj/item/weapon/gun) || istype(thing, /obj/item/weapon/melee))
							if(!(thing.type in safe_weapons))
								threatcount += 2

		if(idmode)
			if(!perp.wear_id)
				threatcount += 4

		else
			if(!perp.wear_id)
				threatcount += 2

		if(ishuman(perp))
			if(istype(perp.wear_suit, /obj/item/clothing/suit/wizrobe))
				threatcount += 2

		if(perp.dna && perp.dna.mutantrace && perp.dna.mutantrace != "none")
			threatcount += 2

		//Agent cards lower threatlevel.
		if(perp.wear_id && istype(perp.wear_id.GetID(), /obj/item/weapon/card/id/syndicate))
			threatcount -= 2

	var/passperpname = ""
	for (var/datum/data/record/E in data_core.general)
		var/perpname = perp.name

		if(perp.wear_id)
			var/obj/item/weapon/card/id/id = perp.wear_id.GetID()

			if(id)
				perpname = id.registered_name
		else
			perpname = "Unknown"
		passperpname = perpname
		if(E.fields["name"] == perpname)
			for (var/datum/data/record/R in data_core.security)
				if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
					threatcount = 4
					break

	var/list/retlist = list(threatcount, passperpname)
	if(emagged)
		retlist[1] = 10
	return retlist





/obj/machinery/detector/power_change()
	if (powered())
		stat &= ~NOPOWER
//		icon_state = "[base_state]1"
	else
		stat |= NOPOWER
//		icon_state = "[base_state]1"

/obj/machinery/detector/attackby(obj/item/W, mob/user)
	if(..(W, user) == 1)
		return 1 // resolved for click code!

	/*if (iswirecutter(W))
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message("<span class='warning'>[user] has disconnected the detector array!</span>", "<span class='warning'>You disconnect the detector array!</span>")
		if (!src.disable)
			user.visible_message("<span class='warning'>[user] has connected the detector array!</span>", "<span class='warning'>You connect the detector array!</span>")
	*/

/obj/machinery/detector/Topic(href, href_list)
	if(..()) return 1

	if(usr) usr.set_machine(src)

	switch(href_list["action"])
		if("idmode")
			idmode = !idmode
		if("scanmode")
			scanmode = !scanmode
		if("senmode")
			senset = !senset
		else
			return

	src.updateUsrDialog()
	return 1



/obj/machinery/detector/attack_hand(mob/user as mob)

	if(src.allowed(user))


		user.set_machine(src)

		if(!src.anchored)
			return

		var/dat = {"
		<TITLE>Mr. V.A.L.I.D. Portable Threat Detector</TITLE><h3>Menu:</h3><h4>

		<br>Citizens must carry ID: <A href='?src=\ref[src];action=idmode'>Turn [idmode ? "Off" : "On"]</A>

		<br>Intrusive Scan: <A href='?src=\ref[src];action=scanmode'>Turn [scanmode ? "Off" : "On"]</A>

		<br>DeMil Alerts: <A href='?src=\ref[src];action=senmode'>Turn [senset ? "Off" : "On"]</A></h4>
		"}

		user << browse(dat, "window=detector;size=575x300")
		onclose(user, "detector")
		return

	else:

		src.visible_message("<span class = 'warning'>ACCESS DENIED!</span>")


/obj/machinery/detector/proc/flash()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_read && world.time < src.last_read + 20))
		return


	var/maxthreat = 0
	var/sndstr = ""
	for (var/mob/O in viewers(src, null))
		if(isobserver(O)) continue
		if (get_dist(src, O) > src.range)
			continue
		var/list/ourretlist = src.assess_perp(O)
		if(!istype(ourretlist) || !ourretlist.len)
			return
		var/dudesthreat = ourretlist[1]
		var/dudesname = ourretlist[2]



		if (dudesthreat >= 4)

			if(maxthreat < 2)
				sndstr = "sound/machines/alert.ogg"
				maxthreat = 2



			src.last_read = world.time
			use_power(1000)
			src.visible_message("<span class = 'warning'>Threat Detected! Subject: [dudesname]</span>")////


		else if(dudesthreat <= 3 && dudesthreat != 0 && senset)

			if(maxthreat < 1)
				sndstr = "sound/machines/domore.ogg"
				maxthreat = 1


			src.last_read = world.time
			use_power(1000)
			src.visible_message("<span class = 'warning'>Additional screening required! Subject: [dudesname]</span>")


		else

			if(maxthreat == 0)
				sndstr = "sound/machines/info.ogg"



			src.last_read = world.time
			use_power(1000)
			src.visible_message("<span class = 'notice'> Subject: [dudesname] clear.</span>")


	flick("[base_state]_flash", src)
	playsound(get_turf(src), sndstr, 100, 1)





/obj/machinery/detector/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(prob(75/severity))
		flash()
	..(severity)

/obj/machinery/detector/HasProximity(atom/movable/AM as mob|obj)
	if ((src.disable) || (src.last_read && world.time < src.last_read + 30))
		return

	if(istype(AM, /mob/living/carbon))

		if ((src.anchored))
			src.flash()

/obj/machinery/detector/wrenchAnchor(mob/user)
	if(..() == 1)
		overlays.len = 0
		if(anchored)
			src.overlays += "[base_state]-s"



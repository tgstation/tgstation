


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

/obj/machinery/detector/proc/assess_perp(mob/living/carbon/human/perp as mob)
	var/threatcount = 0
	if(!(istype(perp, /mob/living/carbon)))
		return
	if(src.emagged == 2) return 10

	if(!src.allowed(perp))

		if(istype(perp.l_hand, /obj/item/weapon/gun) || istype(perp.l_hand, /obj/item/weapon/melee))
			if(!istype(perp.l_hand, /obj/item/weapon/gun/energy/laser/bluetag) \
			&& !istype(perp.l_hand, /obj/item/weapon/gun/energy/laser/redtag) \
			&& !istype(perp.l_hand, /obj/item/weapon/gun/energy/laser/practice))
				threatcount += 4

		if(istype(perp.r_hand, /obj/item/weapon/gun) || istype(perp.r_hand, /obj/item/weapon/melee))
			if(!istype(perp.r_hand, /obj/item/weapon/gun/energy/laser/bluetag) \
			&& !istype(perp.r_hand, /obj/item/weapon/gun/energy/laser/redtag) \
			&& !istype(perp.r_hand, /obj/item/weapon/gun/energy/laser/practice))
				threatcount += 4

		if(istype(perp.belt, /obj/item/weapon/gun) || istype(perp.belt, /obj/item/weapon/melee))
			if(!istype(perp.belt, /obj/item/weapon/gun/energy/laser/bluetag) \
			&& !istype(perp.belt, /obj/item/weapon/gun/energy/laser/redtag) \
			&& !istype(perp.belt, /obj/item/weapon/gun/energy/laser/practice))
				threatcount += 2

		if(istype(perp.back, /obj/item/weapon/gun) || istype(perp.back, /obj/item/weapon/melee))
			if(!istype(perp.back, /obj/item/weapon/gun/energy/laser/bluetag) \
			&& !istype(perp.back, /obj/item/weapon/gun/energy/laser/redtag) \
			&& !istype(perp.back, /obj/item/weapon/gun/energy/laser/practice))
				threatcount += 2



		if(istype(perp.s_store, /obj/item/weapon/gun) || istype(perp.s_store, /obj/item/weapon/melee))
			if(!istype(perp.s_store, /obj/item/weapon/gun/energy/laser/bluetag) \
			&& !istype(perp.s_store, /obj/item/weapon/gun/energy/laser/redtag) \
			&& !istype(perp.s_store, /obj/item/weapon/gun/energy/laser/practice))
				threatcount += 2


		if(scanmode)
			//
			if(istype(perp.l_store, /obj/item/weapon/gun) || istype(perp.l_store, /obj/item/weapon/melee))
				if(!istype(perp.l_store, /obj/item/weapon/gun/energy/laser/bluetag) \
				&& !istype(perp.l_store, /obj/item/weapon/gun/energy/laser/redtag) \
				&& !istype(perp.l_store, /obj/item/weapon/gun/energy/laser/practice))
					threatcount += 2


			if(istype(perp.r_store, /obj/item/weapon/gun) || istype(perp.r_store, /obj/item/weapon/melee))
				if(!istype(perp.r_store, /obj/item/weapon/gun/energy/laser/bluetag) \
				&& !istype(perp.r_store, /obj/item/weapon/gun/energy/laser/redtag) \
				&& !istype(perp.r_store, /obj/item/weapon/gun/energy/laser/practice))
					threatcount += 2



			if (perp.back && istype(perp.back, /obj/item/weapon/storage/backpack))
				//
				var/obj/item/weapon/storage/backpack/B = perp.back
							//
				for(var/things in B.contents)
					//
					if(istype(things, /obj/item/weapon/gun) || istype(things, /obj/item/weapon/melee))
						if(!istype(things, /obj/item/weapon/gun/energy/laser/bluetag) \
						&& !istype(things, /obj/item/weapon/gun/energy/laser/redtag) \
						&& !istype(things, /obj/item/weapon/gun/energy/laser/practice))
							threatcount += 2





		if(idmode)
			//
			if(!perp.wear_id)
				threatcount += 4

		else

			if(!perp.wear_id)
				threatcount += 2


		if(istype(perp.wear_suit, /obj/item/clothing/suit/wizrobe))
			threatcount += 2

		if(perp.dna && perp.dna.mutantrace && perp.dna.mutantrace != "none")
			threatcount += 2





		//Agent cards lower threatlevel.
		//if(perp.wear_id && istype(perp:wear_id.GetID(), /obj/item/weapon/card/id/syndicate)) ///////////////nah, i dont think so
		//	threatcount -= 2




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

	return retlist





/obj/machinery/detector/power_change()
	if ( powered() )
		stat &= ~NOPOWER
		icon_state = "[base_state]1"
//		src.sd_SetLuminosity(2)
	else
		stat |= ~NOPOWER
		icon_state = "[base_state]1"
//		src.sd_SetLuminosity(0)

/obj/machinery/detector/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wirecutters))
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message("\red [user] has disconnected the detector array!", "\red You disconnect the detector array!")
		if (!src.disable)
			user.visible_message("\red [user] has connected the detector array!", "\red You connect the detector array!")






/obj/machinery/detector/Topic(href, href_list)
	if(..()) return

	if(usr) usr.set_machine(src)

	if (href_list["idmode"])

		if(idmode)
			idmode = 0
			//

		else
			idmode = 1



	if (href_list["scanmode"])

		if(scanmode)
			scanmode = 0
			//

		else
			scanmode = 1


	if (href_list["senmode"])

		if(senset)
			senset = 0
			//

		else
			senset = 1

	src.updateUsrDialog()
	return



.

/obj/machinery/detector/attack_hand(mob/user as mob)

	if(src.allowed(user))


		user.set_machine(src)

		if(!src.anchored)
			return

		var/dat = "<h4>"

		if(idmode == 0)
			dat += "Citizens must carry ID: <A href='?src=\ref[src];idmode=1'>Turn On</A><BR><BR>"
		else
			dat += "Citizens must carry ID: <A href='?src=\ref[src];idmode=1'>Turn Off</A><BR><BR>"


		if(scanmode == 0)
			dat += "Intrusive Scan: <A href='?src=\ref[src];scanmode=1'>Turn On</A><BR><BR>"
		else
			dat += "Intrusive Scan: <A href='?src=\ref[src];scanmode=1'>Turn Off</A><BR><BR>"



		if(senset == 0)
			dat += "DeMil Alerts: <A href='?src=\ref[src];senmode=1'>Turn On</A><BR><BR>"
		else
			dat += "DeMil Alerts: <A href='?src=\ref[src];senmode=1'>Turn Off</A><BR><BR>"


		user << browse("<TITLE>Mr. V.A.L.I.D. Portable Threat Detector</TITLE><h3>Menu:</h3><BR><BR>[dat]</h4></ul>", "window=detector;size=575x300")
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
		var/dudesthreat = ourretlist[1]
		var/dudesname = ourretlist[2]



		if (dudesthreat >= 4)

			if(maxthreat < 2)
				sndstr = "sound/machines/alert.ogg"
				maxthreat = 2



			src.last_read = world.time
			use_power(1000)
			src.visible_message("<span class = 'warning'>Theat Detected! Subject: [dudesname]</span>")////


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
		if(anchored)
			src.overlays += "[base_state]-s"



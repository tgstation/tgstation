


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
	req_access = list(access_security, access_forensics_lockers)



/obj/machinery/detector/proc/assess_perp(mob/living/carbon/human/perp as mob)
	var/threatcount = 0

	if(src.emagged == 2) return 10 //Everyone is a criminal!

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

		if(istype(perp:belt, /obj/item/weapon/gun) || istype(perp:belt, /obj/item/weapon/melee))
			if(!istype(perp:belt, /obj/item/weapon/gun/energy/laser/bluetag) \
			&& !istype(perp:belt, /obj/item/weapon/gun/energy/laser/redtag) \
			&& !istype(perp:belt, /obj/item/weapon/gun/energy/laser/practice))
				threatcount += 2

		if(istype(perp:wear_suit, /obj/item/clothing/suit/wizrobe))
			threatcount += 2

		if(perp.dna && perp.dna.mutantrace && perp.dna.mutantrace != "none")
			threatcount += 2

		//Agent cards lower threatlevel.
		if(perp.wear_id && istype(perp:wear_id.GetID(), /obj/item/weapon/card/id/syndicate))
			threatcount -= 2

	if(1)
		for (var/datum/data/record/E in data_core.general)
			var/perpname = perp.name
			if(perp.wear_id)
				var/obj/item/weapon/card/id/id = perp.wear_id.GetID()
				if(id)
					perpname = id.registered_name

			if(E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.security)
					if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
						threatcount = 4
						break

	return threatcount









/obj/machinery/detector/power_change()
	if ( powered() )
		stat &= ~NOPOWER
		icon_state = "[base_state]1"
//		src.sd_SetLuminosity(2)
	else
		stat |= ~NOPOWER
		icon_state = "[base_state]1-p"
//		src.sd_SetLuminosity(0)

//Don't want to render prison breaks impossible
/obj/machinery/detector/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wirecutters))
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message("\red [user] has disconnected the detector array!", "\red You disconnect the detector array!")
		if (!src.disable)
			user.visible_message("\red [user] has connected the detector array!", "\red You connect the detector array!")

//Let the AI trigger them directly.
/obj/machinery/detector/attack_ai()
	if (src.anchored)
		return src.flash()
	else
		return

/obj/machinery/detector/proc/flash()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_read && world.time < src.last_read + 30))
		return



	for (var/mob/O in viewers(src, null))
		if(isobserver(O)) continue
		if (get_dist(src, O) > src.range)
			continue

		if (src.assess_perp(O) >= 4)
			src.visible_message("<span class = 'warning'>Theat Detected! Subject: [O.name]</span>")////
			playsound(get_turf(src), 'sound/machines/info.ogg', 100, 1)
			flick("[base_state]_flash", src)
			src.last_read = world.time
			use_power(1000)
			//world << "<font size='1' color='red'><b>Theat Detected! Subject:[O.name]/b></font>" //debugging






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
		//var/mob/living/carbon/M = AM
		if ((src.anchored))
			src.flash()

/obj/machinery/detector/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		add_fingerprint(user)
		src.anchored = !src.anchored

		if (!src.anchored)
			user.show_message(text("\red [src] can now be moved."))
			src.overlays.Cut()

		else if (src.anchored)
			user.show_message(text("\red [src] is now secured."))
		src.overlays += "[base_state]-s"




/*
/obj/machinery/detector_button/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/detector_button/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/detector_button/attackby(obj/item/weapon/W, mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/detector_button/attack_hand(mob/user as mob)

	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/detector/M in world)
		if(M.id_tag == src.id_tag)
			spawn()
				M.flash()

	sleep(50)

	icon_state = "launcherbtt"
	active = 0

	return




*/

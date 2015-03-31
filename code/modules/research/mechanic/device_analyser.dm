//You use this to scan items and machines to recreate them in a fabricator or the flatpacker
//You can scan syndicate items, but only with the syndicate version (might be overpowered, so I'll make it expensive)

/obj/item/device/device_analyser
	name = "device analyzer"
	desc = "An electromagnetic scanner used by mechanics. Capable of storing objects and machines as portable designs."
	icon = 'icons/obj/device.dmi'
	icon_state = "mechanic"
	gender = NEUTER
	var/list/loaded_designs = list() //the stored designs
	var/max_designs = 10
	var/syndi_filter = 1 //whether the scanner should filter traitor tech items. 1 is filtered, 0 is not filtered
	var/access_avoidance = 0 //whether the scanner can ignore access requirements for machines. 1 is ignore, 0 is not
	var/loadone = 0 //whether or not it should load just one at a time. 0 is all at once, 1 is one at a time
	flags = FPRINT
	slot_flags = SLOT_BELT
	w_class = 2
	item_state = "electronic"
	m_amt = 0 //so the autolathe doesn't try to eat it
	g_amt = 0
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=3;engineering=4;materials=4;programming=3"

/obj/item/device/device_analyser/attack_self()
	..()
	loadone = !loadone
	usr <<"<span class='notice'> You set the Device Analyzer to [loadone ? "transfer one design" : "transfer all designs"] on use.</span>"

/obj/item/device/device_analyser/preattack(var/atom/A, mob/user, proximity_flag) //Hurrah for after-attack
	/*if(get_turf(src) != get_turf(user)) //we aren't in the same place as our holder, so we have been moved and can ignore scanning
		return*/
	if(proximity_flag != 1)
		return
	if(istype(A, /obj)) //don't want to scan mobs or anything like that
		var/obj/O = A
		if(istype(O, /obj/machinery/r_n_d/reverse_engine) && loaded_designs.len)
			return //don't try to scan the reverse engine if we have any designs to upload! let the reverse engine's attackby handle it instead
		for(var/datum/design/mechanic_design/current_design in loaded_designs)
			if(current_design.build_path == O.type)
				user <<"<span class='rose'>You've already got a schematic of \the [O]!</span>"
				return

		if(O.origin_tech || istype(O, /obj/machinery)) //two requirements: items have origin_tech, machines are checked in...
			switch(CanCreateDesign(O, user)) //this proc. Checks to see if there's anything illegal or bad in the thing before scanning it
				if(1)
					if(max_designs && !(max_designs <= loaded_designs.len))
						loaded_designs += new /datum/design/mechanic_design(O)
						user.visible_message("[user] scans \the [O].", "<span class='notice'>You successfully scan \the [O].</span>")
						return 1
					else
						user << "\icon [src] \The [src] flashes a message on-screen: \"Too many designs loaded.\""
				if(-1)
					user <<"<span class='rose'>\icon [src] \The [src]'s safety features prevent you from scanning that object.</span>"
				if(-2)
					user <<"<span class='rose'>\icon [src] \The [src]'s access requirements prevent you from scanning that object.</span>"
				else //no origin_tech, no scans.
					user <<"<span class='rose'>\The [src] can't seem to scan \the [O]!</span>"
		else //no origin_tech, no scans.
			user <<"<span class='rose'>\The [src] can't seem to scan \the [O]!</span>"
	else
		return

/obj/item/device/device_analyser/syndicate
	desc = "A suspicious-looking device anaylzer. A thorough examination reveals that it lacks the required Nanotrasen logo, and that the safety features have been disabled."
	syndi_filter = 0
	access_avoidance = 1 //we aren't forced to have the access for a machine - perfect for traitors
	origin_tech = "magnets=3;engineering=4;materials=4;programming=3;syndicate=3"

/obj/item/device/device_analyser/advanced
	name = "advanced device analyzer"
	desc = "An electromagnetic scanner used by mechanics. This version can skip machine access, as well as having a higher storage capacity."
	access_avoidance = 1
	max_designs = 20

/obj/item/device/device_analyser/proc/CanCreateDesign(var/obj/O, mob/user)
	if(!istype(O))
		return 0

	// Objects that cannot be scanned
	if((O.mech_flags & MECH_SCAN_FAIL)==MECH_SCAN_FAIL)
		return 0

	var/list/techlist
	if(istype(O, /obj/machinery))
		var/obj/machinery/M = O
		if(user && (!M.allowed(user) && M.mech_flags & MECH_SCAN_ACCESS) && !src.access_avoidance) //if we require access, and don't have it, and the scanner can't bypass it
			return -2
		if(M.component_parts)
			for(var/obj/item/weapon/circuitboard/CB in M.component_parts) //fetching the circuit by looking in the parts
				if(istype(CB))
					techlist = ConvertReqString2List(CB.origin_tech)
					break
		else if(istype(M, /obj/machinery/computer))
			var/obj/machinery/computer/C = M
			if(C.circuit)
				var/obj/item/weapon/circuitboard/comp_circuit = text2path(C.circuit)
				techlist = ConvertReqString2List(initial(comp_circuit.origin_tech))

	else if(istype(O, /obj/item))
		var/obj/item/I = O
		if(!I.origin_tech)
			return 0
		techlist = ConvertReqString2List(I.origin_tech)

	if(!techlist) //this don't fly
		return 0

	if(src.syndi_filter)
		if((techlist && techlist["syndicate"]) || (O.mech_flags & MECH_SCAN_ILLEGAL))
			return -1 //special negative return case
	return 1
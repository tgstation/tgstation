//You use this to scan items and machines to recreate them in a fabricator or the flatpacker
//You can scan syndicate items, but only with the syndicate version (might be overpowered, so I'll make it expensive)
/datum

/obj/item/device/device_analyser
	name = "device analyzer"
	desc = "An electromagnetic scanner used by mechanics. Capable of storing objects and machines as portable designs."
	icon = 'icons/obj/device.dmi'
	icon_state = "mechanic"
	gender = NEUTER
	var/list/loaded_designs = list() //the stored designs
	var/max_designs = 10
	var/syndi_filter = 1 //whether the scanner should filter traitor tech items. 1 is filtered, 0 is not filtered
	var/loadone = 0 //whether or not it should load just one at a time. 0 is all at once, 1 is one at a time
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	w_class = 2
	item_state = "electronic"
	m_amt = 300
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=3;engineering=4;materials=4;programming=3"

/obj/item/device/device_analyser/attack_self()
	..()
	loadone = !loadone
	usr <<"<span class='notice'> You set the Device Analyzer to [loadone ? "transfer one design" : "transfer all designs"] on use.</span>"

/obj/item/device/device_analyser/afterattack(var/atom/A, var/mob/user) //Hurrah for after-attack
	if(istype(A, /obj)) //don't want to scan mobs or anything like that
		var/obj/O = A
		for(var/datum/design/mechanic_design/current_design in loaded_designs)
			if(current_design.build_path == O.type)
				user <<"<span class='rose'>You've already got a schematic of \the [O]!</span>"
				return

		if(O.origin_tech || istype(O, /obj/machinery)) //two requirements: items have origin_tech, machines are checked in...
			if(CanCreateDesign(O)) //this proc. Checks to see if there's anything illegal in the thing before scanning it
				if(max_designs && !(max_designs <= loaded_designs.len))
					loaded_designs += new /datum/design/mechanic_design(O)
					user.visible_message("[user] scans \the [O].", "<span class='notice'>You successfully scan \the [O].</span>")
					return 1
				else
					user << "\icon [src] \The [src] flashes a message on-screen: \"Too many designs loaded.\""
			else
				user <<"<span class='rose'>\icon [src] \The [src]'s safety features prevent you from scanning that item.</span>"
		else //no origin_tech, no scans.
			user <<"<span class='rose'>\The [src] can't seem to scan \the [O]!</span>"
	else
		return

/obj/item/device/device_analyser/syndicate
	desc = "A suspicious-looking device anaylzer. A thorough examination reveals that it lacks the required Nanotrasen logo, and that the safety features have been disabled."
	syndi_filter = 0
	origin_tech = "magnets=3;engineering=4;materials=4;programming=3;syndicate=3"

/obj/item/device/device_analyser/proc/CanCreateDesign(var/obj/O)
	if(!istype(O))
		return 0

	var/list/techlist
	if(istype(O, /obj/machinery))
		var/obj/machinery/M = O
		if(M.component_parts)
			for(var/obj/item/weapon/circuitboard/CB in M.component_parts) //fetching the circuit by looking in the parts
				if(istype(CB))
					techlist = ConvertReqString2List(CB.origin_tech)
		else if(istype(M, /obj/machinery/computer))
			var/obj/machinery/computer/C = M
			if(C.circuit)
				var/obj/item/weapon/circuitboard/comp_circuit = text2path(C.circuit)
				techlist = ConvertReqString2List(initial(comp_circuit.origin_tech))

	else if(istype(O, /obj/item))
		var/obj/item/I = O
		techlist = ConvertReqString2List(I.origin_tech) //our tech is simply the item requirement

	if(techlist && techlist["syndicate"] && src.syndi_filter)
		return 0
	return 1
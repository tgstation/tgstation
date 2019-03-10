/obj/machinery/power/deck_relay //This bridges powernets from deck to deck.
	name = "Multi-deck power adapter"
	desc = "This impressive machine uses bluespace based power transmission technology to supply power to alternate decks. It requires a steady power source. Click it with a multitool / ODN scanner to see stats and reacquire connections."
	icon = 'icons/obj/power.dmi'
	icon_state = "cablerelay-off"
	var/obj/machinery/power/deck_relay/below
	var/list/relays = list() //to bridge the powernets.

/obj/machinery/power/deck_relay/multitool_act(mob/user, obj/item/I)
	if(powernet && (powernet.avail > 0))		// is it powered?
		to_chat(user, "<span class='danger'>Total power: [DisplayPower(powernet.avail)]\nLoad: [DisplayPower(powernet.load)]\nExcess power: [DisplayPower(surplus())]</span>")
	if(!powernet)
		icon_state = "cablerelay-off"
		to_chat(user, "<span class='danger'>Powernet connection lost. Attempting to re-establish. Ensure the relays below this one are connected too.</span>")
		linkdown()
		addtimer(CALLBACK(src, .proc/start), 20) //Wait a bit so we can find the one below, then get powering
	return TRUE

/obj/machinery/power/deck_relay/Initialize()
	. = ..()
	linkdown()
	addtimer(CALLBACK(src, .proc/start), 50) //Wait a bit so we can find the one below, then get powering

/obj/machinery/power/deck_relay/proc/start() //We want the bottom one to do the bridging as the bottom one starts where engineering is. It also saves me a headache :)
	if(below)
		return //Only the bottom one does the processing.
	for(var/II = 0 to world.maxz) //AKA 1 to 6 for example
		if(II > world.maxz)
			break
		var/turf/T = SSmapping.get_turf_above(get_turf(src))
		var/obj/machinery/power/deck_relay/DR = locate(/obj/machinery/power/deck_relay) in T
		if(DR)
			relays += DR
		II ++
	for(var/X in relays) //Typeless loops are apparently more efficient.
		var/obj/machinery/power/deck_relay/DR = X
		if(!DR)
			continue
		var/turf/T = get_turf(DR)
		var/obj/structure/cable/C = T.get_cable_node()
		if(C)
			merge_powernets(powernet,C.powernet)//Bridge the powernets.

/obj/machinery/power/deck_relay/proc/linkdown()
	var/turf/T = get_turf(src)
	if(!T || !istype(T))
		return FALSE
	below = null //in case we're re-establishing
	var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked
	C.powernet.add_machine(src) //Nice we're in.
	powernet = C.powernet
	below = locate(/obj/machinery/power/deck_relay) in(SSmapping.get_turf_below(T))
	if(below)
		icon_state = "cablerelay-on"
	return TRUE
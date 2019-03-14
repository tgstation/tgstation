/obj/machinery/power/deck_relay //This bridges powernets
	name = "Multi-deck power adapter"
	desc = "This impressive machine uses plasma based power transmission technology to supply power to alternate decks. It requires a steady power source. Click it with a multitool / ODN scanner to see stats and reacquire connections."
	icon = 'icons/obj/power.dmi'
	icon_state = "cablerelay-off"
	anchored = TRUE
	density = FALSE
	var/obj/machinery/power/deck_relay/below
	var/obj/machinery/power/deck_relay/above
	var/list/relays = list() //to bridge the powernets.

/obj/machinery/power/deck_relay/process()
	refresh() //Sometimes the powernets get lost, so we need to keep checking.
	if(powernet && (powernet.avail <= 0))		// is it powered?
		icon_state = "cablerelay-off"
	else
		icon_state = "cablerelay-on"
	if(QDELETED(below) || QDELETED(above))
		icon_state = "cablerelay-off"
		find_relays()

/obj/machinery/power/deck_relay/multitool_act(mob/user, obj/item/I)
	if(powernet && (powernet.avail > 0))		// is it powered?
		to_chat(user, "<span class='danger'>Total power: [DisplayPower(powernet.avail)]\nLoad: [DisplayPower(powernet.load)]\nExcess power: [DisplayPower(surplus())]</span>")
	if(!powernet || below.powernet != powernet)
		icon_state = "cablerelay-off"
		to_chat(user, "<span class='danger'>Powernet connection lost. Attempting to re-establish. Ensure the relays below this one are connected too.</span>")
		find_relays()
		addtimer(CALLBACK(src, .proc/refresh), 20) //Wait a bit so we can find the one below, then get powering
	return TRUE

/obj/machinery/power/deck_relay/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/find_relays), 30)
	addtimer(CALLBACK(src, .proc/refresh), 50) //Wait a bit so we can find the one below, then get powering

/obj/machinery/power/deck_relay/proc/refresh()
	var/turf/ours = get_turf(src)
	for(var/X in relays) //Typeless loops are apparently more efficient.
		var/obj/machinery/power/deck_relay/DR = X
		if(!DR)
			continue
		var/turf/T = get_turf(DR)
		var/obj/structure/cable/C = T.get_cable_node()
		var/obj/structure/cable/XR = ours.get_cable_node()
		if(C && XR)
			merge_powernets(XR.powernet,C.powernet)//Bridge the powernets.

/obj/machinery/power/deck_relay/proc/find_relays()
	relays = list()
	var/turf/T = get_turf(src)
	if(!T || !istype(T))
		return FALSE
	below = null //in case we're re-establishing
	above = null
	below = locate(/obj/machinery/power/deck_relay) in(SSmapping.get_turf_below(T))
	above = locate(/obj/machinery/power/deck_relay) in(SSmapping.get_turf_above(T))
	relays += below
	relays += above
	if(below || above)
		icon_state = "cablerelay-on"
	return TRUE

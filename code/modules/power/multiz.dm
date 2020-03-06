#define RELAY_OK 1
#define RELAY_ADD_CABLE 2
#define RELAY_ADD_METAL 3

/obj/machinery/power/deck_relay //This bridges powernets
	name = "Multi-deck power adapter"
	desc = "A huge bundle of double insulated cabling which seems to run up into the ceiling."
	icon = 'icons/obj/power.dmi'
	icon_state = "cablerelay-off"
	max_integrity = 350
	integrity_failure = 0.25
	var/broken_status = RELAY_OK
	var/obj/machinery/power/deck_relay/below ///The relay that's below us (for bridging powernets)
	var/obj/machinery/power/deck_relay/above ///The relay that's above us (for bridging powernets)
	anchored = TRUE
	density = FALSE

/obj/machinery/power/deck_relay/examine(mob/user)
	. += ..()
	if(!anchored)
		. += "<span class='notice'>The securing bolts are undone.</span>"
	if(broken_status == RELAY_ADD_CABLE)
		. += "<span class='notice'>The cable insulation is torn apart and the wires are frayed beyond use.</span>"
	if(broken_status == RELAY_ADD_METAL)
		. += "<span class='notice'>The cable insulation is torn apart and the wiring is exposed.</span>"
	. += "<span class='notice'>above:[above]:[above?1:0], below:[below]:[below?1:0] </span>"

/obj/machinery/power/deck_relay/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		if(!anchored && broken_status == RELAY_OK)
			break_connections()
		return FALSE

	else if(istype(I, /obj/item/stack/cable_coil) && broken_status == RELAY_ADD_CABLE)
		var/obj/item/stack/C = I
		if(C.use(15))
			to_chat(user, "<span class='notice'>You fix the frayed wires inside [src].</span>")
			icon_state = "cablerelay-broken-cable"
			broken_status = RELAY_ADD_METAL
		else
			to_chat(user, "You need 15 cables to rewire [src].")

	else if(istype(I, /obj/item/stack/sheet/metal) && broken_status == RELAY_ADD_METAL)
		var/obj/item/stack/S = I
		if(S.use(10))
			to_chat(user, "<span class='notice'>You reseal the insulation for [src].</span>")
			icon_state = "cablerelay"
			broken_status = RELAY_OK
			obj_integrity = max_integrity
		else
			to_chat(user, "You need 10 metal to mend [src].")

	else
		return ..()

/obj/machinery/power/deck_relay/obj_break()
	..()
	if(broken_status == RELAY_OK)
		break_connections()
		visible_message("<span class='warning'>[src]'s insulation breaks, fraying and severing the cable bundle!</span>")
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
		icon_state = "cablerelay-broken"
		broken_status = RELAY_ADD_CABLE

/obj/machinery/power/deck_relay/obj_destruction()
	return //this shouldn't break under usual means

/obj/machinery/power/deck_relay/Destroy()
	break_connections()
	return ..()

///Lose connections and reset the merged powernet so it makes 2 new seperated ones
/obj/machinery/power/deck_relay/proc/break_connections()
	var/obj/machinery/power/deck_relay/old_above = above
	var/obj/machinery/power/deck_relay/old_below = below
	above = null
	below = null

	if(old_above)
		old_above.below = null
		var/turf/above_deck_relay = get_turf(old_above)
		var/obj/structure/cable/above_cable = above_deck_relay.get_cable_node()
//		if(above_cable)
	
	if(old_below)
		old_below.above = null
		var/turf/below_deck_relay = get_turf(old_below)
		var/obj/structure/cable/below_cable = below_deck_relay.get_cable_node()
//		if(below_cable)


///Allows you to scan the relay with a multitool to see stats/reconnect relays
/obj/machinery/power/deck_relay/multitool_act(mob/user, obj/item/I)
	if(!anchored)
		to_chat(user, "<span class='danger'>You need to wrench this into place before getting a reading!</span>")
		return TRUE
	if(broken_status == RELAY_ADD_CABLE || broken_status == RELAY_ADD_METAL)
		to_chat(user, "<span class='danger'>The [src] isn't in proper shape to get a reading!</span>")
		return TRUE
	if(powernet && (above || below))//we have a powernet and at least one connected relay
		to_chat(user, "<span class='danger'>Total power: [DisplayPower(powernet.avail)]\nLoad: [DisplayPower(powernet.load)]\nExcess power: [DisplayPower(surplus())]</span>")
	if(!above || !below)
		to_chat(user, "<span class='danger'>Cannot access valid powernet. Attempting to re-establish. Ensure any relays above and below are aligned properly and on cable nodes.</span>")
		find_relays(src,FALSE)
		//refresh() //Reload powernet
	return TRUE

/obj/machinery/power/deck_relay/Initialize()
	. = ..()
	name = "DR:[rand(1000,9999)]"
//	if(!above || !below)
//		find_relays(force = FALSE)
//		refresh()

///Locates relays that are above and below this object
///If this going in infinite loop, someone bend your universe in donut
///or i shitcode it
/obj/machinery/power/deck_relay/proc/find_relays(from, force)
	var/turf/T = get_turf(src)
	if(!T || !istype(T))
		return FALSE
	to_chat(world, "<span class='danger'>[src] find_relays([from],[force])</span>")
	if(!below || (from && (from != below)) || force) 
		below = locate(/obj/machinery/power/deck_relay) in(SSmapping.get_turf_below(T))
		to_chat(world, "<span class='danger'>[src] re find below [below] from [from]</span>")
		if(below)
			below.above = src
			below.find_relays(src, FALSE)

	if(!above || force || (from && (from != above))) 
		above = locate(/obj/machinery/power/deck_relay) in(SSmapping.get_turf_above(T))
		to_chat(world, "<span class='danger'>[src] re find above [above] from [from]</span>")
		if(above)
			above.below = src
			above.find_relays(src, FALSE)

	if(below || above)
		icon_state = "cablerelay-on"
	return TRUE

///find_relays() on connect_to_network()
/obj/machinery/power/deck_relay/connect_to_network()
	. = ..()
	to_chat(world, "<span class='danger'>[name] connect_to_network() [.]</span>")
	if(!above && !below)
		find_relays(src, FALSE)

///break_connections() on disconnect_from_network()
/obj/machinery/power/deck_relay/disconnect_from_network()
	. = ..()
	to_chat(world, "<span class='danger'>[name] disconnect_from_network() [.]</span>")
	//disconnect_from_bridge()


///Just disconnect this deck_relay from another
/obj/machinery/power/deck_relay/proc/disconnect_from_bridge()
	to_chat(world, "<span class='danger'>[src] disconnect_from_bridge()</span>")
	if(below) 
		to_chat(world, "<span class='danger'>[src] disconnect_from_bridge() below [below]</span>")
		below.above = null
		below = null
	if(above) 
		to_chat(world, "<span class='danger'>[src] disconnect_from_bridge() above [above]</span>")
		above.below = null
		above = null

/obj/machinery/power/deck_relay/proc/refresh() //Reload powernet
	var/turf/deck_relay_turf = get_turf(src)
	var/obj/structure/cable/my_cable = deck_relay_turf.get_cable_node()
//	if(my_cable)

/obj/machinery/power/deck_relay/proc/get_cables(cable_layer) //get cables
	. = list()
	for(var/obj/structure/cable/C in loc)
		if(cable_layer == C.cable_layer)
			. += C
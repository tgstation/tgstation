/obj/structure/cable/power
	name = "power cable"
	desc = "A flexible, superconducting insulated cable for heavy-duty power transfer."
	icon = 'icons/obj/power_cond/cables.dmi'
	icon_state = "0-1"
	cable_item_type = /obj/item/stack/cable_coil/power/power
	network_type = /datum/cablenet/power
	cable_color = "red"
	color = "#ff0000"
	var/datum/cablenet/power/powernet

/obj/structure/cable/power/yellow
	cable_color = "yellow"
	color = "#ffff00"

/obj/structure/cable/power/green
	cable_color = "green"
	color = "#00aa00"

/obj/structure/cable/power/blue
	cable_color = "blue"
	color = "#1919c8"

/obj/structure/cable/power/pink
	cable_color = "pink"
	color = "#ff3cc8"

/obj/structure/cable/power/orange
	cable_color = "orange"
	color = "#ff8000"

/obj/structure/cable/power/cyan
	cable_color = "cyan"
	color = "#00ffff"

/obj/structure/cable/power/white
	cable_color = "white"
	color = "#ffffff"

// the power cable object
/obj/structure/cable/power/Initialize(mapload, param_color)
	. = ..()
	GLOB.power_cable_list += src //add it to the global cable list

/obj/structure/cable/power/Destroy()					// called when a cable is deleted
	if(powernet)
		cut_cable_from_powernet()				// update the powernets
	GLOB.power_cable_list -= src							//remove it from global cable list
	return ..()									// then go ahead and delete the cable

/obj/structure/cable/power/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(powernet && (powernet.avail > 0))		// is it powered?
			to_chat(user, "<span class='danger'>Total power: [DisplayPower(powernet.avail)]\nLoad: [DisplayPower(powernet.load)]\nExcess power: [DisplayPower(surplus())]</span>")
		else
			to_chat(user, "<span class='danger'>The cable is not powered.</span>")
		shock(user, 5, 0.2)
		add_fingerprint(user)
	else
		return ..()

/obj/structure/cable/power/on_network_connect(datum/cablenet/power/P)
	if(!istype(P))
		stack_trace("Power cable at [COORD(src)] connected to non power cablenet")
		return FALSE
	. = ..()

// shock the user with probability prb
/obj/structure/cable/power/shock(mob/user, prb, siemens_coeff = 1)
	if(!prob(prb))
		return 0
	if (electrocute_mob(user, powernet, src, siemens_coeff))
		do_sparks(5, TRUE, src)
		return 1
	else
		return 0

////////////////////////////////////////////
// Power related
///////////////////////////////////////////

// All power generation handled in add_avail()
// Machines should use add_load(), surplus(), avail()
// Non-machines should use add_delayedload(), delayed_surplus(), newavail()

/obj/structure/cable/power/proc/add_avail(amount)
	var/datum/cablenet/power/powernet = network
	if(powernet)
		powernet.newavail += amount

/obj/structure/cable/power/proc/add_load(amount)
	var/datum/cablenet/power/powernet = network
	if(powernet)
		powernet.load += amount

/obj/structure/cable/power/proc/surplus()
	var/datum/cablenet/power/powernet = network
	if(powernet)
		return CLAMP(powernet.avail-powernet.load, 0, powernet.avail)
	else
		return 0

/obj/structure/cable/power/proc/avail()
	var/datum/cablenet/power/powernet = network
	if(powernet)
		return powernet.avail
	else
		return 0

/obj/structure/cable/power/proc/add_delayedload(amount)
	var/datum/cablenet/power/powernet = network
	if(powernet)
		powernet.delayedload += amount

/obj/structure/cable/power/proc/delayed_surplus()
	var/datum/cablenet/power/powernet = network
	if(powernet)
		return CLAMP(powernet.newavail - powernet.delayedload, 0, powernet.newavail)
	else
		return 0

/obj/structure/cable/power/proc/newavail()
	var/datum/cablenet/power/powernet = network
	if(powernet)
		return powernet.newavail
	else
		return 0

///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

////////////////////////////////
// Definitions
////////////////////////////////


/obj/item/stack/cable_coil/power
	merge_type = /obj/item/stack/cable_coil/power/power
	desc = "A coil of insulated power cable."
	cable_path = /obj/structure/cable/power

/obj/item/stack/cable_coil/power/cyborg
	is_cyborg = TRUE
	materials = list()
	can_change_color = TRUE
	cost = 1

//you can use wires to heal robotics
/obj/item/stack/cable_coil/power/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return ..()

	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting && affecting.status == BODYPART_ROBOTIC)
		if(user == H)
			user.visible_message("<span class='notice'>[user] starts to fix some of the wires in [H]'s [affecting.name].</span>", "<span class='notice'>You start fixing some of the wires in [H]'s [affecting.name].</span>")
			if(!do_mob(user, H, 50))
				return
		if(item_heal_robotic(H, user, 0, 15))
			use(1)
		return
	else
		return ..()

/obj/item/stack/cable_coil/power/red
	item_color = "red"
	color = "#ff0000"

/obj/item/stack/cable_coil/power/yellow
	item_color = "yellow"
	color = "#ffff00"

/obj/item/stack/cable_coil/power/blue
	item_color = "blue"
	color = "#1919c8"

/obj/item/stack/cable_coil/power/green
	item_color = "green"
	color = "#00aa00"

/obj/item/stack/cable_coil/power/pink
	item_color = "pink"
	color = "#ff3ccd"

/obj/item/stack/cable_coil/power/orange
	item_color = "orange"
	color = "#ff8000"

/obj/item/stack/cable_coil/power/cyan
	item_color = "cyan"
	color = "#00ffff"

/obj/item/stack/cable_coil/power/white
	item_color = "white"

/obj/item/stack/cable_coil/power/random
	item_color = null
	color = "#ffffff"


/obj/item/stack/cable_coil/power/random/five
	amount = 5

/obj/item/stack/cable_coil/power/cut
	amount = null
	icon_state = "coil2"

/obj/item/stack/cable_coil/power/cut/Initialize(mapload)
	. = ..()
	if(!amount)
		amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()

/obj/item/stack/cable_coil/power/cut/red
	item_color = "red"
	color = "#ff0000"

/obj/item/stack/cable_coil/power/cut/yellow
	item_color = "yellow"
	color = "#ffff00"

/obj/item/stack/cable_coil/power/cut/blue
	item_color = "blue"
	color = "#1919c8"

/obj/item/stack/cable_coil/power/cut/green
	item_color = "green"
	color = "#00aa00"

/obj/item/stack/cable_coil/power/cut/pink
	item_color = "pink"
	color = "#ff3ccd"

/obj/item/stack/cable_coil/power/cut/orange
	item_color = "orange"
	color = "#ff8000"

/obj/item/stack/cable_coil/power/cut/cyan
	item_color = "cyan"
	color = "#00ffff"

/obj/item/stack/cable_coil/power/cut/white
	item_color = "white"

/obj/item/stack/cable_coil/power/cut/random
	item_color = null
	color = "#ffffff"
/obj/item/stack/cable_coil/monitoring
	name = "electronic display cable coil" // only shows up in vendors
	max_amount = 1
	amount = 1
	merge_type = /obj/item/stack/cable_coil/monitoring
	target_type = /obj/structure/cable/monitoring
	gender = FEMALE // yes i made your cable coil female

/obj/item/stack/cable_coil/monitoring/update_name()
	. = ..()
	name = "wire with an electronic display"

/obj/item/stack/cable_coil/monitoring/update_desc()
	. = ..()
	desc = "A piece of insulated power cable with an attached electronic display, allowing for quick and safe network power checking."

/obj/item/stack/cable_coil/monitoring/attack_self(mob/living/user)
	return

/obj/structure/cable/monitoring
	name = "cable with an attached electronic display"
	desc = "A flexible, superconducting insulated cable for heavy-duty power transfer with an attached electronic display that is displaying its current power amount."
	cable_color = CABLE_COLOR_CYAN
	color = CABLE_COLOR_CYAN
	gender = FEMALE // nothing wrong here

/obj/structure/cable/monitoring/examine(mob/user)
	. = ..()
	if(!isobserver(user)) // check if they are an observer, we dont want to double-dip
		. += get_power_info()

/obj/structure/cable/monitoring/update_overlays()
	. = ..()
	. += "power_monitor"

/obj/structure/cable/monitoring/attack_hand(mob/living/user, list/modifiers)
	to_chat(user, get_power_info())

/obj/structure/cable/monitoring/deconstruct(disassembled = TRUE)
	to_chat(usr, span_notice("You start to carefully snip the electronic monitoring equipment..."))
	if(!do_after(usr, 5 SECONDS, src))
		to_chat(usr, span_warning("Your hand slips, and the monitoring equipment is destroyed!"))
		do_sparks(5, TRUE, src)
		playsound(usr, 'sound/effects/sparks2.ogg', 100, TRUE)
		new /obj/item/stack/cable_coil(drop_location(), 1)
		qdel(src) // those electronics are fragile
		return

	if(!(flags_1 & NODECONSTRUCT_1))
		to_chat(usr, span_notice("You manage to free the monitoring equipment and cable free from the network."))
		var/obj/item/stack/cable_coil/monitoring/cable = new(drop_location(), 1)
		cable.set_cable_color(cable_color)

	qdel(src)

/obj/item/stack/cable_coil/valve
	name = "valve cable coil" // only shows up in vendors
	max_amount = 1
	amount = 1
	merge_type = /obj/item/stack/cable_coil/valve
	target_type = /obj/structure/cable/valve
	gender = FEMALE // indeed, the cable coil is female

/obj/item/stack/cable_coil/valve/update_name()
	. = ..()
	name = "fuse wire"

/obj/item/stack/cable_coil/valve/update_desc()
	. = ..()
	desc = "A piece of insulated power cable thats capable of having its power flow stopped without risk of electrocution"

/obj/item/stack/cable_coil/valve/attack_self(mob/living/user)
	return

/obj/structure/cable/valve
	name = "a fuse wire"
	desc = "A flexible, superconducting insulated cable for heavy-duty power transfer, this one is outfitted with special valve capabilities. Enabling for power to be disabled or enabled quickly and safelly."
	cable_color = CABLE_COLOR_CYAN
	color = CABLE_COLOR_CYAN
	gender = FEMALE // seems about right
	var/off_Layer = "industrial" // when off, we switch to the industrial cable tag. When ON we switch to the initial one
	var/transmits_power = TRUE

/obj/structure/cable/valve/update_overlays()
	. = ..()
	if(transmits_power)
		. += "power_on"
	else
		. += "power_off"

/obj/structure/cable/valve/attack_hand(mob/living/user, list/modifiers)
	transmits_power = !transmits_power
	balloon_alert_to_viewers("fuse [transmits_power ? "on" : "off"]")

	if(transmits_power)
		cable_tag = initial(cable_tag)
	else
		cable_tag = off_Layer

	cut_cable_from_powernet(FALSE) // update the powernets
	Connect_cable(TRUE)
	auto_propagate_cut_cable(src)

	update_appearance(UPDATE_OVERLAYS)

/obj/structure/cable/valve/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/item/stack/cable_coil/valve/cable = new(drop_location(), 1)
		cable.set_cable_color(cable_color)
	qdel(src)

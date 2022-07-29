/obj/item/circuitboard/machine/spaceship_navigation_beacon
	name = "Bluespace Navigation Gigabeacon (Machine Board)"
	build_path = /obj/machinery/spaceship_navigation_beacon
	req_components = list()


/obj/machinery/spaceship_navigation_beacon
	name = "Bluespace Navigation Gigabeacon"
	desc = "A device that creates a bluespace anchor that allow ships jump near to it."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "core"
	base_icon_state = "core"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/spaceship_navigation_beacon

	var/locked = FALSE //Locked beacons don't allow to jump to it.


/obj/machinery/spaceship_navigation_beacon/Initialize(mapload)
	. = ..()
	SSshuttle.beacon_list |= src

/obj/machinery/spaceship_navigation_beacon/emp_act()
	locked = TRUE

/obj/machinery/spaceship_navigation_beacon/Destroy()
	SSshuttle.beacon_list -= src
	return ..()

// update the icon_state
/obj/machinery/spaceship_navigation_beacon/update_icon_state()
	icon_state = "[base_icon_state][powered() ? null : "-open"]"
	return ..()

/obj/machinery/spaceship_navigation_beacon/multitool_act(mob/living/user, obj/item/multitool/I)
	..()
	if(panel_open)
		var/chosen_tag = tgui_input_text(user, "Enter the custom name for this beacon", "Beacon Reclassification", max_length = MAX_NAME_LEN)
		if(!chosen_tag)
			return
		var/new_name = "Beacon_[chosen_tag]"
		if(new_name && Adjacent(user))
			name = new_name
			to_chat(user, span_notice("You change beacon name to [name]."))
	else
		locked =!locked
		to_chat(user, span_notice("You [locked ? "" : "un"]lock [src]."))
	return TRUE

/obj/machinery/spaceship_navigation_beacon/examine()
	.=..()
	. += "<span class='[locked ? "warning" : "nicegreen"]'>Status: [locked ? "LOCKED" : "Stable"] </span>"

/obj/machinery/spaceship_navigation_beacon/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "core-open", "core", W))
		return
	if(default_deconstruction_crowbar(W))
		return

	return ..()

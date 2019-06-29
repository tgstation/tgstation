/obj/item/circuitboard/machine/spaceship_navigation_beacon
	name = "Bluespace Navigation Gigabeacon (Machine Board)"
	build_path = /obj/machinery/spaceship_navigation_beacon
	req_components = list()


/obj/machinery/spaceship_navigation_beacon

	name = "Bluespace Navigation Gigabeacon"
	desc = "A device that creates a bluespace anchor that allow ships jump near to it."

	icon = 'icons/obj/abductor.dmi'
	icon_state = "core"

	use_power = IDLE_POWER_USE
	idle_power_usage = 0

	var/id = ""
	var/access_code = ""

	density = TRUE
	circuit = /obj/item/circuitboard/machine/spaceship_navigation_beacon


/obj/machinery/spaceship_navigation_beacon/Initialize()
	. = ..()
	SSshuttle.beacons |= src

/obj/machinery/spaceship_navigation_beacon/random/Initialize()
	.=..()
	randomise_beacon()

/obj/machinery/spaceship_navigation_beacon/proc/randomise_beacon()
	id = GUID() //gives us a random id.
	access_code = GUID() //gives us a random access code.

obj/machinery/spaceship_navigation_beacon/emp_act()
	randomise_beacon()

/obj/machinery/spaceship_navigation_beacon/Destroy()
	SSshuttle.beacons -= src
	return ..()

// update the icon_state
/obj/machinery/spaceship_navigation_beacon/update_icon()
	if(powered())
		icon_state = "core"
	else
		icon_state = "core-open"
	return

/obj/machinery/spaceship_navigation_beacon/power_change()
	. = ..()
	update_icon()

/obj/machinery/spaceship_navigation_beacon/multitool_act(mob/living/user, obj/item/multitool/I)
	if (istype(I))
		id = replacetext((input("Enter the ID for this beacon", "Input ID", id) as text), " ", "_")
		access_code = replacetext((input("Enter the access code for this beacon", "Input access code", access_code) as text), " ", "_")
		name = "Beacon_[input("Enter the custom name for this beacon", "It be Beacon ..your input..") as text]"
		return TRUE

/obj/machinery/spaceship_navigation_beacon/examine()
	.=..()
	. += "<span class='warning'>ID: [id], Access code: [access_code] </span>"

/obj/machinery/spaceship_navigation_beacon/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "core-open", "core", W))
		return
	if(default_deconstruction_crowbar(W))
		return

	if(!powered())
		return

	return ..()

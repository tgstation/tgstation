/obj/item/circuitboard/machine/spaceship_navigation_beacon
	name = "Bluespace Navigation Gigabeacon (Machine Board)"
	build_path = /obj/machinery/spaceship_navigation_beacon
	req_components = list()


/obj/machinery/spaceship_navigation_beacon

	name = "Bluespace Navigation Gigabeacon"
	desc = "A device that creates a bluespace anchor that allow ships jump near to it."

	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beaconf"

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
	id = "[num2hex(rand(1,65535), -1)]" //gives us a random four-digit hex number as id.
	access_code = "[num2hex(rand(1,65535), -1)]" //gives us a random four-digit hex number as access code.

//obj/machinery/spaceship_navigation_beacon/emp_act()
//	randomise_beacon()

/obj/machinery/spaceship_navigation_beacon/Destroy()
	SSshuttle.beacons -= src
	return ..()

// update the icon_state
/obj/machinery/spaceship_navigation_beacon/update_icon()
//	if(active && powernet)
//		icon_state = avail(active_power_usage) ? icon_state_on : icon_state_underpowered
//	else
	icon_state = initial(icon_state)

/obj/machinery/spaceship_navigation_beacon/power_change()
	. = ..()
	update_icon()

/obj/machinery/spaceship_navigation_beacon/multitool_act(mob/living/user, obj/item/multitool/I)
	if (istype(I))
		id = replacetext(lowertext(input("Enter the ID for this beacon", "Input ID", id) as text), " ", "_")
		access_code = replacetext(lowertext(input("Enter the access code for this beacon", "Input access code", access_code) as text), " ", "_")
		name = "Beacon_[input("Enter the custom name for this beacon", "It be Beacon ..your input..") as text)]"
		return TRUE

/obj/machinery/spaceship_navigation_beacon/examine()
	.=..()
	. += "<span class='warning'>ID: [id], Access code: [access_code] </span>"

/obj/machinery/spaceship_navigation_beacon/attackby(obj/item/W, mob/user, params)
//	if(default_unfasten_wrench(user, W))
//		return
	if(default_deconstruction_screwdriver(user, "floor_beaconf", "floor_beaconf", W))//"ore_redemption-open", "ore_redemption", W)) //spaceship_navigation_beacon
//		updateUsrDialog()
		return
	if(default_deconstruction_crowbar(W))
		return

	if(!powered())
		return

	return ..()

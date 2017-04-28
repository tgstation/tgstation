/obj/machinery/launchpad
	name = "bluespace launchpad"
	desc = "A bluespace pad able to thrust matter through bluespace, teleporting it to or from nearby locations."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "qpad-idle"
	anchored = TRUE
	use_power = TRUE
	idle_power_usage = 200
	active_power_usage = 2500
	var/display_name = "Launchpad"
	var/teleport_speed = 40
	var/range = 5
	var/teleporting = FALSE //if it's in the process of teleporting
	var/power_efficiency = 1
	var/x_offset = 0
	var/y_offset = 0

/obj/machinery/launchpad/Initialize()
	. = ..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/launchpad(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/launchpad
	name = "Bluespace Launchpad (Machine Board)"
	build_path = /obj/machinery/launchpad
	origin_tech = "programming=3;engineering=3;plasmatech=2;bluespace=3"
	req_components = list(
							/obj/item/weapon/ore/bluespace_crystal = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)
	def_components = list(/obj/item/weapon/ore/bluespace_crystal = /obj/item/weapon/ore/bluespace_crystal/artificial)

/obj/machinery/launchpad/RefreshParts()
	var/E = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		E += M.rating
	teleport_speed = initial(teleport_speed)
	teleport_speed -= (E*10)

/obj/machinery/launchpad/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "pad-idle-o", "qpad-idle", I))
		return

	if(panel_open)
		if(istype(I, /obj/item/device/multitool))
			var/obj/item/device/multitool/M = I
			M.buffer = src
			to_chat(user, "<span class='notice'>You save the data in the [I.name]'s buffer.</span>")
			return 1

	if(exchange_parts(user, I))
		return

	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/launchpad/proc/isAvailable()
	if(stat & NOPOWER)
		return FALSE
	if(panel_open)
		return FALSE
	return TRUE
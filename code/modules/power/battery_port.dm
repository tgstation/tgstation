/obj/machinery/power/battery_port
	name = "power connector"
	desc = "A user-safe high-current contact port, used for attaching compatible machinery."
	icon_state = "battery_port"
	density = 0
	anchored = 1
	use_power = 0

	var/obj/machinery/power/battery/portable/connected = null

	machine_flags = SCREWTOGGLE | CROWDESTROY

	starting_terminal = 1

/obj/machinery/power/battery_port/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/battery_port,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

	connect_to_network()


/obj/machinery/power/battery_port/Destroy()
	disconnect_battery()
	..()

/obj/machinery/power/battery_port/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/cable_coil) && !terminal)
		var/obj/item/stack/cable_coil/CC = W

		if (CC.amount < 10)
			to_chat(user, "<span class=\"warning\">You need 10 length cable coil to make a terminal.</span>")
			return

		if(make_terminal(user))
			CC.use(10)
			terminal.connect_to_network()

			user.visible_message(\
				"<span class='warning'>[user.name] has added cables to the SMES!</span>",\
				"You added cables the SMES.")
			src.stat = 0
			return 1
	return ..()

/obj/machinery/power/battery_port/update_icon()
	overlays.len = 0
	if(stat & BROKEN)	return

	if(connected && connected.charging)
		overlays += image('icons/obj/power.dmi', "bp-c")
	else
		if(connected)
			if(connected.charge > 0)
				overlays += image('icons/obj/power.dmi', "bp-o")
			else
				overlays += image('icons/obj/power.dmi', "bp-d")

/obj/machinery/power/battery_port/add_load(var/amount)
	if(terminal && terminal.get_powernet())
		terminal.powernet.load += amount
		return 1
	return 0

/obj/machinery/power/battery_port/surplus()
	if(terminal)
		return terminal.surplus()
	return 0

/obj/machinery/power/battery_port/crowbarDestroy(mob/user)
	if(connected)
		to_chat(user, "You can't disconnect \the [src] while it has \the [connected] attached.")
		return -1
	return ..()

/obj/machinery/power/battery_port/proc/connect_battery(obj/machinery/power/battery/portable/portable)
	if(portable)
		connected = portable
		portable.connected_to = src
		connected.update_icon()

/obj/machinery/power/battery_port/proc/disconnect_battery()
	if(connected)
		connected.connected_to = null
		connected.update_icon()
		connected = null
		update_icon()


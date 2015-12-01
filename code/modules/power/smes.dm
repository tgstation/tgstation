// the SMES
// stores power

/obj/machinery/power/battery/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = 1
	anchored = 1
	use_power = 0

	machine_flags = SCREWTOGGLE | CROWDESTROY

	starting_terminal = 1

/obj/machinery/power/battery/smes/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/smes,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)



	RefreshParts()

	if(ticker)
		initialize()

/obj/machinery/power/battery/smes/initialize()
	..()
	if(!terminal)
		stat |= BROKEN

/obj/machinery/power/battery/smes/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob) //these can only be moved by being reconstructed, solves having to remake the powernet.
	if(iscrowbar(W) && panel_open && terminal)
		to_chat(user, "<span class='warning'>You must first cut the terminal from the SMES!</span>")
		return 1
	if(..())
		return 1
	if(panel_open)
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
		else if(istype(W, /obj/item/weapon/wirecutters) && terminal)
			var/turf/T = get_turf(terminal)
			if(T.intact)
				to_chat(user, "<span class='warning'>You must remove the floor plating in front of the SMES first.</span>")
				return
			to_chat(user, "You begin to cut the cables...")
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			if (do_after(user, src, 50) && panel_open && terminal && !T.intact)
				if (prob(50) && electrocute_mob(usr, terminal.get_powernet(), terminal))
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(5, 1, src)
					s.start()
					return
				getFromPool(/obj/item/stack/cable_coil, get_turf(src), 10)
				user.visible_message(\
					"<span class='warning'>[user.name] cut the cables and dismantled the power terminal.</span>",\
					"You cut the cables and dismantle the power terminal.")
				del(terminal)
		else
			user.set_machine(src)
			interact(user)
			return 1
	return

/obj/machinery/power/battery/smes/can_attach_terminal(mob/user)
	return ..(user) && panel_open

/obj/machinery/power/battery/smes/surplus()
	if(terminal)
		return terminal.surplus()
	return 0

/obj/machinery/power/battery/smes/add_load(var/amount)
	if(terminal)
		terminal.add_load(amount)

/obj/machinery/power/battery/smes/infinite
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power."

	infinite_power = 1

	mech_flags = MECH_SCAN_FAIL


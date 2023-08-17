/obj/machinery/sleeper/clockwork
	name = "Clockwork Sleeper"
	desc = "An enclosed machine used to stabilize and heal servants."
	icon_state = "sleeper_clockwork"
	base_icon_state = "sleeper_clockwork"
	circuit = /obj/item/circuitboard/machine/sleeper/clockwork
	min_health = -75

/obj/item/circuitboard/machine/sleeper/clockwork
	build_path = /obj/machinery/sleeper/clockwork
	req_components = list(
		/datum/stock_part/matter_bin/clock = 1,
		/datum/stock_part/manipulator/clock = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 2)

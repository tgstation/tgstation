
////////////////////////////////////////
// External Shield Generator

/obj/item/weapon/circuitboard/shield_gen_ex
	name = "Circuit board (Experimental hull shield generator)"
	board_type = "machine"
	build_path = "/obj/machinery/shield_gen/external"
	origin_tech = "bluespace=4;plasmatech=3"
	frame_desc = "Requires 2 Pico Manipulators, 1 Subspace Transmitter, 5 Pieces of cable, 1 Subspace Crystal, 1 Subspace Amplifier and 1 Console Screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator/pico" = 2,
							"/obj/item/weapon/stock_parts/subspace/transmitter" = 1,
							"/obj/item/weapon/stock_parts/subspace/crystal" = 1,
							"/obj/item/weapon/stock_parts/subspace/amplifier" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1,
							"/obj/item/stack/cable_coil" = 5)

datum/design/shield_gen_ex
	name = "Circuit Design (Experimental hull shield generator)"
	desc = "Allows for the construction of circuit boards used to build an experimental hull shield generator."
	id = "shield_gen"
	req_tech = list("bluespace" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$plasma" = 10000, "$diamond" = 5000, "$gold" = 10000)
	build_path = "/obj/machinery/shield_gen/external"

////////////////////////////////////////
// Shield Generator

/obj/item/weapon/circuitboard/shield_gen
	name = "Circuit board (Experimental shield generator)"
	board_type = "machine"
	build_path = "/obj/machinery/shield_gen/external"
	origin_tech = "bluespace=4;plasmatech=3"
	frame_desc = "Requires 2 Pico Manipulators, 1 Subspace Transmitter, 5 Pieces of cable, 1 Subspace Crystal, 1 Subspace Amplifier and 1 Console Screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator/pico" = 2,
							"/obj/item/weapon/stock_parts/subspace/transmitter" = 1,
							"/obj/item/weapon/stock_parts/subspace/crystal" = 1,
							"/obj/item/weapon/stock_parts/subspace/amplifier" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1,
							"/obj/item/stack/cable_coil" = 5)

datum/design/shield_gen
	name = "Circuit Design (Experimental shield generator)"
	desc = "Allows for the construction of circuit boards used to build an experimental shield generator."
	id = "shield_gen"
	req_tech = list("bluespace" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$plasma" = 10000, "$diamond" = 5000, "$gold" = 10000)
	build_path = "/obj/machinery/shield_gen/external"

////////////////////////////////////////
// Shield Capacitor

/obj/item/weapon/circuitboard/shield_cap
	name = "Circuit board (Experimental shield capacitor)"
	board_type = "machine"
	build_path = "/obj/machinery/shield_capacitor"
	origin_tech = "magnets=3;powerstorage=4"
	frame_desc = "Requires 2 Pico Manipulators, 1 Subspace Filter, 5 Pieces of cable, 1 Subspace Treatment disk, 1 Subspace Analyzer and 1 Console Screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator/pico" = 2,
							"/obj/item/weapon/stock_parts/subspace/filter" = 1,
							"/obj/item/weapon/stock_parts/subspace/treatment" = 1,
							"/obj/item/weapon/stock_parts/subspace/analyzer" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1,
							"/obj/item/stack/cable_coil" = 5)

datum/design/shield_cap
	name = "Circuit Design (Experimental shield capacitor)"
	desc = "Allows for the construction of circuit boards used to build an experimental shielding capacitor."
	id = "shield_cap"
	req_tech = list("magnets" = 3, "powerstorage" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$plasma" = 10000, "$diamond" = 5000, "$silver" = 10000)
	build_path = "/obj/machinery/shield_gen/external"

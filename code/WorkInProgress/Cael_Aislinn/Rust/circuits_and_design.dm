
/obj/item/weapon/circuitboard/rust_core_control
	name = "Circuit board (RUST core controller)"
	build_path = "/obj/machinery/computer/rust_core_control"
	origin_tech = "programming=4;engineering=5;power=6"

/obj/item/weapon/circuitboard/rust_fuel_control
	name = "Circuit board (RUST fuel controller)"
	build_path = "/obj/machinery/computer/rust_fuel_control"
	origin_tech = "programming=4;engineering=5;power=6"

/obj/item/weapon/circuitboard/rust_fuel_port
	name = "Circuit board (RUST fuel port)"
	build_path = "/obj/machinery/computer/rust_fuel_control"
	origin_tech = "programming=4;engineering=5;power=6"

/obj/item/weapon/circuitboard/rust_fuel_compressor
	name = "Circuit board (RUST fuel compressor)"
	build_path = "/obj/machinery/computer/rust_fuel_control"
	origin_tech = "programming=4;engineering=5;power=6"

datum/design/rust_core_control
	name = "Circuit Design (RUST core controller)"
	desc = "Allows for the construction of circuit boards used to build a core control console for the RUST fusion engine."
	id = "rust_core_control"
	req_tech = list("programming" = 4, "engineering" = 5, "power" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$gold" = 2000)
	build_path = "/obj/item/weapon/circuitboard/rust_core_control"

datum/design/rust_fuel_control
	name = "Circuit Design (RUST fuel controller)"
	desc = "Allows for the construction of circuit boards used to build a fuel injector control console for the RUST fusion engine."
	id = "rust_fuel_control"
	req_tech = list("programming" = 4, "engineering" = 5, "power" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$silver" = 2000)
	build_path = "/obj/item/weapon/circuitboard/rust_fuel_control"

datum/design/rust_fuel_port
	name = "Circuit Design (RUST fuel port)"
	desc = "Allows for the construction of circuit boards used to build a fuel injection port for the RUST fusion engine."
	id = "rust_fuel_port"
	req_tech = list("programming" = 4, "engineering" = 5, "magnets" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$uranium" = 3000)
	build_path = "/obj/item/weapon/circuitboard/rust_fuel_port"

datum/design/rust_fuel_compressor
	name = "Circuit Design (RUST fuel compressor)"
	desc = "Allows for the construction of circuit boards used to build a fuel compressor of the RUST fusion engine."
	id = "rust_fuel_compressor"
	req_tech = list("programming" = 4, "engineering" = 5 "magnets" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 2000, "sacid" = 20, "$plasma" = 3000)
	build_path = "/obj/item/weapon/circuitboard/rust_fuel_compressor"

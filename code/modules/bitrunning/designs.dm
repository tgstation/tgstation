// Quantum server

/obj/item/circuitboard/machine/quantum_server
	name = "Quantum Server"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/quantum_server
	req_components = list(
		/datum/stock_part/servo = 2,
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/capacitor = 1,
	)

/**
 * quantum server design
 * are you absolutely sure??
 */

// Netpod

/obj/item/circuitboard/machine/netpod
	name = "Netpod"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/netpod
	req_components = list(
		/datum/stock_part/servo = 1,
		/datum/stock_part/matter_bin = 2,
	)

/datum/design/board/netpod
	name = "Netpod Board"
	desc = "The circuit board for a netpod."
	id = "netpod"
	build_path = /obj/item/circuitboard/machine/netpod
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

// Quantum console

/obj/item/circuitboard/computer/quantum_console
	name = "Quantum Console"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/quantum_console

/datum/design/board/quantum_console
	name = "Quantum Console Board"
	desc = "Allows for the construction of circuit boards used to build a Quantum Console."
	id = "quantum_console"
	build_path = /obj/item/circuitboard/computer/quantum_console
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

// Byteforge

/obj/item/circuitboard/machine/byteforge
	name = "Byteforge"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/byteforge
	req_components = list(
		/datum/stock_part/micro_laser = 1,
	)

/datum/design/board/byteforge
	name = "Byteforge Board"
	desc = "Allows for the construction of circuit boards used to build a Byteforge."
	id = "byteforge"
	build_path = /obj/item/circuitboard/machine/byteforge
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING


/datum/techweb_node/bitrunning
	id = "bitrunning"
	display_name = "Bitrunning Technology"
	description = "Bluespace technology has led to the development of quantum-scale computing, which unlocks the means to materialize atomic structures while executing advanced programs."
	prereq_ids = list("practical_bluespace")
	design_ids = list(
		"byteforge",
		"quantum_console",
		"netpod",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

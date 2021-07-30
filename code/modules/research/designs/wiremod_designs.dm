/datum/design/integrated_circuit
	name = "Integrated Circuit"
	desc = "The foundation of all circuits. All Circuitry go onto this."
	id = "integrated_circuit"
	build_path = /obj/item/integrated_circuit
	build_type = IMPRINTER | COMPONENT_PRINTER
	category = list("Circuitry", "Core")
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/circuit_multitool
	name = "Circuit Multitool"
	desc = "A circuit multitool to mark entities and load them into."
	id = "circuit_multitool"
	build_path = /obj/item/multitool/circuit
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list("Circuitry", "Core")
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/usb_cable
	name = "USB Cable"
	desc = "A cable that allows certain shells to connect to nearby computers and machines."
	id = "usb_cable"
	build_path = /obj/item/usb_cable
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list("Circuitry", "Core")
	// Yes, it would make sense to make them take plastic, but then less people would make them, and I think they're cool
	materials = list(/datum/material/iron = 2500)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/component
	name = "Component ( NULL ENTRY )"
	desc = "A component that goes into an integrated circuit."
	build_type = IMPRINTER | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	category = list("Circuitry", "Components")

/datum/design/component/New(abstract = TRUE)
	. = ..()
	if(abstract)
		subdesigns = list()
		for(var/obj/item/circuit_component/path in subtypesof(/obj/item/circuit_component))
			var/datum/design/subdesign = new(abstract = FALSE)
			subdesign.name = initial(path.name)
			subdesign.id = initial(path.name)
			subdesign.build_path = path
			subdesign.desc = initial(path.display_desc)
			subdesigns += subdesign
			SSresearch.techweb_node_by_id(initial(path.techweb_node_id)).design_ids += initial(path.name)
/datum/design/compact_remote_shell
	name = "Compact Remote Shell"
	desc = "A handheld shell with one big button."
	id = "compact_remote_shell"
	build_path = /obj/item/compact_remote
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 5000)
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list("Circuitry", "Shells")

/datum/design/controller_shell
	name = "Controller Shell"
	desc = "A handheld shell with several buttons."
	id = "controller_shell"
	build_path = /obj/item/controller
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 7000)
	category = list("Circuitry", "Shells")

/datum/design/scanner_shell
	name = "Scanner Shell"
	desc = "A handheld scanner shell that can scan entities."
	id = "scanner_shell"
	build_path = /obj/item/wiremod_scanner
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 7000)
	category = list("Circuitry", "Shells")

/datum/design/bot_shell
	name = "Bot Shell"
	desc = "An immobile shell that can store more components. Has a USB port to be able to connect to computers and machines."
	id = "bot_shell"
	build_path = /obj/item/shell/bot
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 10000)
	category = list("Circuitry", "Shells")

/datum/design/money_bot_shell
	name = "Money Bot Shell"
	desc = "An immobile shell that is similar to a regular bot shell, but accepts monetary inputs and can also dispense money."
	id = "money_bot_shell"
	build_path = /obj/item/shell/money_bot
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 10000, /datum/material/gold = 50)
	category = list("Circuitry", "Shells")

/datum/design/drone_shell
	name = "Drone Shell"
	desc = "A shell with the ability to move itself around."
	id = "drone_shell"
	build_path = /obj/item/shell/drone
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(
		/datum/material/glass = 2000,
		/datum/material/iron = 11000,
		/datum/material/gold = 500,
	)
	category = list("Circuitry", "Shells")

/datum/design/server_shell
	name = "Server Shell"
	desc = "A very large shell that cannot be moved around. Stores the most components."
	id = "server_shell"
	materials = list(
		/datum/material/glass = 5000,
		/datum/material/iron = 15000,
		/datum/material/gold = 1500,
	)
	build_path = /obj/item/shell/server
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list("Circuitry", "Shells")

/datum/design/airlock_shell
	name = "Airlock Shell"
	desc = "A door shell that cannot be moved around when assembled."
	id = "door_shell"
	materials = list(
		/datum/material/glass = 5000,
		/datum/material/iron = 15000,
	)
	build_path = /obj/item/shell/airlock
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list("Circuitry", "Shells")

/datum/design/bci_shell
	name = "Brain-Computer Interface Shell"
	desc = "An implant that can be placed in a user's head to control circuits using their brain."
	id = "bci_shell"
	materials = list(
		/datum/material/glass = 2000,
		/datum/material/iron = 8000,
	)
	build_path = /obj/item/shell/bci
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list("Circuitry", "Shells")

/datum/design/board/bci_implanter
	name = "Brain-Computer Interface Manipulation Chamber"
	desc = "A machine that, when given a brain-computer interface, will implant it into an occupant. Otherwise, will remove any brain-computer interfaces they already have."
	id = "bci_implanter"
	build_path = /obj/item/circuitboard/machine/bci_implanter
	build_type = IMPRINTER | COMPONENT_PRINTER
	category = list("Circuitry", "Core")

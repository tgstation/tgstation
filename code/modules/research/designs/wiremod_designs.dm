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

/datum/design/component/New()
	. = ..()
	if(build_path)
		var/obj/item/circuit_component/component_path = build_path
		desc = initial(component_path.display_desc)

/datum/design/component/arithmetic
	name = "Arithmetic Component"
	id = "comp_arithmetic"
	build_path = /obj/item/circuit_component/arithmetic

/datum/design/component/clock
	name = "Clock Component"
	id = "comp_clock"
	build_path = /obj/item/circuit_component/clock

/datum/design/component/comparison
	name = "Comparison Component"
	id = "comp_comparison"
	build_path = /obj/item/circuit_component/compare/comparison

/datum/design/component/logic
	name = "Logic Component"
	id = "comp_logic"
	build_path = /obj/item/circuit_component/compare/logic

/datum/design/component/delay
	name = "Delay Component"
	id = "comp_delay"
	build_path = /obj/item/circuit_component/delay

/datum/design/component/index
	name = "Index Component"
	id = "comp_index"
	build_path = /obj/item/circuit_component/index

/datum/design/component/length
	name = "Length Component"
	id = "comp_length"
	build_path = /obj/item/circuit_component/length

/datum/design/component/light
	name = "Light Component"
	id = "comp_light"
	build_path = /obj/item/circuit_component/light

/datum/design/component/not
	name = "Not Component"
	id = "comp_not"
	build_path = /obj/item/circuit_component/not

/datum/design/component/ram
	name = "RAM Component"
	id = "comp_ram"
	build_path = /obj/item/circuit_component/ram

/datum/design/component/random
	name = "Random Component"
	id = "comp_random"
	build_path = /obj/item/circuit_component/random

/datum/design/component/species
	name = "Get Species Component"
	id = "comp_species"
	build_path = /obj/item/circuit_component/species

/datum/design/component/speech
	name = "Speech Component"
	id = "comp_speech"
	build_path = /obj/item/circuit_component/speech

/datum/design/component/tostring
	name = "To String Component"
	id = "comp_tostring"
	build_path = /obj/item/circuit_component/tostring

/datum/design/component/typecheck
	name = "Typecheck Component"
	id = "comp_typecheck"
	build_path = /obj/item/circuit_component/compare/typecheck

/datum/design/component/concat
	name = "Concatenation Component"
	id = "comp_concat"
	build_path = /obj/item/circuit_component/concat

/datum/design/component/textcase
	name = "Textcase Component"
	id = "comp_textcase"
	build_path = /obj/item/circuit_component/textcase

/datum/design/component/hear
	name = "Voice Activator Component"
	id = "comp_hear"
	build_path = /obj/item/circuit_component/hear

/datum/design/component/contains
	name = "String Contains Component"
	id = "comp_string_contains"
	build_path = /obj/item/circuit_component/compare/contains

/datum/design/component/self
	name = "Self Component"
	id = "comp_self"
	build_path = /obj/item/circuit_component/self

/datum/design/component/radio
	name = "Radio Component"
	id = "comp_radio"
	build_path = /obj/item/circuit_component/radio

/datum/design/component/gps
	name = "GPS Component"
	id = "comp_gps"
	build_path = /obj/item/circuit_component/gps

/datum/design/component/direction
	name = "Direction Component"
	id = "comp_direction"
	build_path = /obj/item/circuit_component/direction

/datum/design/component/health
	name = "Health Component"
	id = "comp_health"
	build_path = /obj/item/circuit_component/health

/datum/design/component/combiner
	name = "Combiner Component"
	id = "comp_combiner"
	build_path = /obj/item/circuit_component/combiner

/datum/design/component/pull
	name = "Pull Component"
	id = "comp_pull"
	build_path = /obj/item/circuit_component/pull

/datum/design/component/mmi
	name = "MMI Component"
	id = "comp_mmi"
	build_path = /obj/item/circuit_component/mmi

/datum/design/component/multiplexer
	name = "Multiplexer Component"
	id = "comp_multiplexer"
	build_path = /obj/item/circuit_component/multiplexer

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

/datum/design/integrated_circuit
	name = "Integrated Circuit"
	desc = "The foundation of all circuits. All components go onto this."
	id = "integrated_circuit"
	build_path = /obj/item/integrated_circuit
	build_type = IMPRINTER
	category = list("Components")
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/circuit_multitool
	name = "Circuit Multitool"
	desc = "A circuit multitool to mark entities and load them into"
	id = "circuit_multitool"
	build_path = /obj/item/multitool/circuit
	build_type = PROTOLATHE
	category = list("Components")
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE


/datum/design/component
	name = "Component ( NULL ENTRY )"
	desc = "A component that goes into an integrated circuit"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	category = list("Components")

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
	name = "Species Checker Component"
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

/datum/design/component/self
	name = "Self Component"
	id = "comp_self"
	build_path = /obj/item/circuit_component/self

/datum/design/component/radio
	name = "Radio Component"
	id = "comp_radio"
	build_path = /obj/item/circuit_component/radio


/datum/design/shell_compact_remote
	name = "Compact Remote"
	id = "shell_compact_remote"
	build_path = /obj/item/compact_remote
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 5000)
	build_type = PROTOLATHE
	category = list("Components")

/datum/design/shell_controller
	name = "Controller"
	id = "shell_controller"
	build_path = /obj/item/controller
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 7000)
	category = list("Components")

/datum/design/shell_bot
	name = "Bot"
	id = "shell_bot"
	build_path = /obj/item/shell/bot
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 10000)
	category = list("Components")

/datum/design/shell_drone
	name = "Drone"
	id = "shell_drone"
	build_path = /obj/item/shell/drone
	build_type = PROTOLATHE
	materials = list(
		/datum/material/glass = 2000,
		/datum/material/iron = 11000,
		/datum/material/gold = 500,
	)
	category = list("Components")

/datum/design/shell_server
	name = "Server"
	id = "shell_server"
	materials = list(
		/datum/material/glass = 5000,
		/datum/material/iron = 15000,
		/datum/material/gold = 1500,
	)
	build_path = /obj/item/shell/server
	build_type = PROTOLATHE
	category = list("Components")

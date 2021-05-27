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


/datum/design/component
	name = "Component ( NULL ENTRY )"
	desc = "A component that goes into an integrated circuit."
	build_type = IMPRINTER | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	category = list("Circuitry", "Components")

/datum/design/component/arithmetic
	name = "Arithmetic Component"
	desc = "General arithmetic component with add/subtract/multiplication/division capabilities."
	id = "comp_arithmetic"
	build_path = /obj/item/circuit_component/arithmetic

/datum/design/component/clock
	name = "Clock Component"
	desc = "A component that repeatedly fires."
	id = "comp_clock"
	build_path = /obj/item/circuit_component/clock

/datum/design/component/comparison
	name = "Comparison Component"
	desc = "A component that compares two objects."
	id = "comp_comparison"
	build_path = /obj/item/circuit_component/compare/comparison

/datum/design/component/logic
	name = "Logic Component"
	desc = "A component with 'and' and 'or' capabilities."
	id = "comp_logic"
	build_path = /obj/item/circuit_component/compare/logic

/datum/design/component/delay
	name = "Delay Component"
	desc = "A component that delays a signal by a specified duration."
	id = "comp_delay"
	build_path = /obj/item/circuit_component/delay

/datum/design/component/index
	name = "Index Component"
	desc = "A component that returns the value of a list at a given index."
	id = "comp_index"
	build_path = /obj/item/circuit_component/index

/datum/design/component/length
	name = "Length Component"
	desc = "A component that returns the length of its input."
	id = "comp_length"
	build_path = /obj/item/circuit_component/length

/datum/design/component/light
	name = "Light Component"
	desc = "A component that emits a light of a specific brightness and colour. Requires a shell."
	id = "comp_light"
	build_path = /obj/item/circuit_component/light

/datum/design/component/not
	name = "Not Component"
	desc = "A component that inverts its input."
	id = "comp_not"
	build_path = /obj/item/circuit_component/not

/datum/design/component/ram
	name = "RAM Component"
	desc = "A component that retains a variable."
	id = "comp_ram"
	build_path = /obj/item/circuit_component/ram

/datum/design/component/random
	name = "Random Component"
	desc = "A component that returns random values."
	id = "comp_random"
	build_path = /obj/item/circuit_component/random

/datum/design/component/species
	name = "Get Species Component"
	desc = "A component that returns the species of its input."
	id = "comp_species"
	build_path = /obj/item/circuit_component/species

/datum/design/component/speech
	name = "Speech Component"
	desc = "A component that sends a message. Requires a shell."
	id = "comp_speech"
	build_path = /obj/item/circuit_component/speech

/datum/design/component/tostring
	name = "To String Component"
	desc = "A component that converts its input to text."
	id = "comp_tostring"
	build_path = /obj/item/circuit_component/tostring

/datum/design/component/typecheck
	name = "Typecheck Component"
	desc = "A component that checks the type of its input."
	id = "comp_typecheck"
	build_path = /obj/item/circuit_component/compare/typecheck

/datum/design/component/concat
	name = "Concatenation Component"
	desc = "A component that combines strings."
	id = "comp_concat"
	build_path = /obj/item/circuit_component/concat

/datum/design/component/textcase
	name = "Textcase Component"
	desc = "A component that makes its input uppercase or lowercase."
	id = "comp_textcase"
	build_path = /obj/item/circuit_component/textcase

/datum/design/component/hear
	name = "Voice Activator Component"
	desc = "A component that listens for messages. Requires a shell."
	id = "comp_hear"
	build_path = /obj/item/circuit_component/hear

/datum/design/component/contains
	name = "String Contains Component"
	desc = "Checks if a string contains a word/letter"
	id = "comp_string_contains"
	build_path = /obj/item/circuit_component/compare/contains

/datum/design/component/self
	name = "Self Component"
	desc = "A component that returns the current shell."
	id = "comp_self"
	build_path = /obj/item/circuit_component/self

/datum/design/component/radio
	name = "Radio Component"
	desc = "A component that can listen and send frequencies."
	id = "comp_radio"
	build_path = /obj/item/circuit_component/radio


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
	desc = "An immobile shell that can store more components."
	id = "bot_shell"
	build_path = /obj/item/shell/bot
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 10000)
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

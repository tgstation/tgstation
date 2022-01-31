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
		desc = initial(component_path.desc)

/datum/design/component/arithmetic
	name = "Arithmetic Component"
	id = "comp_arithmetic"
	build_path = /obj/item/circuit_component/arithmetic

/datum/design/component/trigonometry
	name = "Trigonometry Component"
	id = "comp_trigonometry"
	build_path = /obj/item/circuit_component/trigonometry

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

/datum/design/component/index_assoc
	name = "Index Associative List Component"
	id = "comp_index_assoc"
	build_path = /obj/item/circuit_component/index/assoc_string

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

/datum/design/component/random
	name = "Random Component"
	id = "comp_random"
	build_path = /obj/item/circuit_component/random

/datum/design/component/binary_conversion
	name = "Binary Conversion Component"
	id = "comp_binary_convert"
	build_path = /obj/item/circuit_component/binary_decimal/binary_conversion

/datum/design/component/decimal_conversion
	name = "Decimal Conversion Component"
	id = "comp_decimal_convert"
	build_path = /obj/item/circuit_component/binary_decimal/decimal_conversion

/datum/design/component/species
	name = "Get Species Component"
	id = "comp_species"
	build_path = /obj/item/circuit_component/species

/datum/design/component/speech
	name = "Speech Component"
	id = "comp_speech"
	build_path = /obj/item/circuit_component/speech

/datum/design/component/timepiece
	name = "Timepiece Component"
	id = "comp_timepiece"
	build_path = /obj/item/circuit_component/timepiece

/datum/design/component/tostring
	name = "To String Component"
	id = "comp_tostring"
	build_path = /obj/item/circuit_component/tostring

/datum/design/component/tonumber
	name = "To Number"
	id = "comp_tonumber"
	build_path = /obj/item/circuit_component/tonumber

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

/datum/design/component/reagentscanner
	name = "Reagents Scanner"
	id = "comp_reagents"
	build_path = /obj/item/circuit_component/reagentscanner

/datum/design/component/health
	name = "Health Component"
	id = "comp_health"
	build_path = /obj/item/circuit_component/health

/datum/design/component/matscanner
	name = "Material Scanner"
	id = "comp_matscanner"
	build_path = /obj/item/circuit_component/matscanner

/datum/design/component/split
	name = "Split Component"
	id = "comp_split"
	build_path = /obj/item/circuit_component/split

/datum/design/component/pull
	name = "Pull Component"
	id = "comp_pull"
	build_path = /obj/item/circuit_component/pull

/datum/design/component/soundemitter
	name = "Sound Emitter Component"
	id = "comp_soundemitter"
	build_path = /obj/item/circuit_component/soundemitter

/datum/design/component/mmi
	name = "MMI Component"
	id = "comp_mmi"
	build_path = /obj/item/circuit_component/mmi

/datum/design/component/router
	name = "Router Component"
	id = "comp_router"
	build_path = /obj/item/circuit_component/router

/datum/design/component/multiplexer
	name = "Multiplexer Component"
	id = "comp_multiplexer"
	build_path = /obj/item/circuit_component/router/multiplexer

/datum/design/component/get_column
	name = "Get Column Component"
	id = "comp_get_column"
	build_path = /obj/item/circuit_component/get_column

/datum/design/component/index_table
	name = "Index Table Component"
	id = "comp_index_table"
	build_path = /obj/item/circuit_component/index_table

/datum/design/component/concat_list
	name = "Concatenate List Component"
	id = "comp_concat_list"
	build_path = /obj/item/circuit_component/concat_list

/datum/design/component/select_query
	name = "Select Query Component"
	id = "comp_select_query"
	build_path = /obj/item/circuit_component/select

/datum/design/component/pathfind
	name = "Pathfinder"
	id = "comp_pathfind"
	build_path = /obj/item/circuit_component/pathfind

/datum/design/component/tempsensor
	name = "Temperature Sensor Component"
	id = "comp_tempsensor"
	build_path = /obj/item/circuit_component/tempsensor

/datum/design/component/pressuresensor
	name = "Pressure Sensor Component"
	id = "comp_pressuresensor"
	build_path = /obj/item/circuit_component/pressuresensor

/datum/design/component/module
	name = "Module Component"
	id = "comp_module"
	build_path = /obj/item/circuit_component/module

/datum/design/component/ntnet_receive
	name = "NTNet Receiver"
	id = "comp_ntnet_receive"
	build_path = /obj/item/circuit_component/ntnet_receive

/datum/design/component/ntnet_send
	name = "NTNet Transmitter"
	id = "comp_ntnet_send"
	build_path = /obj/item/circuit_component/ntnet_send

/datum/design/component/list_literal
	name = "List Literal Component"
	id = "comp_list_literal"
	build_path = /obj/item/circuit_component/list_literal

/datum/design/component/list_assoc_literal
	name = "Associative List Literal"
	id = "comp_list_assoc_literal"
	build_path = /obj/item/circuit_component/list_literal/assoc_literal

/datum/design/component/typecast
	name = "Typecast Component"
	id = "comp_typecast"
	build_path = /obj/item/circuit_component/typecast

/datum/design/component/printer
	name = "Printer Component"
	id = "comp_printer"
	build_path = /obj/item/circuit_component/printer

/datum/design/component/pinpointer
	name = "Proximity Pinpointer Component"
	id = "comp_pinpointer"
	build_path = /obj/item/circuit_component/pinpointer

/datum/design/component/bci
	category = list("Circuitry", "BCI Components")

/datum/design/component/bci/bci_action
	name = "BCI Action Component"
	id = "comp_bci_action"
	build_path = /obj/item/circuit_component/equipment_action/bci

/datum/design/component/bci/object_overlay
	name = "Object Overlay Component"
	id = "comp_object_overlay"
	build_path = /obj/item/circuit_component/object_overlay

/datum/design/component/bci/bar_overlay
	name = "Bar Overlay Component"
	id = "comp_bar_overlay"
	build_path = /obj/item/circuit_component/object_overlay/bar

/datum/design/component/bci/target_intercept
	name = "BCI Target Interceptor"
	id = "comp_target_intercept"
	build_path = /obj/item/circuit_component/target_intercept

/datum/design/component/bci/counter_overlay
	name = "Counter Overlay Component"
	id = "comp_counter_overlay"
	build_path = /obj/item/circuit_component/counter_overlay

/datum/design/component/foreach
	name = "For Each Component"
	id = "comp_foreach"
	build_path = /obj/item/circuit_component/foreach

/datum/design/component/filter_list
	name = "Filter List Component"
	id = "comp_filter_list"
	build_path = /obj/item/circuit_component/filter_list

/datum/design/component/mod_action
	name = "MOD Action Component"
	id = "comp_mod_action"
	build_path = /obj/item/circuit_component/equipment_action/mod

/datum/design/component/id_getter
	name = "ID Getter Component"
	id = "comp_id_getter"
	build_path = /obj/item/circuit_component/id_getter

/datum/design/component/id_info_reader
	name = "ID Getter Component"
	id = "comp_id_info_reader"
	build_path = /obj/item/circuit_component/id_info_reader

/datum/design/component/id_access_reader
	name = "ID Access Reader Component"
	id = "comp_id_access_reader"
	build_path = /obj/item/circuit_component/id_access_reader

/datum/design/component/access_checker
	name = "Access Checker Component"
	id = "comp_access_checker"
	build_path = /obj/item/circuit_component/compare/access

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

/datum/design/gun_shell
	name = "Gun Shell"
	desc = "A handheld shell that can fire projectiles to output entities."
	id = "gun_shell"
	build_path = /obj/item/gun/energy/wiremod_gun
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 10000, /datum/material/plasma = 100)
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

/datum/design/dispenser_shell
	name = "Dispenser Shell"
	desc = "A dispenser shell that can dispense items."
	id = "dispenser_shell"
	materials = list(
		/datum/material/glass = 5000,
		/datum/material/iron = 15000,
	)
	build_path = /obj/item/shell/dispenser
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

/datum/design/scanner_gate_shell
	name = "Scanner Gate Shell"
	desc = "A scanner gate shell that performs mid-depth scans on people when they pass through it."
	id = "scanner_gate_shell"
	materials = list(
		/datum/material/glass = 4000,
		/datum/material/iron = 12000,
	)
	build_path = /obj/item/shell/scanner_gate
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list("Circuitry", "Shells")

/datum/design/board/bci_implanter
	name = "Brain-Computer Interface Manipulation Chamber"
	desc = "A machine that, when given a brain-computer interface, will implant it into an occupant. Otherwise, will remove any brain-computer interfaces they already have."
	id = "bci_implanter"
	build_path = /obj/item/circuitboard/machine/bci_implanter
	build_type = IMPRINTER | COMPONENT_PRINTER
	category = list("Circuitry", "Core")

/datum/design/assembly_shell
	name = "Assembly Shell"
	desc = "An assembly shell that can be attached to wires and other assemblies."
	id = "assembly_shell"
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 5000)
	build_path = /obj/item/assembly/wiremod
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list("Circuitry", "Shells")

/datum/design/mod_module_shell
	name = "MOD Module Shell"
	desc = "A module shell that allows a circuit to be inserted into, and interface with, a MODsuit."
	id = "module_shell"
	materials = list(/datum/material/glass = 2000)
	build_path = /obj/item/mod/module/circuit
	build_type = MECHFAB | COMPONENT_PRINTER
	category = list("MOD Modules", "Shells")

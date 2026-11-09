/datum/design/wiremod_shell
	abstract_type = /datum/design/wiremod_shell
	build_type = COMPONENT_PRINTER
	category = list(
		RND_CATEGORY_CIRCUITRY_SHELLS
	)

/datum/design/wiremod_shell/compact_remote
	name = "Compact Remote Shell"
	desc = "A handheld shell with one big button."
	build_path = /obj/item/compact_remote
	materials = list(/datum/material/glass =SHEET_MATERIAL_AMOUNT, /datum/material/iron =SHEET_MATERIAL_AMOUNT * 2.5)

/datum/design/wiremod_shell/controller
	name = "Controller Shell"
	desc = "A handheld shell with several buttons."
	build_path = /obj/item/controller
	materials = list(/datum/material/glass =SHEET_MATERIAL_AMOUNT, /datum/material/iron = SHEET_MATERIAL_AMOUNT*3.5)

/datum/design/wiremod_shell/scanner
	name = "Scanner Shell"
	desc = "A handheld scanner shell that can scan entities."
	build_path = /obj/item/wiremod_scanner
	materials = list(/datum/material/glass =SHEET_MATERIAL_AMOUNT, /datum/material/iron = SHEET_MATERIAL_AMOUNT*3.5)

/datum/design/wiremod_shell/keyboard
	name = "Keyboard Shell"
	desc = "A handheld shell that allows the user to input a string"
	build_path = /obj/item/keyboard_shell
	materials = list(/datum/material/glass =SHEET_MATERIAL_AMOUNT, /datum/material/iron = SHEET_MATERIAL_AMOUNT*5)

/datum/design/wiremod_shell/gun
	name = "Gun Shell"
	desc = "A handheld shell that can fire projectiles to output entities."
	build_path = /obj/item/gun/energy/wiremod_gun
	materials = list(/datum/material/glass =SHEET_MATERIAL_AMOUNT, /datum/material/iron = SHEET_MATERIAL_AMOUNT*5, /datum/material/plasma =SMALL_MATERIAL_AMOUNT)

/datum/design/wiremod_shell/bot
	name = "Bot Shell"
	desc = "An immobile shell that can store more components. Has a USB port to be able to connect to computers and machines."
	build_path = /obj/item/shell/bot
	materials = list(/datum/material/glass =SHEET_MATERIAL_AMOUNT, /datum/material/iron = SHEET_MATERIAL_AMOUNT*5)

/datum/design/wiremod_shell/money_bot
	name = "Money Bot Shell"
	desc = "An immobile shell that is similar to a regular bot shell, but accepts monetary inputs and can also dispense money."
	build_path = /obj/item/shell/money_bot
	materials = list(/datum/material/glass =SHEET_MATERIAL_AMOUNT, /datum/material/iron = SHEET_MATERIAL_AMOUNT*5, /datum/material/gold =SMALL_MATERIAL_AMOUNT*0.5)

/datum/design/wiremod_shell/drone
	name = "Drone Shell"
	desc = "A shell with the ability to move itself around."
	build_path = /obj/item/shell/drone
	materials = list(
		/datum/material/glass =SHEET_MATERIAL_AMOUNT,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT*5.5,
		/datum/material/gold =SMALL_MATERIAL_AMOUNT*5,
	)

/datum/design/wiremod_shell/server
	name = "Server Shell"
	desc = "A very large shell that cannot be moved around. Stores the most components."
	materials = list(
		/datum/material/glass =SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT*7.5,
		/datum/material/gold =HALF_SHEET_MATERIAL_AMOUNT * 1.5,
	)
	build_path = /obj/item/shell/server

/datum/design/wiremod_shell/airlock
	name = "Airlock Shell"
	desc = "A door shell that cannot be moved around when assembled."
	materials = list(
		/datum/material/glass =SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT*7.5,
	)
	build_path = /obj/item/shell/airlock

/datum/design/wiremod_shell/dispenser
	name = "Dispenser Shell"
	desc = "A dispenser shell that can dispense items."
	materials = list(
		/datum/material/glass =SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT*7.5,
	)
	build_path = /obj/item/shell/dispenser

/datum/design/wiremod_shell/bci
	name = "Brain-Computer Interface Shell"
	desc = "An implant that can be placed in a user's head to control circuits using their brain."
	materials = list(
		/datum/material/glass =SHEET_MATERIAL_AMOUNT,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT*4,
	)
	build_path = /obj/item/shell/bci

/datum/design/wiremod_shell/scanner_gate
	name = "Scanner Gate Shell"
	desc = "A scanner gate shell that performs mid-depth scans on people when they pass through it."
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT*2,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT*6,
	)
	build_path = /obj/item/shell/scanner_gate

/datum/design/wiremod_shell/assembly
	name = "Assembly Shell"
	desc = "An assembly shell that can be attached to wires and other assemblies."
	materials = list(/datum/material/glass =SHEET_MATERIAL_AMOUNT, /datum/material/iron =SHEET_MATERIAL_AMOUNT * 2.5)
	build_path = /obj/item/assembly/wiremod

/datum/design/wiremod_shell/mod_module
	name = "MOD Module Shell"
	desc = "A module shell that allows a circuit to be inserted into, and interface with, a MODsuit."
	materials = list(/datum/material/glass =SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/mod/module/circuit

/datum/design/wiremod_shell/undertile
	name = "Under-tile Shell"
	desc = "A small shell that can fit under the floor."
	materials = list(
		/datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*2.5,
	)
	build_path = /obj/item/undertile_circuit


/datum/design/wiremod_shell/wallmount
	name = "Wall-mounted Shell"
	desc = "A large shell that can be mounted on a wall."
	materials = list(
		/datum/material/glass=SHEET_MATERIAL_AMOUNT,
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*5,
	)
	build_path = /obj/item/wallframe/circuit

/datum/design/wiremod_shell/implant
	name = "Implant Shell Case"
	desc = "A tiny shell that can be implanted in a living being."
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 5,
	)
	transfered_materials = list(
		/obj/item/implantcase/circuit = /obj/item/implantcase/circuit::custom_materials,
		/obj/item/implant/circuit = /obj/item/implant/circuit::custom_materials,
	)
	build_path = /obj/item/implantcase/circuit

//This design has a different path but it's still a wiremod design.
/datum/design/board/bci_implanter
	name = "Brain-Computer Interface Manipulation Chamber"
	desc = "A machine that, when given a brain-computer interface, will implant it into an occupant. Otherwise, will remove any brain-computer interfaces they already have."
	build_path = /obj/item/circuitboard/machine/bci_implanter
	build_type = COMPONENT_PRINTER
	category = list(
		RND_CATEGORY_CIRCUITRY_SHELLS
	)

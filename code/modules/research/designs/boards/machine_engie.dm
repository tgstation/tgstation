//Engineering related machinery boards.

//
//POWER STUFF
//

/datum/design/smes
	name = "Circuit Design (SMES) "
	desc = "Allows for the construction of circuit boards used to build SMES Power Storage Units."
	id="smes"
	req_tech = list("powerstorage" = 4, "engineering" = 4, "programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/smes

/datum/design/cell_charger
	name = "Circuit Design (Cell Charger)"
	desc = "Allows for the construction of circuit boards used to build a cell charger"
	id = "cellcharger"
	req_tech = list("materials" = 2, "engineering" = 2, "powerstorage" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/cell_charger

//
//P.A.C.M.A.N
//

/datum/design/pacman
	name = "PACMAN-type Generator Board"
	desc = "The circuit board that for a PACMAN-type portable generator."
	id = "pacman"
	req_tech = list("programming" = 3, "plasmatech" = 3, "powerstorage" = 3, "engineering" = 3)
	build_type = IMPRINTER
	reliability_base = 79
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/pacman

/datum/design/superpacman
	name = "SUPERPACMAN-type Generator Board"
	desc = "The circuit board that for a SUPERPACMAN-type portable generator."
	id = "superpacman"
	req_tech = list("programming" = 3, "powerstorage" = 4, "engineering" = 4)
	build_type = IMPRINTER
	reliability_base = 76
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/pacman/super

/datum/design/mrspacman
	name = "MRSPACMAN-type Generator Board"
	desc = "The circuit board that for a MRSPACMAN-type portable generator."
	id = "mrspacman"
	req_tech = list("programming" = 3, "powerstorage" = 5, "engineering" = 5)
	build_type = IMPRINTER
	reliability_base = 74
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/pacman/mrs

//
//ATMOSPHERIC MACHINERY.
//

/datum/design/freezer
	name = "Circuit Design (Freezer)"
	desc = "Allows for the construction of circuit boards to build freezers."
	id = "freezer"
	req_tech = list("powerstorage" = 3, "engineering" = 4, "biotech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/freezer

/datum/design/heater
	name = "Circuit Design (Heater)"
	desc = "Allows for the construction of circuit boards to build heaters."
	id ="heater"
	req_tech = list("powerstorage" = 3, "engineering" = 5, "biotech"= 4)
	build_type = IMPRINTER
	materials = list (MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/heater

/datum/design/pipedispenser
	name = "Circuit Design (Pipe Dispenser)"
	desc = "Allows for the construction of circuit boards used to build a Pipe Dispenser."
	id = "pipedispenser"
	req_tech = list("programming" = 3, "materials" = 3,"engineering" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/pipedispenser

/datum/design/pipedispenser/disposal
	name = "Circuit Design (Disposal Pipe Dispenser)"
	desc = "Allows for the construction of circuit boards used to build a Pipe Dispenser."
	id = "dpipedispenser"
	req_tech = list("programming" = 3, "materials" = 3,"engineering" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/pipedispenser/disposal

//
//MECHANICS MACHINES.
//

/datum/design/reverse_engine
	name = "Circuit Design (Reverse Engine)"
	desc = "Allows for the construction of circuit boards used to build a Reverse Engine."
	id = "reverse_engine"
	req_tech = list("materials" = 6, "programming" = 4, "engineering"= 3, "bluespace"= 3, "powerstorage" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/reverse_engine

/datum/design/blueprinter
	name = "Circuit Design (Blueprint Printer)"
	desc = "Allows for the construction of circuit boards used to build a Blueprint Printer."
	id = "blueprinter"
	req_tech = list("engineering" = 3, "programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/blueprinter

/datum/design/general_fab
	name = "Circuit Design (General Fabricator)"
	desc = "Allows for the construction of circuit boards used to build a General Fabricator."
	id = "gen_fab"
	req_tech = list("materials" = 3, "engineering" = 2, "programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/generalfab

/datum/design/flatpacker
	name = "Circuit Design (Flatpack Fabricator)"
	desc = "Allows for the construction of circuit boards used to build a Flatpack Fabricator."
	id = "flatpacker"
	req_tech = list("materials" = 5, "engineering" = 4, "powerstorage" = 3, "programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/flatpacker

//BEAMS.

/datum/design/prism
	name = "Circuit Design (Optical Prism)"
	desc = "Allows for the construction of circuit boards used to build an optical Prism"
	id = "prism"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/prism


//Science related computer & console boards.

/datum/design/robocontrol
	name = "Circuit Design (Robotics Control Console)"
	desc = "Allows for the construction of circuit boards used to build a Robotics Control console."
	id = "robocontrol"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/robotics

/datum/design/mechacontrol
	name = "Circuit Design (Exosuit Control Console)"
	desc = "Allows for the construction of circuit boards used to build an exosuit control console."
	id = "mechacontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/mecha_control

/datum/design/mechapower
	name = "Circuit Design (Mech Bay Power Control Console)"
	desc = "Allows for the construction of circuit boards used to build a mech bay power control console."
	id = "mechapower"
	req_tech = list("programming" = 2, "powerstorage" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/mech_bay_power_console

/datum/design/rdconsole
	name = "Circuit Design (Core R&D Console)"
	desc = "Allows for the construction of circuit boards used to build a new R&D console."
	id = "rdconsole_core"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/rdconsole

/datum/design/rdconsole/robotics
	name = "Circuit Design (Robotics R&D Console)"
	id = "rdconsole_robotics"
	build_path = /obj/item/weapon/circuitboard/rdconsole/robotics

/datum/design/rdconsole/mechanic
	name = "Circuit Design (Mechanic R&D Console)"
	id = "rdconsole_mechanic"
	build_path = /obj/item/weapon/circuitboard/rdconsole/mechanic

/datum/design/rdconsole/mommi
	name = "Circuit Design (MoMMI R&D Console)"
	id = "rdconsole_mommi"
	build_path = /obj/item/weapon/circuitboard/rdconsole/mommi

/datum/design/rdconsole/pod
	name = "Circuit Design (Pod Bay R&D Console)"
	id = "rdconsole_pod"
	build_path = /obj/item/weapon/circuitboard/rdconsole/pod

/datum/design/aifixer
	name = "Circuit Design (AI Integrity Restorer)"
	desc = "Allows for the construction of circuit boards used to build an AI Integrity Restorer."
	id = "aifixer"
	req_tech = list("programming" = 3, "biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/aifixer

/datum/design/bhangmeter
	name = "Circuit Design (Bhangmeter)"
	desc = "Allows for the construction of circuit boards used to build a bhangmeter."
	id = "bhangmeter"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/bhangmeter

/datum/design/rdservercontrol
	name = "Circuit Design(R&D Server Control Console)"
	desc = "The circuit board for a R&D Server Control Console"
	id = "rdservercontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/rdservercontrol

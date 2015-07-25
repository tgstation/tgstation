//Command related machinery.

/datum/design/aicore
	name = "Circuit Design (AI Core)"
	desc = "Allows for the construction of circuit boards used to build new AI cores."
	id = "aicore"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/aicore
	locked = 1
	req_lock_access = list(access_tox, access_robotics, access_rd)

/datum/design/pdapainter
	name = "PDA Painter Board"
	desc = "The circuit board for a PDA Painter."
	id = "pdapainter"
	req_tech = list("programming" = 3, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/pdapainter

/datum/design/telehub
	name = "Circuit Design (Teleporter Hub)"
	desc = "Allows for the construction of circuit boards used to build a Teleporter Hub"
	id = "telehub"
	req_tech = list("programming" = 4, "engineering"=3, "bluespace" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/telehub

/datum/design/telestation
	name = "Circuit Design (Teleporter Station)"
	desc = "Allows for the construction of circuit boards used to build a Teleporter Station."
	id = "telestation"
	req_tech = list("programming" = 4, "engineering" = 3, "bluespace" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Machine Boards"
	build_path = /obj/item/weapon/circuitboard/telestation

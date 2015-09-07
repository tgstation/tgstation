//Security related computers & consoles.

/datum/design/seccamera
	name = "Circuit Design (Security Cameras)"
	desc = "Allows for the construction of circuit boards used to build security camera computers."
	id = "seccamera"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/security

/datum/design/advseccamera
	name = "Circuit Design (Advanced Security Cameras)"
	desc = "Allows for the construction of circuit boards used to build advanced security camera computers."
	id = "advseccamera"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/security/advanced

/datum/design/secdata
	name = "Circuit Design (Security Records Console)"
	desc = "Allows for the construction of circuit boards used to build a security records console."
	id = "secdata"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/secure_data

/datum/design/prisonmanage
	name = "Circuit Design (Prisoner Management Console)"
	desc = "Allows for the construction of circuit boards used to build a prisoner management console."
	id = "prisonmanage"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Console Boards"
	build_path = /obj/item/weapon/circuitboard/prisoner

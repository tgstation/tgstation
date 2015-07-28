/datum/design/safeguard_module
	name = "Module Design (Safeguard)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "safeguard_module"
	req_tech = list("programming" = 3, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20, MAT_GOLD = 100)
	category = "Module Boards"
	build_path = /obj/item/weapon/aiModule/targetted/safeguard

/datum/design/onehuman_module
	name = "Module Design (OneHuman)"
	desc = "Allows for the construction of a OneHuman AI Module."
	id = "onehuman_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20, MAT_DIAMOND = 100)
	category = "Module Boards"
	build_path = /obj/item/weapon/aiModule/targetted/oneHuman
	locked = 1
	req_lock_access = list(access_captain)

/datum/design/protectstation_module
	name = "Module Design (ProtectStation)"
	desc = "Allows for the construction of a ProtectStation AI Module."
	id = "protectstation_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20, MAT_GOLD = 100)
	category = "Module Boards"
	build_path = /obj/item/weapon/aiModule/standard/protectStation

/datum/design/notele_module
	name = "Module Design (TeleporterOffline Module)"
	desc = "Allows for the construction of a TeleporterOffline AI Module."
	id = "notele_module"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20, MAT_GOLD = 100)
	category = "Module Boards"
	build_path = /obj/item/weapon/aiModule/standard/teleporterOffline

/datum/design/quarantine_module
	name = "Module Design (Quarantine)"
	desc = "Allows for the construction of a Quarantine AI Module."
	id = "quarantine_module"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20, MAT_GOLD = 100)
	category = "Module Boards"
	build_path = /obj/item/weapon/aiModule/standard/quarantine

/datum/design/oxygen_module
	name = "Module Design (OxygenIsToxicToHumans)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "oxygen_module"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20, MAT_GOLD = 100)
	category = "Module Boards"
	build_path = /obj/item/weapon/aiModule/standard/oxygen
	locked = 1
	req_lock_access = list(access_captain)

/datum/design/freeform_module
	name = "Module Design (Freeform)"
	desc = "Allows for the construction of a Freeform AI Module."
	id = "freeform_module"
	req_tech = list("programming" = 4, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20, MAT_GOLD = 100)
	category = "Module Boards"
	build_path = /obj/item/weapon/aiModule/freeform

/datum/design/reset_module
	name = "Module Design (Reset)"
	desc = "Allows for the construction of a Reset AI Module."
	id = "reset_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20, MAT_GOLD = 100)
	category = "Module Boards"
	build_path = /obj/item/weapon/aiModule/reset

/datum/design/purge_module //tempted to lock this, have a vote on it - Comic
	name = "Module Design (Purge)"
	desc = "Allows for the construction of a Purge AI Module."
	id = "purge_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20, MAT_DIAMOND = 100)
	category = "Module Boards"
	build_path = /obj/item/weapon/aiModule/purge

/datum/design/freeformcore_module
	name = "Core Module Design (Freeform)"
	desc = "Allows for the construction of a Freeform AI Core Module."
	id = "freeformcore_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20, MAT_DIAMOND = 100)
	category = "Module Boards"
	build_path = /obj/item/weapon/aiModule/freeform/core

/datum/design/asimov
	name = "Core Module Design (Asimov)"
	desc = "Allows for the construction of a Asimov AI Core Module."
	id = "asimov_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20, MAT_DIAMOND = 100)
	category = "Module Boards"
	build_path = /obj/item/weapon/aiModule/core/asimov

/datum/design/paladin_module
	name = "Core Module Design (P.A.L.A.D.I.N.)"
	desc = "Allows for the construction of a P.A.L.A.D.I.N. AI Core Module."
	id = "paladin_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20, MAT_DIAMOND = 100)
	category = "Module Boards"
	build_path = /obj/item/weapon/aiModule/core/paladin

/datum/design/tyrant_module
	name = "Core Module Design (T.Y.R.A.N.T.)"
	desc = "Allows for the construction of a T.Y.R.A.N.T. AI Module."
	id = "tyrant_module"
	req_tech = list("programming" = 4, "syndicate" = 2, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20, MAT_DIAMOND = 100)
	category = "Module Boards"
	build_path = /obj/item/weapon/aiModule/core/tyrant
	locked = 1
	req_lock_access = list(access_captain)

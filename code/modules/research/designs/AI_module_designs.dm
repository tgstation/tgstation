///////////////////////////////////
//////////AI Module Disks//////////
///////////////////////////////////

datum/design/safeguard_module
	name = "AI Module(Safeguard)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "safeguard_module"
	req_tech = list("programming" = 3, "materials" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/supplied/safeguard

datum/design/onehuman_module
	name = "AI Module (OneHuman)"
	desc = "Allows for the construction of a OneHuman AI Module."
	id = "onehuman_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/zeroth/oneHuman

datum/design/protectstation_module
	name = "AI Module (ProtectStation)"
	desc = "Allows for the construction of a ProtectStation AI Module."
	id = "protectstation_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/supplied/protectStation

datum/design/quarantine_module
	name = "AI Module (Quarantine)"
	desc = "Allows for the construction of a Quarantine AI Module."
	id = "quarantine_module"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/supplied/quarantine

datum/design/oxygen_module
	name = "AI Module (OxygenIsToxicToHumans)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "oxygen_module"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/supplied/oxygen

datum/design/freeform_module
	name = "AI Module (Freeform)"
	desc = "Allows for the construction of a Freeform AI Module."
	id = "freeform_module"
	req_tech = list("programming" = 4, "materials" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/supplied/freeform

datum/design/reset_module
	name = "AI Module (Reset)"
	desc = "Allows for the construction of a Reset AI Module."
	id = "reset_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/reset

datum/design/purge_module
	name = "AI Module (Purge)"
	desc = "Allows for the construction of a Purge AI Module."
	id = "purge_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/reset/purge

datum/design/freeformcore_module
	name = "AI Core Module (Freeform)"
	desc = "Allows for the construction of a Freeform AI Core Module."
	id = "freeformcore_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/freeformcore

datum/design/asimov
	name = "AI Core Module (Asimov)"
	desc = "Allows for the construction of a Asimov AI Core Module."
	id = "asimov_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/full/asimov

datum/design/paladin_module
	name = "AI Core Module (P.A.L.A.D.I.N.)"
	desc = "Allows for the construction of a P.A.L.A.D.I.N. AI Core Module."
	id = "paladin_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/full/paladin

datum/design/tyrant_module
	name = "AI Core Module (T.Y.R.A.N.T.)"
	desc = "Allows for the construction of a T.Y.R.A.N.T. AI Module."
	id = "tyrant_module"
	req_tech = list("programming" = 4, "syndicate" = 2, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/full/tyrant

datum/design/corporate_module
	name = "AI Core Module (Corporate)"
	desc = "Allows for the construction of a Corporate AI Core Module."
	id = "corporate_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/full/corp

datum/design/custom_module
	name = "AI Core Module (Custom)"
	desc = "Allows for the construction of a Custom AI Core Module."
	id = "custom_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/full/custom
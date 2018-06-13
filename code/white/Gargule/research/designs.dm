/datum/design/cyberimp_surgical_alien
	name = "Alien Surgical Implant"
	desc = "A set of alien surgical tools hidden behind a concealed panel on the user's arm."
	id = "ci-aliensurgery"
	build_type = PROTOLATHE | MECHFAB
	materials = list (MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/surgery/alien
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/circular_saw_folding
	name = "Folding Bone Saw"
	id = "circular_saw_folding"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/circular_saw/folding
	category = list("initial", "Medical")

/datum/design/optable_folding
	name = "Folding Table"
	id = "optable_folding"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/optable
	category = list("initial", "Medical")

/datum/design/cyberimp_science_hud
	name = "Science HUD Implant"
	desc = "Cybernetic eye implants with an analyzer for scanning items and reagents."
	id = "ci-scihud"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/cyberimp/eyes/hud/science
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_diagnostic_hud
	name = "Diagnostic HUD Implant"
	desc = "A heads-up display capable of analyzing the integrity and status of robotics and exosuits."
	id = "ci-diaghud"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/cyberimp/eyes/hud/diagnostic
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
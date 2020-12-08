/datum/design/cyberimp_mantis
	name = "Mantis Blade Implant"
	desc = "A long, sharp, mantis-like blade installed within the forearm, acting as a deadly self defense weapon."
	id = "ci-mantis"
	build_type = MECHFAB
	materials = list (/datum/material/iron = 3500, /datum/material/glass = 1500, /datum/material/silver = 1500)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/armblade
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/cyberimp_hacker
	name = "Hacking Hand Implant"
	desc = "An advanced hacking and machine modification toolkit fitted into an arm implant, designed to be installed on a subject's arm."
	id = "ci-hacker"
	build_type = MECHFAB
	materials = list (/datum/material/iron = 3500, /datum/material/glass = 1500, /datum/material/silver = 1500)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/hacker
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/cyberimp_flash
	name = "Photon Projector Implant"
	desc = "An integrated projector mounted onto a user's arm that is able to be used as a powerful flash."
	id = "ci-flash"
	build_type = MECHFAB
	materials = list (/datum/material/iron = 3500, /datum/material/glass = 1500, /datum/material/silver = 1500)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/flash
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/cyberimp_botany
	name = "Botany Arm Implant"
	desc = "Everything a botanist needs in an arm implant, designed to be installed on a subject's arm."
	id = "ci-botany"
	build_type = MECHFAB | PROTOLATHE
	materials = list (/datum/material/iron = 3500, /datum/material/glass = 1500, /datum/material/silver = 1500, /datum/material/plastic = 2000)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/botany
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_NV
	name = "Night Vision Eyes"
	desc = "These cybernetic eyes will give you Night Vision. Big, mean, and green."
	id = "ci-nv"
	build_type = MECHFAB | PROTOLATHE
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 600, /datum/material/gold = 600, /datum/material/uranium = 1000,)
	build_path = /obj/item/organ/eyes/night_vision/cyber
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_antisleep
	name = "CNS Jumpstarter Implant"
	desc = "This implant will automatically attempt to jolt you awake from unconsciousness, with a short cooldown between jolts. Conflicts with the CNS Rebooter."
	id = "ci-antisleep"
	build_type = MECHFAB | PROTOLATHE
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 1000, /datum/material/gold = 500)
	build_path = /obj/item/organ/cyberimp/brain/anti_sleep
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_scanner
	name = "Internal Medical Analyzer"
	desc = "This implant interfaces with a host's body, sending detailed readouts of the vessel's condition on command via the mind."
	id = "ci-scanner"
	build_type = MECHFAB | PROTOLATHE
	construction_time = 40
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500, /datum/material/silver = 2000, /datum/material/gold = 1500)
	build_path = /obj/item/organ/cyberimp/chest/scanner
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberlink_nt_low
	name = "NT Cyberlink 1.0"
	desc = "Allows for synchronization of basic cybernetic mechanisms."
	id = "ci-nt_low"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 8 SECONDS
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 2000, /datum/material/silver = 1000)
	build_path = /obj/item/organ/internal/cyberimp/cyberlink/nt_low
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/cyberlink_nt_high
	name = "NT Cyberlink 2.0"
	desc = "Allows for synchronization of advanced cybernetic mechanisms."
	id = "ci-nt_high"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 8 SECONDS
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 4000, /datum/material/silver = 2000 , /datum/material/gold = 2000)
	build_path = /obj/item/organ/internal/cyberimp/cyberlink/nt_high
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_TOOLS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

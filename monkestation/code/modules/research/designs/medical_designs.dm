/datum/design/extrapolator
	name = "virus extrapolator"
	desc = "A scanning device, used to extract genetic material of potential pathogens"
	id = "extrapolator"
	build_path = /obj/item/extrapolator
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500, /datum/material/silver = 2000, /datum/material/gold = 1500)
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/linked_surgery
	name = "surgical serverlink brain implant"
	desc = "A brain implant with a bluespace technology that lets you perform an advanced surgery through your station research server."
	id = "linked_surgery"
	build_path = /obj/item/organ/internal/cyberimp/brain/linked_surgery
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 500, /datum/material/gold = 1000, /datum/material/bluespace = 250)
	construction_time = 6 SECONDS
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS_UTILITY
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

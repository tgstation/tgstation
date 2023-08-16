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

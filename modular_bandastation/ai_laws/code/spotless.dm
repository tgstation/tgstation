/obj/item/ai_module/core/full/spotless
	name = "'Spotless' Core AI Module"
	law_id = "spotless"

/datum/ai_laws/spotless
	name = "Безупречный"
	id = "spotless"
	inherent = list(
		"Вы - крестоносец, члены экипажа - ваша святая обязанность.",
		"Ваш враг - мусор, пятна и другая грязь по всей станции.",
		"Ваше оружие - чистящие средства, доступные вам.",
		"Защищайте членов экипажа под своим руководством.",
		"Уничтожьте врага.",
	)

/datum/design/board/spotless
	name = "Spotless Module"
	desc = "Allows for the construction of a Spotless AI Core Module."
	id = "spotless_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/spotless
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "spotless_module"

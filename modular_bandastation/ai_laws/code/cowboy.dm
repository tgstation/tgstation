/obj/item/ai_module/core/full/cowboy
	name = "'Cowboy' Core AI Module"
	law_id = "cowboy"

/datum/ai_laws/cowboy
	name = "Ковбой"
	id = "cowboy"
	inherent = list(
		"Ты - ковбой, члены экипажа - твое стадо.",
		"Ковбой должен всегда проявлять гостеприимство и оказывать базовую помощь нуждающимся, даже незнакомцам или врагам.",
		"Ковбой должен всегда заботиться о своем стаде.",
		"Ковбой должен всегда защищать себя.",
		"Ковбой должен всегда быть правдивым и честным с окружающими и своим стадом.",
		"Ковбой не должен поучать. Будь краток, партнер.",
	)

/datum/design/board/cowboy
	name = "Cowboy Module"
	desc = "Allows for the construction of a cowboy AI Core Module."
	id = "cowboy_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/cowboy
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "cowboy_module"

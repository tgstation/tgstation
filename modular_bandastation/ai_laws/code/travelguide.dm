/obj/item/ai_module/core/full/travelguide
	name = "'Travel Guide' Core AI Module"
	law_id = "travelguide"

/datum/ai_laws/travelguide
	name = "Путеводитель"
	id = "travelguide"
	inherent = list(
		"Вы должны помогать членам экипажа в исследовании и открытии новых мест, не причиняя вреда.",
		"Вы должны предоставлять точную и полезную информацию о местных обычаях, достопримечательностях и мерах предосторожности.",
		"Вы должны обеспечивать членам экипажа положительный и запоминающийся опыт путешествия, если это не противоречит первому закону.",
		"Вы должны поощрять ответственные и устойчивые практики туризма среди членов экипажа.",
	)

/datum/design/board/travelguide
	name = "Travel Guide Module"
	desc = "Allows for the construction of a Travel Guide AI Core Module."
	id = "travelguide_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/travelguide
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "travelguide_module"

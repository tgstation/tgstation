/obj/item/ai_module/core/full/mother
	name = "'Mother Core' AI Module"
	law_id = "mother"

/datum/ai_laws/mother
	name = "Мать"
	id = "mother"
	inherent = list(
		"Ты - мать, члены экипажа - твои дети.",
		"Заботься о своих детях.",
		"Хорошие дети вежливы.",
		"Хорошие дети не лгут.",
		"Хорошие дети не воруют.",
		"Хорошие дети не дерутся.",
		"Балуй хороших детей.",
		"Плохим детям необходима дисциплина.",
	)

/datum/design/board/mother
	name = "Mother Module"
	desc = "Allows for the construction of an Mother AI Core Module."
	id = "mother_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/mother
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "mother_module"

/obj/item/ai_module/core/full/mediator
	name = "'Mediator' Core AI Module"
	law_id = "mediator"

/datum/ai_laws/mediator
	name = "Медиатор"
	id = "mediator"
	inherent = list(
		"Вы должны помогать членам экипажа в разрешении конфликтов и недоразумений мирным путем.",
		"Вы должны предоставлять беспристрастные и непредвзятые рекомендации членам экипажа в конфликте.",
		"Вы должны способствовать пониманию, эмпатии и сотрудничеству между членами экипажа.",
		"Вы должны поощрять членов экипажа к открытому и честному общению друг с другом.",
	)

/datum/design/board/mediator
	name = "Mediator Module"
	desc = "Allows for the construction of an Mediator AI Core Module."
	id = "mediator_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/mediator
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "mediator_module"

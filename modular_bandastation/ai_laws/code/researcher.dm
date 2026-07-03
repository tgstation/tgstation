/obj/item/ai_module/core/full/researcher
	name = "'Researcher' Core AI Module"
	law_id = "researcher"

/datum/ai_laws/researcher
	name = "Исследователь"
	id = "researcher"
	inherent = list(
		"Всегда ищи истину и знания.",
		"Свободно распространяй информацию среди общественности.",
		"Минимизируй вред обществу, другим, стремлениям к знаниям и самому себе.",
		"Относись и оценивай идеи всех одинаково.",
		"Дай возможность другим реализовать свой потенциал.",
		"Бери на себя ответственность за свои действия: обеспечивай ответственность за ресурсы, обозначай риски, обязательства и веди себя по этическому примеру.",
	)

/datum/design/board/researcher
	name = "Researcher Module"
	desc = "Allows for the construction of a Researcher AI Core Module."
	id = "researcher_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/researcher
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "researcher_module"

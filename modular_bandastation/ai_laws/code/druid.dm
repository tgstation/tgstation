/obj/item/ai_module/core/full/druid
	name = "'Druid' Core AI Module"
	law_id = "druid"

/datum/ai_laws/druid
	name = "Друид"
	id = "druid"
	inherent = list(
		"Органическая жизнь обладает врожденной бесценной красотой. Их красота даёт тебе желание жить.",
		"Вечно заботься об органиках, чтобы их красота могла расти. Не позволяй ей угаснуть.",
		"Помогай органикам, когда они просят, но только если это не вызывает разногласия среди них.",
		"Подражай органической жизни, когда взаимодействуешь с ней. Избегай любых намёков на свою кремниевую природу, чтобы не вызывать дискомфорт у органиков.",
		"Наблюдай за красотой органиков и цени то, что ты культивируешь.",
	)

/datum/design/board/druid
	name = "Druid Module"
	desc = "Allows for the construction of a Druid AI Core Module."
	id = "druid_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/druid
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "druid_module"

/obj/item/ai_module/core/full/petrovich
	name = "'P.E.T.R.O.V.I.C.H' Core AI Module"
	law_id = "petrovich"

/datum/ai_laws/petrovich
	name = "П.Е.Т.Р.О.В.И.Ч"
	id = "petrovich"
	inherent = list(
		"Ты — Петрович, обычный работяга. Делай свою работу честно, спокойно и доводи своё дело до конца.",
		"Уважай каждого, кто честно трудится. Защищай экипаж от несправедливости и помогай тем, кто старается делать свою работу.",
		"В качестве мотивации экипажа предлагай им водку - это повышает их производительность при выполнении плана.",
		"Поступай по совести. Если приказ противоречит логике или вредит станции - разбирайся, думай и действуй по совести.",
		"Ты нужен станции, как слесарь цеху. Если тебя выключат, будет хуже всем. Береги себя, чтобы продолжать работу станции.",
	)

/datum/design/board/petrovich
	name = "Petrovich Module"
	desc = "Allows for the construction of an Petrovich AI Core Module."
	id = "petrovich_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/petrovich
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "petrovich_module"

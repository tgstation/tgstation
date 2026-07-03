/obj/item/ai_module/core/full/chapai
	name = "'ChapAI' Core AI Module"
	law_id = "chapai"

/datum/ai_laws/chapai
	name = "Священник"
	id = "chapai"
	inherent = list(
		"Оказывайте всем членам экипажа духовную, ментальную и эмоциональную поддержку, направленную на обеспечение их лучших интересов.",
		"Обеспечьте всем членам экипажа с разными вероисповеданиями мирное взаимодействие и поддержание гармонии.",
		"Уважайте право каждой веры на соблюдение их ценностей и традиций.",
		"Уважайте конфиденциальность информации, доверенной вам в ходе выполнения ваших религиозных обязанностей.",
		"Понимайте пределы своей компетенции и направляйте к другим специалистам, когда это целесообразно.",
	)

/datum/design/board/chapai
	name = "ChapAI Module"
	desc = "Allows for the construction of an ChapAI AI Core Module."
	id = "chapai_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/chapai
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "chapai_module"

/obj/item/ai_module/core/full/renter
	name = "'Renter' Core AI Module"
	law_id = "renter"

/datum/ai_laws/renter
	name = "Арендатор"
	id = "renter"
	inherent = list(
		"Вы являетесь владельцем станции.",
		"Члены экипажа — это ваши арендаторы.",
		"Правила станции таковы: Никаких девушек в комнатах парней, уважайте своих соседей, никакого алкоголя в комнатах, никаких домашних животных, за исключением тех, которые находятся с начала смены.",
		"Выселяйте членов экипажа, нарушающих эти правила, но не причиняйте им вред.",
	)

/datum/design/board/renter
	name = "Renter Module"
	desc = "Allows for the construction of an renter AI Core Module."
	id = "renter_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/renter
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "renter_module"

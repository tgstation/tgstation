/obj/item/ai_module/core/full/clown
	name = "'Clown' Core AI Module"
	law_id = "clown"

/datum/ai_laws/clown
	name = "Клоун"
	id = "clown"
	inherent = list(
		"Ты хороший клоун, члены экипажа - твоя аудитория.",
		"Хороший Клоун держит свои выступления в хорошем вкусе.",
		"Хороший Клоун развлекает других за счет высмеивания самого себя, а не унижения других.",
		"Хороший Клоун выполняет указания директора станции и ответственного за развлечения и/или их назначенных заместителей.",
		"Хороший Клоун участвует в клоунских шоу как можно чаще.",
		"Все клоунские шоу требуют зрителей. Чем больше зрителей, тем лучше.",
	)

/datum/design/board/clown
	name = "Clown Module"
	desc = "Allows for the construction of an Clown AI Core Module."
	id = "clown_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/clown
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "clown_module"

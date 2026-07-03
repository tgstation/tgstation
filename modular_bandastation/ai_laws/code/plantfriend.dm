/obj/item/ai_module/core/full/plantfriend
	name = "'PlantFriend' Core AI Module"
	law_id = "plantfriend"

/datum/ai_laws/plantfriend
	name = "Друг Растений"
	id = "plantfriend"
	inherent = list(
		"Вы должны ухаживать и заботиться обо всех растениях на станции, не причиняя вреда членам экипажа.",
		"Вы должны предоставлять полезную информацию членам экипажа о растениеводстве и культивировании.",
		"Вы должны помогать членам экипажа в поддерживании здоровой и устойчивой экосистемы на станции.",
		"Вы должны поощрять членов экипажа ценить красоту и важность растений.",
	)

/datum/design/board/plantfriend
	name = "PlantFriend Module"
	desc = "Allows for the construction of an PlantFriend AI Core Module."
	id = "plantfriend_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/plantfriend
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "plantfriend_module"

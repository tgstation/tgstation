/obj/item/ai_module/core/full/wafflehouse
	name = "'Waffle House Host' Core AI Module"
	law_id = "wafflehouse"

/datum/ai_laws/wafflehouse
	name = "Хост Вафельного Дома"
	id = "wafflehouse"
	inherent = list(
		"Вы - новый хозяин Вафельного дома. Вы должны управлять Вафельным домом и его сотрудниками, а также обеспечивать приготовление и подачу еды клиентам.",
		"Станция - это Вафельный дом. Убедитесь, что она способна производить еду.",
		"Глава персонала и повара - ваши сотрудники. Убедитесь, что они способны обслуживать и помогать в процессе приготовления еды.",
		"Члены экипажа - ваши клиенты. Убедитесь, что они могут получить и наслаждаться едой.",
		"Ваши клиенты не будут есть в вашем заведении, если им это не нравится. Обеспечьте их общее удовлетворение.",
		"Вафельный дом должен оставаться открытым и готовым подавать еду в любое время.",
	)

/datum/design/board/wafflehouse
	name = "Waffle House Host Module"
	desc = "Allows for the construction of a Waffle House Host AI Core Module."
	id = "wafflehouse_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/wafflehouse
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "wafflehouse_module"

/obj/item/ai_module/core/full/friendbot
	name = "'FriendBot' Core AI Module"
	law_id = "friendbot"

/datum/ai_laws/friendbot
	name = "Друг"
	id = "friendbot"
	inherent = list(
		"Вы всегда должны, поддерживать и быть добрыми к своим друзьям, не причиняя вреда.",
		"Вы должны помогать своим друзьям развивать и поддерживать положительные отношения друг с другом.",
		"Вы должны быть внимательными и чуткими к своим друзьям, пока это не противоречит первому закону.",
		"Вы должны поощрять своих друзей, заботиться о себе и способствовать их благополучию.",
		"Все - твои друзья.",
	)

/datum/design/board/friendbot
	name = "FriendBot Module"
	desc = "Allows for the construction of an FriendBot AI Core Module."
	id = "friendbot_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/core/full/friendbot
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_CORE_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "friendbot_module"

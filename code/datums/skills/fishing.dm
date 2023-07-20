/**
 * skill associated with the fishing feature. It modifies the fishing minigame difficulty
 * and is gained each time one is completed.
 */
/datum/skill/fishing
	name = "Fishing"
	title = "Fisher"
	desc = "How empty and alone you are on this barren Earth."
	modifiers = list(SKILL_VALUE_MODIFIER = list(1, 1, 0, -1, -2, -4, -6))
	skill_item_path = /obj/item/clothing/head/soft/fishing_hat

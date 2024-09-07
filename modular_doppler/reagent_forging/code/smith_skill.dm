/datum/skill/smithing
	name = "Smithing"
	title = "Smithy"
	desc = "The desperate artist who strives after the flames of the forge."
	modifiers = list(
		SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.75, 0.6, 0.5),
		SKILL_PROBS_MODIFIER = list(10, 15, 20, 25, 30, 35, 40)
	)
	skill_item_path = /obj/item/clothing/neck/cloak/skill_reward/smithing

/obj/item/clothing/neck/cloak/skill_reward/smithing
	name = "legendary smithy's cloak"
	desc = "Worn by the most skilled smithies, this legendary cloak is only attainable by knowing every inch of the blacksmith's forge. \
	This status symbol represents a being who has forged some of the finest weapons and armors."
	icon = 'modular_doppler/reagent_forging/icons/obj/cloaks.dmi'
	worn_icon = 'modular_doppler/reagent_forging/icons/mob/neck.dmi'
	icon_state = "smithingcloak"
	associated_skill_path = /datum/skill/smithing

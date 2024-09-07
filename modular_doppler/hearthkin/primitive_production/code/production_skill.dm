/datum/skill/production
	name = "Production"
	title = "Producer"
	desc = "The artist who finds themselves using multiple mediums in which to express their creativity."
	modifiers = list(
		SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.75, 0.6, 0.5),
		SKILL_PROBS_MODIFIER = list(10, 15, 20, 25, 30, 35, 40)
	)
	skill_item_path = /obj/item/clothing/neck/cloak/skill_reward/production

/obj/item/clothing/neck/cloak/skill_reward/production
	name = "legendary producer's cloak"
	desc = "Worn by the most skilled producers, this legendary cloak is only attainable by knowing how to create the best products. \
	This status symbol represents a being who has crafted some of the finest glass and ceramic works."
	icon = 'modular_doppler/hearthkin/primitive_production/icons/cloaks.dmi'
	worn_icon = 'modular_doppler/hearthkin/primitive_production/icons/neck.dmi'
	icon_state = "productioncloak"
	associated_skill_path = /datum/skill/production

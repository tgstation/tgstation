/mob/living/basic/statue/mannequin
	name = "mannequin"
	desc = "Oh, so this is a dress-up game now."
	icon = 'icons/mob/human/mannequin.dmi'
	icon_state = "mannequin_wood_male"
	icon_living = "mannequin_wood_male"
	icon_dead = "mannequin_wood_male"
	health = 300
	maxHealth = 300
	melee_damage_lower = 15
	melee_damage_upper = 30
	status_flags = CANPUSH
	sentience_type = SENTIENCE_ARTIFICIAL
	ai_controller = /datum/ai_controller/basic_controller/stares_at_people
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)
	/// the path to a fake item we will hold in our right hand
	var/obj/item/held_item
	/// the path to a fake hat we will wear
	var/obj/item/hat

/mob/living/basic/statue/mannequin/Initialize(mapload)
	. = ..()
	update_appearance()

/mob/living/basic/statue/mannequin/update_overlays()
	. = ..()
	if(held_item)
		. += mutable_appearance(held_item::righthand_file, held_item::inhand_icon_state)
	if(hat)
		. += mutable_appearance(hat::worn_icon, hat::worn_icon_state || hat::post_init_icon_state || hat::icon_state)

/datum/ai_controller/basic_controller/stares_at_people
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/statue/stares_at_people.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 6,
	)

	ai_movement = /datum/ai_movement/dumb

/mob/living/basic/statue/mannequin/suspicious
	name = "mannequin?"
	desc = "Their eyes follow you."
	health = 1500 //yeah uhh avoid these
	maxHealth = 1500
	ai_controller = /datum/ai_controller/basic_controller/suspicious_mannequin

/datum/ai_controller/basic_controller/suspicious_mannequin
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/statue/suspicious_mannequin.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance

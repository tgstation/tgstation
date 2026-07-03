// MARK: Crocodile
/mob/living/basic/lizard/big/crocodile
	name = "crocodile"
	desc = "Клац, клац, клац. Острые зубки, толстая кожа - страшно!"
	icon = 'modular_bandastation/mobs/icons/crocodile.dmi'
	icon_state = "crocodile"
	icon_living = "crocodile"
	icon_dead = "crocodile_dead"
	pixel_x = -8
	pixel_y = -4
	base_pixel_x = -8
	base_pixel_y = -4
	gender = MALE
	butcher_results = list(/obj/item/food/meat/slab/human/mutant/lizard = 5)

	maxHealth = 250
	health = 250

	melee_damage_lower = 15
	melee_damage_upper = 15

	ai_controller = /datum/ai_controller/basic_controller/crocodile

/mob/living/basic/lizard/big/crocodile/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	AddElement(/datum/element/ridable, /datum/component/riding/creature/crocodile)

// Croco AI
/datum/ai_planning_subtree/random_speech/crocodile
	speech_chance = 5
	sound = list('sound/mobs/humanoids/lizard/lizard_hiss.ogg')
	emote_hear = list("рычит.", "хрипит.", "шипит.")
	emote_see = list("машет хвостом.", "широко раскрывает пасть.")

/datum/ai_controller/basic_controller/crocodile
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/go_for_swim,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/random_speech/crocodile,
	)

// Croco rideable
/datum/component/riding/creature/crocodile

/datum/component/riding/creature/crocodile/get_rider_offsets_and_layers(pass_index, mob/offsetter)
	return list(
		TEXT_NORTH = list( 0, 8),
		TEXT_SOUTH = list( 0, 8),
		TEXT_EAST =  list(-2, 8),
		TEXT_WEST =  list( 2, 8),
	)

/datum/component/riding/creature/crocodile/get_parent_offsets_and_layers()
	return list(
		TEXT_NORTH = list(0, 0, MOB_BELOW_PIGGYBACK_LAYER),
		TEXT_SOUTH = list(0, 0, MOB_BELOW_PIGGYBACK_LAYER),
		TEXT_EAST =  list(0, 0, MOB_BELOW_PIGGYBACK_LAYER),
		TEXT_WEST =  list(0, 0, MOB_BELOW_PIGGYBACK_LAYER),
	)

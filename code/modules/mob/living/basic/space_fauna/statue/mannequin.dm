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
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 6,
	)

	ai_movement = /datum/ai_movement/dumb
	idle_behavior = null
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/face_target_or_face_initial, // we be creepy and all
	)

/datum/ai_planning_subtree/face_target_or_face_initial

/datum/ai_planning_subtree/face_target_or_face_initial/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(isnull(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]))
		return
	var/mob/living/we = controller.pawn
	controller.blackboard[BB_STARTING_DIRECTION] = we.dir
	controller.queue_behavior(/datum/ai_behavior/face_target_or_face_initial, BB_BASIC_MOB_CURRENT_TARGET)

/datum/ai_behavior/face_target_or_face_initial

/datum/ai_behavior/face_target_or_face_initial/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/movable/target = controller.blackboard[target_key]
	return ismovable(target) && isturf(target.loc) && ismob(controller.pawn)

/datum/ai_behavior/face_target_or_face_initial/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/movable/target = controller.blackboard[target_key]
	var/mob/living/we = controller.pawn
	if(isnull(target) || get_dist(we, target) > 8)
		we.dir = controller.blackboard[BB_STARTING_DIRECTION]
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	we.face_atom(target)
	return AI_BEHAVIOR_DELAY

/mob/living/basic/statue/mannequin/suspicious
	name = "mannequin?"
	desc = "Their eyes follow you."
	health = 1500 //yeah uhh avoid these
	maxHealth = 1500
	ai_controller = /datum/ai_controller/basic_controller/suspicious_mannequin

/datum/ai_controller/basic_controller/suspicious_mannequin
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 14,
		BB_EMOTE_KEY = "scream", //spooky
	)

	ai_movement = /datum/ai_movement/jps //threat
	idle_behavior = null
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/run_emote,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

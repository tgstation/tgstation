/// moonicorn subtype, very hostile unless there's some food to be eatin'
/mob/living/basic/cow/moonicorn
	name = "moonicorn"
	desc = "Magical cow of legend. Its horn will pacify anything it touches, rendering victims mostly helpless. \
		Victims, yes, because despite the enimatic and wonderous appearance, the moonicorn is incredibly aggressive."
	icon_state = "moonicorn"
	icon_living = "moonicorn"
	icon_dead = "moonicorn_dead"
	icon_gib = null //otherwise does the regular cow gib animation
	faction = list(FACTION_HOSTILE)
	speed = 1
	melee_damage_lower = 25
	melee_damage_upper = 25
	obj_damage = 35
	attack_verb_continuous = "telekinetically rams its moonihorn into"
	attack_verb_simple = "telekinetically ram your moonihorn into"
	gold_core_spawnable = NO_SPAWN
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	ai_controller = /datum/ai_controller/basic_controller/cow/moonicorn
	tame_message = "nods with respect"
	self_tame_message = "nod with respect"
	milked_reagent = /datum/reagent/drug/mushroomhallucinogen
	food_types = list(/obj/item/food/grown/galaxythistle)

/mob/living/basic/cow/moonicorn/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/venomous, /datum/reagent/pax, 5, injection_flags = INJECT_CHECK_PENETRATE_THICK | INJECT_CHECK_IGNORE_SPECIES)
	AddElement(/datum/element/movement_turf_changer, /turf/open/floor/grass/fairy)

/mob/living/basic/cow/moonicorn/setup_eating()
	//identical but different static list used
	var/static/list/food_types
	if(!food_types)
		food_types = src.food_types.Copy()
	AddElement(/datum/element/basic_eating, food_types = food_types)
	AddComponent(/datum/component/tameable, tame_chance = 25, bonus_tame_chance = 15)

/mob/living/basic/cow/moonicorn/on_ai_controller_gained_friend(datum/ai_controller/controller, mob/living/new_friend, is_first_friend)
	. = ..()
	///stop killing my FRIENDS
	faction |= new_friend.faction

/datum/ai_controller/basic_controller/cow/moonicorn
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items/friendly_for_items/food,
		BB_BASIC_MOB_TIP_REACTING = FALSE,
		BB_BASIC_MOB_TIPPER = null,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/tip_reaction,
		/datum/ai_planning_subtree/random_speech/cow,
		//finds someone to kill
		/datum/ai_planning_subtree/simple_find_target,
		//...or something to eat, possibly. both types of target handled by melee attack subtree
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

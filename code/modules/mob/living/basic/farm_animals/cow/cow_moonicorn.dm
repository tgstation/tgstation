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
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	ai_controller = /datum/ai_controller/basic_controller/cow/moonicorn
	food_types = list(/obj/item/food/grown/galaxythistle)
	tame_message = "nods with respect"
	self_tame_message = "nod with respect"
	milked_reagent = /datum/reagent/drug/mushroomhallucinogen

/mob/living/basic/cow/moonicorn/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/venomous, /datum/reagent/pax, 5, injection_flags = INJECT_CHECK_PENETRATE_THICK | INJECT_CHECK_IGNORE_SPECIES)
	AddElement(/datum/element/movement_turf_changer, /turf/open/floor/grass/fairy)

/mob/living/basic/cow/moonicorn/setup_eating()
	var/static/list/food_types
	if(!food_types)
		food_types = src.food_types.Copy()
	AddComponent(/datum/component/tameable, food_types = food_types, tame_chance = 25, bonus_tame_chance = 15)

/mob/living/basic/cow/moonicorn/tamed(mob/living/tamer, atom/food)
	. = ..()
	///stop killing my FRIENDS
	faction |= tamer.faction

/datum/ai_controller/basic_controller/cow/moonicorn
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items/moonicorn,
		BB_BASIC_MOB_TIP_REACTING = FALSE,
		BB_BASIC_MOB_TIPPER = null,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/tip_reaction,
		/datum/ai_planning_subtree/random_speech/cow,
		//finds someone to kill
		/datum/ai_planning_subtree/simple_find_target,
		//...or something to eat, possibly. both types of target handled by melee attack subtree
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

///moonicorns will not attack people holding something that could tame them.
/datum/targeting_strategy/basic/allow_items/moonicorn

/datum/targeting_strategy/basic/allow_items/moonicorn/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	. = ..()
	if(!.)
		return FALSE

	if(isliving(the_target)) //Targeting vs living mobs
		var/mob/living/living_target = the_target
		for(var/obj/item/food/grown/galaxythistle/tame_food in living_target.held_items)
			return FALSE //heyyy this can tame me! let's NOT fight

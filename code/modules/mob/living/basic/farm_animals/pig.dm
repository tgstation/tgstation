//pig
/mob/living/basic/pig
	name = "pig"
	desc = "A fat pig."
	icon_state = "pig"
	icon_living = "pig"
	icon_dead = "pig_dead"
	icon_gib = "pig_gib"
	gender = MALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_emote = list("oinks","squees")
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab/pig = 6)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	melee_damage_lower = 1
	melee_damage_upper = 2
	health = 50
	maxHealth = 50
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/pig

/mob/living/basic/pig/Initialize(mapload)
	AddElement(/datum/element/pet_bonus, "oinks!")
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured)
	make_tameable()
	. = ..()

///wrapper for the tameable component addition so you can have non tamable cow subtypes
/mob/living/basic/pig/proc/make_tameable()
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/grown/carrot), tame_chance = 25, bonus_tame_chance = 15, after_tame = CALLBACK(src, PROC_REF(tamed)))

/mob/living/basic/pig/proc/tamed(mob/living/tamer)
	can_buckle = TRUE
	buckle_lying = 0
	AddElement(/datum/element/ridable, /datum/component/riding/creature/pig)
	visible_message(span_notice("[src] snorts respectfully."))

/datum/ai_controller/basic_controller/pig
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/ignore_faction(),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/pig,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/pig
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/pig

/datum/ai_behavior/basic_melee_attack/pig
	action_cooldown = 2 SECONDS

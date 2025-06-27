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
	butcher_results = list(/obj/item/food/meat/slab/pig = 6)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/items/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	melee_damage_lower = 1
	melee_damage_upper = 2
	health = 50
	maxHealth = 50
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/pig

/datum/emote/pig
	mob_type_allowed_typecache = /mob/living/basic/pig
	mob_type_blacklist_typecache = list()

/datum/emote/pig/oink
	key = "oink"
	key_third_person = "oinks"
	message = "oinks!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE
	sound = SFX_PIG_OINK
/mob/living/basic/pig/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "oink")
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured)
	make_tameable()

///wrapper for the tameable component addition so you can have non tamable cow subtypes
/mob/living/basic/pig/proc/make_tameable()
	var/list/food_types = string_list(list(/obj/item/food/grown/carrot))
	AddComponent(/datum/component/tameable, food_types = food_types, tame_chance = 25, bonus_tame_chance = 15)

/mob/living/basic/pig/tamed(mob/living/tamer, atom/food)
	AddElement(/datum/element/ridable, /datum/component/riding/creature/pig)
	visible_message(span_notice("[src] snorts respectfully."))

/datum/ai_controller/basic_controller/pig
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/pig,
	)

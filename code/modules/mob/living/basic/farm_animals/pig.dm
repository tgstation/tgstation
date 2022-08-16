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
	health = 50
	maxHealth = 50
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/pig

/mob/living/basic/pig/Initialize()
	AddElement(/datum/element/pet_bonus, "oinks!")
	make_tameable()
	. = ..()

///wrapper for the tameable component addition so you can have non tamable cow subtypes
/mob/living/basic/pig/proc/make_tameable()
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/grown/carrot), tame_chance = 25, bonus_tame_chance = 15, after_tame = CALLBACK(src, .proc/tamed))

/mob/living/basic/pig/proc/tamed(mob/living/tamer)
	can_buckle = TRUE
	buckle_lying = 0
	AddElement(/datum/element/ridable, /datum/component/riding/creature/pig)
	visible_message(span_notice("[src] snorts respectfully."))

/datum/ai_controller/basic_controller/pig
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	

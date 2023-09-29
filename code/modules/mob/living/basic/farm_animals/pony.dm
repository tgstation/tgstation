/mob/living/basic/pony
	name = "pony"
	desc = "Look at my horse, my horse is amazing!"
	icon_state = "pony"
	icon_living = "pony"
	icon_dead = "pony_dead"
	gender = MALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_emote = list("neighs", "winnies")
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
	melee_damage_lower = 5
	melee_damage_upper = 10
	health = 50
	maxHealth = 50
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/pony

/mob/living/basic/pony/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/pet_bonus, "whickers.")
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured)
	AddElement(/datum/element/waddling)
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/grown/apple), tame_chance = 25, bonus_tame_chance = 15, after_tame = CALLBACK(src, PROC_REF(tamed)))

/mob/living/basic/pony/proc/tamed(mob/living/tamer)
	can_buckle = TRUE
	buckle_lying = 0
	playsound(src, 'sound/creatures/pony/snort.ogg', 50)
	AddElement(/datum/element/ridable, /datum/component/riding/creature/pony)
	visible_message(span_notice("[src] snorts happily."))

	ai_controller.replace_planning_subtrees(list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/pony/tamed
	))

/mob/living/basic/pony/proc/whinny_angrily()
	manual_emote("whinnies ANGRILY!")

	playsound(src, pick(list(
		'sound/creatures/pony/whinny01.ogg',
		'sound/creatures/pony/whinny02.ogg',
		'sound/creatures/pony/whinny03.ogg'
	)), 50)

/mob/living/basic/pony/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()

	if (prob(33))
		whinny_angrily()

/mob/living/basic/pony/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()

	if (!.)
		return

	whinny_angrily()

/datum/ai_controller/basic_controller/pony
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/ignore_faction,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/pony
	)

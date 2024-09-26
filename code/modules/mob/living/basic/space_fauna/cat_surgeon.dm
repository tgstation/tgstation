/**
 * ## Cat Surgeon
 *
 * A mean motherfucker who wants to steal them cat tails... be warned should you see it, as it doesn't really speak much either.
 */

/mob/living/basic/cat_butcherer
	name = "Cat Surgeon"
	desc = "A man with the quest of chasing endless feline tail."
	icon = 'icons/mob/simple/simple_human.dmi'
	icon_state = "cat_butcher"
	icon_living = "cat_butcher"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	speed = 0.8
	maxHealth = 100
	health = 100
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "slashes at"
	attack_verb_simple = "slash at"
	attack_sound = 'sound/items/weapons/circsawhit.ogg'
	combat_mode = TRUE
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	habitable_atmos = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 7.5
	faction = list(FACTION_HOSTILE)
	status_flags = CANPUSH
	basic_mob_flags = DEL_ON_DEATH

	ai_controller = /datum/ai_controller/basic_controller/cat_butcherer

	/// The stuff we drop on death.
	var/static/list/drop_on_death = list(
		/obj/effect/mob_spawn/corpse/human/cat_butcher,
		/obj/item/circular_saw,
	)

/mob/living/basic/cat_butcherer/Initialize(mapload)
	. = ..()
	apply_dynamic_human_appearance(src, mob_spawn_path = /obj/effect/mob_spawn/corpse/human/cat_butcher, l_hand = /obj/item/circular_saw, bloody_slots = ITEM_SLOT_GLOVES|ITEM_SLOT_OCLOTHING)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/death_drops, drop_on_death)
	RegisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(after_attack))

/mob/living/basic/cat_butcherer/proc/after_attack(mob/living/basic/attacker, atom/target)
	SIGNAL_HANDLER

	if(!iscarbon(target) || !prob(35))
		return

	var/mob/living/carbon/human/attacked = target
	var/obj/item/organ/external/tail/cat/tail = attacked.get_organ_by_type(/obj/item/organ/external/tail/cat)
	if(QDELETED(tail))
		return

	visible_message(
		span_warning("[src] severs [attacked]'s tail off in one swift swipe!"),
		span_warning("You sever [attacked]'s tail off."),
	)
	tail.Remove(attacked)
	tail.forceMove(drop_location())

/datum/ai_controller/basic_controller/cat_butcherer
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

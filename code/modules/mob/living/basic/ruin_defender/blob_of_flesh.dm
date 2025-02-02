/datum/ai_controller/basic_controller/fleshblob
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 7,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/mob/living/basic/fleshblob
	name = "mass of flesh"
	desc = "A moving slithering mass of flesh, seems to be very much in pain. Better avoid. It has no mouth and it must scream."
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "fleshblob"
	icon_living = "fleshblob"
	mob_size = MOB_SIZE_LARGE
	gender = NEUTER
	basic_mob_flags = DEL_ON_DEATH
	faction = list(FACTION_HOSTILE, FACTION_MINING)
	melee_damage_lower = 3
	melee_damage_upper = 3
	health = 160
	maxHealth = 160
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_SMASH
	attack_verb_continuous = "attempts to assimilate"
	attack_verb_simple = "attempt to assimilate"
	mob_biotypes = MOB_ORGANIC
	speed = 8
	combat_mode = TRUE
	ai_controller = /datum/ai_controller/basic_controller/fleshblob

/mob/living/basic/fleshblob/Initialize(mapload, obj/item/bodypart/limb)
	. = ..()
	grant_actions_by_list(list(/datum/action/consume/fleshblob))
	ADD_TRAIT(src, TRAIT_STRONG_GRABBER, INNATE_TRAIT)
	AddElement(/datum/element/death_drops, string_list(list(/obj/effect/gibspawner/generic)))
	AddComponent(\
		/datum/component/blood_walk, \
		blood_type = /obj/effect/decal/cleanable/blood/trails, \
		target_dir_change = TRUE,\
	)

/mob/living/basic/fleshblob/container_resist_act(mob/living/user)
	. = ..()
	if(!do_after(user, 4 SECONDS, target = src, timed_action_flags = IGNORE_TARGET_LOC_CHANGE|IGNORE_USER_LOC_CHANGE|IGNORE_INCAPACITATED))
		return FALSE
	var/datum/action/consume/fleshblob/consume = locate() in actions
	if(isnull(consume))
		return
	consume.stop_consuming()

/mob/living/basic/fleshblob/melee_attack(mob/living/target, list/modifiers, ignore_cooldown = FALSE)
	if(target.loc == src || pulling == target)
		return FALSE
	. = ..()
	if(!istype(target) || isnull(.)) // we deal 0 damage
		return
	start_pulling(target, state = GRAB_AGGRESSIVE)
	var/datum/action/consume/fleshblob/consume = locate() in actions
	if(isnull(consume))
		return
	consume.Trigger() // subtrees wouldve spammed this shit repeatedly anyway

/datum/action/consume/fleshblob
	devour_verb = "assimilate"
	devour_time = 3 SECONDS

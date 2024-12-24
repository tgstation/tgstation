/datum/ai_controller/basic_controller/fleshblob
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 7,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/adjacent,
	)

/mob/living/basic/fleshblob
	name = "mass of flesh"
	desc = "A moving slithering mass of flesh, seems to be very much in pain. Better avoid. It has no mouth and it must scream."
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "fleshblob"
	icon_living = "fleshblob"
	mob_size = MOB_SIZE_LARGE
	basic_mob_flags = DEL_ON_DEATH
	faction = list(FACTION_HOSTILE, FACTION_MINING)
	melee_damage_lower = 0
	melee_damage_upper = 0
	health = 250 //Avoid or lock away
	maxHealth = 250
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_SMASH
	attack_verb_continuous = "attempts to assimilate"
	attack_verb_simple = "attempt to assimilate"
	mob_biotypes = MOB_ORGANIC
	speed = 4.5
	ai_controller = /datum/ai_controller/basic_controller/fleshblob

/mob/living/basic/fleshblob/Initialize(mapload, obj/item/bodypart/limb)
	. = ..()
	grant_actions_by_list(list(/datum/action/consume/fleshblob = BB_TARGETED_ACTION))
	ADD_TRAIT(src, TRAIT_STRONG_GRABBER, INNATE_TRAIT)
	AddElement(/datum/element/death_drops, string_list(list(/obj/effect/gibspawner/generic)))
	AddComponent(\
		/datum/component/blood_walk, \
		blood_type = /obj/effect/decal/cleanable/blood/trails, \
		target_dir_change = TRUE,\
	)

/mob/living/basic/fleshblob/container_resist_act(mob/living/user)
	. = ..()
	if(!do_after(user, 4 SECONDS))
		return FALSE
	var/datum/action/consume/fleshblob/consume = locate() in actions
	if(isnull(consume))
		return
	consume.stop_consuming()

/mob/living/basic/fleshblob/melee_attack(mob/living/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if(!istype(target) || isnull(.)) // we deal 0 damage
		return
	start_pulling(target, supress_message = TRUE)

/datum/action/consume/fleshblob
	devour_verb = "assimilate"

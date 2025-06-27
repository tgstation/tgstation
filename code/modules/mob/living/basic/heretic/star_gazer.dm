/mob/living/basic/heretic_summon/star_gazer
	name = "\improper Star Gazer"
	desc = "A creature that has been tasked to watch over the stars."
	icon = 'icons/mob/nonhuman-player/96x96eldritch_mobs.dmi'
	icon_state = "star_gazer"
	icon_living = "star_gazer"
	pixel_x = -32
	base_pixel_x = -32
	mob_biotypes = MOB_HUMANOID | MOB_SPECIAL
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	speed = -0.2
	maxHealth = 6000
	health = 6000

	obj_damage = 400
	armour_penetration = 20
	melee_damage_lower = 40
	melee_damage_upper = 40
	sentience_type = SENTIENCE_BOSS
	attack_verb_continuous = "ravages"
	attack_verb_simple = "ravage"
	attack_vis_effect = ATTACK_EFFECT_SLASH
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	melee_attack_cooldown = 0.6 SECONDS
	speak_emote = list("growls")
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 0, STAMINA = 0, OXY = 0)
	death_sound = 'sound/effects/magic/cosmic_expansion.ogg'

	slowed_by_drag = FALSE
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	can_buckle_to = FALSE
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1

	ai_controller = /datum/ai_controller/basic_controller/star_gazer

/mob/living/basic/heretic_summon/star_gazer/Initialize(mapload)
	. = ..()
	var/static/list/death_loot = list(/obj/effect/temp_visual/cosmic_domain)
	AddElement(/datum/element/death_drops, death_loot)
	AddElement(/datum/element/death_explosion, 3, 6, 12)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_SHOE)
	AddElement(/datum/element/wall_smasher, ENVIRONMENT_SMASH_RWALLS)
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)
	AddElement(/datum/element/ai_target_damagesource)
	AddComponent(/datum/component/regenerator, outline_colour = "#b97a5d")
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_LAVA_IMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_ASHSTORM_IMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NO_TELEPORT, MEGAFAUNA_TRAIT)
	ADD_TRAIT(src, TRAIT_MARTIAL_ARTS_IMMUNE, MEGAFAUNA_TRAIT)
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	set_light(4, l_color = "#dcaa5b")

// Star gazer attacks everything around itself applies a spooky mark
/mob/living/basic/heretic_summon/star_gazer/melee_attack(mob/living/target, list/modifiers, ignore_cooldown)
	. = ..()
	if (!. || !isliving(target))
		return

	target.apply_status_effect(/datum/status_effect/star_mark)
	target.apply_damage(damage = 5, damagetype = BURN)
	var/datum/targeting_strategy/target_confirmer = GET_TARGETING_STRATEGY(ai_controller.blackboard[BB_TARGETING_STRATEGY])
	for(var/mob/living/nearby_mob in range(1, src))
		if(target == nearby_mob || !target_confirmer?.can_attack(src, nearby_mob))
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark)
		nearby_mob.apply_damage(10)
		to_chat(nearby_mob, span_userdanger("\The [src] [attack_verb_continuous] you!"))
		do_attack_animation(nearby_mob, ATTACK_EFFECT_SLASH)
		log_combat(src, nearby_mob, "slashed")

/datum/ai_controller/basic_controller/star_gazer
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends/attack_everything,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/attack_obstacle_in_path/pet_target/star_gazer,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path/star_gazer,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/attack_obstacle_in_path/star_gazer
	attack_behaviour = /datum/ai_behavior/attack_obstructions/star_gazer

/datum/ai_planning_subtree/attack_obstacle_in_path/pet_target/star_gazer
	attack_behaviour = /datum/ai_behavior/attack_obstructions/star_gazer

/datum/ai_behavior/attack_obstructions/star_gazer
	action_cooldown = 0.4 SECONDS
	can_attack_turfs = TRUE
	can_attack_dense_objects = TRUE

/datum/pet_command/attack/star_gazer
	speech_commands = list("attack", "sic", "kill", "slash them")
	command_feedback = "stares!"
	pointed_reaction = "stares intensely!"
	refuse_reaction = "..."
	attack_behaviour = /datum/ai_behavior/basic_melee_attack

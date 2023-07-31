/mob/living/basic/star_gazer
	name = "Star Gazer"
	desc = "A creature that has been tasked to watch over the stars."
	icon = 'icons/mob/nonhuman-player/96x96eldritch_mobs.dmi'
	icon_state = "star_gazer"
	icon_living = "star_gazer"
	pixel_x = -32
	base_pixel_x = -32
	basic_mob_flags = DEL_ON_DEATH
	mob_biotypes = MOB_HUMANOID | MOB_EPIC
	faction = list(FACTION_HERETIC)
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	speed = -0.2
	maxHealth = 6000
	health = 6000

	obj_damage = 400
	armour_penetration = 20
	melee_damage_lower = 40
	melee_damage_upper = 40
	combat_mode = TRUE
	sentience_type = SENTIENCE_BOSS
	attack_verb_continuous = "ravages"
	attack_verb_simple = "ravage"
	attack_vis_effect = ATTACK_EFFECT_SLASH
	attack_sound = 'sound/weapons/bladeslice.ogg'
	speak_emote = list("growls")
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	death_sound = 'sound/magic/cosmic_expansion.ogg'

	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0

	gold_core_spawnable = NO_SPAWN
	slowed_by_drag = FALSE
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1

	ai_controller = /datum/ai_controller/basic_controller/star_gazer

/mob/living/basic/star_gazer/Initialize(mapload)
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

/datum/ai_controller/basic_controller/star_gazer
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/star_gazer(),
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/not_friends/attack_closed_turfs(),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/attack_obstacle_in_path/pet_target/star_gazer,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path/star_gazer,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/star_gazer,
	)

/datum/targetting_datum/basic/star_gazer
	stat_attack = HARD_CRIT

/datum/ai_planning_subtree/basic_melee_attack_subtree/star_gazer
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/star_gazer

/datum/ai_behavior/basic_melee_attack/star_gazer
	action_cooldown = 0.6 SECONDS

/datum/ai_behavior/basic_melee_attack/star_gazer/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn

	if(!isliving(target))
		return
	var/mob/living/living_target = target
	living_target.apply_status_effect(/datum/status_effect/star_mark)
	living_target.apply_damage_type(damage = 5, damagetype = CLONE)
	if(living_target.pulledby != living_pawn)
		if(living_pawn.Adjacent(living_target) && isturf(living_target.loc) && living_target.stat == SOFT_CRIT)
			living_target.grabbedby(living_pawn)
	for(var/mob/living/nearby_mob in range(1, living_pawn))
		if(nearby_mob.stat == DEAD || living_target == nearby_mob || faction_check(nearby_mob.faction, list(FACTION_HERETIC)))
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark)
		nearby_mob.adjustBruteLoss(10)
		living_pawn.do_attack_animation(nearby_mob, ATTACK_EFFECT_SLASH)
		log_combat(living_pawn, nearby_mob, "slashed")

/datum/ai_planning_subtree/attack_obstacle_in_path/star_gazer
	attack_behaviour = /datum/ai_behavior/attack_obstructions/star_gazer

/datum/ai_planning_subtree/attack_obstacle_in_path/pet_target/star_gazer
	attack_behaviour = /datum/ai_behavior/attack_obstructions/star_gazer

/datum/ai_behavior/attack_obstructions/star_gazer
	action_cooldown = 0.4 SECONDS
	can_attack_turfs = TRUE
	can_attack_dense_objects = TRUE

/datum/pet_command/point_targetting/attack/star_gazer
	speech_commands = list("attack", "sic", "kill", "slash them")
	command_feedback = "stares!"
	pointed_reaction = "stares intensely!"
	refuse_reaction = "..."
	attack_behaviour = /datum/ai_behavior/basic_melee_attack/star_gazer

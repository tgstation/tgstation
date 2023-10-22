/datum/antagonist/bitrunning_glitch/cyber_behemoth
	name = ROLE_CYBER_BEHEMOTH
	threat = 150

/mob/living/basic/cyber_behemoth
	name = "cyber behemoth"
	icon_state = "old"
	icon_living = "old"
	icon_dead = "old_dead"
	basic_mob_flags = DEL_ON_DEATH
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	mob_size = MOB_SIZE_HUGE

	health = 1000
	maxHealth = 1000
	melee_damage_lower = 25
	melee_damage_upper = 45

	attack_verb_continuous = "drills"
	attack_verb_simple = "drills"
	attack_sound = 'sound/weapons/drill.ogg'
	attack_vis_effect = ATTACK_EFFECT_MECHFIRE
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	bubble_icon = "machine"

	faction = list(
		FACTION_BOSS,
		FACTION_HIVEBOT,
		FACTION_HOSTILE,
		FACTION_SPIDER,
		FACTION_STICKMAN,
		ROLE_ALIEN,
		ROLE_GLITCH,
		ROLE_SYNDICATE,
	)

	combat_mode = TRUE
	speech_span = SPAN_ROBOT
	death_message = "blows apart!"

	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = TCMB
	ai_controller = /datum/ai_controller/basic_controller/behemoth

/mob/living/basic/behemoth/death(gibbed)
	do_sparks(number = 3, cardinal_only = TRUE, source = src)
	return ..()

/datum/ai_controller/basic_controller/behemoth
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_wounded_target,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
	)

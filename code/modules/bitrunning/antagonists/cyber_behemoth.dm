/datum/antagonist/bitrunning_glitch/cyber_behemoth
	name = ROLE_CYBER_BEHEMOTH
	threat = 150

/mob/living/basic/cyber_behemoth
	name = ROLE_CYBER_BEHEMOTH
	real_name = ROLE_CYBER_BEHEMOTH
	icon_state = "behemoth"
	icon_living = "behemoth"
	icon_dead = "behemoth"
	basic_mob_flags = DEL_ON_DEATH
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	mob_size = MOB_SIZE_HUGE

	health = 1000
	maxHealth = 1000
	melee_damage_lower = 15
	melee_damage_upper = 25

	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
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


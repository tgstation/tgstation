///Small subtype until we refactor throwing so that we don't need the throw override
/mob/living/basic/mining
	faction = list("mining")
	weather_immunities = list(WEATHER_LAVA,WEATHER_ASH)
	combat_mode = TRUE
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS | ENVIRONMENT_SMASH_STRUCTURES

	response_harm_continuous = "strikes"
	response_harm_simple = "strike"

	status_flags = NONE
	see_in_dark = 8

	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	mob_size = MOB_SIZE_LARGE
	ai_controller = /mob/living/basic/mining/angry_smash


	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_dead = "Goliath_dead"
	icon_gib = "syndicate_gib"

	//var/crusher_loot
	//var/throw_message = "bounces off of"
	//var/fromtendril = FALSE
	//var/icon_aggro = null
	//var/crusher_drop_mod = 25



///Watcher
/mob/living/basic/mining/angry_smash
	maxHealth = 100


/datum/ai_controller/basic_controller/angry_smash
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic()
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/cockroach,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/hauberoach,  //If we are attacking someone, this will prevent us from hunting
		/datum/ai_planning_subtree/find_and_hunt_target
	)

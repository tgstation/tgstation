/datum/ai_controller/basic_controller/pet_cult
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/cultist,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/cultist,
		BB_FRIENDLY_MESSAGE = "eagerly awaits your command...",
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/pets/pet_cult/pet_cult.bt.json"

///if target gets pulled away, unset him
/datum/ai_controller/basic_controller/pet_cult/proc/delete_pull_target(datum/source, atom/movable/was_pulling)
	SIGNAL_HANDLER

	UnregisterSignal(src, COMSIG_ATOM_NO_LONGER_PULLING)

	if(was_pulling == blackboard[BB_DEAD_CULTIST])
		clear_blackboard_key(BB_DEAD_CULTIST)

///targeting strat to attack non cultists
/datum/targeting_strategy/basic/cultist
	custom_faction_check = TRUE

/datum/targeting_strategy/basic/cultist/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	return IS_CULTIST_OR_CULTIST_MOB(the_target)

///command ability to draw runes
/datum/pet_command/untargeted_ability/draw_rune
	command_name = "Draw Rune"
	command_desc = "Draw a revival rune."
	radial_icon = 'icons/obj/antags/cult/rune.dmi'
	radial_icon_state = "1"
	speech_commands = list("rune", "revival")
	ability_key = BB_RUNE_ABILITY

/datum/pet_command/untargeted_ability/draw_rune/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to draw a rune!"

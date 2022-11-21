/**
 * # Pet Command: Idle
 * Tells a pet to resume its idle behaviour, usually staying put where you leave it
 */
/datum/component/pet_command/idle
	command_key = PET_COMMAND_IDLE

/datum/component/pet_command/idle/Initialize(list/speech_commands = list("sit", "stay", "stop"), command_feedback = "sits")
	return ..()

/**
 * # Pet Command: Stop
 * Tells a pet to exit command mode and resume its normal behaviour, which includes regular target-seeking and what have you
 */
/datum/component/pet_command/free
	command_key = PET_COMMAND_NONE

/datum/component/pet_command/free/Initialize(list/speech_commands = list("free", "loose"), command_feedback = "relaxes")
	return ..()

/**
 * # Pet Command: Follow
 * Tells a pet to follow you until you tell it to do something else, simple really
 */
/datum/component/pet_command/follow
	command_key = PET_COMMAND_FOLLOW

/datum/component/pet_command/follow/Initialize(list/speech_commands = list("heel", "follow"), command_feedback)
	return ..()

/datum/component/pet_command/follow/set_command_active(mob/living/commander)
	set_command_target(commander)
	return ..()

/**
 * # Pet Command: Attack
 * Tells a pet to chase and bite the next thing you point at
 */
/datum/component/pet_command/point_targetting/attack
	command_key = PET_COMMAND_ATTACK

/datum/component/pet_command/point_targetting/attack/Initialize(list/speech_commands = list("attack", "sic", "kill"), command_feedback = "growl")
	return ..()

/**
 * # Pet Command: Targetted Ability
 * Tells a pet to use some kind of ability on the next thing you point at
 */

/datum/component/pet_command/point_targetting/use_ability
	command_key = PET_COMMAND_USE_ABILITY

/datum/component/pet_command/point_targetting/use_ability/Initialize(list/speech_commands = list("shoot", "blast", "cast"), command_feedback = "growl")
	return ..()

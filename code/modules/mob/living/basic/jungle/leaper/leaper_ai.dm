/datum/ai_controller/basic_controller/leaper
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "leaper.bt.json"

/datum/pet_command/use_ability/flop
	command_name = "Flop"
	command_desc = "Command your pet to belly flop your target!"
	radial_icon = 'icons/mob/actions/actions_items.dmi'
	radial_icon_state = "sniper_zoom"
	speech_commands = list("flop", "crush")
	pet_ability_key = BB_LEAPER_FLOP

/datum/pet_command/use_ability/bubble
	command_name = "Poison Bubble"
	command_desc = "Launch poisonous bubbles at your target!"
	radial_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	radial_icon_state = "leaper"
	speech_commands = list("bubble", "shoot")
	pet_ability_key = BB_LEAPER_BUBBLE

/datum/pet_command/use_ability/bubble/retrieve_command_text(atom/living_pet, atom/target)
	return isnull(target) ? null : "signals [living_pet] to shoot a bubble towards [target]!"

/datum/pet_command/untargeted_ability/blood_rain
	command_name = "Blood Rain"
	command_desc = "Let it rain poisonous blood!"
	radial_icon = 'icons/effects/effects.dmi'
	radial_icon_state = "blood_effect_falling"
	speech_commands = list("blood", "rain", "volley")
	ability_key = BB_LEAPER_VOLLEY

/datum/pet_command/untargeted_ability/blood_rain/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to unleash a volley of rain!"

/datum/pet_command/untargeted_ability/summon_toad
	command_name = "Summon Toads"
	command_desc = "Summon crazy suicide frogs!"
	radial_icon = 'icons/mob/simple/animal.dmi'
	radial_icon_state = "frog_trash"
	speech_commands = list("frogs", "bombers")
	ability_key = BB_LEAPER_SUMMON

/datum/pet_command/untargeted_ability/summon_toad/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to summon some explosive frogs!"

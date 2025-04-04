/datum/preference/personality
	savefile_key = "personalities"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/personality/apply_to_human(mob/living/carbon/human/target, value)
	if(isdummy(target) || CONFIG_GET(flag/disable_human_mood) || isnull(target.mob_mood))
		return
	for(var/personality_type in value)
		var/datum/personality/personality = GLOB.personality_controller.personalities[text2path(personality_type)]
		personality.apply_to_mob(target)

/datum/preference/personality/is_valid(value)
	return islist(value) || isnull(value)

/datum/preference/personality/deserialize(input, datum/preferences/preferences)
	if(!LAZYLEN(input))
		return null

	var/list/input_sanitized
	for(var/personality_type in input)
		if(istext(personality_type))
			// Loading from json has each path in the list as a string that we need to convert back to typepath
			personality_type = text2path(personality_type)

		if(!ispath(personality_type, /datum/personality))
			continue
		if(GLOB.personality_controller.is_incompatible(input_sanitized, personality_type))
			continue
		if(LAZYLEN(input_sanitized) >= CONFIG_GET(number/max_personalities))
			break
		LAZYADD(input_sanitized, personality_type)

	return input_sanitized

/datum/preference/personality/create_default_value()
	return null

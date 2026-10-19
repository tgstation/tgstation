/datum/preference/personality
	savefile_key = "personalities"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = TRUE
	randomize_by_default = FALSE
	should_update_preview = FALSE

/datum/preference/personality/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	if(isdummy(target) || !ishuman(target) || isnull(target.mob_mood))
		return
	if(!CONFIG_GET(flag/roundstart_traits))
		return
	target.clear_personalities()
	for(var/personality_key in value)
		var/datum/personality/personality = SSpersonalities.personalities_by_key[personality_key]
		target.add_personality(personality.type)

/datum/preference/personality/is_valid(value, datum/preferences/preferences)
	return islist(value) || isnull(value)

/datum/preference/personality/deserialize(input, datum/preferences/preferences)
	if(!LAZYLEN(input))
		return null

	if(!SSpersonalities.initialized)
		SSpersonalities.init_personalities()

	var/list/input_sanitized
	var/list/sanitized_types
	for(var/personality_key in input)
		var/datum/personality/personality = SSpersonalities.personalities_by_key[personality_key]
		if(!istype(personality))
			continue
		if(SSpersonalities.is_incompatible(sanitized_types, personality.type))
			continue
		if(LAZYLEN(input_sanitized) >= CONFIG_GET(number/max_personalities))
			break
		LAZYADD(input_sanitized, personality_key)
		LAZYADD(sanitized_types, personality.type)

	return input_sanitized

/datum/preference/personality/create_default_value()
	return null

/datum/preference/personality/create_random_value(datum/preferences/preferences)
	var/list/random_personalities
	for(var/datum/personality/personality_type as anything in SSpersonalities.select_random_personalities())
		LAZYADD(random_personalities, initial(personality_type.savefile_key))
	return random_personalities

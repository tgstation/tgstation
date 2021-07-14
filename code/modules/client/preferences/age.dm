/datum/preference/age
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "age"

/datum/preference/age/deserialize(input)
	return sanitize_integer(input, AGE_MIN, AGE_MAX, create_default_value())

/datum/preference/age/serialize(input)
	return sanitize_integer(input, AGE_MIN, AGE_MAX, create_default_value())

/datum/preference/age/create_default_value()
	return rand(AGE_MIN, AGE_MAX)

/datum/preference/age/transform_value(value)
	return text2num(value)

/datum/preference/age/is_valid(value)
	return !isnull(value) && value >= AGE_MIN && value <= AGE_MAX

/datum/preference/age/apply(mob/living/carbon/human/target, value)
	target.age = value

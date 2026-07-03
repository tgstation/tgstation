GLOBAL_LIST_INIT(donor_chat_effects, list(
	"Автоматически" = "auto",
	"Металлик" = "metal",
	"Светящийся" = "glowing",
	"Выключить" = null,
))

/datum/preference/choiced/donor_chat_effect
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "donor_chat_effect"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/donor_chat_effect/init_possible_values()
	return assoc_to_keys(GLOB.donor_chat_effects)

/datum/preference/choiced/donor_chat_effect/create_default_value()
	return GLOB.donor_chat_effects[1]

/datum/preference/toggle/donor_public
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = TRUE
	savefile_key = "donor_public"
	savefile_identifier = PREFERENCE_PLAYER

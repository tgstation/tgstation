/// All the possible values for the pixel size, left here for convenience.
#define STRETCH_TO_FIT 0
#define PIXEL_PERFECT_1X 1
#define PIXEL_PERFECT_1_5X 1.5
#define PIXEL_PERFECT_2X 2
#define PIXEL_PERFECT_3X 3

/datum/preference/numeric/pixel_size
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "pixel_size"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 3

	step = 0.5

/datum/preference/numeric/pixel_size/create_default_value()
	return PIXEL_PERFECT_2X

/datum/preference/numeric/pixel_size/apply_to_client(client/client, value)
	client?.view_size?.resetFormat()

#undef STRETCH_TO_FIT
#undef PIXEL_PERFECT_1X
#undef PIXEL_PERFECT_1_5X
#undef PIXEL_PERFECT_2X
#undef PIXEL_PERFECT_3X

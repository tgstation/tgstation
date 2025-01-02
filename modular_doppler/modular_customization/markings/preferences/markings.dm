///
// Preferences
///

// Head markings

/datum/preference/choiced/markings/markings_head
	savefile_key = "markings_head"
	main_feature_name = "Bodymarkings Head"
	body_zone = HEAD
	markingval = MARKING_HEAD

/datum/preference/color/markings/markings_head
	savefile_key = "markings_head_color"
	markingval = MARKING_HEAD

/datum/preference/choiced/markings/markings_head2
	savefile_key = "markings_head2"
	main_feature_name = "Bodymarkings Head 2"
	body_zone = HEAD
	markingval = MARKING_HEAD2

/datum/preference/choiced/markings/markings_head2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_head) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_head2
	savefile_key = "markings_head_color2"
	markingval = MARKING_HEAD2

/datum/preference/color/markings/markings_head2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_head) != SPRITE_ACCESSORY_NONE

/datum/preference/choiced/markings/markings_head3
	savefile_key = "markings_head3"
	main_feature_name = "Bodymarkings Head 2"
	body_zone = HEAD
	markingval = MARKING_HEAD3

/datum/preference/choiced/markings/markings_head3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_head2) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_head3
	savefile_key = "markings_head_color3"
	markingval = MARKING_HEAD3

/datum/preference/color/markings/markings_head3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_head2) != SPRITE_ACCESSORY_NONE

// Chest markings

/datum/preference/choiced/markings/markings_chest
	savefile_key = "markings_chest"
	main_feature_name = "Bodymarkings Chest"
	body_zone = CHEST
	markingval = MARKING_CHEST


/datum/preference/color/markings/markings_chest
	savefile_key = "markings_chest_color"
	markingval = MARKING_CHEST

/datum/preference/choiced/markings/markings_chest2
	savefile_key = "markings_chest2"
	main_feature_name = "Bodymarkings Chest 2"
	body_zone = CHEST
	markingval = MARKING_CHEST2

/datum/preference/choiced/markings/markings_chest2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_chest) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_chest2
	savefile_key = "markings_chest_color2"
	markingval = MARKING_CHEST2

/datum/preference/color/markings/markings_chest2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_chest) != SPRITE_ACCESSORY_NONE

/datum/preference/choiced/markings/markings_chest3
	savefile_key = "markings_chest3"
	main_feature_name = "Bodymarkings Chest"
	body_zone = CHEST
	markingval = MARKING_CHEST3

/datum/preference/choiced/markings/markings_chest3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_chest2) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_chest3
	savefile_key = "markings_chest_color3"
	markingval = MARKING_CHEST3

/datum/preference/color/markings/markings_chest3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_chest2) != SPRITE_ACCESSORY_NONE

// Right arm markings

/datum/preference/choiced/markings/markings_r_arm
	savefile_key = "markings_r_arm"
	main_feature_name = "Bodymarkings Right Arm"
	body_zone = ARM_RIGHT
	markingval = MARKING_RARM

/datum/preference/color/markings/markings_r_arm
	savefile_key = "markings_r_arm_color"
	markingval = MARKING_RARM

/datum/preference/choiced/markings/markings_r_arm2
	savefile_key = "markings_r_arm2"
	main_feature_name = "Bodymarkings Right Arm 2"
	body_zone = ARM_RIGHT
	markingval = MARKING_RARM2

/datum/preference/choiced/markings/markings_r_arm2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_r_arm) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_r_arm2
	savefile_key = "markings_r_arm_color2"
	markingval = MARKING_RARM2

/datum/preference/color/markings/markings_r_arm2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_r_arm) != SPRITE_ACCESSORY_NONE

/datum/preference/choiced/markings/markings_r_arm3
	savefile_key = "markings_r_arm3"
	main_feature_name = "Bodymarkings Right Arm 3"
	body_zone = ARM_RIGHT
	markingval =  MARKING_RARM3

/datum/preference/choiced/markings/markings_r_arm3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_r_arm2) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_r_arm3
	savefile_key = "markings_r_arm_color3"
	markingval = MARKING_RARM3

/datum/preference/color/markings/markings_r_arm3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_r_arm2) != SPRITE_ACCESSORY_NONE


// Left arm markings

/datum/preference/choiced/markings/markings_l_arm
	savefile_key = "markings_l_arm"
	main_feature_name = "Bodymarkings Left Arm"
	body_zone = ARM_LEFT
	markingval = MARKING_LARM

/datum/preference/color/markings/markings_l_arm
	savefile_key = "markings_l_arm_color"
	markingval = MARKING_LARM

/datum/preference/choiced/markings/markings_l_arm2
	savefile_key = "markings_l_arm2"
	main_feature_name = "Bodymarkings Left Arm 2"
	body_zone = ARM_LEFT
	markingval = MARKING_LARM2

/datum/preference/choiced/markings/markings_l_arm2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_l_arm) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_l_arm2
	savefile_key = "markings_l_arm_color2"
	markingval = MARKING_LARM2

/datum/preference/color/markings/markings_l_arm2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_l_arm) != SPRITE_ACCESSORY_NONE

/datum/preference/choiced/markings/markings_l_arm3
	savefile_key = "markings_l_arm3"
	main_feature_name = "Bodymarkings Left Arm 3"
	body_zone = ARM_LEFT
	markingval = MARKING_LARM3


/datum/preference/choiced/markings/markings_l_arm3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_l_arm2) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_l_arm3
	savefile_key = "markings_l_arm_color3"
	markingval = MARKING_LARM3

/datum/preference/color/markings/markings_l_arm3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_l_arm2) != SPRITE_ACCESSORY_NONE

// Left hand markings

/datum/preference/choiced/markings/markings_l_hand
	savefile_key = "markings_l_hand"
	main_feature_name = "Bodymarkings Left Hand"
	body_zone = HAND_LEFT
	markingval = MARKING_LHAND

/datum/preference/color/markings/markings_l_hand
	savefile_key = "markings_l_hand_color"
	markingval = MARKING_LHAND

/datum/preference/choiced/markings/markings_l_hand2
	savefile_key = "markings_l_hand2"
	main_feature_name = "Bodymarkings Left Hand 2"
	body_zone = HAND_LEFT
	markingval = MARKING_LHAND2

/datum/preference/choiced/markings/markings_l_hand2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_l_hand) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_l_hand2
	savefile_key = "markings_l_hand_color2"
	markingval = MARKING_LHAND2

/datum/preference/color/markings/markings_l_hand2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_l_hand) != SPRITE_ACCESSORY_NONE

/datum/preference/choiced/markings/markings_l_hand3
	savefile_key = "markings_l_hand3"
	main_feature_name = "Bodymarkings Left Hand 3"
	body_zone = HAND_LEFT
	markingval = MARKING_LHAND3

/datum/preference/choiced/markings/markings_l_hand3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_l_hand2) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_l_hand3
	savefile_key = "markings_l_hand_color3"
	markingval = MARKING_LHAND3

/datum/preference/color/markings/markings_l_hand3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_l_hand2) != SPRITE_ACCESSORY_NONE

// Right hand markings

/datum/preference/choiced/markings/markings_r_hand
	savefile_key = "markings_r_hand"
	main_feature_name = "Bodymarkings Right Hand"
	body_zone = HAND_RIGHT
	markingval = MARKING_RHAND

/datum/preference/color/markings/markings_r_hand
	savefile_key = "markings_r_hand_color"
	markingval = MARKING_RHAND

/datum/preference/choiced/markings/markings_r_hand2
	savefile_key = "markings_r_hand2"
	main_feature_name = "Bodymarkings Right Hand 2"
	body_zone = HAND_RIGHT
	markingval = MARKING_RHAND2

/datum/preference/choiced/markings/markings_r_hand2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_r_hand) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_r_hand2
	savefile_key = "markings_r_hand_color2"
	markingval = MARKING_RHAND2

/datum/preference/color/markings/markings_r_hand2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_r_hand) != SPRITE_ACCESSORY_NONE

/datum/preference/choiced/markings/markings_r_hand3
	savefile_key = "markings_r_hand3"
	main_feature_name = "Bodymarkings Right Hand 3"
	body_zone = HAND_RIGHT
	markingval = MARKING_RHAND3

/datum/preference/choiced/markings/markings_r_hand3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_r_hand2) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_r_hand3
	savefile_key = "markings_r_hand_color3"
	markingval = MARKING_RHAND3

/datum/preference/color/markings/markings_r_hand3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_r_hand2) != SPRITE_ACCESSORY_NONE

// Left leg markings

/datum/preference/choiced/markings/markings_l_leg
	savefile_key = "markings_l_leg"
	main_feature_name = "Bodymarkings Left Leg"
	body_zone = LEG_LEFT
	markingval = MARKING_LLEG

/datum/preference/color/markings/markings_l_leg
	savefile_key = "markings_l_leg_color"
	markingval = MARKING_LLEG

/datum/preference/choiced/markings/markings_l_leg2
	savefile_key = "markings_l_leg2"
	main_feature_name = "Bodymarkings Left Leg 2"
	body_zone = LEG_LEFT
	markingval = MARKING_LLEG2

/datum/preference/choiced/markings/markings_l_leg2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_l_leg) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_l_leg2
	savefile_key = "markings_l_leg_color2"
	markingval = MARKING_LLEG2

/datum/preference/color/markings/markings_l_leg2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_l_leg) != SPRITE_ACCESSORY_NONE


/datum/preference/choiced/markings/markings_l_leg3
	savefile_key = "markings_l_leg3"
	main_feature_name = "Bodymarkings Left Leg 3"
	body_zone = LEG_LEFT
	markingval = MARKING_LLEG3

/datum/preference/choiced/markings/markings_l_leg3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_l_leg2) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_l_leg3
	savefile_key = "markings_l_leg_color3"
	markingval = MARKING_LLEG3

/datum/preference/color/markings/markings_l_leg3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_l_leg2) != SPRITE_ACCESSORY_NONE

// Right leg markings

/datum/preference/choiced/markings/markings_r_leg
	savefile_key = "markings_r_leg"
	main_feature_name = "Bodymarkings Right Leg"
	body_zone = LEG_RIGHT
	markingval = MARKING_RLEG

/datum/preference/color/markings/markings_r_leg
	savefile_key = "markings_r_leg_color"
	markingval = MARKING_RLEG

/datum/preference/choiced/markings/markings_r_leg2
	savefile_key = "markings_r_leg2"
	main_feature_name = "Bodymarkings Right Leg 2"
	body_zone = LEG_RIGHT
	markingval = MARKING_RLEG2

/datum/preference/choiced/markings/markings_r_leg2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_r_leg) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_r_leg2
	savefile_key = "markings_r_leg_color2"
	markingval = MARKING_RLEG2

/datum/preference/color/markings/markings_r_leg2/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_r_leg) != SPRITE_ACCESSORY_NONE

/datum/preference/choiced/markings/markings_r_leg3
	savefile_key = "markings_r_leg3"
	main_feature_name = "Bodymarkings Right Leg 3"
	body_zone = LEG_RIGHT
	markingval = MARKING_RLEG3

/datum/preference/choiced/markings/markings_r_leg3/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/markings/markings_r_leg2) != SPRITE_ACCESSORY_NONE

/datum/preference/color/markings/markings_r_leg3
	savefile_key = "markings_r_leg_color3"
	markingval = MARKING_RLEG3

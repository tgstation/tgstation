/// Female uniform datum. Helps us to create and use presets for clothing types
/datum/female_uniform
	/// Icon file with female version masks for this uniform
	var/icon/mask_icon = FEMALE_MASK_ICON_MODULAR
	/// Overrides mask's icon state to use in `wear_female_version()`. Null if no need to override
	var/mask_icon_state
	/// Bitflags for this mask
	var/mask_flags = NONE

/datum/female_uniform/turtleneck
	mask_icon_state = FEMALE_MASK_TURTLENECK
	mask_flags = FEMALE_MASK_APPLY_ON_ADJUSTED

/datum/female_uniform/rus_army
	mask_icon_state = FEMALE_MASK_RUS_ARMY

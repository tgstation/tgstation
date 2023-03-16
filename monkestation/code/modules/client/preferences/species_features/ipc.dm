/datum/preference/choiced/ipc_antenna
	savefile_key = "feature_ipc_antenna"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "IPC Antenna"
	should_generate_icons = TRUE

/datum/preference/choiced/ipc_antenna/init_possible_values()
	var/list/values = list()

	var/icon/ipc_head = icon('monkestation/icons/mob/species/ipc/bodyparts.dmi', "synth_head")

	for (var/antennae_name in GLOB.ipc_antennas_list)
		var/datum/sprite_accessory/antennae = GLOB.ipc_antennas_list[antennae_name]
		if(antennae.locked)
			continue

		var/icon/icon_with_antennae = new(ipc_head)
		icon_with_antennae.Blend(icon(antennae.icon, "m_ipc_antenna_[antennae.icon_state]_FRONT"), ICON_OVERLAY)
		icon_with_antennae.Scale(64, 64)
		icon_with_antennae.Crop(15, 64, 15 + 31, 64 - 31)

		values[antennae.name] = icon_with_antennae

	return values

/datum/preference/choiced/ipc_antenna/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_antenna"] = value


/datum/preference/choiced/ipc_chassis
	savefile_key = "feature_ipc_chassis"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "IPC Chassis"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "ipc_chassis"

/datum/preference/choiced/ipc_chassis/init_possible_values()
	var/list/values = list()

	var/icon/ipc = icon('monkestation/icons/mob/species/ipc/bodyparts.dmi', "blank")
	for (var/chassis_name in GLOB.ipc_chassis_list)
		var/datum/sprite_accessory/chassis = GLOB.ipc_chassis_list[chassis_name]
		if(chassis.locked)
			continue

		var/icon/chassis_icon = icon(
			'monkestation/icons/mob/species/ipc/ipc_chassis.dmi',
			"m_ipc_chassis_[chassis.icon_state]_FRONT")

		var/icon/final_icon = icon(ipc)
		final_icon.Blend(chassis_icon, ICON_OVERLAY)

		final_icon.Crop(10, 8, 22, 23)
		final_icon.Scale(26, 32)
		final_icon.Crop(-2, 1, 29, 32)

		values[chassis.name] = final_icon

	return values

/datum/preference/choiced/ipc_chassis/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_chassis"] = value
	target.regenerate_icons()

/datum/preference/choiced/ipc_screen
	savefile_key = "feature_ipc_screen"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "IPC Screen"
	relevant_mutant_bodypart = "ipc_screen"
	should_generate_icons = TRUE

/datum/preference/choiced/ipc_screen/init_possible_values()
	var/list/values = list()

	var/icon/ipc_head = icon('monkestation/icons/mob/species/ipc/bodyparts.dmi', "synth_head")

	for (var/screen_name in GLOB.ipc_screens_list)
		var/datum/sprite_accessory/screen = GLOB.ipc_screens_list[screen_name]
		if(screen.locked)
			continue

		var/icon/icon_with_screen = new(ipc_head)
		icon_with_screen.Blend(icon(screen.icon, "m_ipc_screen_[screen.icon_state]_ADJ"), ICON_OVERLAY)
		icon_with_screen.Scale(64, 64)
		icon_with_screen.Crop(15, 64, 15 + 31, 64 - 31)

		values[screen.name] = icon_with_screen

	return values

/datum/preference/choiced/ipc_screen/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_screen"] = value

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

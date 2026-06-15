/datum/species/shadow/get_species_description()
	return "The elusive Shadows of Frontier space."

/datum/species/shadow/get_species_lore()
	return list(
		"As a Shadow:",
		" + You have an example rule. ",
		" - You have an example restriction. ",
		"Lore unfinished."
	)

/datum/species/shadow/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "moon",
			SPECIES_PERK_NAME = "Shadowborn",
			SPECIES_PERK_DESC = "Their skin blooms in the darkness. All kinds of damage, \
				no matter how extreme, will heal over time as long as there is no light.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "Nightvision",
			SPECIES_PERK_DESC = "Their eyes are adapted to the night, and can see in the dark with no problems.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_MOON,
			SPECIES_PERK_NAME = "Ulterior motives",
			SPECIES_PERK_DESC = "Your goals may not align with the station or her crew. IMPORTANT: This is not a license to grief.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Lightburn",
			SPECIES_PERK_DESC = "Their flesh withers in the light. Any exposure to light is \
				incredibly painful for the shadowperson, charring their skin.",
		),
	)

	return to_add

/datum/species/pony
	name = "\improper Pony"
	plural_form = "Ponies"
	id = SPECIES_PONY
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
	)
	inherent_biotypes = MOB_ORGANIC
	mutant_organs = list( // TODO: SET THIS UP FOR THE HORN/WING/NONE CHOICE
		///obj/item/organ/horns = SPRITE_ACCESSORY_NONE,
	)
	mutanteyes = /obj/item/organ/eyes/pony
	sexes = FALSE // todo: get them to only be women
	payday_modifier = 0.8
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	no_equip_flags = ITEM_SLOT_GLOVES
	species_cookie = /obj/item/food/grown/apple
	inert_mutation = /datum/mutation/human/telekinesis
	species_language_holder = /datum/language_holder/pony

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/pony,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/pony,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/pony,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/pony,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/pony,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/pony,
	)

/datum/species/pony/randomize_features()
	var/list/features = ..()
	//features["lizard_markings"] = pick(SSaccessories.lizard_markings_list)
	return features

// TODO: GET WRITEUPS FROM WINTERSSHIELD ON THESE
/datum/species/pony/get_physical_attributes()
	return "Lizardpeople can withstand slightly higher temperatures than most species, but they are very vulnerable to the cold \
		and can't regulate their body-temperature internally, making the vacuum of space extremely deadly to them."

/datum/species/pony/get_species_description()
	return "The militaristic Lizardpeople hail originally from Tizira, but have grown \
		throughout their centuries in the stars to possess a large spacefaring \
		empire: though now they must contend with their younger, more \
		technologically advanced Human neighbours."

/datum/species/pony/get_species_lore()
	return list(
		"The face of conspiracy theory was changed forever the day mankind met the lizards.",

		"Hailing from the arid world of Tizira, lizards were travelling the stars back when mankind was first discovering how neat trains could be. \
		However, much like the space-fable of the space-tortoise and space-hare, lizards have rejected their kin's motto of \"slow and steady\" \
		in favor of resting on their laurels and getting completely surpassed by 'bald apes', due in no small part to their lack of access to plasma.",

		"The history between lizards and humans has resulted in many conflicts that lizards ended on the losing side of, \
		with the finale being an explosive remodeling of their moon. Today's lizard-human relations are seeing the continuance of a record period of peace.",

		"Lizard culture is inherently militaristic, though the influence the military has on lizard culture \
		begins to lessen the further colonies lie from their homeworld - \
		with some distanced colonies finding themselves subsumed by the cultural practices of other species nearby.",

		"On their homeworld, lizards celebrate their 16th birthday by enrolling in a mandatory 5 year military tour of duty. \
		Roles range from combat to civil service and everything in between. As the old slogan goes: \"Your place will be found!\"",
	)

/datum/species/get_features()
	var/list/features = ..()

	features += /datum/preference/choiced/lizard_snout
	features += /datum/preference/choiced/lizard_frills
	features += /datum/preference/choiced/lizard_horns
	features += /datum/preference/choiced/lizard_tail
	features += /datum/preference/choiced/lizard_body_markings

	GLOB.features_by_species[type] = features

	return features

/datum/bodypart_overlay/mutant
	/// Annoying annoying annoyed annoyance - this is to avoid a massive headache trying to work around tails
	var/feature_key_sprite = null

/datum/dna/initialize_dna(newblood_type, create_mutation_blocks = TRUE, randomize_features = TRUE)
	. = ..()
	/// Weirdness Check Zone
	if(randomize_features)
		if(istype(species, /datum/species/human/genemod))
			var/skin_tone = pick(GLOB.skin_tones)
			features["mcolor"] = skintone2hex(skin_tone) //spoof
		if(species.id != /datum/species/human/felinid::id)
			features["tail_cat"] = /datum/sprite_accessory/tails/human/none::name
			features["ears"] = /datum/sprite_accessory/ears/none::name
		if(species.id != /datum/species/monkey::id)
			features["tail_monkey"] = /datum/sprite_accessory/tails/monkey/none::name
		if(species.id != /datum/species/human/felinid::id)
			features["tail_cat"] = /datum/sprite_accessory/tails/human/none::name
	update_dna_identity()

/mob/living/carbon/human
	/// Color of the undershirt
	var/undershirt_color = "#FFFFFF"
	/// Color of the socks
	var/socks_color = "#FFFFFF"
	/// The selected bra.
	var/bra = "Nude"
	/// Color of the bra.
	var/bra_color = "#FFFFFF"
	/// Flags for showing/hiding underwear, toggleabley by a verb
	var/underwear_visibility = NONE

///copies over clothing preferences like underwear to another human
/mob/living/carbon/human/copy_clothing_prefs(mob/living/carbon/human/destination)
	. = ..()

	destination.undershirt_color = undershirt_color
	destination.socks_color = socks_color
	destination.bra = bra
	destination.bra_color = bra_color

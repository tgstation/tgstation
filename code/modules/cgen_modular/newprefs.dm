#define SUPPLEMENTAL_FEATURE_KEY "supplemental_feature"

/// FIRST TRI-COLOR
/datum/preference/tri_color/tricol_alpha
	savefile_key = "feature_tricolor_alpha"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_inherent_trait = USE_TRICOLOR_ALPHA

/datum/preference/tri_color/tricol_alpha/create_default_value()
	return list(COLOR_RED, COLOR_GREEN, COLOR_BLUE)

/datum/preference/tri_color/tricol_alpha/apply_to_human(mob/living/carbon/human/target, value)
	//to_chat(world, "GWA: applying tricolor alpha ([value[1]],[value[2]],[value[3]])")
	//world.log << "SCREAMING AS TRICOL ALPHA IS APPLIED MAYBE HOPEFULLY ([value[1]],[value[2]],[value[3]])"
	target.dna.features["tricolor-a1"] = value[1]
	target.dna.features["tricolor-a2"] = value[2]
	target.dna.features["tricolor-a3"] = value[3]

/datum/preference/tri_color/tricol_alpha/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE


/datum/mutant_newdnafeature/tricol_a1
	name = "Tri-Color A.1"
	id = "tricol-a1"

/datum/mutant_newdnafeature/tricol_a1/gen_unique_features(var/features, var/L)
	//world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL A1"
	if(features[id])
		L[DNA_TRICOL_A1_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_a1/update_appear(var/datum/dna/dna, var/features)
	//world.log << "SKYRAPTOR_NEWPRFS: UPDATING TRICOL A1"
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_A1_BLOCK))

/datum/mutant_newdnafeature/tricol_a2
	name = "Tri-Color A.2"
	id = "tricol-a2"

/datum/mutant_newdnafeature/tricol_a2/gen_unique_features(var/features, var/L)
	//world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL A2"
	if(features[id])
		L[DNA_TRICOL_A2_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_a2/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_A2_BLOCK))

/datum/mutant_newdnafeature/tricol_a3
	name = "Tri-Color A.3"
	id = "tricol-a3"

/datum/mutant_newdnafeature/tricol_a3/gen_unique_features(var/features, var/L)
	//world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL A3"
	if(features[id])
		L[DNA_TRICOL_A3_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_a3/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_A3_BLOCK))



/// SECOND TRI-COLOR
/datum/preference/tri_color/tricol_beta
	savefile_key = "feature_tricolor_beta"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_inherent_trait = USE_TRICOLOR_BETA

/datum/preference/tri_color/tricol_beta/create_default_value()
	return list(COLOR_RED, COLOR_GREEN, COLOR_BLUE)

/datum/preference/tri_color/tricol_beta/apply_to_human(mob/living/carbon/human/target, value)
	//to_chat(world, "GWA: applying tricolor beta ([value[1]],[value[2]],[value[3]])")
	//world.log << "SCREAMING AS TRICOL BETA IS APPLIED MAYBE HOPEFULLY ([value[1]],[value[2]],[value[3]])"
	target.dna.features["tricolor-b1"] = value[1]
	target.dna.features["tricolor-b2"] = value[2]
	target.dna.features["tricolor-b3"] = value[3]

/datum/preference/tri_color/tricol_beta/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE


/datum/mutant_newdnafeature/tricol_b1
	name = "Tri-Color B.1"
	id = "tricol-b1"

/datum/mutant_newdnafeature/tricol_b1/gen_unique_features(var/features, var/L)
	//world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL B1"
	if(features[id])
		L[DNA_TRICOL_B1_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_b1/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_B1_BLOCK))

/datum/mutant_newdnafeature/tricol_b2
	name = "Tri-Color B.2"
	id = "tricol-b2"

/datum/mutant_newdnafeature/tricol_b2/gen_unique_features(var/features, var/L)
	//world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL B2"
	if(features[id])
		L[DNA_TRICOL_B2_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_b2/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_B2_BLOCK))

/datum/mutant_newdnafeature/tricol_b3
	name = "Tri-Color B.3"
	id = "tricol-b3"

/datum/mutant_newdnafeature/tricol_b3/gen_unique_features(var/features, var/L)
	//world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL B3"
	if(features[id])
		L[DNA_TRICOL_B3_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_b3/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_B3_BLOCK))



/// TRI-COLOR 3 oH GOD
/// SECOND TRI-COLOR
/datum/preference/tri_color/tricol_charlie
	savefile_key = "feature_tricolor_charlie"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_inherent_trait = USE_TRICOLOR_CHARLIE

/datum/preference/tri_color/tricol_charlie/create_default_value()
	return list(COLOR_RED, COLOR_GREEN, COLOR_BLUE)

/datum/preference/tri_color/tricol_charlie/apply_to_human(mob/living/carbon/human/target, value)
	//to_chat(world, "GWA: applying tricolor charlie ([value[1]],[value[2]],[value[3]])")
	//world.log << "SCREAMING AS TRICOL CHARLIE IS APPLIED MAYBE HOPEFULLY ([value[1]],[value[2]],[value[3]])"
	target.dna.features["tricolor-c1"] = value[1]
	target.dna.features["tricolor-c2"] = value[2]
	target.dna.features["tricolor-c3"] = value[3]

/datum/preference/tri_color/tricol_charlie/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE


/datum/mutant_newdnafeature/tricol_c1
	name = "Tri-Color C.1"
	id = "tricol-c1"

/datum/mutant_newdnafeature/tricol_c1/gen_unique_features(var/features, var/L)
	//world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL B1"
	if(features[id])
		L[DNA_TRICOL_C1_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_c1/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_C1_BLOCK))

/datum/mutant_newdnafeature/tricol_c2
	name = "Tri-Color C.2"
	id = "tricol-c2"

/datum/mutant_newdnafeature/tricol_c2/gen_unique_features(var/features, var/L)
	//world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL B2"
	if(features[id])
		L[DNA_TRICOL_C2_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_c2/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_C2_BLOCK))

/datum/mutant_newdnafeature/tricol_c3
	name = "Tri-Color C.3"
	id = "tricol-c3"

/datum/mutant_newdnafeature/tricol_c3/gen_unique_features(var/features, var/L)
	//world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL B3"
	if(features[id])
		L[DNA_TRICOL_C3_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_c3/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_C3_BLOCK))



/// FRILLS COLORS FOR LIZARDS AND SCUGS
/datum/preference/color/frills_color
	savefile_key = "frills_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES

/datum/preference/color/frills_color/create_default_value()
	return sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")

/datum/preference/color/frills_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["frills_color"] = value

/datum/preference/color/frills_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE


/datum/preference/choiced/lizard_frills/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "frills_color"

	return data


/datum/mutant_newdnafeature/frills_color
	name = "Frills Color"
	id = "frills_color"

/datum/mutant_newdnafeature/frills_color/gen_unique_features(var/features, var/L)
	//world.log << "SKYRAPTOR_NEWPRFS: GENERATING FRILL COLORS"
	if(features[id])
		L[DNA_FRILLS_COLOR_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/frills_color/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_FRILLS_COLOR_BLOCK))



/// HORNS COLORS FOR LIZARDS AND SCUGS
/datum/preference/color/horns_color
	savefile_key = "horns_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES

/datum/preference/color/horns_color/create_default_value()
	return sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")

/datum/preference/color/horns_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["horns_color"] = value

/datum/preference/color/horns_color/is_valid(value)
	if (!..(value))
		return FALSE

	return TRUE


/datum/preference/choiced/lizard_horns/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "horns_color"

	return data


/datum/mutant_newdnafeature/horns_color
	name = "Horns Color"
	id = "horns_color"

/datum/mutant_newdnafeature/horns_color/gen_unique_features(var/features, var/L)
	//world.log << "SKYRAPTOR_NEWPREFS: GENERATING HORN COLORS"
	if(features[id])
		L[DNA_HORNS_COLOR_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/horns_color/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_HORNS_COLOR_BLOCK))

#undef SUPPLEMENTAL_FEATURE_KEY

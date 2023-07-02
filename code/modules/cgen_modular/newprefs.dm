/// FIRST TRI-COLOR
/datum/mutant_newdnafeature/tricol_a1
	name = "Tri-Color A.1"
	id = "tricol-a1"

/datum/mutant_newdnafeature/tricol_a1/gen_unique_features(var/features, var/L)
	world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL A1"
	if(features[id])
		L[DNA_TRICOL_A1_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_a1/update_appear(var/datum/dna/dna, var/features)
	world.log << "SKYRAPTOR_NEWPRFS: UPDATING TRICOL A1"
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_A1_BLOCK))

/datum/mutant_newdnafeature/tricol_a2
	name = "Tri-Color A.2"
	id = "tricol-a2"

/datum/mutant_newdnafeature/tricol_a2/gen_unique_features(var/features, var/L)
	world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL A2"
	if(features[id])
		L[DNA_TRICOL_A2_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_a2/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_A2_BLOCK))

/datum/mutant_newdnafeature/tricol_a3
	name = "Tri-Color A.3"
	id = "tricol-a3"

/datum/mutant_newdnafeature/tricol_a3/gen_unique_features(var/features, var/L)
	world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL A3"
	if(features[id])
		L[DNA_TRICOL_A3_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_a3/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_A3_BLOCK))



/// SECOND TRI-COLOR
/datum/mutant_newdnafeature/tricol_b1
	name = "Tri-Color B.1"
	id = "tricol-b1"

/datum/mutant_newdnafeature/tricol_b1/gen_unique_features(var/features, var/L)
	world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL B1"
	if(features[id])
		L[DNA_TRICOL_B1_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_b1/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_B1_BLOCK))

/datum/mutant_newdnafeature/tricol_b2
	name = "Tri-Color B.2"
	id = "tricol-b2"

/datum/mutant_newdnafeature/tricol_b2/gen_unique_features(var/features, var/L)
	world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL B2"
	if(features[id])
		L[DNA_TRICOL_B2_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_b2/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_B2_BLOCK))

/datum/mutant_newdnafeature/tricol_b3
	name = "Tri-Color B.3"
	id = "tricol-b3"

/datum/mutant_newdnafeature/tricol_b3/gen_unique_features(var/features, var/L)
	world.log << "SKYRAPTOR_NEWPRFS: GENERATING TRICOL B3"
	if(features[id])
		L[DNA_TRICOL_B3_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/tricol_b3/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_TRICOL_B3_BLOCK))



/// FRILLS AND HORNS COLORS FOR SCUGS
/datum/mutant_newdnafeature/frills_color
	name = "Frills Color"
	id = "frills_color"

/datum/mutant_newdnafeature/frills_color/gen_unique_features(var/features, var/L)
	world.log << "SKYRAPTOR_NEWPRFS: GENERATING FRILL COLORS"
	if(features[id])
		L[DNA_FRILLS_COLOR_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/frills_color/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_FRILLS_COLOR_BLOCK))

/datum/mutant_newdnafeature/horns_color
	name = "Horns Color"
	id = "horns_color"

/datum/mutant_newdnafeature/horns_color/gen_unique_features(var/features, var/L)
	world.log << "SKYRAPTOR_NEWPREFS: GENERATING HORN COLORS"
	if(features[id])
		L[DNA_HORNS_COLOR_BLOCK] = sanitize_hexcolor(features[id], include_crunch = FALSE)

/datum/mutant_newdnafeature/horns_color/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = sanitize_hexcolor(get_uni_feature_block(features, DNA_HORNS_COLOR_BLOCK))

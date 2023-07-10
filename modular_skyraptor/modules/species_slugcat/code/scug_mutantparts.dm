// == SECTION 1: SNOUTS ==
GLOBAL_LIST_EMPTY(snouts_list_slugcat)

/datum/mutant_spritecat/slugcat_snout
	name = "Slugcat Snouts"
	id = "snout_scug"
	sprite_acc = /datum/sprite_accessory/snouts/slugcat
	default = "Standard"

/datum/mutant_spritecat/slugcat_snout/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts/slugcat, GLOB.snouts_list_slugcat)
		world.log << "CELEBRATE: FOR THE SCUGS HAVE SNOOTS"
		return ..()

/datum/sprite_accessory/snouts/slugcat
	icon = 'modular_skyraptor/modules/species_slugcat/icons/slugcat_external.dmi'
	em_block = TRUE
	hasinner = TRUE
	inner_color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/snouts/slugcat/innercolor_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a1"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/snouts/slugcat/standard
	name = "Standard"
	icon_state = "standard"

/datum/sprite_accessory/snouts/slugcat/sharp
	name = "Sharp"
	icon_state = "sharp"

/datum/sprite_accessory/snouts/slugcat/round
	name = "Round"
	icon_state = "round"

/datum/mutant_newdnafeature/slugcat_snout
	name = "Slugcat Snout DNA"
	id = "snout_scug"

/datum/mutant_newdnafeature/slugcat_snout/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_SNOUT_BLOCK] = construct_block(GLOB.snouts_list_slugcat.Find(features[id]), GLOB.snouts_list_slugcat.len)
	return ..()

/datum/mutant_newdnafeature/slugcat_snout/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.snouts_list_slugcat[deconstruct_block(get_uni_feature_block(features, DNA_SNOUT_BLOCK), GLOB.snouts_list_slugcat.len)]
	return ..()



// == SECTION 2: BODYMARKINGS TESTING ==
GLOBAL_LIST_EMPTY(bodymarks_list_slugcat)

/datum/mutant_spritecat/slugcat_bodymarks
	name = "Slugcat Bodymarks"
	id = "bodymarks_scug"
	sprite_acc = /datum/sprite_accessory/body_markings/slugcat
	default = "None"

/datum/mutant_spritecat/slugcat_bodymarks/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings/slugcat, GLOB.bodymarks_list_slugcat)
		world.log << "CELEBRATE: FOR THE SCUGS HAVE BODY MARKINGS"
		return ..()

/datum/sprite_accessory/body_markings/slugcat
	icon = 'modular_skyraptor/modules/species_slugcat/icons/slugcat_external.dmi'
	color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/body_markings/slugcat/color_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a1"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/body_markings/slugcat/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/body_markings/slugcat/lbelly
	name = "Debug Light Belly"
	icon_state = "lbelly"
	gender_specific = 1



// == SECTION 2.1: SLUGCAT BODYMARKING PART TWO==
/datum/mutant_newmutantpart/bodymarks_slugcat
	name = "slugcat body markings"
	id = "bodymarks_scug"

/datum/mutant_newmutantpart/bodymarks_slugcat/get_accessory(var/bodypart, var/features)
	..()
	if(bodypart == "bodymarks_scug")
		return GLOB.bodymarks_list_slugcat[features["bodymarks_scug"]]
	else
		return FALSE

/datum/mutant_newdnafeature/slugcat_bodymark
	name = "Slugcat Body Pattern DNA"
	id = "bodymarks_scug"

/datum/mutant_newdnafeature/slugcat_bodymark/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_LIZARD_MARKINGS_BLOCK] = construct_block(GLOB.bodymarks_list_slugcat.Find(features[id]), GLOB.bodymarks_list_slugcat.len)
	return ..()

/datum/mutant_newdnafeature/slugcat_bodymark/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.bodymarks_list_slugcat[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_MARKINGS_BLOCK), GLOB.bodymarks_list_slugcat.len)]
		dna.features["body_markings"] = GLOB.bodymarks_list_slugcat[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_MARKINGS_BLOCK), GLOB.bodymarks_list_slugcat.len)]
	return ..()



// == SECTION 3: HORNS TO BECOME EARS AUGHNGH ==
GLOBAL_LIST_EMPTY(horns_list_slugcat)

/datum/mutant_spritecat/slugcat_horns
	name = "Slugcat Horns"
	id = "horns_scug"
	sprite_acc = /datum/sprite_accessory/horns/slugcat
	default = "Standard"

/datum/mutant_spritecat/slugcat_horns/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/horns/slugcat, GLOB.horns_list_slugcat)
		world.log << "CELEBRATE: FOR THE SCUGS HAVE HORN-EARS"
		return ..()

/datum/sprite_accessory/horns/slugcat
	icon = 'modular_skyraptor/modules/species_slugcat/icons/slugcat_external.dmi'
	em_block = TRUE

/datum/sprite_accessory/horns/slugcat/standard
	name = "Standard"
	icon_state = "standard"

/datum/sprite_accessory/horns/slugcat/tall
	name = "Tall"
	icon_state = "tall"

/datum/sprite_accessory/horns/slugcat/sharp
	name = "Sharp"
	icon_state = "sharp"

/datum/sprite_accessory/horns/slugcat/forward
	name = "Forward"
	icon_state = "forward"

/datum/sprite_accessory/horns/slugcat/flopped
	name = "Flopped"
	icon_state = "flopped"

/datum/sprite_accessory/horns/slugcat/fluffy
	name = "Fluffy"
	icon_state = "fluffy"

/datum/sprite_accessory/horns/slugcat/short
	name = "Short"
	icon_state = "short"

/datum/mutant_newdnafeature/slugcat_horns
	name = "Slugcat Horns DNA"
	id = "horns_scug"

/datum/mutant_newdnafeature/slugcat_horns/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_HORNS_BLOCK] = construct_block(GLOB.horns_list_slugcat.Find(features[id]), GLOB.horns_list_slugcat.len)
	return ..()

/datum/mutant_newdnafeature/slugcat_horns/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.horns_list_slugcat[deconstruct_block(get_uni_feature_block(features, DNA_HORNS_BLOCK), GLOB.horns_list_slugcat.len)]
	return ..()




// == SECTION 4: TAILS ==
GLOBAL_LIST_EMPTY(tails_list_slugcat)
/datum/mutant_spritecat/slugcat_tails
	name = "Slugcat Tails"
	id = "tail_scug"
	sprite_acc = /datum/sprite_accessory/tails/slugcat
	default = "Standard"

/datum/mutant_spritecat/slugcat_tails/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/slugcat, GLOB.tails_list_slugcat)
		world.log << "CELEBRATE: FOR THE SCUGS HAVE TAILS"
		return ..()

/datum/sprite_accessory/tails/slugcat
	icon = 'modular_skyraptor/modules/species_slugcat/icons/slugcat_tails.dmi'

/datum/sprite_accessory/tails/slugcat/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/tails/slugcat/standard
	name = "Standard"
	icon_state = "std"

/datum/sprite_accessory/tails/slugcat/thick
	name = "Thick"
	icon_state = "thick"

/datum/mutant_newdnafeature/slugcat_tail
	name = "Slugcat Tails DNA"
	id = "tail_scug"

/datum/mutant_newdnafeature/slugcat_tail/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_LIZARD_TAIL_BLOCK] = construct_block(GLOB.tails_list_slugcat.Find(features[id]), GLOB.tails_list_slugcat.len)
	return ..()

/datum/mutant_newdnafeature/slugcat_tail/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.tails_list_slugcat[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_TAIL_BLOCK), GLOB.tails_list_slugcat.len)]
	return ..()




// == SECTION 5: FRILLS ==
GLOBAL_LIST_EMPTY(frills_list_slugcat)

/datum/mutant_spritecat/slugcat_frills
	name = "Slugcat Frills"
	id = "frills_scug"
	sprite_acc = /datum/sprite_accessory/frills/slugcat
	default = "None"

/datum/mutant_spritecat/slugcat_frills/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/frills/slugcat, GLOB.frills_list_slugcat)
		world.log << "CELEBRATE: FOR THE SCUGS HAVE SNOOTS"
		return ..()

/datum/sprite_accessory/frills/slugcat
	icon = 'modular_skyraptor/modules/species_slugcat/icons/slugcat_external.dmi'
	em_block = TRUE

/datum/sprite_accessory/frills/slugcat/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/frills/slugcat/aquatic
	name = "Aquatic"
	icon_state = "aquatic"

/datum/sprite_accessory/frills/slugcat/sharp
	name = "Sharp"
	icon_state = "sharp"

/datum/sprite_accessory/frills/slugcat/fluffy
	name = "Fluffy"
	icon_state = "fluffy"

/datum/mutant_newdnafeature/slugcat_frills
	name = "Slugcat Frills DNA"
	id = "frills_scug"

/datum/mutant_newdnafeature/slugcat_frills/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_FRILLS_BLOCK] = construct_block(GLOB.frills_list_slugcat.Find(features[id]), GLOB.frills_list_slugcat.len)
	return ..()

/datum/mutant_newdnafeature/slugcat_frills/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.frills_list_slugcat[deconstruct_block(get_uni_feature_block(features, DNA_FRILLS_BLOCK), GLOB.frills_list_slugcat.len)]
	return ..()

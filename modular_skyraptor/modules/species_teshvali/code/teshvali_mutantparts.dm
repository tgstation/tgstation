// == SECTION 1: SNOUTS ==
GLOBAL_LIST_EMPTY(snouts_list_teshvali)

/datum/mutant_spritecat/teshvali_snout
	name = "Teshari Snouts"
	id = "snout_teshvali"
	sprite_acc = /datum/sprite_accessory/snouts/teshvali
	default = "Standard"

/datum/mutant_spritecat/teshvali_snout/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts/teshvali, GLOB.snouts_list_teshvali)
		world.log << "CELEBRATE: FOR THE TESHIS HAVE SNOOTS"
		return ..()

/datum/sprite_accessory/snouts/teshvali
	icon = 'modular_skyraptor/modules/species_teshvali/icons/teshvali_external.dmi'
	em_block = TRUE
	hasinner = TRUE
	inner_color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/snouts/teshvali/innercolor_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a1"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/snouts/teshvali/standard
	name = "Standard"
	icon_state = "standard"

/datum/sprite_accessory/snouts/teshvali/sharp
	name = "Sniffer"
	icon_state = "sniffer"

/datum/mutant_newdnafeature/teshvali_snout
	name = "Teshari Snout DNA"
	id = "snout_teshvali"

/datum/mutant_newdnafeature/teshvali_snout/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_SNOUT_BLOCK] = construct_block(GLOB.snouts_list_teshvali.Find(features[id]), GLOB.snouts_list_teshvali.len)
	return ..()

/datum/mutant_newdnafeature/teshvali_snout/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.snouts_list_teshvali[deconstruct_block(get_uni_feature_block(features, DNA_SNOUT_BLOCK), GLOB.snouts_list_teshvali.len)]
	return ..()



// == SECTION 2: BODYMARKINGS TESTING ==
GLOBAL_LIST_EMPTY(bodymarks_list_teshvali)

/datum/mutant_spritecat/teshvali_bodymarks
	name = "Teshari Bodymarks"
	id = "bodymarks_teshvali"
	sprite_acc = /datum/sprite_accessory/body_markings/teshvali
	default = "None"

/datum/mutant_spritecat/teshvali_bodymarks/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings/teshvali, GLOB.bodymarks_list_teshvali)
		world.log << "CELEBRATE: FOR THE TESHIS HAVE BODY MARKINGS"
		return ..()

/datum/sprite_accessory/body_markings/teshvali
	icon = 'modular_skyraptor/modules/species_teshvali/icons/teshvali_external.dmi'
	color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/body_markings/teshvali/color_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a1"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/body_markings/teshvali/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/body_markings/teshvali/lbelly
	name = "Light Belly"
	icon_state = "lbelly"
	gender_specific = 1



// == SECTION 2.1: SLUGCAT BODYMARKING PART TWO==
/datum/mutant_newmutantpart/bodymarks_teshvali
	name = "teshvali body markings"
	id = "bodymarks_teshvali"

/datum/mutant_newmutantpart/bodymarks_teshvali/get_accessory(var/bodypart, var/features)
	..()
	if(bodypart == "bodymarks_teshvali")
		return GLOB.bodymarks_list_teshvali[features["bodymarks_teshvali"]]
	else
		return FALSE

/datum/mutant_newdnafeature/teshvali_bodymark
	name = "Teshari Body Pattern DNA"
	id = "bodymarks_teshvali"

/datum/mutant_newdnafeature/teshvali_bodymark/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_LIZARD_MARKINGS_BLOCK] = construct_block(GLOB.bodymarks_list_teshvali.Find(features[id]), GLOB.bodymarks_list_teshvali.len)
	return ..()

/datum/mutant_newdnafeature/teshvali_bodymark/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.bodymarks_list_teshvali[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_MARKINGS_BLOCK), GLOB.bodymarks_list_teshvali.len)]
		dna.features["body_markings"] = GLOB.bodymarks_list_teshvali[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_MARKINGS_BLOCK), GLOB.bodymarks_list_teshvali.len)]
	return ..()



// == SECTION 3: HORNS TO BECOME EARS AUGHNGH ==
GLOBAL_LIST_EMPTY(horns_list_teshvali)

/datum/mutant_spritecat/teshvali_horns
	name = "Teshari Horns"
	id = "horns_teshvali"
	sprite_acc = /datum/sprite_accessory/horns/teshvali
	default = "Fluffy"

/datum/mutant_spritecat/teshvali_horns/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/horns/teshvali, GLOB.horns_list_teshvali)
		world.log << "CELEBRATE: FOR THE SCUGS HAVE HORN-EARS"
		return ..()

/datum/sprite_accessory/horns/teshvali
	icon = 'modular_skyraptor/modules/species_teshvali/icons/teshvali_external.dmi'
	em_block = TRUE
	hasinner = TRUE
	inner_color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/horns/teshvali/innercolor_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a2"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/horns/teshvali/fluffy
	name = "Fluffy"
	icon_state = "fluffy"

/datum/sprite_accessory/horns/teshvali/upright
	name = "Upright"
	icon_state = "upright"

/datum/sprite_accessory/horns/teshvali/mane
	name = "Mane"
	icon_state = "mane"

/datum/mutant_newdnafeature/teshvali_horns
	name = "Teshari Horns DNA"
	id = "horns_teshvali"

/datum/mutant_newdnafeature/teshvali_horns/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_HORNS_BLOCK] = construct_block(GLOB.horns_list_teshvali.Find(features[id]), GLOB.horns_list_teshvali.len)
	return ..()

/datum/mutant_newdnafeature/teshvali_horns/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.horns_list_teshvali[deconstruct_block(get_uni_feature_block(features, DNA_HORNS_BLOCK), GLOB.horns_list_teshvali.len)]
	return ..()



// == SECTION 4: TAILS ==
GLOBAL_LIST_EMPTY(tails_list_teshvali)
/datum/mutant_spritecat/teshvali_tails
	name = "Slugcat Tails"
	id = "tail_teshvali"
	sprite_acc = /datum/sprite_accessory/tails/teshvali
	default = "Standard"

/datum/mutant_spritecat/teshvali_tails/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/teshvali, GLOB.tails_list_teshvali)
		world.log << "CELEBRATE: FOR THE SCUGS HAVE TAILS"
		return ..()

/datum/sprite_accessory/tails/teshvali
	icon = 'modular_skyraptor/modules/species_teshvali/icons/teshvali_tails.dmi'
	hasinner = TRUE
	inner_color_src = SPRITE_ACC_SCRIPTED_COLOR
	hasinner2 = TRUE
	inner2_color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/tails/teshvali/innercolor_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a1"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/tails/teshvali/innercolor2_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a3"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/tails/teshvali/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/tails/teshvali/fluffy
	name = "Fluffy"
	icon_state = "fluffy"

/datum/mutant_newdnafeature/teshvali_tail
	name = "Slugcat Tails DNA"
	id = "tail_teshvali"

/datum/mutant_newdnafeature/teshvali_tail/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_LIZARD_TAIL_BLOCK] = construct_block(GLOB.tails_list_teshvali.Find(features[id]), GLOB.tails_list_teshvali.len)
	return ..()

/datum/mutant_newdnafeature/teshvali_tail/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.tails_list_teshvali[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_TAIL_BLOCK), GLOB.tails_list_teshvali.len)]
	return ..()

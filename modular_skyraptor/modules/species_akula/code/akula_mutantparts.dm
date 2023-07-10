// == SECTION 1: SNOUTS ==
GLOBAL_LIST_EMPTY(snouts_list_akula)

/datum/mutant_spritecat/akula_snout
	name = "Akula Snouts"
	id = "snout_akula"
	sprite_acc = /datum/sprite_accessory/snouts/akula
	default = "Full Snout"

/datum/mutant_spritecat/akula_snout/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts/akula, GLOB.snouts_list_akula)
		world.log << "CELEBRATE: FOR THE AKULA HAVE SNOOTS"
		return ..()

/datum/sprite_accessory/snouts/akula
	icon = 'modular_skyraptor/modules/species_akula/icons/akula_external.dmi'
	em_block = TRUE
	hasinner = TRUE
	inner_color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/snouts/akula/innercolor_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a1"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/snouts/akula/fullsnout
	name = "Full Snout"
	icon_state = "fullsnout"
	hasinner = TRUE


/datum/mutant_newdnafeature/akula_snout
	name = "Akula Snout DNA"
	id = "snout_akula"

/datum/mutant_newdnafeature/akula_snout/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_SNOUT_BLOCK] = construct_block(GLOB.snouts_list_akula.Find(features[id]), GLOB.snouts_list_akula.len)
	return ..()

/datum/mutant_newdnafeature/akula_snout/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.snouts_list_akula[deconstruct_block(get_uni_feature_block(features, DNA_SNOUT_BLOCK), GLOB.snouts_list_akula.len)]
	return ..()



// == SECTION 2: BODYMARKINGS TESTING ==
GLOBAL_LIST_EMPTY(bodymarks_list_akula)

/datum/mutant_spritecat/akula_bodymarks
	name = "Akula Bodymarks"
	id = "bodymarks_akula"
	sprite_acc = /datum/sprite_accessory/body_markings/akula
	default = "Light belly"

/datum/mutant_spritecat/akula_bodymarks/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings/akula, GLOB.bodymarks_list_akula)
		world.log << "CELEBRATE: FOR THE AKULA HAVE BODY MARKINGS"
		return ..()

/datum/sprite_accessory/body_markings/akula
	icon = 'modular_skyraptor/modules/species_akula/icons/akula_external.dmi'
	color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/body_markings/akula/color_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a1"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/body_markings/akula/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/body_markings/akula/lbelly
	name = "Light Belly"
	icon_state = "lbelly"
	gender_specific = 1



// == SECTION 2.1: SLUGCAT BODYMARKING PART TWO==
/datum/mutant_newmutantpart/bodymarks_akula
	name = "akula body markings"
	id = "bodymarks_akula"

/datum/mutant_newmutantpart/bodymarks_akula/get_accessory(var/bodypart, var/features)
	..()
	if(bodypart == "bodymarks_akula")
		return GLOB.bodymarks_list_akula[features["bodymarks_akula"]]
	else
		return FALSE


/datum/mutant_newdnafeature/akula_bodymark
	name = "Akula Body Pattern DNA"
	id = "bodymarks_akula"

/datum/mutant_newdnafeature/akula_bodymark/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_LIZARD_MARKINGS_BLOCK] = construct_block(GLOB.bodymarks_list_akula.Find(features[id]), GLOB.bodymarks_list_akula.len)
	return ..()

/datum/mutant_newdnafeature/akula_bodymark/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.bodymarks_list_akula[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_MARKINGS_BLOCK), GLOB.bodymarks_list_akula.len)]
		dna.features["body_markings"] = GLOB.bodymarks_list_akula[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_MARKINGS_BLOCK), GLOB.bodymarks_list_akula.len)]
	return ..()



// == SECTION 3: HORNS TO BECOME EARS AUGHNGH ==
GLOBAL_LIST_EMPTY(horns_list_akula)

/datum/mutant_spritecat/akula_horns
	name = "Akula Horns"
	id = "horns_akula"
	sprite_acc = /datum/sprite_accessory/horns/akula
	default = "Standard"

/datum/mutant_spritecat/akula_horns/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/horns/akula, GLOB.horns_list_akula)
		world.log << "CELEBRATE: FOR THE AKULA HAVE HORN-EARS"
		return ..()

/datum/sprite_accessory/horns/akula
	icon = 'modular_skyraptor/modules/species_akula/icons/akula_external.dmi'
	em_block = TRUE
	hasinner = TRUE
	inner_color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/horns/akula/innercolor_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a2"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/horns/akula/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/horns/akula/perky
	name = "Perky"
	icon_state = "perky"
	hasinner = TRUE

/datum/mutant_newdnafeature/akula_horns
	name = "Akula Horns DNA"
	id = "horns_akula"

/datum/mutant_newdnafeature/akula_horns/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_HORNS_BLOCK] = construct_block(GLOB.horns_list_akula.Find(features[id]), GLOB.horns_list_akula.len)
	return ..()

/datum/mutant_newdnafeature/akula_horns/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.horns_list_akula[deconstruct_block(get_uni_feature_block(features, DNA_HORNS_BLOCK), GLOB.horns_list_akula.len)]
	return ..()



// == SECTION 4: TAILS ==
GLOBAL_LIST_EMPTY(tails_list_akula)
/datum/mutant_spritecat/akula_tails
	name = "Akula Tails"
	id = "tail_akula"
	sprite_acc = /datum/sprite_accessory/tails/akula
	default = "Standard"

/datum/mutant_spritecat/akula_tails/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/akula, GLOB.tails_list_akula)
		world.log << "CELEBRATE: FOR THE AKULA HAVE TAILS"
		return ..()

/datum/sprite_accessory/tails/akula
	icon = 'modular_skyraptor/modules/species_akula/icons/akula_tails.dmi'

/datum/sprite_accessory/tails/akula/shark
	name = "Shark"
	icon_state = "shark"

/datum/sprite_accessory/tails/akula/shark_nofin
	name = "Shark No-Fin"
	icon_state = "sharknofin"

/datum/sprite_accessory/tails/akula/fish
	name = "Fish"
	icon_state = "fish"

/datum/mutant_newdnafeature/akula_tail
	name = "Akula Tails DNA"
	id = "tail_akula"

/datum/mutant_newdnafeature/akula_tail/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_LIZARD_TAIL_BLOCK] = construct_block(GLOB.tails_list_akula.Find(features[id]), GLOB.tails_list_akula.len)
	return ..()

/datum/mutant_newdnafeature/akula_tail/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.tails_list_akula[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_TAIL_BLOCK), GLOB.tails_list_akula.len)]
	return ..()

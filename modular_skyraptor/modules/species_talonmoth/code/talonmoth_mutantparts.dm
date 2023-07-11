// == SECTION 1: SNOUTS ==
GLOBAL_LIST_EMPTY(snouts_list_talonmoth)

/datum/mutant_spritecat/talonmoth_snout
	name = "Talon Moth Snouts"
	id = "snout_talonmoth"
	sprite_acc = /datum/sprite_accessory/snouts/talonmoth
	default = "Long"

/datum/mutant_spritecat/talonmoth_snout/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts/talonmoth, GLOB.snouts_list_talonmoth)
		world.log << "CELEBRATE: FOR THE MOFFS HAVE SNOOTS"
		return ..()

/datum/sprite_accessory/snouts/talonmoth
	icon = 'modular_skyraptor/modules/species_talonmoth/icons/talonmoth_external.dmi'
	em_block = TRUE
	hasinner = TRUE
	inner_color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/snouts/talonmoth/innercolor_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a1"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/snouts/talonmoth/long
	name = "Long"
	icon_state = "long"
	hasinner = TRUE

/datum/sprite_accessory/snouts/talonmoth/short
	name = "Short"
	icon_state = "short"
	hasinner = TRUE


/datum/mutant_newdnafeature/talonmoth_snout
	name = "Talonmoth Snout DNA"
	id = "snout_talonmoth"

/datum/mutant_newdnafeature/talonmoth_snout/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_SNOUT_BLOCK] = construct_block(GLOB.snouts_list_talonmoth.Find(features[id]), GLOB.snouts_list_talonmoth.len)
	return ..()

/datum/mutant_newdnafeature/talonmoth_snout/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.snouts_list_talonmoth[deconstruct_block(get_uni_feature_block(features, DNA_SNOUT_BLOCK), GLOB.snouts_list_talonmoth.len)]
	return ..()




// == SECTION 2: BODYMARKINGS TESTING ==
GLOBAL_LIST_EMPTY(bodymarks_list_talonmoth)

/datum/mutant_spritecat/talonmoth_bodymarks
	name = "Talon Moth Bodymarks"
	id = "bodymarks_talonmoth"
	sprite_acc = /datum/sprite_accessory/body_markings/talonmoth
	default = "None"

/datum/mutant_spritecat/talonmoth_bodymarks/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings/talonmoth, GLOB.bodymarks_list_talonmoth)
		world.log << "CELEBRATE: FOR THE MOFFS HAVE BODY MARKINGS"
		return ..()

/datum/sprite_accessory/body_markings/talonmoth
	icon = 'modular_skyraptor/modules/species_talonmoth/icons/talonmoth_external.dmi'
	color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/body_markings/talonmoth/color_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a1"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/body_markings/talonmoth/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/body_markings/talonmoth/lbelly
	name = "Light Belly"
	icon_state = "lbelly"
	gender_specific = 1



// == SECTION 2.1: SLUGCAT BODYMARKING PART TWO==
/datum/mutant_newmutantpart/bodymarks_talonmoth
	name = "talonmoth body markings"
	id = "bodymarks_talonmoth"

/datum/mutant_newmutantpart/bodymarks_talonmoth/get_accessory(var/bodypart, var/features)
	..()
	if(bodypart == "bodymarks_talonmoth")
		return GLOB.bodymarks_list_talonmoth[features["bodymarks_talonmoth"]]
	else
		return FALSE

/datum/mutant_newdnafeature/talonmoth_bodymark
	name = "Talon Moth Body Pattern DNA"
	id = "bodymarks_talonmoth"

/datum/mutant_newdnafeature/talonmoth_bodymark/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_LIZARD_MARKINGS_BLOCK] = construct_block(GLOB.bodymarks_list_talonmoth.Find(features[id]), GLOB.bodymarks_list_talonmoth.len)
	return ..()

/datum/mutant_newdnafeature/talonmoth_bodymark/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.bodymarks_list_talonmoth[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_MARKINGS_BLOCK), GLOB.bodymarks_list_talonmoth.len)]
		dna.features["body_markings"] = GLOB.bodymarks_list_talonmoth[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_MARKINGS_BLOCK), GLOB.bodymarks_list_talonmoth.len)]
	return ..()

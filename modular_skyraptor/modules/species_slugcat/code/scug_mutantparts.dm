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

/datum/sprite_accessory/snouts/slugcat/standard
	name = "Standard"
	icon_state = "standard"



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

/datum/mutant_newdnafeature/akula_bodymark/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_LIZARD_MARKINGS_BLOCK] = construct_block(GLOB.bodymarks_list_slugcat.Find(features[id]), GLOB.bodymarks_list_slugcat.len)
	return ..()

/datum/mutant_newdnafeature/akula_bodymark/update_appear(var/datum/dna/dna, var/features)
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

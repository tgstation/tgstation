// == SECTION 1: SNOUTS ==
GLOBAL_LIST_EMPTY(snouts_list_avalari)

/datum/mutant_spritecat/avalari_snout
	name = "Avali Snouts"
	id = "snout_avalari"
	sprite_acc = /datum/sprite_accessory/snouts/avalari
	default = "Standard"

/datum/mutant_spritecat/avalari_snout/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts/avalari, GLOB.snouts_list_avalari)
		world.log << "CELEBRATE: FOR THE AVALI HAVE SNOOTS"
		return ..()

/datum/sprite_accessory/snouts/avalari
	icon = 'modular_skyraptor/modules/species_teshvali/icons/avalari_external.dmi'
	em_block = TRUE
	hasinner = TRUE
	inner_color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/snouts/avalari/innercolor_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a1"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/snouts/avalari/standard
	name = "Standard"
	icon_state = "standard"

/datum/sprite_accessory/snouts/avalari/sharp
	name = "Sniffer"
	icon_state = "sniffer"

/datum/mutant_newdnafeature/avalari_snout
	name = "Avali Snout DNA"
	id = "snout_avalari"

/datum/mutant_newdnafeature/avalari_snout/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_SNOUT_BLOCK] = construct_block(GLOB.snouts_list_avalari.Find(features[id]), GLOB.snouts_list_avalari.len)
	return ..()

/datum/mutant_newdnafeature/avalari_snout/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.snouts_list_avalari[deconstruct_block(get_uni_feature_block(features, DNA_SNOUT_BLOCK), GLOB.snouts_list_avalari.len)]
	return ..()



// == SECTION 2: BODYMARKINGS TESTING ==
GLOBAL_LIST_EMPTY(bodymarks_list_avalari)

/datum/mutant_spritecat/avalari_bodymarks
	name = "Avali Bodymarks"
	id = "bodymarks_avalari"
	sprite_acc = /datum/sprite_accessory/body_markings/avalari
	default = "None"

/datum/mutant_spritecat/avalari_bodymarks/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings/avalari, GLOB.bodymarks_list_avalari)
		world.log << "CELEBRATE: FOR THE AVALI HAVE BODY MARKINGS"
		return ..()

/datum/sprite_accessory/body_markings/avalari
	icon = 'modular_skyraptor/modules/species_teshvali/icons/avalari_external.dmi'
	color_src = SPRITE_ACC_SCRIPTED_COLOR
	hasinner = TRUE
	inner_color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/body_markings/avalari/color_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a1"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/body_markings/avalari/innercolor_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a3"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/body_markings/avalari/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/body_markings/avalari/lbelly
	name = "Light Belly"
	icon_state = "lbelly"
	gender_specific = 1

/datum/sprite_accessory/body_markings/avalari/lbelly_striped
	name = "Striped Light Belly"
	icon_state = "lbelly_striped"
	gender_specific = 1

/datum/sprite_accessory/body_markings/avalari/belly_striped
	name = "Striped Belly"
	icon_state = "belly_striped"
	gender_specific = 1



// == SECTION 2.1: SLUGCAT BODYMARKING PART TWO==
/datum/mutant_newmutantpart/bodymarks_avalari
	name = "avalari body markings"
	id = "bodymarks_avalari"

/datum/mutant_newmutantpart/bodymarks_avalari/get_accessory(var/bodypart, var/features)
	..()
	if(bodypart == "bodymarks_avalari")
		return GLOB.bodymarks_list_avalari[features["bodymarks_avalari"]]
	else
		return FALSE

/datum/mutant_newdnafeature/avalari_bodymark
	name = "Avali Body Pattern DNA"
	id = "bodymarks_avalari"

/datum/mutant_newdnafeature/avalari_bodymark/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_LIZARD_MARKINGS_BLOCK] = construct_block(GLOB.bodymarks_list_avalari.Find(features[id]), GLOB.bodymarks_list_avalari.len)
	return ..()

/datum/mutant_newdnafeature/avalari_bodymark/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.bodymarks_list_avalari[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_MARKINGS_BLOCK), GLOB.bodymarks_list_avalari.len)]
		dna.features["body_markings"] = GLOB.bodymarks_list_avalari[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_MARKINGS_BLOCK), GLOB.bodymarks_list_avalari.len)]
	return ..()



// == SECTION 3: HORNS TO BECOME EARS AUGHNGH ==
GLOBAL_LIST_EMPTY(horns_list_avalari)

/datum/mutant_spritecat/avalari_horns
	name = "Avali Horns"
	id = "horns_avalari"
	sprite_acc = /datum/sprite_accessory/horns/avalari
	default = "Fluffy"

/datum/mutant_spritecat/avalari_horns/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/horns/avalari, GLOB.horns_list_avalari)
		world.log << "CELEBRATE: FOR THE AVALI HAVE HORN-EARS"
		return ..()

/datum/sprite_accessory/horns/avalari
	icon = 'modular_skyraptor/modules/species_teshvali/icons/avalari_external.dmi'
	em_block = TRUE
	hasinner = TRUE
	inner_color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/horns/avalari/innercolor_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a2"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/horns/avalari/regular
	name = "Regular"
	icon_state = "regular"

/datum/sprite_accessory/horns/avalari/bushy
	name = "Bushy"
	icon_state = "bushy"

/datum/sprite_accessory/horns/avalari/spiky
	name = "Spiky"
	icon_state = "spiky"

/datum/sprite_accessory/horns/avalari/mohawk
	name = "Mohawk"
	icon_state = "mohawk"

/datum/sprite_accessory/horns/avalari/pointy
	name = "Pointy"
	icon_state = "Pointy"

/datum/sprite_accessory/horns/avalari/upright
	name = "Upright"
	icon_state = "upright"

/datum/sprite_accessory/horns/avalari/mane
	name = "Mane"
	icon_state = "mane"

/datum/sprite_accessory/horns/avalari/maneless
	name = "Mane (Fluffless)"
	icon_state = "maneless"

/datum/sprite_accessory/horns/avalari/droopy
	name = "Droopy"
	icon_state = "droopy"

/datum/sprite_accessory/horns/avalari/longway
	name = "Longway"
	icon_state = "longway"

/datum/sprite_accessory/horns/avalari/tree
	name = "Tree"
	icon_state = "tree"

/datum/sprite_accessory/horns/avalari/ponytail
	name = "Ponytail"
	icon_state = "ponytail"

/datum/sprite_accessory/horns/avalari/mushroom
	name = "Mushroom"
	icon_state = "mushroom"

/datum/sprite_accessory/horns/avalari/backstrafe
	name = "Backstrafe"
	icon_state = "backstrafe"

/datum/sprite_accessory/horns/avalari/thinmohawk
	name = "Thin Mohawk"
	icon_state = "thinmohawk"

/datum/sprite_accessory/horns/avalari/thin
	name = "Thin"
	icon_state = "thin"

/datum/sprite_accessory/horns/avalari/thinmane
	name = "Thin Mane"
	icon_state = "thinmane"

/datum/sprite_accessory/horns/avalari/thinmaneless
	name = "Thin Mane (Fluffless)"
	icon_state = "thinmaneless"

/datum/sprite_accessory/horns/avalari/wooly
	name = "Wooly"
	icon_state = "wooly"

/datum/mutant_newdnafeature/avalari_horns
	name = "Avali Horns DNA"
	id = "horns_avalari"

/datum/mutant_newdnafeature/avalari_horns/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_HORNS_BLOCK] = construct_block(GLOB.horns_list_avalari.Find(features[id]), GLOB.horns_list_avalari.len)
	return ..()

/datum/mutant_newdnafeature/avalari_horns/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.horns_list_avalari[deconstruct_block(get_uni_feature_block(features, DNA_HORNS_BLOCK), GLOB.horns_list_avalari.len)]
	return ..()



// == SECTION 4: TAILS ==
GLOBAL_LIST_EMPTY(tails_list_avalari)
/datum/mutant_spritecat/avalari_tails
	name = "Avali Tails"
	id = "tail_avalari"
	sprite_acc = /datum/sprite_accessory/tails/avalari
	default = "Standard"

/datum/mutant_spritecat/avalari_tails/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/avalari, GLOB.tails_list_avalari)
		world.log << "CELEBRATE: FOR THE AVALI HAVE TAILS"
		return ..()

/datum/sprite_accessory/tails/avalari
	icon = 'modular_skyraptor/modules/species_teshvali/icons/avalari_tails.dmi'
	hasinner = TRUE
	inner_color_src = SPRITE_ACC_SCRIPTED_COLOR
	hasinner2 = TRUE
	inner2_color_src = SPRITE_ACC_SCRIPTED_COLOR

/datum/sprite_accessory/tails/avalari/innercolor_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a1"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/tails/avalari/innercolor2_override(mob/living/carbon/human/target)
	if(!isnull(target))
		var/col = target.dna.features["tricolor-a3"]
		if(!isnull(col))
			return col
		else
			return COLOR_WHITE
	else
		return COLOR_WHITE

/datum/sprite_accessory/tails/avalari/standard
	name = "Standard"
	icon_state = "standard"

/datum/sprite_accessory/tails/avalari/fluffy
	name = "Fluffy"
	icon_state = "fluffy"

/datum/sprite_accessory/tails/avalari/thin
	name = "Thin"
	icon_state = "thin"

/datum/mutant_newdnafeature/avalari_tail
	name = "Avali Tails DNA"
	id = "tail_avalari"

/datum/mutant_newdnafeature/avalari_tail/gen_unique_features(var/features, var/L)
	if(features[id])
		L[DNA_LIZARD_TAIL_BLOCK] = construct_block(GLOB.tails_list_avalari.Find(features[id]), GLOB.tails_list_avalari.len)
	return ..()

/datum/mutant_newdnafeature/avalari_tail/update_appear(var/datum/dna/dna, var/features)
	if(dna.features[id])
		dna.features[id] = GLOB.tails_list_avalari[deconstruct_block(get_uni_feature_block(features, DNA_LIZARD_TAIL_BLOCK), GLOB.tails_list_avalari.len)]
	return ..()

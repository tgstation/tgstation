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

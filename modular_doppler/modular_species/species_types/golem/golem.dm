//// Doppler Golems - Overwrites and continuiations of
// code/modules/mob/living/carbon/human/species_types/golems.dm
/datum/species/golem
	preview_outfit = /datum/outfit/golem_preview
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_LAVA_IMMUNE,
		TRAIT_NEVER_WOUNDED,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
	//	TRAIT_NODISMEMBER,	removing this for now...
		TRAIT_NOFIRE,
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_PLASMA_TRANSFORM,
		TRAIT_NO_UNDERWEAR,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_SNOWSTORM_IMMUNE,
		TRAIT_UNHUSKABLE,
		TRAIT_BOULDER_BREAKER,
		//deviating from TG here <--
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
	)
	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN //golem ERT

/datum/outfit/golem_preview
	name = "Golem (Species Preview)"
	head = /obj/item/food/grown/poppy/geranium/fraxinella

/datum/species/golem/get_species_lore()
	return list(
		"@Lobster",
	)

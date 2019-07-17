/datum/species/spurdo
	name = "Spurdo"
	id = "spurdo"
	default_color = "FFFFFF"
	species_traits = list(MUTCOLORS,HAIR,FACEHAIR,NOEYESPRITES,LIPS,SPURDOVOICE)
	default_features = list("mcolor" = "FFFFFF", "wings" = "None")
	fixed_mut_color = "FFFFFF"
	use_skintones = 0
	limbs_id = "spurdo"
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | DAIRY
	liked_food = JUNKFOOD | MEAT
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN

/datum/species/spurdo/qualifies_for_rank(rank, list/features)
	return TRUE
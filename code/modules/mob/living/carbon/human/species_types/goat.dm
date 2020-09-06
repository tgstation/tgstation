/datum/species/goat
	name = "Goat"
	id = "goat"
	say_mod = "bleats"
	sexes = 0
	nojumpsuit = TRUE
	species_traits = list(AGENDER, NO_UNDERWEAR, NOEYESPRITES)
	use_skintones = FALSE
	flying_species = FALSE
	inherent_traits = list(TRAIT_RESISTCOLD)
	meat = /obj/item/reagent_containers/food/snacks/meat/slab
	default_features = list("mcolor" = "FFF", "wings" = "None")
	liked_food = VEGETABLES| FRUIT | GRAIN | RAW
	disliked_food = MEAT | DAIRY
	damage_overlay_type = ""
	disliked_food = NONE
	payday_modifier = 1
	limbs_id = "goat"
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

/datum/species/goat/qualifies_for_rank(rank, list/features)
	return TRUE	//Pure humans are always allowed in all roles.

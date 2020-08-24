/datum/species/spirit
	name = "Spirit"
	id = "spirit"
	say_mod = "echoes"
	sexes = 0
	nojumpsuit = TRUE
	species_traits = list(AGENDER, NO_UNDERWEAR, NOBLOOD, NOEYESPRITES)
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_NOBREATH,TRAIT_GENELESS,TRAIT_NOMETABOLISM,TRAIT_TOXIMMUNE,TRAIT_RESISTHEAT,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_FAKEDEATH,TRAIT_XENO_IMMUNE,TRAIT_NODISMEMBER,TRAIT_NOLIMBDISABLE,TRAIT_ALWAYS_CLEAN, TRAIT_NOSLIPALL)
	use_skintones = FALSE
	flying_species = TRUE
	meat = null
	default_features = list("mcolor" = "FFF", "wings" = "None")
	skinned_type = /obj/item/stack/sheet/animalhide/human
	liked_food = JUNKFOOD | FRIED | GROSS | RAW
	damage_overlay_type = ""
	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD
	disliked_food = NONE
	payday_modifier = 1
	limbs_id = "spirit"
	changesource_flags = MIRROR_BADMIN | WABBAJACK

/datum/species/spirit/qualifies_for_rank(rank, list/features)
	return TRUE	//Pure humans are always allowed in all roles.

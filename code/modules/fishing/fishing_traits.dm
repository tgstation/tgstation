/datum/fishing_trait
	/// Description of the trait in the fishing catalog
	var/catalog_description

/// Difficulty modifier from this mod, needs to return a list with two values
/datum/fishing_trait/proc/difficulty_mod(obj/item/fishing_rod/rod, mob/fisherman)
	SHOULD_CALL_PARENT(TRUE) //Technically it doesn't but this makes it saner without custom unit test
	return list(ADDITIVE_FISHING_MOD = 0, MULTIPLICATIVE_FISHING_MOD = 1)

/// Catch weight table modifier from this mod, needs to return a list with two values
/datum/fishing_trait/proc/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman)
	SHOULD_CALL_PARENT(TRUE)
	return list(ADDITIVE_FISHING_MOD = 0, MULTIPLICATIVE_FISHING_MOD = 1)

/// Returns special minigame rules applied by this trait
/datum/fishing_trait/proc/minigame_mod(obj/item/fishing_rod/rod, mob/fisherman)
	return list()

/datum/fishing_trait/wary
	catalog_description = "This fish will avoid visible fish lines, cloaked line recommended."

/datum/fishing_trait/wary/difficulty_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	// Wary fish require transparent line or they're harder
	if(!rod.line || !(rod.line.fishing_line_traits & FISHING_LINE_CLOAKED))
		.[ADDITIVE_FISHING_MOD] = -FISH_TRAIT_MINOR_DIFFICULTY_BOOST

/datum/fishing_trait/shiny_lover
	catalog_description = "This fish loves shiny things, shiny lure recommended."

/datum/fishing_trait/shiny_lover/difficulty_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	// These fish are easier to catch with shiny lure
	if(rod.hook && rod.hook.fishing_hook_traits & FISHING_HOOK_SHINY)
		.[ADDITIVE_FISHING_MOD] = FISH_TRAIT_MINOR_DIFFICULTY_BOOST

/datum/fishing_trait/picky_eater
	catalog_description = "This fish is very picky and will ignore low quality bait."

/datum/fishing_trait/picky_eater/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	if(!rod.bait || !(HAS_TRAIT(rod.bait, GOOD_QUALITY_BAIT_TRAIT) || HAS_TRAIT(rod.bait, GREAT_QUALITY_BAIT_TRAIT)))
		.[MULTIPLICATIVE_FISHING_MOD] = 0


/datum/fishing_trait/nocturnal
	catalog_description = "This fish avoids bright lights, fishing in darkness recommended."

/datum/fishing_trait/nocturnal/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	var/turf/T = get_turf(fisherman)
	var/light_amount = T.get_lumcount()
	if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
		.[MULTIPLICATIVE_FISHING_MOD] = 0


/datum/fishing_trait/heavy
	catalog_description = "This fish tends to stay near the waterbed.";

/datum/fishing_trait/heavy/minigame_mod(obj/item/fishing_rod/rod, mob/fisherman)
	return list(FISHING_MINIGAME_RULE_HEAVY_FISH)


/datum/fishing_trait/carnivore
	catalog_description = "This fish can only be baited with meat."

/datum/fishing_trait/carnivore/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	.[MULTIPLICATIVE_FISHING_MOD] = 0
	if(rod.bait && istype(rod.bait, /obj/item/food))
		var/obj/item/food/food_bait = rod.bait
		if(food_bait.foodtypes & MEAT)
			.[MULTIPLICATIVE_FISHING_MOD] = 1

/datum/fishing_trait/vegan
	catalog_description = "This fish can only be baited with fresh produce."

/datum/fishing_trait/vegan/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	.[MULTIPLICATIVE_FISHING_MOD] = 0
	if(rod.bait && istype(rod.bait, /obj/item/food/grown))
		.[MULTIPLICATIVE_FISHING_MOD] = 1

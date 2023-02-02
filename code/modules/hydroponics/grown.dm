// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

// A few defines for use in calculating our plant's bite size.
/// When calculating bite size, potency is multiplied by this number.
#define BITE_SIZE_POTENCY_MULTIPLIER 0.05
/// When calculating bite size, max_volume is multiplied by this number.
#define BITE_SIZE_VOLUME_MULTIPLIER 0.01

// Base type. Subtypes are found in /grown dir. Lavaland-based subtypes can be found in mining/ash_flora.dm
/obj/item/food/grown
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "berrypile"
	worn_icon = 'icons/mob/clothing/head/hydroponics.dmi'
	name = "fresh produce" // so recipe text doesn't say 'snack'
	max_volume = PLANT_REAGENT_VOLUME
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	/// type path, gets converted to item on New(). It's safe to assume it's always a seed item.
	var/obj/item/seeds/seed = null
	///Name of the plant
	var/plantname = ""
	/// The modifier applied to the plant's bite size. If a plant has a large amount of reagents naturally, this should be increased to match.
	var/bite_consumption_mod = 1
	/// The typepath made when the plant is splatted with liquid contents.
	var/splat_type = /obj/effect/decal/cleanable/food/plant_smudge
	/// If TRUE, this object needs to be dry to be ground up
	var/dry_grind = FALSE
	/// If FALSE, this object cannot be distilled into an alcohol.
	var/can_distill = TRUE
	/// The reagent this plant distill to. If NULL, it uses a generic fruit_wine reagent and adjusts its variables.
	var/distill_reagent
	/// Flavor of the plant's wine if NULL distll_reagent. If NULL, this is automatically set to the fruit's flavor.
	var/wine_flavor
	/// Boozepwr of the wine if NULL distill_reagent
	var/wine_power = 10
	/// Color of the grown object, for use in coloring greyscale splats.
	var/filling_color
	/// If the grown food has an alternaitve icon state to use in places.
	var/alt_icon

/obj/item/food/grown/Initialize(mapload, obj/item/seeds/new_seed)
	if(!tastes)
		tastes = list("[name]" = 1) //This happens first else the component already inits

	if(istype(new_seed))
		seed = new_seed.Copy()

	else if(ispath(seed))
		// This is for adminspawn or map-placed growns. They get the default stats of their seed type.
		seed = new seed()
		seed.adjust_potency(50-seed.potency)
	else if(!seed)
		stack_trace("Grown object created without a seed. WTF")
		return INITIALIZE_HINT_QDEL

	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)

	make_dryable()

	// Go through all traits in their genes and call on_new_plant from them.
	for(var/datum/plant_gene/trait/trait in seed.genes)
		trait.on_new_plant(src, loc)

	// Set our default bitesize: bite size = 1 + (potency * 0.05) * (max_volume * 0.01) * modifier
	// A 100 potency, non-densified plant = 1 + (5 * 1 * modifier) = 6u bite size
	// For reference, your average 100 potency tomato has 14u of reagents - So, with no modifier it is eaten in 3 bites
	bite_consumption = 1 + round(max((seed.potency * BITE_SIZE_POTENCY_MULTIPLIER), 1) * (max_volume * BITE_SIZE_VOLUME_MULTIPLIER) * bite_consumption_mod)

	. = ..() //Only call it here because we want all the genes and shit to be applied before we add edibility. God this code is a mess.

	seed.prepare_result(src)
	transform *= TRANSFORM_USING_VARIABLE(seed.potency, 100) + 0.5 //Makes the resulting produce's sprite larger or smaller based on potency!

	if(seed.get_gene(/datum/plant_gene/trait/brewing))
		ferment()

/obj/item/food/grown/Destroy()
	if(isatom(seed))
		QDEL_NULL(seed)
	return ..()

/obj/item/food/grown/proc/make_dryable()
	AddElement(/datum/element/dryable, type)

/obj/item/food/grown/make_leave_trash()
	if(trash_type)
		AddElement(/datum/element/food_trash, trash_type, FOOD_TRASH_OPENABLE, TYPE_PROC_REF(/obj/item/food/grown/, generate_trash))
	return

/// Generates a piece of trash based on our plant item. Used by [/datum/element/food_trash].
/// location - Optional. If passed, generates the item at the passed location instead of at src's drop location.
/obj/item/food/grown/proc/generate_trash(atom/location)
	// If this is some type of grown thing, we pass a seed arg into its Inititalize()
	if(ispath(trash_type, /obj/item/grown) || ispath(trash_type, /obj/item/food/grown))
		return new trash_type(location || drop_location(), seed)

	return new trash_type(location || drop_location())

/obj/item/food/grown/grind_requirements()
	if(dry_grind && !HAS_TRAIT(src, TRAIT_DRIED))
		to_chat(usr, span_warning("[src] needs to be dry before it can be ground up!"))
		return
	return TRUE

/// Turns the nutriments and vitamins into the distill reagent or fruit wine
/obj/item/food/grown/proc/ferment()
	for(var/datum/reagent/reagent in reagents.reagent_list)
		if(reagent.type != /datum/reagent/consumable/nutriment && reagent.type != /datum/reagent/consumable/nutriment/vitamin)
			continue
		var/purity = clamp(seed.lifespan/200 + seed.endurance/200, 0, 1)
		var/quality_min = 0
		var/quality_max = DRINK_FANTASTIC
		var/quality = round(LERP(quality_min, quality_max, purity))
		if(distill_reagent)
			var/data = list()
			var/datum/reagent/consumable/ethanol/booze = distill_reagent
			data["quality"] = quality
			data["boozepwr"] = round(initial(booze.boozepwr) * purity)
			reagents.add_reagent(distill_reagent, reagent.volume, data, added_purity = purity)
		else
			var/data = list()
			data["names"] = list("[initial(name)]" = 1)
			data["color"] = filling_color
			data["boozepwr"] = round(wine_power * purity)
			data["quality"] = quality
			if(wine_flavor)
				data["tastes"] = list(wine_flavor = 1)
			else
				data["tastes"] = list(tastes[1] = 1)
			reagents.add_reagent(/datum/reagent/consumable/ethanol/fruit_wine, reagent.volume, data, added_purity = purity)
		reagents.del_reagent(reagent.type)

/obj/item/food/grown/on_grind()
	. = ..()
	var/nutriment = reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
	if(grind_results?.len)
		for(var/i in 1 to grind_results.len)
			grind_results[grind_results[i]] = nutriment
		reagents.del_reagent(/datum/reagent/consumable/nutriment)
		reagents.del_reagent(/datum/reagent/consumable/nutriment/vitamin)

/obj/item/food/grown/on_juice()
	var/nutriment = reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
	if(juice_results?.len)
		for(var/i in 1 to juice_results.len)
			juice_results[juice_results[i]] = nutriment
		reagents.del_reagent(/datum/reagent/consumable/nutriment)
		reagents.del_reagent(/datum/reagent/consumable/nutriment/vitamin)

#undef BITE_SIZE_POTENCY_MULTIPLIER
#undef BITE_SIZE_VOLUME_MULTIPLIER

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
	icon = 'icons/obj/service/hydroponics/harvest.dmi'
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
	/// If the grown food has an alternative icon state to use in places.
	var/alt_icon
	/// Should we pixel offset ourselves at init? for mapping
	var/offset_at_init = TRUE

/obj/item/food/grown/New(loc, obj/item/seeds/new_seed)
	return ..()

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

	if(offset_at_init)
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

	reagents.clear_reagents()
	seed.prepare_result(src)
	transform *= TRANSFORM_USING_VARIABLE(seed.potency, 100) + 0.5 //Makes the resulting produce's sprite larger or smaller based on potency!

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

/obj/item/food/grown/blend_requirements()
	if(dry_grind && !HAS_TRAIT(src, TRAIT_DRIED))
		to_chat(usr, span_warning("[src] needs to be dry before it can be ground up!"))
		return
	return TRUE

/// Turns the nutriments and vitamins into the distill reagent or fruit wine
/obj/item/food/grown/proc/ferment()
	var/reagent_purity = seed.get_reagent_purity()
	var/purity_above_base = clamp((reagent_purity - 0.5) * 2, 0, 1)
	var/quality_min = DRINK_NICE
	var/quality_max = DRINK_FANTASTIC
	var/quality = round(LERP(quality_min, quality_max, purity_above_base))
	for(var/datum/reagent/reagent in reagents.reagent_list)
		if(reagent.type != /datum/reagent/consumable/nutriment && reagent.type != /datum/reagent/consumable/nutriment/vitamin)
			continue
		if(distill_reagent)
			var/data = list()
			var/datum/reagent/consumable/ethanol/booze = distill_reagent
			data["quality"] = quality
			data["boozepwr"] = round(initial(booze.boozepwr) * reagent_purity * 2) // default boozepwr at 50% purity
			reagents.add_reagent(distill_reagent, reagent.volume, data, added_purity = reagent_purity)
		else
			var/data = list()
			data["names"] = list("[initial(name)]" = 1)
			data["color"] = filling_color || reagent.color // filling_color is not guaranteed to be set for every plant. try to use it if we have it, otherwise use the reagent's color var
			data["boozepwr"] = round(wine_power * reagent_purity * 2) // default boozepwr at 50% purity
			data["quality"] = quality
			if(wine_flavor)
				data["tastes"] = list(wine_flavor = 1)
			else
				data["tastes"] = list(tastes[1] = 1)
			reagents.add_reagent(/datum/reagent/consumable/ethanol/fruit_wine, reagent.volume, data, added_purity = reagent_purity)
		reagents.del_reagent(reagent.type)

/obj/item/food/grown/grind_atom(datum/reagents/target_holder, mob/user)
	var/grind_results_num = LAZYLEN(grind_results)
	if(grind_results_num)
		var/average_purity = reagents.get_average_purity()
		var/total_nutriment_amount = reagents.get_reagent_amount(/datum/reagent/consumable/nutriment, type_check = REAGENT_SUB_TYPE)
		var/single_reagent_amount = grind_results_num > 1 ? round(total_nutriment_amount / grind_results_num, CHEMICAL_QUANTISATION_LEVEL) : total_nutriment_amount
		reagents.remove_reagent(/datum/reagent/consumable/nutriment, total_nutriment_amount, include_subtypes = TRUE)
		for(var/reagent in grind_results)
			reagents.add_reagent(reagent, single_reagent_amount, added_purity = average_purity)

	return reagents?.trans_to(target_holder, reagents.total_volume, transferred_by = user)

/obj/item/food/grown/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	//if we attack with paper and the grown is a mushroom, create a spore print.
	if(istype(tool, /obj/item/paper) && seed?.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
		qdel(tool)
		seed.name = "[LOWER_TEXT(seed.plantname)] spore print"
		seed.desc = "A dusting of [LOWER_TEXT(seed.plantname)] spores have been deposited in a beautiful pattern on the surface of the paper. "
		seed.icon_state = "spore_print[pick(1,2,3)]"
		seed.forceMove(drop_location())
		playsound(user, 'sound/items/paper_flip.ogg', 20)
		seed = null
		qdel(src)
		return ITEM_INTERACT_SUCCESS
	else
		return ..()

#undef BITE_SIZE_POTENCY_MULTIPLIER
#undef BITE_SIZE_VOLUME_MULTIPLIER

// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

// Base type. Subtypes are found in /grown dir. Lavaland-based subtypes can be found in mining/ash_flora.dm
/obj/item/food/grown
	icon = 'icons/obj/hydroponics/harvest.dmi'
	name = "fresh produce" // so recipe text doesn't say 'snack'
	max_volume = 100
	w_class = WEIGHT_CLASS_SMALL
	/// type path, gets converted to item on New(). It's safe to assume it's always a seed item.
	var/obj/item/seeds/seed = null
	///Name of the plant
	var/plantname = ""
	/// If set, bitesize = 1 + round(reagents.total_volume / bite_consumption_mod)
	var/bite_consumption_mod = 0
	///the splat it makes when it splats lol
	var/splat_type = /obj/effect/decal/cleanable/food/plant_smudge

	resistance_flags = FLAMMABLE
	var/dry_grind = FALSE //If TRUE, this object needs to be dry to be ground up
	var/can_distill = TRUE //If FALSE, this object cannot be distilled into an alcohol.
	var/distill_reagent //If NULL and this object can be distilled, it uses a generic fruit_wine reagent and adjusts its variables.
	var/wine_flavor //If NULL, this is automatically set to the fruit's flavor. Determines the flavor of the wine if distill_reagent is NULL.
	var/wine_power = 10 //Determines the boozepwr of the wine if distill_reagent is NULL.
	///Color of the grown object
	var/filling_color


/obj/item/food/grown/Initialize(mapload, obj/item/seeds/new_seed)
	if(!tastes)
		tastes = list("[name]" = 1) //This happens first else the component already inits

	if(new_seed)
		seed = new_seed.Copy()

	else if(ispath(seed))
		// This is for adminspawn or map-placed growns. They get the default stats of their seed type.
		seed = new seed()
		seed.adjust_potency(50-seed.potency)

	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)

	make_dryable()

	for(var/datum/plant_gene/trait/T in seed.genes)
		T.on_new(src, loc)

	. = ..() //Only call it here because we want all the genes and shit to be applied before we add edibility. God this code is a mess.

	seed.prepare_result(src)
	transform *= TRANSFORM_USING_VARIABLE(seed.potency, 100) + 0.5 //Makes the resulting produce's sprite larger or smaller based on potency!

/obj/item/food/grown/MakeEdible()
	AddComponent(/datum/component/edible,\
				initial_reagents = food_reagents,\
				food_flags = food_flags,\
				foodtypes = foodtypes,\
				volume = max_volume,\
				eat_time = eat_time,\
				tastes = tastes,\
				eatverbs = eatverbs,\
				bite_consumption = bite_consumption_mod ? 1 + round(max_volume / bite_consumption_mod) : bite_consumption,\
				microwaved_type = microwaved_type,\
				junkiness = junkiness,\
				on_consume = CALLBACK(src, .proc/OnConsume))


/obj/item/food/grown/proc/make_dryable()
	AddElement(/datum/element/dryable, type)

/obj/item/food/grown/examine(user)
	. = ..()
	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			if(T.examine_line)
				. += T.examine_line

/obj/item/food/grown/attackby(obj/item/O, mob/user, params)
	..()
	if (istype(O, /obj/item/plant_analyzer))
		var/obj/item/plant_analyzer/plant_analyzer = O
		to_chat(user, plant_analyzer.scan_plant(src))
	else
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_attackby(src, O, user)


/obj/item/food/grown/MakeLeaveTrash()
	if(trash_type)
		AddElement(/datum/element/food_trash, trash_type, FOOD_TRASH_OPENABLE, /obj/item/food/grown/.proc/generate_trash)
	return

// Various gene procs
/obj/item/food/grown/attack_self(mob/user)
	SEND_SIGNAL(src, COMSIG_PLANT_SQUASH, user)
	..()

/obj/item/food/grown/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //was it caught by a mob?
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_throw_impact(src, hit_atom)

/obj/item/food/grown/proc/OnConsume(mob/living/eater, mob/living/feeder)
	if(iscarbon(usr))
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_consume(src, usr)

///Callback for bonus behavior for generating trash of grown food.
/obj/item/food/grown/proc/generate_trash(atom/location)
	return new trash_type(location, seed)

/obj/item/food/grown/grind_requirements()
	if(dry_grind && !HAS_TRAIT(src, TRAIT_DRIED))
		to_chat(usr, "<span class='warning'>[src] needs to be dry before it can be ground up!</span>")
		return
	return TRUE

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

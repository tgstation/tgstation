// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/service/hydroponics/harvest.dmi'
	worn_icon = 'icons/mob/clothing/head/hydroponics.dmi'
	abstract_type = /obj/item/grown
	resistance_flags = FLAMMABLE
	var/obj/item/seeds/seed = null // type path, gets converted to item on New(). It's safe to assume it's always a seed item.
	/// Should we pixel offset ourselves at init? for mapping
	var/offset_at_init = TRUE
	/// The reagent this plant distill to. If NULL, it uses a generic fruit_wine reagent and adjusts its variables.
	var/distill_reagent

// This may look like it's doing nothing but it's necessary, we do this to have kwargs work in New (for passing into Initialize)
/obj/item/grown/New(loc, obj/item/seeds/new_seed)
	return ..()

/obj/item/grown/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	create_reagents(100)

	if(istype(new_seed))
		seed = new_seed.Copy()

	else if(ispath(seed))
		// This is for adminspawn or map-placed growns. They get the default stats of their seed type.
		seed = new seed()
		seed.adjust_potency(50-seed.potency)

	if(offset_at_init)
		pixel_x = base_pixel_x + rand(-5, 5)
		pixel_y = base_pixel_y + rand(-5, 5)

	if(seed)
		// Go through all traits in their genes and call on_new_plant from them.
		for(var/datum/plant_gene/trait/trait in seed.genes)
			trait.on_new_plant(src, loc)

		if(istype(src, seed.product)) // no adding reagents if it is just a trash item
			seed.prepare_result(src)
		transform *= TRANSFORM_USING_VARIABLE(seed.potency, 100) + 0.5
		add_juice()

/obj/item/grown/Destroy()
	if(isatom(seed))
		QDEL_NULL(seed)
	return ..()

/obj/item/grown/proc/add_juice()
	if(reagents)
		return TRUE
	return FALSE

/obj/item/grown/on_grind()
	. = ..()
	for(var/i in 1 to grind_results.len)
		grind_results[grind_results[i]] = round(seed.potency)

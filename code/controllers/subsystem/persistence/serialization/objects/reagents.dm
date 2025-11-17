/obj/item/reagent_containers/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, amount_per_transfer_from_this)
	return .

/obj/item/reagent_containers/get_custom_save_vars(save_flags=ALL)
	. = ..()
	var/has_identical_reagents = TRUE
	var/list/cached_reagents = reagents.reagent_list
	var/list/reagents_to_save
	for(var/datum/reagent/reagent as anything in cached_reagents)
		var/amount = floor(reagent.volume)
		if(amount <= 0)
			continue

		LAZYSET(reagents_to_save, reagent.type, amount)

		// checks if reagent & amount inside both reagent lists are identical
		if(LAZYACCESS(list_reagents, reagent.type) == amount)
			continue
		has_identical_reagents = FALSE

	if(length(reagents_to_save) != length(list_reagents))
		has_identical_reagents = FALSE

	if(!has_identical_reagents)
		.[NAMEOF(src, list_reagents)] = reagents_to_save

	if(initial(initial_reagent_flags) != reagents.flags)
		.[NAMEOF(src, initial_reagent_flags)] = reagents.flags

	return .

/obj/machinery/duct/get_save_vars(save_flags=ALL)
	. = ..()
	// idk shit about plumbing but i think these are correct?
	. += NAMEOF(src, lock_layers)
	. += NAMEOF(src, duct_layer)
	. += NAMEOF(src, ignore_colors)
	. += NAMEOF(src, duct_color)

	. -= NAMEOF(src, color)
	return .

/obj/item/lazarus_injector/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, loaded)
	return .

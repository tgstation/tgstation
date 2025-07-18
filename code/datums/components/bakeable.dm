///This component indicates this object can be baked in an oven.
/datum/component/bakeable
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS // So you can change bake results with various cookstuffs
	///Result atom type of baking this object
	var/atom/bake_result
	///Amount of time required to bake the food
	var/required_bake_time = 2 MINUTES
	///Is this a positive bake result?
	var/positive_result = TRUE

	///Time spent baking so far
	var/current_bake_time = 0

	/// REF() to the mind which placed us in an oven
	var/who_baked_us

	/// Reagents that should be added to the result
	var/list/added_reagents

/datum/component/bakeable/Initialize(bake_result, required_bake_time, positive_result, use_large_steam_sprit, list/added_reagents)
	. = ..()
	if(!isitem(parent)) //Only items support baking at the moment
		return COMPONENT_INCOMPATIBLE

	src.bake_result = bake_result
	src.required_bake_time = required_bake_time
	src.positive_result = positive_result
	src.added_reagents = added_reagents
	if(positive_result)
		ADD_TRAIT(parent, TRAIT_BAKEABLE, REF(src))


	var/obj/item/item_target = parent
	if(!PERFORM_ALL_TESTS(focus_only/check_materials_when_processed) || !positive_result || !item_target.custom_materials)
		return

	var/atom/result = new bake_result
	if(!item_target.compare_materials(result))
		var/warning = "custom_materials of [result.type] when baked compared to just spawned don't match"
		var/what_it_should_be = item_target.get_materials_english_list()
		stack_trace("[warning]. custom_materials should be [what_it_should_be].")
	qdel(result)

// Inherit the new values passed to the component
/datum/component/bakeable/InheritComponent(datum/component/bakeable/new_comp, original, bake_result, required_bake_time, positive_result, use_large_steam_sprite)
	if(!original)
		return
	if(bake_result)
		src.bake_result = bake_result
	if(required_bake_time)
		src.required_bake_time = required_bake_time
	if(positive_result)
		src.positive_result = positive_result

/datum/component/bakeable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_OVEN_PLACED_IN, PROC_REF(on_baking_start))
	RegisterSignal(parent, COMSIG_ITEM_OVEN_PROCESS, PROC_REF(on_bake))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/bakeable/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_OVEN_PLACED_IN, COMSIG_ITEM_OVEN_PROCESS, COMSIG_ATOM_EXAMINE))
	REMOVE_TRAIT(parent, TRAIT_BAKEABLE, REF(src))

/// Signal proc for [COMSIG_ITEM_OVEN_PLACED_IN] when baking starts (parent enters an oven)
/datum/component/bakeable/proc/on_baking_start(datum/source, atom/used_oven, mob/baker)
	SIGNAL_HANDLER

	if(baker && baker.mind)
		who_baked_us = REF(baker.mind)

///Ran every time an item is baked by something
/datum/component/bakeable/proc/on_bake(datum/source, atom/used_oven, seconds_per_tick = 1)
	SIGNAL_HANDLER

	// Let our signal know if we're baking something good or ... burning something
	var/baking_result = positive_result ? COMPONENT_BAKING_GOOD_RESULT : COMPONENT_BAKING_BAD_RESULT

	current_bake_time += seconds_per_tick * 10 //turn it into ds
	if(current_bake_time >= required_bake_time)
		finish_baking(used_oven)

	return COMPONENT_HANDLED_BAKING | baking_result

///Ran when an object finished baking
/datum/component/bakeable/proc/finish_baking(atom/used_oven)
	var/atom/original_object = parent
	var/obj/item/plate/oven_tray/used_tray = original_object.loc
	var/atom/baked_result = new bake_result(used_tray)
	if(baked_result.reagents && positive_result) //make space and tranfer reagents if it has any & the resulting item isn't bad food or other bad baking result
		baked_result.reagents.clear_reagents()
		original_object.reagents.trans_to(baked_result, original_object.reagents.total_volume)
		if(added_reagents) // Add any new reagents that should be added
			baked_result.reagents.add_reagent_list(added_reagents)
		if(istype(original_object, /obj/item/food) && istype(baked_result, /obj/item/food))
			var/obj/item/food/original_food = original_object
			var/obj/item/food/baked_food = baked_result
			LAZYADD(baked_food.intrinsic_food_materials, original_food.intrinsic_food_materials)

	if(who_baked_us)
		ADD_TRAIT(baked_result, TRAIT_FOOD_CHEF_MADE, who_baked_us)

	if(original_object.custom_materials)
		baked_result.set_custom_materials(original_object.custom_materials, 1)

	baked_result.pixel_x = original_object.pixel_x
	baked_result.pixel_y = original_object.pixel_y
	used_tray.AddToPlate(baked_result)

	var/list/asomnia_hadders = list()
	for(var/mob/smeller in get_hearers_in_view(DEFAULT_MESSAGE_RANGE, used_oven))
		if(HAS_TRAIT(smeller, TRAIT_ANOSMIA))
			asomnia_hadders += smeller

	if(positive_result)
		used_oven.visible_message(
			span_notice("You smell something great coming from [used_oven]."),
			blind_message = span_notice("You smell something great..."),
			ignored_mobs = asomnia_hadders,
		)
		BLACKBOX_LOG_FOOD_MADE(baked_result.type)
	else
		used_oven.visible_message(
			span_warning("You smell a burnt smell coming from [used_oven]."),
			blind_message = span_warning("You smell a burnt smell..."),
			ignored_mobs = asomnia_hadders,
		)
	SEND_SIGNAL(parent, COMSIG_ITEM_BAKED, baked_result)
	qdel(parent)

///Gives info about the items baking status so you can see if its almost done
/datum/component/bakeable/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!current_bake_time) //Not baked yet
		if(positive_result)
			if(initial(bake_result.gender) == PLURAL)
				examine_list += span_notice("[parent] can be [span_bold("baked")] into some [initial(bake_result.name)].")
			else
				examine_list += span_notice("[parent] can be [span_bold("baked")] into \a [initial(bake_result.name)].")
		return

	if(positive_result)
		if(current_bake_time <= required_bake_time * 0.75)
			examine_list += span_notice("[parent] probably needs to be baked a bit longer!")
		else if(current_bake_time <= required_bake_time)
			examine_list += span_notice("[parent] seems to be almost finished baking!")
	else
		examine_list += span_danger("[parent] should probably not be put in the oven.")

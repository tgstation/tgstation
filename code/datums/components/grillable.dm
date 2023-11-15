/datum/component/grillable
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS // So you can change grill results with various cookstuffs
	///Result atom type of grilling this object
	var/atom/cook_result
	///Amount of time required to cook the food
	var/required_cook_time = 2 MINUTES
	///Is this a positive grill result?
	var/positive_result = TRUE
	///Time spent cooking so far
	var/current_cook_time = 0
	///Do we use the large steam sprite?
	var/use_large_steam_sprite = FALSE
	/// REF() to the mind which placed us on the griddle
	var/who_placed_us
	/// Reagents that should be added to the result
	var/list/added_reagents

/datum/component/grillable/Initialize(cook_result, required_cook_time, positive_result, use_large_steam_sprite, list/added_reagents)
	. = ..()
	if(!isitem(parent)) //Only items support grilling at the moment
		return COMPONENT_INCOMPATIBLE

	src.cook_result = cook_result
	src.required_cook_time = required_cook_time
	src.positive_result = positive_result
	src.use_large_steam_sprite = use_large_steam_sprite
	src.added_reagents = added_reagents

/datum/component/grillable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_GRILL_PLACED, PROC_REF(on_grill_placed))
	RegisterSignal(parent, COMSIG_ITEM_GRILL_TURNED_ON, PROC_REF(on_grill_turned_on))
	RegisterSignal(parent, COMSIG_ITEM_GRILL_TURNED_OFF, PROC_REF(on_grill_turned_off))
	RegisterSignal(parent, COMSIG_ITEM_GRILL_PROCESS, PROC_REF(on_grill))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/grillable/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ITEM_GRILL_TURNED_ON,
		COMSIG_ITEM_GRILL_TURNED_OFF,
		COMSIG_ITEM_GRILL_PROCESS,
		COMSIG_ITEM_GRILL_PLACED,
	))

// Inherit the new values passed to the component
/datum/component/grillable/InheritComponent(datum/component/grillable/new_comp, original, cook_result, required_cook_time, positive_result, use_large_steam_sprite)
	if(!original)
		return
	if(cook_result)
		src.cook_result = cook_result
	if(required_cook_time)
		src.required_cook_time = required_cook_time
	if(positive_result)
		src.positive_result = positive_result
	if(use_large_steam_sprite)
		src.use_large_steam_sprite = use_large_steam_sprite

/// Signal proc for [COMSIG_ITEM_GRILL_PLACED], item is placed on the grill.
/datum/component/grillable/proc/on_grill_placed(datum/source, mob/griller)
	SIGNAL_HANDLER

	if(griller && griller.mind)
		who_placed_us = REF(griller.mind)

	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/// Signal proc for [COMSIG_ITEM_GRILL_TURNED_ON], starts the grilling process.
/datum/component/grillable/proc/on_grill_turned_on(datum/source)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(add_grilled_item_overlay))

	var/atom/atom_parent = parent
	atom_parent.update_appearance()

/// Signal proc for [COMSIG_ITEM_GRILL_TURNED_OFF], stops the grilling process.
/datum/component/grillable/proc/on_grill_turned_off(datum/source)
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS)

	var/atom/atom_parent = parent
	atom_parent.update_appearance()

///Ran every time an item is grilled by something
/datum/component/grillable/proc/on_grill(datum/source, atom/used_grill, seconds_per_tick = 1)
	SIGNAL_HANDLER

	. = COMPONENT_HANDLED_GRILLING

	current_cook_time += seconds_per_tick * 10 //turn it into ds
	if(current_cook_time >= required_cook_time)
		finish_grilling(used_grill)

///Ran when an object finished grilling
/datum/component/grillable/proc/finish_grilling(atom/grill_source)
	var/atom/original_object = parent
	var/atom/grilled_result

	if(isstack(parent)) //Check if its a sheet, for grilling multiple things in a stack
		var/obj/item/stack/stack_parent = original_object
		grilled_result = new cook_result(original_object.loc, stack_parent.amount)

	else
		grilled_result = new cook_result(original_object.loc)
		if(original_object.custom_materials)
			grilled_result.set_custom_materials(original_object.custom_materials)

	if(IsEdible(grilled_result) && positive_result)
		BLACKBOX_LOG_FOOD_MADE(grilled_result.type)
		grilled_result.reagents.clear_reagents()
		original_object.reagents?.trans_to(grilled_result, original_object.reagents.total_volume)
		if(added_reagents) // Add any new reagents that should be added
			grilled_result.reagents.add_reagent_list(added_reagents)

	SEND_SIGNAL(parent, COMSIG_ITEM_GRILLED, grilled_result)
	if(who_placed_us)
		ADD_TRAIT(grilled_result, TRAIT_FOOD_CHEF_MADE, who_placed_us)

	grill_source.visible_message("<span class='[positive_result ? "notice" : "warning"]'>[parent] turns into \a [grilled_result]!</span>")
	grilled_result.pixel_x = original_object.pixel_x
	grilled_result.pixel_y = original_object.pixel_y
	qdel(parent)

///Ran when an object almost finishes grilling
/datum/component/grillable/proc/on_examine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!current_cook_time) //Not grilled yet
		if(positive_result)
			if(initial(cook_result.name) == PLURAL)
				examine_list += span_notice("[parent] can be [span_bold("grilled")] into some [initial(cook_result.name)].")
			else
				examine_list += span_notice("[parent] can be [span_bold("grilled")] into \a [initial(cook_result.name)].")
		return

	if(positive_result)
		if(current_cook_time <= required_cook_time * 0.75)
			examine_list += span_notice("[parent] probably needs to be cooked a bit longer!")
		else if(current_cook_time <= required_cook_time)
			examine_list += span_notice("[parent] seems to be almost finished cooking!")
	else
		examine_list += span_danger("[parent] should probably not be put on the grill.")

///Ran when an object moves from the grill
/datum/component/grillable/proc/on_moved(atom/source, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER

	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	source.update_appearance()

/datum/component/grillable/proc/add_grilled_item_overlay(datum/source, list/overlays)
	SIGNAL_HANDLER

	overlays += mutable_appearance('icons/effects/steam.dmi', "[use_large_steam_sprite ? "steam_triple" : "steam_single"]", ABOVE_OBJ_LAYER)

#define CROSSBREED_BASE_PATHS list(\
/datum/compressor_recipe/crossbreed/burning,\
/datum/compressor_recipe/crossbreed/charged,\
/datum/compressor_recipe/crossbreed/chilling,\
/datum/compressor_recipe/crossbreed/consuming,\
/datum/compressor_recipe/crossbreed/industrial,\
/datum/compressor_recipe/crossbreed/prismatic,\
/datum/compressor_recipe/crossbreed/regenerative,\
/datum/compressor_recipe/crossbreed/reproductive,\
/datum/compressor_recipe/crossbreed/selfsustaining,\
/datum/compressor_recipe/crossbreed/stabilized,\
)

/obj/machinery/plumbing/ooze_compressor
	name = "ooze compressor"
	desc = "Compresses ooze into extracts."

	icon = 'monkestation/code/modules/slimecore/icons/machinery.dmi'
	base_icon_state = "cross_compressor"
	icon_state = "cross_compressor"
	category="Distribution"

	anchored = TRUE

	idle_power_usage = 10
	active_power_usage = 1000

	buffer = 5000
	reagent_flags = NO_REACT

	var/compressing = FALSE
	var/repeat_recipe = FALSE

	var/list/reagents_for_recipe = list()
	var/datum/compressor_recipe/current_recipe

	var/static/list/recipe_choices = list()
	var/static/list/base_choices = list()
	var/static/list/cross_breed_choices = list()
	var/static/list/choice_to_datum = list()

/obj/machinery/plumbing/ooze_compressor/Initialize(mapload, bolt, layer)
	. = ..()
	if(!length(recipe_choices))
		for(var/datum/compressor_recipe/listed as anything in (subtypesof(/datum/compressor_recipe) - typesof(/datum/compressor_recipe/crossbreed)))
			var/datum/compressor_recipe/stored_recipe = new listed
			recipe_choices |= list("[initial(stored_recipe.output_item.name)]" = image(icon = initial(stored_recipe.output_item.icon), icon_state = initial(stored_recipe.output_item.icon_state)))
			choice_to_datum |= list("[initial(stored_recipe.output_item.name)]" = stored_recipe)

	if(!length(cross_breed_choices))
		for(var/datum/compressor_recipe/listed as anything in CROSSBREED_BASE_PATHS)
			var/datum/compressor_recipe/stored_recipe = new listed
			var/obj/item/slimecross/crossbreed = stored_recipe.output_item
			var/image/new_image = image(icon = initial(stored_recipe.output_item.icon), icon_state = initial(stored_recipe.output_item.icon_state))
			new_image.color = return_color_from_string(initial(crossbreed.colour))
			if(initial(crossbreed.colour) == "rainbow")
				new_image.rainbow_effect()
			base_choices |= list("[initial(stored_recipe.output_item.name)]" = new_image)
			cross_breed_choices |= list("[initial(stored_recipe.output_item.name)]" = list())

			for(var/datum/compressor_recipe/subtype as anything in subtypesof(listed))
				var/datum/compressor_recipe/subtype_stored = new subtype
				var/obj/item/slimecross/subtype_breed = subtype_stored.output_item
				var/image/subtype_image = image(icon = initial(subtype_stored.output_item.icon), icon_state = initial(subtype_stored.output_item.icon_state))
				subtype_image.color = return_color_from_string(initial(subtype_breed.colour))
				if(initial(subtype_breed.colour) == "rainbow")
					subtype_image.rainbow_effect()

				cross_breed_choices["[initial(stored_recipe.output_item.name)]"] |= list("[initial(subtype_breed.colour)] [initial(subtype_stored.output_item.name)]" = subtype_image)
				choice_to_datum |= list("[initial(subtype_breed.colour)] [initial(subtype_stored.output_item.name)]" = subtype_stored)

	AddComponent(/datum/component/plumbing/ooze_compressor, bolt, layer)
	register_context()

/obj/machinery/plumbing/ooze_compressor/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Toggle Repeated Extract Compression"
	context[SCREENTIP_CONTEXT_LMB] = "Select a normal extract to make"
	context[SCREENTIP_CONTEXT_RMB] = "Select a crossbreed to make"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/plumbing/ooze_compressor/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignals(reagents, list(COMSIG_REAGENTS_REM_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_CLEAR_REAGENTS, COMSIG_REAGENTS_REACTED), PROC_REF(on_reagent_change))
	RegisterSignal(reagents, COMSIG_QDELETING, PROC_REF(on_reagents_del))

/obj/machinery/plumbing/ooze_compressor/update_icon_state()
	. = ..()
	if(compressing)
		icon_state = "cross_compressor_running"
	else
		icon_state = base_icon_state

/obj/machinery/plumbing/ooze_compressor/examine(mob/user)
	. = ..()
	if(!current_recipe)
		return
	for(var/datum/reagent/reagent as anything in current_recipe.required_oozes)
		var/reagent_volume = 0
		for(var/datum/reagent/listed_reagent as anything in reagents.reagent_list)
			if(listed_reagent.type != reagent)
				continue
			reagent_volume = listed_reagent.volume
		. += span_notice("[reagent_volume] out of [current_recipe.required_oozes[reagent]] units of [initial(reagent.name)].")
		reagent_volume = 0

/obj/machinery/plumbing/ooze_compressor/update_overlays()
	. = ..()
	if(length(reagents.reagent_list) >= 1 && length(reagents_for_recipe) >= 1)
		var/needed_reagents = reagents_for_recipe[1]
		var/datum/reagent/first_reagent = reagents.reagent_list[1]
		var/filled_precent = first_reagent.volume / reagents_for_recipe[needed_reagents]

		var/state = "quarter"
		switch(filled_precent)
			if(0.5 to 0.99)
				state = "half"
			if(1 to INFINITY)
				state = "full"

		var/mutable_appearance/right_side = mutable_appearance(icon, "cross_compressor_right_[state]", layer, src)
		right_side.color = first_reagent.color
		. += right_side

	if(length(reagents.reagent_list) >= 2 && length(reagents_for_recipe) >= 2)
		var/needed_reagents = reagents_for_recipe[2]
		var/datum/reagent/first_reagent = reagents.reagent_list[2]
		var/filled_precent = first_reagent.volume / reagents_for_recipe[needed_reagents]

		var/state = "quarter"
		switch(filled_precent)
			if(0.5 to 0.99)
				state = "half"
			if(1 to INFINITY)
				state = "full"

		var/mutable_appearance/left_side = mutable_appearance(icon, "cross_compressor_left_[state]", layer, src)
		left_side.color = first_reagent.color
		. += left_side

	. += mutable_appearance(icon, "cross_compressor_tank", layer + 0.01, src)

/// Handles properly detaching signal hooks.
/obj/machinery/plumbing/ooze_compressor/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_REM_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_CLEAR_REAGENTS, COMSIG_REAGENTS_REACTED, COMSIG_QDELETING))
	return NONE

/// Handles stopping the emptying process when the chamber empties.
/obj/machinery/plumbing/ooze_compressor/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	update_appearance()
	if(holder.total_volume == 0 && !compressing) //we were emptying, but now we aren't
		holder.flags |= NO_REACT
	return NONE

/obj/machinery/plumbing/ooze_compressor/process(seconds_per_tick)
	if(!compressing)
		use_power(active_power_usage * seconds_per_tick)

/obj/machinery/plumbing/ooze_compressor/proc/compress_recipe()
	compressing = TRUE
	update_appearance()
	if(!repeat_recipe)
		reagents_for_recipe = list()
	addtimer(CALLBACK(src, PROC_REF(finish_compressing)), 3 SECONDS)

/obj/machinery/plumbing/ooze_compressor/proc/finish_compressing()
	for(var/i in 1 to current_recipe.created_amount)
		new current_recipe.output_item(loc)
	compressing = FALSE
	update_appearance()
	reagents.clear_reagents()
	if(!repeat_recipe)
		current_recipe = null

/obj/machinery/plumbing/ooze_compressor/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(change_recipe(user))
		reagents.clear_reagents()

/obj/machinery/plumbing/ooze_compressor/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(change_recipe(user, TRUE))
		reagents.clear_reagents()

/obj/machinery/plumbing/ooze_compressor/AltClick(mob/user)
	if(anchored)
		visible_message(span_notice("[user] presses a button turning the repeat recipe system [repeat_recipe ? "Off" : "On"]"))
		repeat_recipe = !repeat_recipe
		return TRUE
	. = ..()

/obj/machinery/plumbing/ooze_compressor/proc/change_recipe(mob/user, cross_breed = FALSE)
	var/choice
	if(cross_breed)
		var/base_choice = show_radial_menu(user, src, base_choices, require_near = TRUE, tooltips = TRUE)
		if(!base_choice)
			return
		choice = show_radial_menu(user, src, cross_breed_choices[base_choice], require_near = TRUE, tooltips = TRUE)
	else
		choice = show_radial_menu(user, src, recipe_choices, require_near = TRUE, tooltips = TRUE)

	if(!(choice in choice_to_datum))
		return

	if(compressing)
		return

	current_recipe = choice_to_datum[choice]
	reagents_for_recipe = list()
	reagents_for_recipe += current_recipe.required_oozes

#undef CROSSBREED_BASE_PATHS

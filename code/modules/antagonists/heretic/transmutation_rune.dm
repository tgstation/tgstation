/// The heretic's rune, which they use to complete transmutation rituals.
/obj/effect/heretic_rune
	name = "transmutation rune"
	desc = "A flowing circle of shapes and runes is etched into the floor, filled with a thick black tar-like fluid. This one looks pretty small."
	icon = 'icons/obj/antags/cult/rune.dmi'
	icon_state = "main1"
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	plane = FLOOR_PLANE
	layer = RUNE_LAYER
	///Used mainly for summoning ritual to prevent spamming the rune to create millions of monsters.
	var/is_in_use = FALSE

/obj/effect/heretic_rune/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/effects/eldritch.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "heretic_rune", silicon_image)
	ADD_TRAIT(src, TRAIT_MOPABLE, INNATE_TRAIT)

/obj/effect/heretic_rune/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	. += span_notice("Allows you to transmute objects by invoking the rune after collecting the prerequisites overhead.")
	. += span_notice("You can use your <i>Mansus Grasp</i> on the rune to remove it.")

/obj/effect/heretic_rune/attack_paw(mob/living/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/effect/heretic_rune/can_interact(mob/living/user)
	. = ..()
	if(!.)
		return
	if(!IS_HERETIC(user))
		return FALSE
	if(is_in_use)
		return FALSE
	return TRUE

/obj/effect/heretic_rune/interact(mob/living/user)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(try_rituals), user)
	return TRUE

/**
 * Attempt to begin a ritual, giving them an input list to chose from.
 * Also ensures is_in_use is enabled and disabled before and after.
 */
/obj/effect/heretic_rune/proc/try_rituals(mob/living/user)
	is_in_use = TRUE

	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	var/list/rituals = heretic_datum.get_rituals()
	if(!length(rituals))
		loc.balloon_alert(user, "no rituals available!")
		is_in_use = FALSE
		return

	var/chosen = tgui_input_list(user, "Chose a ritual to attempt.", "Chose a Ritual", rituals)
	if(!chosen || !istype(rituals[chosen], /datum/heretic_knowledge) || QDELETED(src) || QDELETED(user) || QDELETED(heretic_datum))
		is_in_use = FALSE
		return

	do_ritual(user, rituals[chosen])
	is_in_use = FALSE

/**
 * Attempt to invoke a ritual from the past list of knowledges.
 *
 * Arguments
 * * user - the heretic / the person who invoked the rune
 * * knowledge_list - a non-assoc list of heretic_knowledge datums.
 *
 * returns TRUE if any rituals passed succeeded, FALSE if they all failed.
 */
/obj/effect/heretic_rune/proc/do_ritual(mob/living/user, datum/heretic_knowledge/ritual)

	// Collect all nearby valid atoms over the rune for processing in rituals.
	var/list/atom/movable/atoms_in_range = list()
	for(var/atom/close_atom as anything in range(1, src))
		if(!ismovable(close_atom))
			continue
		if(isitem(close_atom))
			var/obj/item/close_item = close_atom
			if(close_item.item_flags & ABSTRACT) //woops sacrificed your own head
				continue
		if(close_atom.invisibility)
			continue
		if(close_atom == user)
			continue

		atoms_in_range += close_atom

	// A copy of our requirements list.
	// We decrement the values of to determine if enough of each key is present.
	var/list/requirements_list = ritual.required_atoms.Copy()
	var/list/banned_atom_types = ritual.banned_atom_types.Copy()
	// A list of all atoms we've selected to use in this recipe.
	var/list/selected_atoms = list()

	// Do the snowflake check to see if we can continue or not.
	// selected_atoms is passed and can be modified by this proc.
	if(!ritual.recipe_snowflake_check(user, atoms_in_range, selected_atoms, loc))
		return FALSE

	var/list/stack_reqs = list()

	// Now go through all our nearby atoms and see which are good for our ritual.
	for(var/atom/nearby_atom as anything in atoms_in_range)
		// Go through all of our required atoms
		for(var/req_type in requirements_list)
			// We already have enough of this type, skip
			if(requirements_list[req_type] <= 0)
				continue
			// If req_type is a list of types, check all of them for one match.
			if(islist(req_type))
				if(!is_type_in_list(nearby_atom, req_type))
					continue
			else if(!istype(nearby_atom, req_type))
				continue
			// if list has items, check if the strict type is banned.
			if(length(banned_atom_types))
				if(nearby_atom.type in banned_atom_types)
					continue
			// If it's a stack, we gotta see if it has more than one inside,
			// as our requirements may want more than one item of a stack
			// It's also important that we split the required amount from the stack and add that
			// to the selected_atoms AFTERWARD so we don't change anything if the reqs aren't met.
			if(isstack(nearby_atom))
				var/obj/item/stack/picked_stack = nearby_atom
				if(!stack_reqs[req_type])
					stack_reqs[req_type] = requirements_list[req_type]
				requirements_list[req_type] -= min(picked_stack.amount || requirements_list[req_type])

			// Otherwise, just add the mark down the item as fulfilled x1
			else
				requirements_list[req_type]--
				// This item is a valid type. Add it to our selected atoms list.
				selected_atoms |= nearby_atom

	// All of the atoms have been checked, let's see if the ritual was successful
	var/list/what_are_we_missing = list()
	for(var/req_type in requirements_list)
		var/number_of_things = requirements_list[req_type]
		// <= 0 means it's fulfilled, skip
		if(number_of_things <= 0)
			continue

		// > 0 means it's unfilfilled - the ritual has failed, we should tell them why
		// Lets format the thing they're missing and put it into our list
		var/formatted_thing = "[number_of_things] "
		if(islist(req_type))
			var/list/req_type_list = req_type
			var/list/req_text_list = list()
			for(var/atom/possible_type as anything in req_type_list)
				req_text_list += ritual.parse_required_item(possible_type)
			formatted_thing += english_list(req_text_list, and_text = "or")

		else
			formatted_thing = ritual.parse_required_item(req_type)

		what_are_we_missing += formatted_thing

	if(length(what_are_we_missing))
		// Let them know it screwed up
		loc.balloon_alert(user, "ritual failed, missing components!")
		// Then let them know what they're missing
		to_chat(user, span_hierophant_warning("You are missing [english_list(what_are_we_missing)] in order to complete the ritual \"[ritual.name]\"."))
		return FALSE

	//Everything's good, proceed and collect from the available stacks what's needed if needed.
	if(length(stack_reqs))
		for(var/obj/item/stack/nearby_stack in atoms_in_range)
			for(var/stack_path in stack_reqs)
				if(!istype(nearby_stack, stack_path) && (!islist(stack_path) || !is_type_in_list(nearby_stack, stack_path)))
					continue
				var/amount_to_give = min(nearby_stack.amount || stack_reqs[stack_path])
				var/obj/item/stack/our_stack = locate(nearby_stack.merge_type) in selected_atoms
				if(!our_stack)
					our_stack = nearby_stack.split_stack(amount = amount_to_give)
					selected_atoms |= our_stack
				else
					nearby_stack.merge(our_stack, limit = our_stack.amount + amount_to_give)

	// If we made it here, the ritual had all necessary components, and we can try to cast it.
	// This doesn't necessarily mean the ritual will succeed, but it's valid!
	// Do the animations and associated feedback.
	flick("[icon_state]_active", src)
	playsound(user, 'sound/effects/magic/castsummon.ogg', 75, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_exponent = 10)

	// - We temporarily make all of our chosen atoms invisible, as some rituals may sleep,
	// and we don't want people to be able to run off with ritual items.
	// - We make a duplicate list here to ensure that all atoms are correctly un-invisibled by the end.
	// Some rituals may remove atoms from the selected_atoms list, and not consume them.
	var/list/initial_selected_atoms = selected_atoms.Copy()
	for(var/atom/to_disappear as anything in selected_atoms)
		to_disappear.SetInvisibility(INVISIBILITY_ABSTRACT, id=type)

	// All the components have been invisibled, time to actually do the ritual. Call on_finished_recipe
	// (Note: on_finished_recipe may sleep in the case of some rituals like summons, which expect ghost candidates.)
	// - If the ritual was success (Returned TRUE), proceede to clean up the atoms involved in the ritual. The result has already been spawned by this point.
	// - If the ritual failed for some reason (Returned FALSE), likely due to no ghosts taking a role or an error, we shouldn't clean up anything, and reset.
	var/ritual_result = ritual.on_finished_recipe(user, selected_atoms, loc)

	if(ritual_result)
		ritual.cleanup_atoms(selected_atoms)

	// Clean up done, re-appear anything that hasn't been deleted.
	for(var/atom/to_appear as anything in initial_selected_atoms)
		if(QDELETED(to_appear))
			continue
		to_appear.RemoveInvisibility(type)

	// And finally, give some user feedback
	// No feedback is given on failure here -
	// the ritual itself should handle it (providing specifics as to why it failed)
	if(ritual_result)
		loc.balloon_alert(user, "ritual complete")

	return ritual_result


/// A 3x3 heretic rune. The kind heretics actually draw in game.
/obj/effect/heretic_rune/big
	icon = 'icons/effects/96x96.dmi'
	icon_state = "transmutation_rune"
	pixel_x = -30
	pixel_y = 18
	pixel_z = -48
	greyscale_config = /datum/greyscale_config/heretic_rune

/obj/effect/heretic_rune/big/Initialize(mapload, path_colour)
	. = ..()
	if (path_colour)
		set_greyscale(colors = list(path_colour))

/obj/effect/temp_visual/drawing_heretic_rune
	duration = 30 SECONDS
	icon = 'icons/effects/96x96.dmi'
	icon_state = "transmutation_rune"
	pixel_x = -30
	pixel_y = 18
	pixel_z = -48
	plane = FLOOR_PLANE
	layer = RUNE_LAYER
	greyscale_config = /datum/greyscale_config/heretic_rune
	/// We only set this state after setting the colour, otherwise the animation doesn't colour correctly
	var/animation_state = "transmutation_rune_draw"

/obj/effect/temp_visual/drawing_heretic_rune/Initialize(mapload, path_colour = COLOR_WHITE)
	. = ..()
	set_greyscale(colors = list(path_colour))
	icon_state = animation_state
	var/image/silicon_image = image(icon = 'icons/effects/eldritch.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "heretic_rune", silicon_image)

/obj/effect/temp_visual/drawing_heretic_rune/fast
	duration = 12 SECONDS
	animation_state = "transmutation_rune_fast"

/obj/effect/temp_visual/drawing_heretic_rune/fail
	duration = 0.25 SECONDS
	animation_state = "transmutation_rune_fail"

/**
 * Adding this element to an atom will have it automatically render an overlay.
 * The overlay can be specified in new as the first paramter; if not set it defaults to rust_overlay's rust_default
 */
/datum/element/rust
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	argument_hash_start_idx = 2
	/// The rust image itself, since the icon and icon state are only used as an argument
	var/image/rust_overlay

/datum/element/rust/Attach(atom/target, rust_icon = 'icons/effects/rust_overlay.dmi', rust_icon_state = "rust_default")
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	if(!rust_overlay)
		rust_overlay = image(rust_icon, rust_icon_state)
	ADD_TRAIT(target, TRAIT_RUSTY, ELEMENT_TRAIT(type))
	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(apply_rust_overlay))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(handle_examine))
	RegisterSignal (target, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_interaction))
	RegisterSignals(target, list(COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WELDER), COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_RUSTSCRAPER)), PROC_REF(secondary_tool_act))
	RegisterSignal(target, COMSIG_ATOM_EXPOSE_REAGENT, PROC_REF(on_reagent_expose))
	// Unfortunately registering with parent sometimes doesn't cause an overlay update
	target.update_appearance()

/datum/element/rust/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_UPDATE_OVERLAYS)
	UnregisterSignal(source, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(source, COMSIG_ATOM_ITEM_INTERACTION)
	UnregisterSignal(source, list(COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WELDER), COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_RUSTSCRAPER)))
	UnregisterSignal(source, COMSIG_ATOM_EXPOSE_REAGENT)
	REMOVE_TRAIT(source, TRAIT_RUSTY, ELEMENT_TRAIT(type))
	source.update_appearance()

/datum/element/rust/proc/handle_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_notice("[source] is very rusty, you could probably <i>burn</i> or <i>scrape</i> it off.")

/datum/element/rust/proc/apply_rust_overlay(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	if(rust_overlay)
		overlays += rust_overlay

/// Because do_after sleeps we register the signal here and defer via an async call
/datum/element/rust/proc/secondary_tool_act(atom/source, mob/user, obj/item/item)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(handle_tool_use), source, user, item)
	return ITEM_INTERACT_BLOCKING

/// We call this from secondary_tool_act because we sleep with do_after
/datum/element/rust/proc/handle_tool_use(atom/source, mob/user, obj/item/item)
	switch(item.tool_behaviour)
		if(TOOL_WELDER)
			if(!item.tool_start_check(user, amount=1))
				return

			user.balloon_alert(user, "burning off rust...")

			if(!item.use_tool(source, user, 5 SECONDS))
				return
			user.balloon_alert(user, "burned off rust")
			Detach(source)
			return


		if(TOOL_RUSTSCRAPER)
			if(!item.tool_start_check(user))
				return
			user.balloon_alert(user, "scraping off rust...")
			if(!item.use_tool(source, user, 2 SECONDS))
				return
			user.balloon_alert(user, "scraped off rust")
			Detach(source)
			return

///Immediately removes rust if exposed to space cola.
/datum/element/rust/proc/on_reagent_expose(atom/source, datum/reagent/reagent_splashed, reac_volume, methods)
	SIGNAL_HANDLER
	if(!istype(reagent_splashed, /datum/reagent/consumable/space_cola))
		return
	if(methods & INHALE)
		return
	Detach(source)

/// Prevents placing floor tiles on rusted turf
/datum/element/rust/proc/on_interaction(datum/source, mob/user, obj/item/tool, modifiers)
	SIGNAL_HANDLER
	if(istype(tool, /obj/item/stack/tile) || istype(tool, /obj/item/stack/rods))
		user.balloon_alert(user, "floor too rusted!")
		return ITEM_INTERACT_BLOCKING

/// For rust applied by heretics
/datum/element/rust/heretic

/datum/element/rust/heretic/Attach(atom/target, rust_icon, rust_icon_state)
	. = ..()
	if(. == ELEMENT_INCOMPATIBLE)
		return .
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

/datum/element/rust/heretic/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_ENTERED)
	UnregisterSignal(source, COMSIG_ATOM_EXITED)
	for(var/obj/effect/glowing_rune/rune_to_remove in source)
		qdel(rune_to_remove)
	for(var/mob/living/victim in source)
		victim.remove_status_effect(/datum/status_effect/rust_corruption)

/datum/element/rust/heretic/proc/on_entered(turf/source, atom/movable/entered, ...)
	SIGNAL_HANDLER

	if(!isliving(entered))
		return
	var/mob/living/victim = entered
	if(IS_HERETIC(victim))
		return
	if(victim.can_block_magic(MAGIC_RESISTANCE))
		return
	victim.apply_status_effect(/datum/status_effect/rust_corruption)

/datum/element/rust/heretic/proc/on_exited(turf/source, atom/movable/gone)
	SIGNAL_HANDLER
	if(!isliving(gone))
		return
	var/mob/living/leaver = gone
	leaver.remove_status_effect(/datum/status_effect/rust_corruption)

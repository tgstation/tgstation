/datum/action/chameleon_outfit
	name = "Select Chameleon Outfit"
	desc = "LMB: Select a job to update all of your chameleon items to.<br>\
		RMB: Save your current chameleon setup as a custom outfit."
	button_icon_state = "chameleon_outfit"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED

	/// Determines when we're in use
	var/applying = FALSE
	/// Cached assoc list of job outfit datums by their names that we can select
	/// If you intend on editing this, ensure you are copying it first
	var/list/outfit_options
	/// Assoc list of custom outfit names ("Custom outfit 1", "Custom outfit 2", etc) to list of all item typepaths saved in that outfit
	var/list/custom_outfits
	/// Cap on how many custom outfits we can save
	var/max_custom_oufits = 10
	/// Used to generate the next custom outfit name, also to track which next to override if we've passed the limit
	var/next_custom_outfit = 1

/datum/action/chameleon_outfit/New()
	. = ..()
	outfit_options = get_initial_outfits()

/datum/action/chameleon_outfit/proc/get_initial_outfits()
	var/static/list/standard_outfit_options
	if(!standard_outfit_options)
		standard_outfit_options = list()
		for(var/datum/outfit/found_outfit as anything in subtypesof(/datum/outfit/job))
			standard_outfit_options[initial(found_outfit.name)] = new found_outfit()
		sortTim(standard_outfit_options, GLOBAL_PROC_REF(cmp_text_asc))

	return standard_outfit_options

/datum/action/chameleon_outfit/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!. || applying)
		return
	if(usr != owner) // i guess
		return
	applying = TRUE

	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		. = save_current_outfit(usr)
	else
		. = select_outfit(usr)

	applying = FALSE
	return .

/datum/action/chameleon_outfit/proc/save_current_outfit(mob/user)
	var/list/saved_paths = list()
	for(var/datum/action/item_action/chameleon/change/change_action in owner.actions)
		if(change_action.active_type)
			saved_paths |= change_action.active_type

	save_outfit(user, saved_paths)

/datum/action/chameleon_outfit/proc/save_outfit(mob/user, list/saved_paths)
	if(!length(saved_paths))
		owner.balloon_alert(user, "no outfit saved!")
		return

	for(var/existing_outfit in custom_outfits)
		if(custom_outfits[existing_outfit] ~= saved_paths)
			owner.balloon_alert(user, "outfit already saved!")
			return

	if(next_custom_outfit > max_custom_oufits)
		next_custom_outfit = 1

	LAZYSET(custom_outfits, "Custom Outfit #[next_custom_outfit]", saved_paths)
	owner.balloon_alert(user, "outfit saved in slot [next_custom_outfit]")
	next_custom_outfit += 1

/datum/action/chameleon_outfit/proc/select_outfit(mob/user)
	var/list/all_options = list()
	if(LAZYLEN(custom_outfits))
		all_options += "--- Custom outfits ---"
		all_options += custom_outfits
	all_options += "--- Job outfits ---"
	all_options += outfit_options

	var/selected = tgui_input_list(user, "Select outfit to change into", "Chameleon Outfit", all_options)
	if(isnull(selected) || QDELETED(src) || QDELETED(user) || QDELETED(owner) || !IsAvailable(feedback = TRUE))
		return FALSE

	var/selected_outfit = all_options[selected]
	if(islist(selected_outfit))
		var/list/selected_custom_outfit = selected_outfit
		var/datum/outfit/empty_outfit = new()
		apply_outfit(empty_outfit, selected_custom_outfit.Copy())
		qdel(empty_outfit)
		return TRUE

	if(istype(selected_outfit, /datum/outfit))
		apply_outfit(selected_outfit)
		return TRUE

	return FALSE

/**
 * Applies the given outfit to all chameleon actions the owner has
 *
 * * outfit - what outfit to apply
 * * outfit_types - optinal, list of typepaths to apply. If null, defaults to all items in the passed outfit. This list is mutated!
 */
/datum/action/chameleon_outfit/proc/apply_outfit(datum/outfit/outfit, list/outfit_types)
	if(isnull(outfit_types))
		outfit_types = outfit.get_chameleon_disguise_info()

	for(var/datum/action/item_action/chameleon/change/change_action in owner.actions)
		change_action.apply_outfit(outfit, outfit_types)
		if(!isitem(change_action.target))
			continue
		var/obj/item/cham_item = change_action.target
		if(!cham_item.slot_flags)
			continue
		// Clothing items get a small delay to create a visual effect and also introduce some counterplay and also distinguish from lings
		stoplag(0.1 SECONDS)

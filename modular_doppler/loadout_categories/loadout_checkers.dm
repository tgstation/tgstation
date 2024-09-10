// -- The loadout item datum and related procs. --
/// Called after a loadout item gets a custom description
/atom/proc/on_loadout_custom_described()
	return

/*
 * Generate a list of singleton loadout_item datums from all subtypes of [type_to_generate]
 *
 * returns a list of singleton datums.
 */
/proc/generate_loadout_items(type_to_generate)
	RETURN_TYPE(/list)

	. = list()
	if(!ispath(type_to_generate))
		CRASH("generate_loadout_items(): called with an invalid or null path as an argument!")

	for(var/datum/loadout_item/found_type as anything in subtypesof(type_to_generate))
		/// Any item without a name is "abstract"
		if(isnull(initial(found_type.name)))
			continue

		if(!ispath(initial(found_type.item_path)))
			stack_trace("generate_loadout_items(): Attempted to instantiate a loadout item ([initial(found_type.name)]) with an invalid or null typepath! (got path: [initial(found_type.item_path)])")
			continue

		var/datum/loadout_item/spawned_type = new found_type()
		GLOB.all_loadout_datums[spawned_type.item_path] = spawned_type
		. |= spawned_type

/datum/loadout_category
	var/erp_category = FALSE

/datum/loadout_item
	/// If set, is a list of job names of which can get the loadout item
	var/list/restricted_roles
	/// If set, is a list of job names of which can't get the loadout item
	var/list/blacklisted_roles
	/// If set, is a list of species which can get the loadout item
	var/list/restricted_species
	/// Whether the item requires a specific season in order to be available
	var/required_season = null
	/// If the item won't appear when the ERP config is disabled
	var/erp_item = FALSE
	/// If the item goes into the special erp box
	var/erp_box = FALSE

/*
 * Place our [var/item_path] into [outfit].
 *
 * By default, just adds the item into the outfit's backpack contents, if non-visual.
 *
 * equipper - If we're equipping our outfit onto a mob at the time, this is the mob it is equipped on. Can be null.
 * outfit - The outfit we're equipping our items into.
 * visual - If TRUE, then our outfit is only for visual use (for example, a preview).
 * override_items - The type of override to use.
 */
/datum/loadout_item/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(!visuals_only)
		LAZYADD(outfit.backpack_contents, item_path)

/*
 * To be called before insert_path_into_outfit()
 *
 * Checks if an important_for_life item exists and puts the loadout item into the backpack if they would take up the same slot as it.
 *
 * equipper - If we're equipping our outfit onto a mob at the time, this is the mob it is equipped on. Can be null.
 * outfit - The outfit we're equipping our items into.
 * outfit_important_for_life - The outfit whose slots we want to make sure we don't equip an item into.
 * visual - If TRUE, then our outfit is only for visual use (for example, a preview).
 *
 * Returns TRUE if there is an important_for_life item in the slot that the loadout item would normally occupy, FALSE otherwise
 */
/datum/loadout_item/proc/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	outfit_important_for_life = equipper.dna.species.outfit_important_for_life
	if(!outfit_important_for_life || !pre_equip_item(outfit, outfit_important_for_life, src, visuals_only))
		insert_path_into_outfit(outfit, src, visuals_only)
	if(!visuals_only)
		LAZYADD(outfit.backpack_contents, item_path)

/*
 * Called after the item is equipped on [equipper], at the end of character setup.
 */
/datum/loadout_item/proc/post_equip_item(datum/preferences/preference_source, mob/living/carbon/human/equipper)
	return FALSE

/**
 * Called before a loadout item is given to a mob, making sure that they're
 * elligible to receive it, based on all of that item's restrictions, if any.
 *
 * Returns `TRUE` if `target` is allowed to receive this item, `FALSE` if not.
 */
/datum/loadout_item/proc/can_be_applied_to(mob/living/target, datum/preferences/preference_source, datum/job/equipping_job, silent = FALSE)
	var/client/client = preference_source.parent
	if(restricted_roles && equipping_job && !(equipping_job.title in restricted_roles))
		if(client && !silent)
			to_chat(target, span_warning("You were unable to get a loadout item ([initial(item_path.name)]) due to job restrictions!"))
		return FALSE

	if(blacklisted_roles && equipping_job && (equipping_job.title in blacklisted_roles))
		if(client && !silent)
			to_chat(target, span_warning("You were unable to get a loadout item ([initial(item_path.name)]) due to job blacklists!"))
		return FALSE

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		var/datum/dna/dna = carbon_target.dna
		if(!istype(dna) || (restricted_species && !(dna.species.id in restricted_species)))
			if(client && !silent)
				to_chat(target, span_warning("You were unable to get a loadout item ([initial(item_path.name)]) due to species restrictions!"))
			return FALSE
	return TRUE

/datum/loadout_item/get_ui_buttons()
	var/list/buttons = ..()

	if(can_be_named)
		UNTYPED_LIST_ADD(buttons, list(
			"label" = "Change description",
			"act_key" = "set_description",
			"button_icon" = FA_ICON_PEN,
			"active_key" = INFO_DESCRIBED,
		))
	return buttons

/datum/loadout_item/to_ui_data()
	var/list/formatted_item = ..()
	formatted_item["restricted_roles"] = restricted_roles
	formatted_item["blacklisted_roles"] = blacklisted_roles
	formatted_item["restricted_species"] = restricted_species

	return formatted_item

/datum/loadout_item/handle_loadout_action(datum/preference_middleware/loadout/manager, mob/user, action, params)
	if(action == "set_description" && can_be_named)
		return set_description(manager, user)
	return ..()

/// Sets the description of the item.
/datum/loadout_item/proc/set_description(datum/preference_middleware/loadout/manager, mob/user)
	var/list/loadout = manager.preferences.read_preference(/datum/preference/loadout)
	var/input_desc = tgui_input_text(
		user = user,
		message = "What description do you want to give the [name]? Leave blank to clear.",
		title = "[name] description",
		default = loadout?[item_path]?[INFO_DESCRIBED], // plop in existing description (if any)
		max_length = MAX_DESC_LEN,
	)
	if(QDELETED(src) || QDELETED(user) || QDELETED(manager) || QDELETED(manager.preferences))
		return FALSE

	loadout = manager.preferences.read_preference(/datum/preference/loadout) // Make sure no shenanigans happened
	if(!loadout?[item_path])
		return FALSE

	if(input_desc)
		loadout[item_path][INFO_DESCRIBED] = input_desc
	else if(input_desc == "")
		loadout[item_path] -= INFO_DESCRIBED

	manager.preferences.update_preference(GLOB.preference_entries[/datum/preference/loadout], loadout)
	return TRUE

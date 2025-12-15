/**
 * ### Atom skin singleton datum
 *
 * Simple datum which holds information about a skin that can be applied to an atom.
 */
/datum/atom_skin
	abstract_type = /datum/atom_skin

	/// Required, name shown in the radial menu
	var/preview_name

	/// If true, changing the reskin also changes the base_icon_state of the atom
	var/change_base_icon_state = FALSE
	/// If true, changing the reskin also changes the inhand_icon_state of the atom
	var/change_inhand_icon_state = FALSE
	/// If true, unset vars are reset to their original values when applying this skin
	var/reset_missing = TRUE

	/// Optional, name to change the atom to when applied
	var/new_name
	/// Optional, description to change the atom to when applied
	var/new_desc
	/// Optional, icon to change the atom to when applied
	var/new_icon
	/// Optional, icon_state to change the atom to when applied
	var/new_icon_state

/**
 * Applies all relevant skin changes to the given atom
 * Can be overridden to add additional behavior, such as registering signals or altering other vars.
 *
 * * apply_to: The atom to apply the skin to
 */
/datum/atom_skin/proc/apply(atom/apply_to)
	SHOULD_CALL_PARENT(TRUE)
	APPLY_VAR_OR_RESET_INITIAL(apply_to, name, new_name, reset_missing)
	APPLY_VAR_OR_RESET_INITIAL(apply_to, desc, new_desc, reset_missing)
	APPLY_VAR_OR_RESET_INITIAL(apply_to, icon, new_icon, reset_missing)
	APPLY_VAR_OR_RESET_TO(apply_to, icon_state, new_icon_state, reset_missing, initial(apply_to.post_init_icon_state) || initial(apply_to.icon_state))
	if(change_base_icon_state)
		APPLY_VAR_OR_RESET_INITIAL(apply_to, base_icon_state, new_icon_state, reset_missing)
	if(change_inhand_icon_state && isitem(apply_to))
		var/obj/item/item_apply_to = apply_to
		APPLY_VAR_OR_RESET_INITIAL(item_apply_to, inhand_icon_state, new_icon_state, reset_missing)

/**
 * Resets all changes this skin would have made to the given atom
 * Does not verify that the skin was actually applied to the atom beforehand.
 * Can be overridden to add additional behavior, such as unregistering signals or altering other vars.
 *
 * * clear_from: The atom to clear the skin from
 */
/datum/atom_skin/proc/clear_skin(atom/clear_from)
	SHOULD_CALL_PARENT(TRUE)
	RESET_INITIAL_IF_SET(clear_from, name, new_name)
	RESET_INITIAL_IF_SET(clear_from, desc, new_desc)
	RESET_INITIAL_IF_SET(clear_from, icon, new_icon)
	RESET_TO_IF_SET(clear_from, icon_state, new_icon_state, initial(clear_from.post_init_icon_state) || initial(clear_from.icon_state))
	if(change_base_icon_state)
		RESET_INITIAL_IF_SET(clear_from, base_icon_state, new_icon_state)
	if(change_inhand_icon_state && isitem(clear_from))
		var/obj/item/item_clear_from = clear_from
		RESET_INITIAL_IF_SET(item_clear_from, inhand_icon_state, new_icon_state)

/// Gets a preview image for this skin based on the given atom's icon and icon_state
/datum/atom_skin/proc/get_preview_icon(atom/for_atom)
	return image(
		icon = new_icon || for_atom.icon,
		icon_state = new_icon_state || for_atom.icon_state,
	)

/**
 * ### Reskinnable atoms
 *
 * Simple component which lets an atom be alt-clicked to open a radial menu to choose a new skin to apply.
 */
/datum/component/reskinable_item
	dupe_mode = COMPONENT_DUPE_SELECTIVE
	/// Base reskin type to pull options from - all subtypes except those blacklisted are valid options
	VAR_PRIVATE/base_reskin_type
	/// If TRUE, the reskin option is infinite-use. If FALSE, the component is deleted on use (so you're stuck with that skin).
	VAR_PRIVATE/infinite_reskin = FALSE
	/// List of subtypes of /datum/atom_skin that are not allowed to be used for this item
	VAR_PRIVATE/list/blacklisted_subtypes

	/// Currently applied skin preview_name
	VAR_PRIVATE/current_skin

/datum/component/reskinable_item/Initialize(base_reskin_type, infinite = FALSE, initial_skin, list/blacklisted_subtypes = list())
	if(!isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE

	src.base_reskin_type = base_reskin_type
	src.infinite_reskin = infinite
	src.blacklisted_subtypes = blacklisted_subtypes

	if(initial_skin)
		set_skin_by_name(initial_skin)

	var/atom/atom_parent = parent
	atom_parent.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

/datum/component/reskinable_item/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(on_click_alt_reskin))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE_TAGS, PROC_REF(add_tags))
	RegisterSignal(parent, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(add_context))

/datum/component/reskinable_item/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CLICK_ALT)
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE_TAGS)
	UnregisterSignal(parent, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM)

/datum/component/reskinable_item/CheckDupeComponent(datum/component/comp, base_reskin_type, infinite = FALSE, initial_skin, list/blacklisted_subtypes = list())
	if(src.base_reskin_type != base_reskin_type)
		return FALSE // new comp - though the alt-click behavior will collide

	src.infinite_reskin = infinite
	src.blacklisted_subtypes = blacklisted_subtypes

	set_skin_by_name(initial_skin)
	return TRUE // same comp

/datum/component/reskinable_item/proc/get_skins_by_name()
	var/list/reskin_options = list()
	for(var/datum/atom_skin/reskin_option as anything in valid_subtypesof(base_reskin_type) - blacklisted_subtypes)
		reskin_options[reskin_option::preview_name] = reskin_option

	return reskin_options

/datum/component/reskinable_item/proc/set_skin_by_name(input_name)
	var/list/reskin_options = get_skins_by_name()
	if(current_skin)
		var/datum/atom_skin/previous_skin = GLOB.atom_skins[reskin_options[current_skin]]
		previous_skin.clear_skin(parent)

	if(input_name)
		var/datum/atom_skin/reskin_to_apply = GLOB.atom_skins[reskin_options[input_name]]
		reskin_to_apply.apply(parent)

	current_skin = input_name

	var/atom/atom_parent = parent
	atom_parent.update_appearance()

	if(isitem(parent))
		var/obj/item/item_parent = parent
		item_parent.update_slot_icon()

	SEND_SIGNAL(parent, COMSIG_OBJ_RESKIN, input_name)

/datum/component/reskinable_item/proc/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	context[SCREENTIP_CONTEXT_ALT_LMB] = "Reskin"
	return CONTEXTUAL_SCREENTIP_SET

/datum/component/reskinable_item/proc/add_tags(atom/source, mob/user, list/tags)
	SIGNAL_HANDLER

	tags["reskinnable"] = "This item is able to be reskinned! Alt-Click to do so!"

/// Called when alt clicked and the item has unique reskin options
/datum/component/reskinable_item/proc/on_click_alt_reskin(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!user.can_perform_action(parent, NEED_DEXTERITY))
		return NONE

	INVOKE_ASYNC(src, PROC_REF(reskin_obj), user)
	return CLICK_ACTION_SUCCESS

/**
 * Reskins object based on a user's choice
 *
 * Arguments:
 * * user The mob choosing a reskin option
 */
/datum/component/reskinable_item/proc/reskin_obj(mob/user)
	var/atom/atom_parent = parent

	var/list/items = list()
	for(var/reskin_name, reskin_typepath in get_skins_by_name())
		items[reskin_name] = GLOB.atom_skins[reskin_typepath].get_preview_icon(atom_parent)

	sort_list(items)

	var/pick = show_radial_menu(user, parent, items, custom_check = CALLBACK(src, PROC_REF(check_reskin_menu), user), radius = 38, require_near = TRUE)
	if(!pick || !items[pick])
		return

	set_skin_by_name(pick)
	to_chat(user, span_info("[parent] is now skinned as '[pick].'"))

	if(!infinite_reskin)
		qdel(src)

/**
 * Checks if we are allowed to interact with a radial menu for reskins
 *
 * Arguments:
 * * user The mob interacting with the menu
 */
/datum/component/reskinable_item/proc/check_reskin_menu(mob/user)
	if(QDELETED(parent))
		return FALSE
	if(user.incapacitated)
		return FALSE
	return TRUE

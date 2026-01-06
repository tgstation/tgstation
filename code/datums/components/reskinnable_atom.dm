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
	/// Specifies the icon state for the atom's appearance in hand. Should appear in both new_lefthand_file and new_righthand_file.
	var/new_inhand_icon_state
	/// Optional, specifies the left hand inhand icon file. Don't forget to set the right hand file as well.
	var/new_lefthand_file
	/// Optional, specifies the right hand inhand icon file. Don't forget to set the left hand file as well.
	var/new_righthand_file
	/// Optional, specifies the worn icon file.
	var/new_worn_icon
	/// When set true, will allow concrete subtypes of abstract subtypes (such as for organizational purposes) to be selectable as reskins in the loadout menu.
	var/allow_all_subtypes_in_loadout
	/// Mandatory for GAGs items. The path to the greyscale item this is to be applied to.
	var/atom/greyscale_item_path
	/// Auto populated. The greyscale_config from greyscale_item_path.
	VAR_FINAL/greyscale_config
	/// Auto populated. The greyscale_colors from greyscale_item_path.
	VAR_FINAL/greyscale_colors

/datum/atom_skin/New()
	. = ..()
	if(isnull(greyscale_item_path))
		return

	// Populate the fields required for GAGS previews
	greyscale_config = greyscale_item_path::greyscale_config
	greyscale_colors = greyscale_item_path::greyscale_colors

	// The icon isn't 'new'. So we don't make an extra icon in map_icons.
	if(greyscale_item_path::post_init_icon_state == new_icon_state)
		new_icon_state = null

/// Returns the correct preview icon state for this atom skin, whether it be a map_preview or a normal icon. This is assumed from our var population above.
/datum/atom_skin/proc/get_preview_icon_state()
	if(isnull(greyscale_item_path)) // Not a GAGs icon
		return new_icon_state
	if(isnull(new_icon_state)) // The base GAGS item icon
		return "[greyscale_item_path]"

	return "[greyscale_item_path]--[new_icon_state]" // A GAGs reskin of the item icon

/**
 * Applies all relevant skin changes to the given atom
 * Can be overridden to add additional behavior, such as registering signals or altering other vars.
 *
 * * apply_to: The atom to apply the skin to
 */
/datum/atom_skin/proc/apply(atom/apply_to, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(!HAS_TRAIT(apply_to, TRAIT_WAS_RENAMED))
		APPLY_VAR_OR_RESET_INITIAL(apply_to, name, new_name, reset_missing)
		APPLY_VAR_OR_RESET_INITIAL(apply_to, desc, new_desc, reset_missing)
	if(!apply_to.greyscale_config) // Never want to be resetting a GAGS icon back to initial.
		APPLY_VAR_OR_RESET_INITIAL(apply_to, icon, new_icon, reset_missing)
	APPLY_VAR_OR_RESET_TO(apply_to, icon_state, new_icon_state, reset_missing, initial(apply_to.post_init_icon_state) || initial(apply_to.icon_state))
	if(change_base_icon_state)
		APPLY_VAR_OR_RESET_INITIAL(apply_to, base_icon_state, new_icon_state, reset_missing)
	if(isitem(apply_to))
		var/obj/item/item_apply_to = apply_to
		if(!item_apply_to.greyscale_config_worn)
			APPLY_VAR_OR_RESET_INITIAL(item_apply_to, worn_icon, new_worn_icon, reset_missing)
		if(!item_apply_to.greyscale_config_inhand_left)
			APPLY_VAR_OR_RESET_INITIAL(item_apply_to, lefthand_file, new_lefthand_file, reset_missing)
			APPLY_VAR_OR_RESET_INITIAL(item_apply_to, righthand_file, new_righthand_file, reset_missing)
		APPLY_VAR_OR_RESET_INITIAL(item_apply_to, worn_icon_state, new_icon_state, reset_missing)
		if(change_inhand_icon_state || new_inhand_icon_state)
			APPLY_VAR_OR_RESET_INITIAL(item_apply_to, inhand_icon_state, new_inhand_icon_state || new_icon_state, reset_missing)

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
	var/is_greyscale = clear_from.greyscale_config || clear_from.greyscale_colors
	if(!is_greyscale)
		RESET_INITIAL_IF_SET(clear_from, icon, new_icon)
	RESET_TO_IF_SET(clear_from, icon_state, new_icon_state, initial(clear_from.post_init_icon_state) || initial(clear_from.icon_state))
	if(change_base_icon_state)
		RESET_INITIAL_IF_SET(clear_from, base_icon_state, new_icon_state)
	if(isitem(clear_from))
		var/obj/item/item_clear_from = clear_from
		RESET_INITIAL_IF_SET(item_clear_from, worn_icon, new_worn_icon)
		RESET_INITIAL_IF_SET(item_clear_from, inhand_icon_state, change_inhand_icon_state ? new_inhand_icon_state : new_icon_state)
		if(!is_greyscale)
			RESET_INITIAL_IF_SET(item_clear_from, worn_icon_state, new_icon_state)
			RESET_INITIAL_IF_SET(item_clear_from, lefthand_file, new_lefthand_file)
			RESET_INITIAL_IF_SET(item_clear_from, righthand_file, new_righthand_file)

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

/datum/component/reskinable_item/Initialize(base_reskin_type, infinite = FALSE, initial_skin, list/blacklisted_subtypes)
	if(!isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/atom_parent = parent
#ifdef UNIT_TESTS
	if(atom_parent.greyscale_config && (atom_parent.type in GLOB.all_loadout_datums)) // We only care about these when they're in the loadout
		var/datum/atom_skin/reskin_type = base_reskin_type
		if(reskin_type && isnull(reskin_type::greyscale_item_path)) // greyscale_item_path unset
			stack_trace("[type] added to a greyscale item without setting the greyscale_item_path! In [reskin_type], add 'greyscale_item_path = [atom_parent::type]'.")
		else if(atom_parent.type != reskin_type::greyscale_item_path) // greyscale_item_path set but doesn't match the item it's being added to
			stack_trace("[type] added to an invalid item type, [atom_parent.type]. [reskin_type] is set up to only be added to: [reskin_type::greyscale_item_path]. \
				Either fix its greyscale_item_path if this is incorrect, or apply a different skin.")
#endif

	src.base_reskin_type = base_reskin_type
	src.infinite_reskin = infinite
	src.blacklisted_subtypes = blacklisted_subtypes

	if(initial_skin)
		set_skin_by_name(initial_skin)

	var/list/reskin_options = get_skins_by_name()
	if(length(reskin_options) <= 1) // Check that we actually have reskin options - if not there's no point to existing past this point.
		return COMPONENT_REDUNDANT

	atom_parent.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

/datum/component/reskinable_item/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(on_click_alt_reskin))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE_TAGS, PROC_REF(add_tags))
	RegisterSignal(parent, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(add_context))

/datum/component/reskinable_item/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CLICK_ALT)
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE_TAGS)
	UnregisterSignal(parent, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM)

/datum/component/reskinable_item/CheckDupeComponent(datum/component/comp, base_reskin_type, infinite = FALSE, initial_skin, list/blacklisted_subtypes)
	// Always absorb added components
	src.base_reskin_type = base_reskin_type
	src.infinite_reskin = infinite
	src.blacklisted_subtypes = blacklisted_subtypes

	if(initial_skin)
		set_skin_by_name(initial_skin)

	var/list/reskin_options = get_skins_by_name()
	if(length(reskin_options) <= 1) // Check that we actually have reskin options - if not there's no point to existing past this point.
		qdel(src)

	return TRUE

/datum/component/reskinable_item/proc/get_skins_by_name()
	var/list/reskin_options = list()
	for(var/datum/atom_skin/reskin_option as anything in valid_subtypesof(base_reskin_type) - blacklisted_subtypes)
		reskin_options[reskin_option::preview_name] = reskin_option

	return reskin_options

/datum/component/reskinable_item/proc/set_skin_by_name(input_name, mob/user)
	var/list/reskin_options = get_skins_by_name()
	var/list/atom_skins = get_atom_skins()
	if(current_skin)
		var/datum/atom_skin/previous_skin = atom_skins[reskin_options[current_skin]]
		previous_skin.clear_skin(parent, user)

	if(input_name)
		var/datum/atom_skin/reskin_to_apply = atom_skins[reskin_options[input_name]]
		reskin_to_apply.apply(parent, user)

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
	var/list/atom_skins = get_atom_skins()
	for(var/reskin_name, reskin_typepath in get_skins_by_name())
		var/datum/atom_skin/reskin = atom_skins[reskin_typepath]
		items[reskin_name] = image(icon = reskin.new_icon || atom_parent.icon, icon_state = reskin.new_icon_state || atom_parent.icon_state)

	sort_list(items)

	var/pick = show_radial_menu(user, parent, items, custom_check = CALLBACK(src, PROC_REF(check_reskin_menu), user), radius = 38, require_near = TRUE)
	if(!pick || !items[pick])
		return

	set_skin_by_name(pick, user)
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

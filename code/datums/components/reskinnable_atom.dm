/// Global list of available atom skins
GLOBAL_LIST_INIT_TYPED(atom_skins, /datum/atom_skin, init_subtypes_w_path_keys(/datum/atom_skin))

/**
 * ### Atom skin singleton datum
 *
 * Simple datum which holds information about a skin that can be applied to an atom.
 */
/datum/atom_skin
	abstract_type = /datum/atom_skin

	/// Name shown in the radial menu
	var/preview_name

	/// If true, changing the reskin also changes the base_icon_state of the atom
	var/change_base_icon_state
	/// If true, changing the reskin also changes the inhand_icon_state of the atom
	var/change_inhand_icon_state

	/// Optional, name to change the atom to when applied
	var/new_name

	/// Optional, description to change the atom to when applied
	/// You can use %NEW_SKIN% in the description to insert the preview_name of the new skin
	var/new_desc

	/// Optional, icon to change the atom to when applied
	var/new_icon

	/// Optional, icon_state to change the atom to when applied
	var/new_icon_state

/datum/atom_skin/proc/apply(atom/apply_to, reset_missing = FALSE)
	if(new_name)
		apply_to.name = new_name
	else if(reset_missing)
		apply_to.name = initial(apply_to.name)
	if(new_desc)
		apply_to.desc = replacetext(new_desc, "%NEW_SKIN%", preview_name)
	else if(reset_missing)
		apply_to.desc = initial(apply_to.desc)
	if(new_icon)
		apply_to.icon = new_icon
	else if(reset_missing)
		apply_to.icon = initial(apply_to.icon)
	if(new_icon_state)
		apply_to.icon_state = new_icon_state
	else if(reset_missing)
		apply_to.icon_state = initial(apply_to.post_init_icon_state) || initial(apply_to.icon_state)

	if(change_base_icon_state)
		apply_to.base_icon_state = new_icon_state
	else if(reset_missing)
		apply_to.base_icon_state = initial(apply_to.base_icon_state)

	if(isitem(apply_to))
		var/obj/item/item_apply_to = apply_to
		if(change_inhand_icon_state)
			item_apply_to.inhand_icon_state = new_icon_state
		else if(reset_missing)
			item_apply_to.inhand_icon_state = initial(item_apply_to.inhand_icon_state)

/**
 * ### Reskinnable atoms
 *
 * Simple component which lets an atom be alt-clicked to open a radial menu to choose a new skin to apply.
 */
/datum/component/reskinable_item
	/// Base reskin type to pull options from - all subtypes are valid options
	VAR_PRIVATE/base_reskin_type
	/// If TRUE, the reskin option is infinite-use. If FALSE, the component is deleted on use (so you're stuck with that skin).
	VAR_PRIVATE/infinite_reskin = FALSE
	/// Currently applied skin preview_name
	VAR_PRIVATE/current_skin

/datum/component/reskinable_item/Initialize(base_reskin_type, infinite = FALSE)
	if(!isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE

	src.base_reskin_type = base_reskin_type
	src.infinite_reskin = infinite

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
	var/list/items = list()
	var/list/reskin_datums = list()
	for(var/reskin_option in subtypesof(base_reskin_type))
		var/datum/atom_skin/reskin = GLOB.atom_skins[reskin_option]

		items += list("[reskin.preview_name]" = image(icon = reskin.new_icon, icon_state = reskin.new_icon_state))
		reskin_datums[reskin.preview_name] = reskin

	sort_list(items)

	var/pick = show_radial_menu(user, parent, items, custom_check = CALLBACK(src, PROC_REF(check_reskin_menu), user), radius = 38, require_near = TRUE)
	if(!pick || !reskin_datums[pick])
		return

	var/datum/atom_skin/reskin_to_apply = reskin_datums[pick]
	reskin_to_apply.apply(parent, !!current_skin)

	current_skin = pick

	to_chat(user, span_info("[parent] is now skinned as '[pick].'"))
	SEND_SIGNAL(parent, COMSIG_OBJ_RESKIN, user, pick)

	var/atom/atom_parent = parent
	atom_parent.update_appearance()

	if(isitem(parent))
		var/obj/item/item_parent = parent
		item_parent.update_slot_icon()

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

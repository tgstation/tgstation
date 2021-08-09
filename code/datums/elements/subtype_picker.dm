/**
 * subtype picker element allows for an item to transform into its subtypes (this is not enforced and you can turn in whatever types, but
 * i used this name as it was incredibly accurate for current usage of the behavior)
 *
 * Used for the null rod to pick the other holy weapons.
 * NOTE: this may set off a red flag as there are states on an element, but these are initialized values set by the first bespoke element.
 * further subtype_pickers of the same type will not change the states.
 */
/datum/element/subtype_picker
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	///on Attach, it's a list of types and their menu descriptions. after building, it's a list of lists with all the data each item needs to give to the radial menu.
	var/list/subtype2descriptions
	///list given to the radial menu to display
	var/list/built_radial_list
	///the radial will return a name of the wanted subtype, this is a list of references back to the type
	var/list/name2subtype
	///optional proc to callback to when the weapon is picked
	var/datum/callback/on_picked_callback

/datum/element/subtype_picker/Attach(datum/target, subtype2descriptions, on_picked_callback)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	src.subtype2descriptions = subtype2descriptions
	src.on_picked_callback = on_picked_callback
	if(!built_radial_list)
		build_radial_list()
	RegisterSignal(target, COMSIG_ITEM_ATTACK_SELF, .proc/on_attack_self)

/datum/element/subtype_picker/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ITEM_ATTACK_SELF)

///signal called by the stat of the target changing
/datum/element/subtype_picker/proc/on_attack_self(datum/target, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/pick_subtype, target, user)

/**
 * pick_subtype: turns the list of types to their description into all the data radial menus need
 */
/datum/element/subtype_picker/proc/build_radial_list()
	built_radial_list = list()
	name2subtype = list()
	for(var/obj/item/subtype as anything in subtype2descriptions)

		var/datum/radial_menu_choice/option = new
		option.image = image(icon = initial(subtype.icon), icon_state = initial(subtype.icon_state))
		option.info = span_boldnotice(subtype2descriptions[subtype])

		name2subtype[initial(subtype.name)] = subtype
		built_radial_list += list(initial(subtype.name) = option)
	built_radial_list = sortList(built_radial_list)

/**
 * pick_subtype: called from on_attack_self, shows a user a radial menu of all available null rod reskins and replaces the current null rod with the user's chosen reskinned variant
 *
 * Arguments:
 * * target: parent this element is attached to that is being activated
 * * picker: user who interacted with the item
 */
/datum/element/subtype_picker/proc/pick_subtype(datum/target, mob/picker)

	var/name_of_type = show_radial_menu(picker, target, built_radial_list, custom_check = CALLBACK(src, .proc/check_menu, target, picker), radius = 42, require_near = TRUE)
	if(!name_of_type || !check_menu(target, picker))
		return

	on_picked_callback?.Invoke(picked_subtype)

	var/picked_subtype = name2subtype[name_of_type] // This needs to be on a separate var as list member access is not allowed for new
	picked_subtype = new picked_subtype(picker.drop_location())

	qdel(target)
	picker.put_in_hands(picked_subtype)

/**
 * Checks if we are allowed to interact with the radial menu
 *
 * Arguments:
 * * target: parent the radial menu is from
 * * user: the mob interacting with the menu
 */
/datum/element/subtype_picker/proc/check_menu(datum/target, mob/user)
	if(!istype(user))
		return FALSE
	if(QDELETED(target))
		return FALSE
	if(user.incapacitated() || !user.is_holding(target))
		return FALSE
	return TRUE

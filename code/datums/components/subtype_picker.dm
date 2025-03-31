/**
 * subtype picker component allows for an item to transform into its subtypes (this is not enforced and you can turn in whatever types, but
 * i used this name as it was incredibly accurate for current usage of the behavior)
 *
 * Used for the null rod to pick the other holy weapons.
 */
/datum/component/subtype_picker
	///A list of types and their menu descriptions
	var/list/subtype2descriptions
	///list given to the radial menu to display, built after init
	var/list/built_radial_list
	///the radial will return a name of the wanted subtype, this is a list of names back to the type, built after init
	var/list/name2subtype
	///optional proc to callback to when the weapon is picked
	var/datum/callback/on_picked_callback

/datum/component/subtype_picker/Initialize(subtype2descriptions, on_picked_callback)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.subtype2descriptions = subtype2descriptions
	src.on_picked_callback = on_picked_callback
	build_radial_list()

/datum/component/subtype_picker/Destroy(force)
	on_picked_callback = null
	return ..()

/datum/component/subtype_picker/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))

/datum/component/subtype_picker/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)

///signal called by the stat of the target changing
/datum/component/subtype_picker/proc/on_attack_self(datum/target, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(pick_subtype), target, user)

/**
 * pick_subtype: turns the list of types to their description into all the data radial menus need
 */
/datum/component/subtype_picker/proc/build_radial_list()
	built_radial_list = list()
	name2subtype = list()
	for(var/obj/item/subtype as anything in subtype2descriptions)

		var/datum/radial_menu_choice/option = new
		option.image = image(icon = initial(subtype.icon), icon_state = initial(subtype.icon_state))
		option.info = span_boldnotice(subtype2descriptions[subtype])

		name2subtype[initial(subtype.name)] = subtype
		built_radial_list += list(initial(subtype.name) = option)
	built_radial_list = sort_list(built_radial_list)

/**
 * pick_subtype: called from on_attack_self, shows a user a radial menu of all available null rod reskins and replaces the current null rod with the user's chosen reskinned variant
 *
 * Arguments:
 * * target: parent this element is attached to that is being activated
 * * picker: user who interacted with the item
 */
/datum/component/subtype_picker/proc/pick_subtype(datum/target, mob/picker)

	var/name_of_type = show_radial_menu(picker, target, built_radial_list, custom_check = CALLBACK(src, PROC_REF(check_menu), target, picker), radius = 42, require_near = TRUE)
	if(!name_of_type || !check_menu(target, picker))
		return

	var/picked_subtype = name2subtype[name_of_type]
	on_picked_callback?.Invoke(picked_subtype)
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
/datum/component/subtype_picker/proc/check_menu(datum/target, mob/user)
	if(!istype(user))
		return FALSE
	if(QDELETED(target))
		return FALSE
	if(user.incapacitated || !user.is_holding(target))
		return FALSE
	return TRUE

/datum/sortrouter_filter
	/// name of the filter shown in UI
	var/name
	/// if it meets criteria, item is pushed to this direction
	var/dir_target = NORTH
	/// value of our filter, checked by us
	var/value = ""
	/// is our output inverted? checked by sorter
	var/inverted = FALSE
	/// the sorter we belong to
	var/obj/machinery/power/manufacturing/sorter/sorter

/datum/sortrouter_filter/New(sorter)
	. = ..()
	if(isnull(sorter))
		return
	src.sorter = sorter

/datum/sortrouter_filter/Destroy()
	. = ..()
	if(isnull(sorter))
		return
	sorter = null

/datum/sortrouter_filter

/datum/sortrouter_filter/proc/return_name()
	return name

/datum/sortrouter_filter/proc/edit(mob/user)
	to_chat(user, "This filter is not editable.")

/datum/sortrouter_filter/proc/meets_conditions(atom/checking)

/datum/sortrouter_filter/is_stack
	name = "input is stack"

/datum/sortrouter_filter/is_stack/meets_conditions(atom/checking)
	return isstack(checking)

/datum/sortrouter_filter/is_ore
	name = "input is ore"

/datum/sortrouter_filter/is_ore/meets_conditions(atom/checking)
	return istype(checking, /obj/item/stack/ore)

/datum/sortrouter_filter/is_mail
	name = "input is mail"

/datum/sortrouter_filter/is_mail/meets_conditions(atom/checking)
	return istype(checking, /obj/item/mail)

/datum/sortrouter_filter/is_tagged
	name = "input is tagged X"

/datum/sortrouter_filter/is_tagged/edit(mob/user)
	var/target = tgui_input_list(user, "Select a tag", "Tag", sort_list(GLOB.TAGGERLOCATIONS))
	if(isnull(target) || !user.can_perform_action(sorter, ALLOW_SILICON_REACH))
		return
	value = GLOB.TAGGERLOCATIONS.Find(target)

/datum/sortrouter_filter/is_tagged/return_name()
	return "input is tagged [value ? GLOB.TAGGERLOCATIONS[value] : ""]"

/datum/sortrouter_filter/is_tagged/meets_conditions(checking)
	var/obj/item/delivery/mail_or_delivery = checking
	var/sort_tag
	if(istype(checking, /obj/item/delivery) || istype(checking, /obj/item/mail))
		sort_tag = mail_or_delivery.sort_tag

	return value == sort_tag

/datum/sortrouter_filter/name_contains
	name = "input's name contains"

/datum/sortrouter_filter/name_contains/edit(mob/user)
	var/target = tgui_input_text(user, "What should it contain?", "Name", value, 12)
	if(isnull(target)|| !user.can_perform_action(sorter, ALLOW_SILICON_REACH))
		return
	value = target

/datum/sortrouter_filter/name_contains/return_name()
	return "input's name contains [value]"

/datum/sortrouter_filter/name_contains/meets_conditions(atom/checking)
	return findtext(LOWER_TEXT(checking.name), value)

/datum/sortrouter_filter/is_path_specific
	name = "input is specific item"
	/// are we currently listening for an item to set as our filter?
	var/currently_listening = FALSE

/datum/sortrouter_filter/is_path_specific/edit(mob/user)
	name = initial(name)
	if(!currently_listening)
		name = "awaiting item"
		to_chat(user, "Hit the sorter with the item of choice to set the filter.")
		sorter.balloon_alert(user, "awaiting item!")
		currently_listening = TRUE
		RegisterSignal(sorter, COMSIG_ATOM_ATTACKBY, PROC_REF(sorter_hit))
	else
		currently_listening = FALSE
		UnregisterSignal(sorter, COMSIG_ATOM_ATTACKBY)

/datum/sortrouter_filter/is_path_specific/proc/sorter_hit(datum/source, obj/item/attacking_item, user, params)
	currently_listening = FALSE
	value = attacking_item.type
	name = attacking_item.name
	sorter.balloon_alert(user, "filter set")
	UnregisterSignal(sorter, COMSIG_ATOM_ATTACKBY)
	return COMPONENT_NO_AFTERATTACK

/datum/sortrouter_filter/is_path_specific/meets_conditions(atom/checking)
	return checking.type == value

/datum/sortrouter_filter/is_path_specific/subtypes
	name = "input is specific kind of item"

/datum/sortrouter_filter/is_path_specific/subtypes/meets_conditions(atom/checking)
	return istype(checking.type, value)

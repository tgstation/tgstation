/obj/item/implantpad
	name = "implant pad"
	desc = "Used to modify implants."
	icon = 'icons/obj/devices/tool.dmi'
	icon_state = "implantpad-0"
	base_icon_state = "implantpad"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	interaction_flags_click = FORBID_TELEKINESIS_REACH|ALLOW_RESTING

	///The implant case currently inserted into the pad.
	var/obj/item/implantcase/inserted_case

/obj/item/implantpad/update_icon_state()
	icon_state = "[base_icon_state]-[!isnull(inserted_case)]"
	return ..()

/obj/item/implantpad/examine(mob/user)
	. = ..()
	if(!inserted_case)
		. += span_info("It is currently empty.")
		return

	if(Adjacent(user))
		. += span_info("It contains \a [inserted_case].")
	else
		. += span_warning("There seems to be something inside it, but you can't quite tell what from here...")
	. += span_info("Alt-click to remove [inserted_case].")

/obj/item/implantpad/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == inserted_case)
		inserted_case = null
		update_appearance(UPDATE_ICON)

/obj/item/implantpad/attackby(obj/item/implantcase/attacking_item, mob/user, list/modifiers)
	if(inserted_case || !istype(attacking_item))
		return ..()
	if(!user.transferItemToLoc(attacking_item, src))
		return
	user.balloon_alert(user, "case inserted")
	inserted_case = attacking_item
	update_static_data_for_all_viewers()
	update_appearance(UPDATE_ICON)

/obj/item/implantpad/click_alt(mob/user)
	remove_implant(user)
	return CLICK_ACTION_SUCCESS

/obj/item/implantpad/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "ImplantPad", name)
		ui.open()

/obj/item/implantpad/ui_static_data(mob/user)
	var/list/data = list()
	data["has_case"] = !!inserted_case
	if(!inserted_case)
		return data
	data["has_implant"] = !!inserted_case.imp
	if(inserted_case.imp)
		data["case_information"] = inserted_case.imp.get_data()
	return data

/obj/item/implantpad/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = usr
	if(action == "eject_implant")
		remove_implant(user)
		return

///Removes the implant from the pad and puts it in the user's hands if possible.
/obj/item/implantpad/proc/remove_implant(mob/user)
	if(!inserted_case)
		user.balloon_alert(user, "no case inside!")
		return FALSE
	add_fingerprint(user)
	inserted_case.add_fingerprint(user)
	user.put_in_hands(inserted_case)
	user.balloon_alert(user, "case removed")
	update_appearance(UPDATE_ICON)
	update_static_data_for_all_viewers()
	return TRUE

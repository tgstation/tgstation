/atom/movable/screen/robot
	icon = 'icons/hud/screen_cyborg.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/robot/module
	name = "cyborg module"
	icon_state = "nomod"

/atom/movable/screen/robot/Click(location, control, params)
	if(isobserver(usr))
		return TRUE

/atom/movable/screen/robot/module/Click(location, control, params)
	. = ..()
	var/mob/living/silicon/robot/robot_owner = hud.mymob
	if(robot_owner.model.type == /obj/item/robot_model)
		if(.)
			return
		robot_owner.pick_model()
		return

	var/list/modifiers = params2list(params)
	var/obj/item/held_item = robot_owner.get_active_held_item()
	if(held_item && !LAZYACCESS(modifiers, RIGHT_CLICK) && !.)
		robot_owner.deactivate_module(held_item)
		return

	// Observers can look at borg's inventories, so we ignore parent return value here, unlike everywhere else.
	if(usr.active_storage == robot_owner.model.atom_storage)
		robot_owner.model.atom_storage.hide_contents(usr)
	else
		robot_owner.model.atom_storage.open_storage(usr)
	return TRUE

/atom/movable/screen/robot/module_slot
	name = "Module"
	examine_thats = "This is your"
	desc = "Stun prod goes here."
	icon_state = "inv1"
	base_icon_state = "inv1"
	/// Slot number of the module
	VAR_FINAL/slot_num = 1
	VAR_PRIVATE/static/list/possible_text_colors = list("#ff0000", "#ff9900", "#00cc00")

/atom/movable/screen/robot/module_slot/proc/set_slot(slot_num)
	src.slot_num = slot_num
	var/slot_column = ((slot_num - 1) % 3) + 1

	name = "Module [slot_num]"
	base_icon_state = "inv[slot_column]"
	icon_state = base_icon_state

	maptext = MAPTEXT_SPESSFONT("<span style='color: [possible_text_colors[slot_column]]; -dm-text-outline: 0'>[slot_num]</span>")
	maptext_x = 6
	maptext_y = 19

/atom/movable/screen/robot/module_slot/Click()
	if(..())
		return
	var/mob/living/silicon/robot/borg = usr
	borg.swap_hand(slot_num)

/atom/movable/screen/robot/radio
	name = "radio"
	icon_state = "radio"
	screen_loc = ui_borg_radio

/atom/movable/screen/robot/radio/Click()
	if(..())
		return
	var/mob/living/silicon/robot/R = usr
	R.radio.interact(R)

/atom/movable/screen/robot/lamp
	name = "headlamp"
	icon_state = "lamp_off"
	base_icon_state = "lamp"
	screen_loc = ui_borg_lamp

/atom/movable/screen/robot/lamp/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/user = usr
	user.toggle_headlamp()
	update_appearance()

/atom/movable/screen/robot/lamp/update_icon_state()
	icon_state = "[base_icon_state]_[astype(hud?.mymob, /mob/living/silicon/robot)?.lamp_enabled ? "on" : "off"]"
	return ..()

/atom/movable/screen/robot/modpc
	name = "Modular Interface"
	icon_state = "template"
	screen_loc = ui_borg_tablet

/atom/movable/screen/robot/modpc/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/user = usr
	user.modularInterface?.interact(user)

/atom/movable/screen/robot/alerts
	name = "Alert Panel"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "alerts"
	screen_loc = ui_borg_alerts

/atom/movable/screen/robot/alerts/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/borgo = usr
	borgo.alert_control.ui_interact(borgo)

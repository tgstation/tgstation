/atom/movable/screen/robot
	icon = 'icons/hud/screen_cyborg.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/robot/module
	name = "cyborg module"
	icon_state = "nomod"

/atom/movable/screen/robot/Click()
	if(isobserver(usr))
		return TRUE

/atom/movable/screen/robot/module/Click()
	//observers can look at borg's inventories
	var/mob/living/silicon/robot/robot_owner = hud.mymob
	if(robot_owner.model.type != /obj/item/robot_model)
		if(usr.active_storage == robot_owner.model.atom_storage)
			robot_owner.model.atom_storage.hide_contents(usr)
		else
			robot_owner.model.atom_storage.open_storage(usr)
		return TRUE
	. = ..()
	if(.)
		return
	robot_owner.pick_model()

/atom/movable/screen/robot/module_slot
	name = "module"
	icon_state = "inv1"
	/// Slot number of the module
	var/slot_num = 1

/atom/movable/screen/robot/module_slot/proc/set_slot(slot_num)
	src.slot_num = slot_num
	name = "module[slot_num]"
	icon_state = "inv[slot_num]"

/atom/movable/screen/robot/module_slot/Click()
	if(..())
		return
	var/mob/living/silicon/robot/R = usr
	R.toggle_module(slot_num)

/atom/movable/screen/robot/radio
	name = "radio"
	icon_state = "radio"
	screen_loc = ui_borg_radio

/atom/movable/screen/robot/radio/Click()
	if(..())
		return
	var/mob/living/silicon/robot/R = usr
	R.radio.interact(R)

/atom/movable/screen/robot/store
	name = "store"
	icon_state = "store"
	screen_loc = ui_borg_store

/atom/movable/screen/robot/store/Click()
	if(..())
		return
	var/mob/living/silicon/robot/R = usr
	R.uneq_active()

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

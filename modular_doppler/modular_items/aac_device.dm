/obj/item/aac_device
	name = "AAC Device"
	desc = "An Augmented and Alternative Communication device designed to facilitate oral communication \
	for people with communicative disabilities."
	icon = 'modular_doppler/modular_cosmetics/GAGS/icons/obj/devices.dmi'
	icon_state = "aac_device"
	w_class = WEIGHT_CLASS_SMALL
	obj_flags = UNIQUE_RENAME
	slot_flags = ITEM_SLOT_BELT
	flags_1 = IS_PLAYER_COLORABLE_1
	greyscale_config = /datum/greyscale_config/aac_device
	greyscale_colors = "#FFFFFF#FFFFFF"

/obj/item/aac_device/attack_self(mob/user)
	user.balloon_alert_to_viewers("typing...", "started typing...")
	playsound(src, 'modular_doppler/modular_items/sounds/aac_started_type.ogg', 50, TRUE)
	var/str = tgui_input_text(user, "What would you like the device to say?", "Say Text", "", MAX_MESSAGE_LEN, encode = FALSE)
	if(!str)
		user.balloon_alert_to_viewers("stops typing", "stopped typing")
		playsound(src, 'modular_doppler/modular_items/sounds/aac_stopped_type.ogg', 50, TRUE)
		return
	src.say(str)
	str = null

/obj/item/aac_device/item_ctrl_click(mob/user)
	var/new_name = reject_bad_name(tgui_input_text(user, "Name your Text-to-Speech device. This matters for displaying it in the chat bar.", "Set TTS Device Name", "", MAX_NAME_LEN))
	if(new_name)
		name = "[new_name]'s [initial(name)]"
	else
		name = initial(name)

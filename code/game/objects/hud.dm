/obj/hud
	name = "hud"
	unacidable = 1
	var/mob/mymob = null
	var/list/adding = null
	var/list/other = null
	var/obj/screen/druggy = null
	var/vimpaired = null
	var/obj/screen/alien_view = null
	var/obj/screen/g_dither = null
	var/obj/screen/blurry = null
	var/list/darkMask = null
	var/obj/screen/r_hand_hud_object = null
	var/obj/screen/l_hand_hud_object = null
	var/show_intent_icons = 1
	var/list/obj/screen/hotkeybuttons = null
	var/hotkey_ui_hidden = 0 //This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/list/obj/screen/item_action/item_action_list = null //Used for the item action ui buttons.

	var/h_type = /obj/screen		//this is like...the most pointless thing ever. Use a god damn define!
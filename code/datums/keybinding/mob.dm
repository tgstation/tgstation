/datum/keybinding/mob
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB


/datum/keybinding/mob/face_north
	hotkey_keys = list("CtrlW", "CtrlNorth")
	name = "face_north"
	full_name = "Face North"
	description = ""
	keybind_signal = COMSIG_KB_MOB_FACENORTH_DOWN

/datum/keybinding/mob/face_north/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.northface()
	return TRUE


/datum/keybinding/mob/face_east
	hotkey_keys = list("CtrlD", "CtrlEast")
	name = "face_east"
	full_name = "Face East"
	description = ""
	keybind_signal = COMSIG_KB_MOB_FACEEAST_DOWN

/datum/keybinding/mob/face_east/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.eastface()
	return TRUE


/datum/keybinding/mob/face_south
	hotkey_keys = list("CtrlS", "CtrlSouth")
	name = "face_south"
	full_name = "Face South"
	description = ""
	keybind_signal = COMSIG_KB_MOB_FACESOUTH_DOWN

/datum/keybinding/mob/face_south/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.southface()
	return TRUE

/datum/keybinding/mob/face_west
	hotkey_keys = list("CtrlA", "CtrlWest")
	name = "face_west"
	full_name = "Face West"
	description = ""
	keybind_signal = COMSIG_KB_MOB_FACEWEST_DOWN

/datum/keybinding/mob/face_west/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.westface()
	return TRUE

/datum/keybinding/mob/stop_pulling
	hotkey_keys = list("H", "Delete")
	name = "stop_pulling"
	full_name = "Stop pulling"
	description = ""
	keybind_signal = COMSIG_KB_MOB_STOPPULLING_DOWN

/datum/keybinding/mob/stop_pulling/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	if(!M.pulling)
		to_chat(user, "<span class='notice'>You are not pulling anything.</span>")
	else
		M.stop_pulling()
	return TRUE

/datum/keybinding/mob/cycle_intent_right
	hotkey_keys = list("Northwest") // HOME
	name = "cycle_intent_right"
	full_name = "cycle intent right"
	description = ""
	keybind_signal = COMSIG_KB_MOB_CYCLEINTENTRIGHT_DOWN

/datum/keybinding/mob/cycle_intent_right/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_RIGHT)
	return TRUE

/datum/keybinding/mob/cycle_intent_left
	hotkey_keys = list("Insert")
	name = "cycle_intent_left"
	full_name = "cycle intent left"
	description = ""
	keybind_signal = COMSIG_KB_MOB_CYCLEINTENTLEFT_DOWN

/datum/keybinding/mob/cycle_intent_left/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_LEFT)
	return TRUE

/datum/keybinding/mob/swap_hands
	hotkey_keys = list("X", "Northeast") // PAGEUP
	name = "swap_hands"
	full_name = "Swap hands"
	description = ""
	keybind_signal = COMSIG_KB_MOB_SWAPHANDS_DOWN

/datum/keybinding/mob/swap_hands/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.swap_hand()
	return TRUE

/datum/keybinding/mob/activate_inhand
	hotkey_keys = list("Z", "Southeast") // Southeast = PAGEDOWN
	name = "activate_inhand"
	full_name = "Activate in-hand"
	description = "Uses whatever item you have inhand"
	keybind_signal = COMSIG_KB_MOB_ACTIVATEINHAND_DOWN

/datum/keybinding/mob/activate_inhand/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.mode()
	return TRUE

/datum/keybinding/mob/drop_item
	hotkey_keys = list("Q")
	name = "drop_item"
	full_name = "Drop Item"
	description = ""
	keybind_signal = COMSIG_KB_MOB_DROPITEM_DOWN

/datum/keybinding/mob/drop_item/down(client/user)
	. = ..()
	if(.)
		return
	if(iscyborg(user.mob)) //cyborgs can't drop items
		return FALSE
	var/mob/M = user.mob
	var/obj/item/I = M.get_active_held_item()
	if(!I)
		to_chat(user, "<span class='warning'>You have nothing to drop in your hand!</span>")
	else
		user.mob.dropItemToGround(I)
	return TRUE

/datum/keybinding/mob/toggle_move_intent
	hotkey_keys = list("Alt")
	name = "toggle_move_intent"
	full_name = "Hold to toggle move intent"
	description = "Held down to cycle to the other move intent, release to cycle back"
	keybind_signal = COMSIG_KB_MOB_TOGGLEMOVEINTENT_DOWN

/datum/keybinding/mob/toggle_move_intent/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/mob/toggle_move_intent/up(client/user)
	var/mob/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/mob/toggle_move_intent_alternative
	hotkey_keys = list("Unbound")
	name = "toggle_move_intent_alt"
	full_name = "press to cycle move intent"
	description = "Pressing this cycle to the opposite move intent, does not cycle back"
	keybind_signal = COMSIG_KB_MOB_TOGGLEMOVEINTENTALT_DOWN

/datum/keybinding/mob/toggle_move_intent_alternative/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/mob/target_head_cycle
	hotkey_keys = list("Numpad8")
	name = "target_head_cycle"
	full_name = "Target: Cycle head"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETCYCLEHEAD_DOWN

/datum/keybinding/mob/target_head_cycle/down(client/user)
	. = ..()
	if(.)
		return
	user.body_toggle_head()
	return TRUE

/datum/keybinding/mob/target_r_arm
	hotkey_keys = list("Numpad4")
	name = "target_r_arm"
	full_name = "Target: right arm"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTARM_DOWN

/datum/keybinding/mob/target_r_arm/down(client/user)
	. = ..()
	if(.)
		return
	user.body_r_arm()
	return TRUE

/datum/keybinding/mob/target_body_chest
	hotkey_keys = list("Numpad5")
	name = "target_body_chest"
	full_name = "Target: Body"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETBODYCHEST_DOWN

/datum/keybinding/mob/target_body_chest/down(client/user)
	. = ..()
	if(.)
		return
	user.body_chest()
	return TRUE

/datum/keybinding/mob/target_left_arm
	hotkey_keys = list("Numpad6")
	name = "target_left_arm"
	full_name = "Target: left arm"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTARM_DOWN

/datum/keybinding/mob/target_left_arm/down(client/user)
	. = ..()
	if(.)
		return
	user.body_l_arm()
	return TRUE

/datum/keybinding/mob/target_right_leg
	hotkey_keys = list("Numpad1")
	name = "target_right_leg"
	full_name = "Target: Right leg"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETRIGHTLEG_DOWN

/datum/keybinding/mob/target_right_leg/down(client/user)
	. = ..()
	if(.)
		return
	user.body_r_leg()
	return TRUE

/datum/keybinding/mob/target_body_groin
	hotkey_keys = list("Numpad2")
	name = "target_body_groin"
	full_name = "Target: Groin"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETBODYGROIN_DOWN

/datum/keybinding/mob/target_body_groin/down(client/user)
	. = ..()
	if(.)
		return
	user.body_groin()
	return TRUE

/datum/keybinding/mob/target_left_leg
	hotkey_keys = list("Numpad3")
	name = "target_left_leg"
	full_name = "Target: left leg"
	description = ""
	keybind_signal = COMSIG_KB_MOB_TARGETLEFTLEG_DOWN

/datum/keybinding/mob/target_left_leg/down(client/user)
	. = ..()
	if(.)
		return
	user.body_l_leg()
	return TRUE



/datum/keybinding/mob/action
	description = "Alt click an action button and set it to the corresponding number to use this hotkey"
	keybind_signal = "temp_lazy"
	var/action_num = 0

/datum/keybinding/mob/action/New()
	keybind_signal = COMSIG_KB_MOB_ACTIONBINDING_DOWN(action_num)
	return ..()


/datum/keybinding/mob/action/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/user_mob = user.mob
	var/obj/screen/movable/action_button/bound_button = user_mob.action_bindings[action_num]
	if(bound_button)
		bound_button.Click()

/datum/keybinding/mob/action/action_binding_one
	hotkey_keys = list()
	name = "action_binding_one"
	full_name = "Action button one"
	action_num = 1

/datum/keybinding/mob/action/action_binding_two
	hotkey_keys = list()
	name = "action_binding_two"
	full_name = "Action button two"
	action_num = 2

/datum/keybinding/mob/action/action_binding_three
	hotkey_keys = list()
	name = "action_binding_three"
	full_name = "Action button three"
	action_num = 3

/datum/keybinding/mob/action/action_binding_four
	hotkey_keys = list()
	name = "action_binding_four"
	full_name = "Action button four"
	action_num = 4

/datum/keybinding/mob/action/action_binding_five
	hotkey_keys = list("5")
	name = "action_binding_five"
	full_name = "Action button five"
	action_num = 5

/datum/keybinding/mob/action/action_binding_six
	hotkey_keys = list("6")
	name = "action_binding_six"
	full_name = "Action button six"
	action_num = 6

/datum/keybinding/mob/action/action_binding_seven
	hotkey_keys = list("7")
	name = "action_binding_seven"
	full_name = "Action button seven"
	action_num = 7

/datum/keybinding/mob/action/action_binding_eight
	hotkey_keys = list("8")
	name = "action_binding_eight"
	full_name = "Action button eight"
	action_num = 8

/datum/keybinding/mob/action/action_binding_nine
	hotkey_keys = list("9")
	name = "action_binding_nine"
	full_name = "Action button nine"
	action_num = 9

/datum/keybinding/mob/action/action_binding_ten
	hotkey_keys = list("0")
	name = "action_binding_ten"
	full_name = "Action button ten"
	action_num = 10

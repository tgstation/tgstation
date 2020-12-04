
/atom/movable/screen/robot/pda_msg_send
	name = "PDA - Send Message"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "pda_send"

/atom/movable/screen/robot/pda_msg_send/Click()
	if(..())
		return
	var/mob/living/silicon/robot/R = usr
	R.cmd_send_pdamesg(usr)

/atom/movable/screen/robot/pda_msg_show
	name = "PDA - Show Message Log"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "pda_receive"

/atom/movable/screen/robot/pda_msg_show/Click()
	if(..())
		return
	var/mob/living/silicon/robot/R = usr
	R.cmd_show_message_log(usr)


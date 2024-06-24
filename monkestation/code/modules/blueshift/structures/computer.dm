/obj/machinery/computer/shuttle/pod/advanced
	icon = 'monkestation/code/modules/blueshift/icons/computer.dmi'
	icon_state = "intercom"
	icon_screen = "null"
	layer = ABOVE_OBJ_LAYER

/obj/machinery/computer/shuttle/pod/advanced/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	locked = FALSE
	to_chat(user, span_warning("You fry the pod's alert level checking system."))
	return TRUE

/obj/machinery/computer/emergency_shuttle/advanced
	icon = 'monkestation/code/modules/blueshift/icons/computer.dmi'
	icon_state = "computer"
	icon_keyboard = ""
	icon_screen = ""

/obj/machinery/computer/crew/shuttle
	icon = 'monkestation/code/modules/blueshift/icons/computer.dmi'
	icon_state = "computer_left"
	icon_keyboard = ""
	icon_screen = ""


/obj/machinery/computer/security/shuttle
	icon = 'monkestation/code/modules/blueshift/icons/computer.dmi'
	icon_state = "computer_right"
	icon_keyboard = ""
	icon_screen = ""

/obj/machinery/computer/shuttle/ferry/shuttle
	icon = 'monkestation/code/modules/blueshift/icons/computer.dmi'
	icon_state = "computer"
	icon_keyboard = ""
	icon_screen = ""

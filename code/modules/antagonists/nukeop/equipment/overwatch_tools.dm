///One of the special items that spawns in the overwatch agent's room.
/obj/item/paper/fluff/overwatch
	name = "OVERWATCH NOTES #1"
	color = COLOR_RED
	desc = "A "
	default_raw_text = @{"

<br>

<br>

<br>

	"}

/obj/machinery/computer/security/overwatch
	name = "overwatch camera console"
	desc = "Allows you to view members of your operative team "
	icon_screen = "syndie"
	icon_keyboard = "syndie_key"
	network = list(OPERATIVE_CAMERA_NET)
	circuit = /obj/item/circuitboard/computer/overwatch

/obj/item/circuitboard/computer/overwatch
	name = "Overwatch Cameras"
	build_path = /obj/machinery/computer/security/overwatch

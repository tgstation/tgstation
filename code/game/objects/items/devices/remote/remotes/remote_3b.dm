//Three button vertical remote
//IDs go from the bottom slot to the top slot

/obj/item/device/remote/three_button
	name = "three-button remote"
	icon_state = "remote_3b"

/obj/item/device/remote/three_button/New()
	..()
	controller = new/datum/context_click/remote_control/three_button(src)

/datum/context_click/remote_control/three_button
	buttons = list("3B1" = null,
					"3B2" = null,
					"3B3" = null)

/datum/context_click/remote_control/three_button/return_clicked_id(x_pos, y_pos)
	switch(y_pos)
		if(6 to 12)
			return "3B1"
		if(13 to 19)
			return "3B2"
		if(20 to 26)
			return "3B3"

/datum/context_click/remote_control/three_button/get_icon_type(button_id)
	return "3b"

/datum/context_click/remote_control/three_button/get_pixel_displacement(button_id)
	var/y_dis = 0
	switch(button_id)
		if("3B1")
			y_dis = -7
		if("3B2")
			y_dis = 0
		if("3B3")
			y_dis = 7
	return list("pixel_x" = 0, "pixel_y" = y_dis)
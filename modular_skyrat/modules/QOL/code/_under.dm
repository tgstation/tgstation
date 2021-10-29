/obj/item/clothing/under/CtrlClick(mob/user)
	. = ..()
	if(has_sensor == HAS_SENSORS)
		sensor_mode = SENSOR_COORDS
		to_chat(usr, "<span class='notice'>Your suit will now report your exact vital lifesigns as well as your coordinate position.</span>")

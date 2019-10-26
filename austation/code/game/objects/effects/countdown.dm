/obj/effect/countdown/dominator
	name = "dominator countdown"
	text_size = 1
	color = "#ff00ff" // Overwritten when the dominator starts

/obj/effect/countdown/dominator/get_value()
	var/obj/machinery/dominator/D = attached_to
	if(!istype(D) || !D.gang)
		return
	if(D.gang.domination_time != NOT_DOMINATING)
		return D.gang.domination_time_remaining()
	else
		return "OFFLINE"
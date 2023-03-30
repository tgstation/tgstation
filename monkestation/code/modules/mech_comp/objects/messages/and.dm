/obj/item/mcobject/messaging/and
	name = "AND component"
	base_icon_state = "comp_and"
	icon_state = "comp_and"

	var/input1
	var/input2
	var/time_window = 1 SECONDS

/obj/item/mcobject/messaging/and/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("input 1", check1)
	MC_ADD_INPUT("input 2", check2)
	MC_ADD_CONFIG("Set Time Window", set_time)

/obj/item/mcobject/messaging/and/examine(mob/user)
	. = ..()
	. += span_notice("Check window: <b>[time_window]</b> tenths of a second.")

/obj/item/mcobject/messaging/and/proc/set_time(mob/user, obj/item/tool)
	var/time = input("Enter the window in tenths of a second", "Configure Component", time_window) as null|num
	if(isnull(time))
		return

	time_window = time
	to_chat(user, span_notice("You set the time window of [src] to [time]."))
	log_message("time window set to [time_window] by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

/obj/item/mcobject/messaging/and/proc/check1(datum/mcmessage/input)
	set waitfor = FALSE
	if(input1)
		return
	if(!input.Truthy())
		return

	input1 = TRUE

	if(input2)
		fire(stored_message, input)
		input1 = 0
		input2 = 0
		return

	sleep(time_window)
	input1 = FALSE

/obj/item/mcobject/messaging/and/proc/check2(datum/mcmessage/input)
	set waitfor = FALSE
	if(input2)
		return
	if(!input.Truthy())
		return

	input2 = TRUE
	if(input1)
		fire(stored_message, input)
		input1 = 0
		input2 = 0
		return

	sleep(time_window)
	input2 = FALSE

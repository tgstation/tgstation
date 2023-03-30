/obj/item/mcobject/messaging/delay
	name = "delay component"
	base_icon_state = "comp_wait"
	icon_state = "comp_wait"

	var/on = FALSE
	var/delay = 1 SECONDS

/obj/item/mcobject/messaging/delay/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("delay", delay)
	MC_ADD_CONFIG("Set Delay", set_delay)

/obj/item/mcobject/messaging/delay/update_icon_state()
	. = ..()
	icon_state = on ? "[icon_state]1" : icon_state

/obj/item/mcobject/messaging/delay/examine(mob/user)
	. = ..()
	. += span_notice("Delay: [delay] tenths of a second.")

/obj/item/mcobject/messaging/delay/proc/set_delay(mob/user, obj/item/tool)
	var/time = input(user, "Enter delay in tenths of a second", "Configure Component", delay) as null|num
	if(!time)
		return

	delay = time
	to_chat(user, span_notice("You set the delay on [src] to [delay]."))
	log_message("delay set tp [delay] by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

/obj/item/mcobject/messaging/delay/proc/delay(datum/mcmessage/input)
	set waitfor = FALSE
	if(on)
		return

	on = TRUE
	update_icon_state()
	sleep(delay)
	fire(input)
	on = FALSE
	update_icon_state()

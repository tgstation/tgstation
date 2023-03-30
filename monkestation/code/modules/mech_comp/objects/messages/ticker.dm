/obj/item/mcobject/messaging/ticker
	name = "ticker component"
	base_icon_state = "comp_arith"
	icon_state = "comp_arith"

	var/interval = 1 SECONDS
	///Store the number of loops we want seperately.
	var/total_loops = -1
	var/loops = -1
	var/on = FALSE

/obj/item/mcobject/messaging/ticker/Initialize(mapload)
	. = ..()
	MC_ADD_CONFIG("Set Interval", set_interval)
	MC_ADD_CONFIG("Set Loop Counter", set_loops)
	MC_ADD_INPUT("begin loop", start_loop)

/obj/item/mcobject/messaging/ticker/examine(mob/user)
	. = ..()
	. += span_notice("It is currently [on ? "on" : "off"].")
	. += span_notice("Interval time: [interval] second(s).")
	. += span_notice("Total loops: [total_loops == -1 ? "infinite" : total_loops].")

/obj/item/mcobject/messaging/ticker/proc/set_interval(mob/user, obj/item/tool)
	var/num = input(user, "Set interval in seconds (0.5 - 60)", "Configure Component", interval) as null|num
	if(!num)
		return

	interval = clamp(num, 0.5, 60)
	to_chat(user, "You set [src]'s interval to [interval] seconds.")
	return TRUE

/obj/item/mcobject/messaging/ticker/proc/set_loops(mob/user, obj/item/tool)
	var/num = input(user, "Set number of loops (-1 for infinite)", "Configure Component", total_loops) as null|num
	if(isnull(num))
		return

	total_loops = clamp(num, -1, 100)
	to_chat(user, "You set [src]'s loop count to [total_loops == -1 ? "infinite" : "[total_loops]"].")
	return TRUE

/obj/item/mcobject/messaging/ticker/proc/start_loop(datum/mcmessage/input)
	set waitfor = FALSE
	if(on)
		return
	on = TRUE
	loops = total_loops
	while(!QDELETED(src) && ((loops > 0) || total_loops == -1))
		loops--
		fire(stored_message)
		sleep(interval * 10) //Convert interval to deciseconds
	on = FALSE

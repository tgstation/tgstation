/obj/item/mcobject/messaging/repeater
	name = "repeater component"
	base_icon_state = "comp_arith"
	icon_state = "comp_arith"

	var/processing = FALSE
	var/loops_needed = 1
	var/loops = 0

/obj/item/mcobject/messaging/repeater/Initialize(mapload)
	. = ..()
	configs -= MC_CFG_OUTPUT_MESSAGE
	MC_ADD_CONFIG("Set Delay", set_delay)
	MC_ADD_INPUT("toggle", toggle)

	START_PROCESSING(SSobj, src)

/obj/item/mcobject/messaging/repeater/proc/toggle(datum/mcmessage/input)
	processing = !processing
	say("Will now [processing ? "Loop" : "Wait"]")


/obj/item/mcobject/messaging/repeater/proc/set_delay(mob/user, obj/item/tool)
	var/time = tgui_input_number(user, "Enter how many cycles to wait (1 cycle is 2 seconds)", "Configure Component", loops_needed, 100, 1)
	if(!time)
		return
	loops_needed = time

/obj/item/mcobject/messaging/repeater/process(seconds_per_tick)
	if(!processing)
		return
	if(loops_needed <= loops)
		fire(stored_message)
		loops = 0
		return
	loops ++

/obj/item/mcobject/messaging/radioscanner
	name = "radio scanner component"
	base_icon_state = "comp_radioscanner"
	icon_state = "comp_radioscanner"

	var/frequency = FREQ_COMMON
	var/obj/item/radio/radio

/obj/item/mcobject/messaging/radioscanner/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.canhear_range = 0
	configs -= MC_CFG_OUTPUT_MESSAGE

	MC_ADD_INPUT("set frequency", set_frequency)
	MC_ADD_CONFIG("Set Frequency", set_frequency_config)
	RegisterSignal(radio, COMSIG_RADIO_NEW_MESSAGE, PROC_REF(incoming_message))

/obj/item/mcobject/messaging/radioscanner/proc/change_frequency(num)
	num = sanitize_frequency(num)
	frequency = num
	radio.set_frequency(frequency)
	return frequency

/obj/item/mcobject/messaging/radioscanner/proc/set_frequency(datum/mcmessage/input)
	var/number = text2num(input.cmd)
	if((isnull(number)))
		return

	change_frequency(number)

/obj/item/mcobject/messaging/radioscanner/proc/set_frequency_config(mob/user, obj/item/tool)
	var/num = input(user, "Set frequency", "Configure Component", frequency) as null|num
	if(!num)
		return
	num = change_frequency(num)
	to_chat(user, span_notice("You set [src]'s frequency to [format_frequency(frequency)]."))
	return TRUE

/obj/item/mcobject/messaging/radioscanner/proc/incoming_message(datum/source, atom/movable/speaker, message, freq_num)
	SIGNAL_HANDLER

	fire("name=[speaker.GetVoice()]&message=[message]") //mimic list2params

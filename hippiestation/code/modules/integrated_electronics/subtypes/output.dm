/obj/item/integrated_circuit/output/text_to_radio
	name = "text-to-radio circuit"
	desc = "Takes any string as an input and will make the device output it in the radio with the frequency chosen as input."
	extended_desc = "Similar to the text-to-speech circuit, except the fact that the text is converted into a subspace signal and broadcasted to the desired frequency, or 1459 as default.\
					The frequency is a string, not a number, and doesn't need the dot. Example: Common frequency is 145.9, so the result is '1459' as a string."
	icon_state = "speaker"
	complexity = 15
	inputs = list("text" = IC_PINTYPE_STRING, "frequency" = IC_PINTYPE_STRING)
	outputs = list()
	activators = list("broadcast" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 100
	var/obj/item/device/radio/radio

/obj/item/integrated_circuit/output/text_to_radio/Initialize()
	..()
	radio = new(src)

/obj/item/integrated_circuit/output/text_to_radio/Destroy()
	qdel(radio)
	..()

/obj/item/integrated_circuit/output/text_to_radio/do_work()
	text = get_pin_data(IC_INPUT, 1)
	var/freq = get_pin_data(IC_INPUT, 2)
	if(!isnull(text))
		var/atom/movable/A = get_object()
		radio.talk_into(A, text, GLOB.reverseradiochannels[freq], SPAN_ROBOT)
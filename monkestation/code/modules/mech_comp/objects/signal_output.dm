/obj/item/mcobject/signal_output
	name = "signal output component"

	icon = 'monkestation/icons/obj/mechcomp.dmi'
	icon_state = "comp_signal"
	base_icon_state = "comp_signal"

	var/datum/radio_frequency/radio_connection
	var/signal_frequency = FREQ_SIGNALER
	var/code = DEFAULT_SIGNALER_CODE

/obj/item/mcobject/signal_output/Initialize(mapload)
	. = ..()
	MC_ADD_CONFIG("Change Signal Code", adjust_signal)
	MC_ADD_INPUT("change signal", change_signal_input)
	MC_ADD_INPUT("fire", send_signal)

	set_frequency(signal_frequency)

/obj/item/mcobject/signal_output/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)
	return

/obj/item/mcobject/signal_output/proc/send_signal(datum/mcmessage/input)
	if(!radio_connection)
		return

	var/logging_data = "[src] has sent signal [code]."

	var/datum/signal/signal = new(list("code" = code), logging_data = logging_data)
	radio_connection.post_signal(src, signal)

/obj/item/mcobject/signal_output/proc/adjust_signal(mob/user, obj/item/tool)
	var/new_code = tgui_input_number(user, "Change the Signal Code", "Signal Output Component", code, min_value = 0)
	if(!new_code)
		return
	code = new_code
	say("SUCCESS:Signal Code changed: [code]")
	return TRUE

/obj/item/mcobject/signal_output/proc/change_signal_input(datum/mcmessage/input)
	var/buffer = text2num(input.cmd)
	if(!IS_SAFE(buffer))
		return
	code = buffer

/datum/computer_file/program/signaler
	filename = "signaler"
	filedesc = "SignalCommander"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "signal"
	extended_desc = "A small built-in frequency app that sends out signaller signals with the appropriate hardware."
	size = 2
	tgui_id = "NtosSignaler"
	program_icon = "satellite-dish"
	usage_flags = PROGRAM_TABLET | PROGRAM_LAPTOP
	///What is the saved signal frequency?
	var/signal_frequency = FREQ_SIGNALER
	/// What is the saved signal code?
	var/signal_code = DEFAULT_SIGNALER_CODE
	/// Radio connection datum used by signalers.
	var/datum/radio_frequency/radio_connection

/datum/computer_file/program/signaler/run_program(mob/living/user)
	. = ..()
	if (!.)
		return
	if(!computer?.get_modular_computer_part(MC_SIGNALER)) //Giving a clue to users why the program is spitting out zeros.
		to_chat(user, "<span class='warning'>\The [computer] flashes an error: \"hardware\\signal_hardware\\startup.bin -- file not found\".</span>")


/datum/computer_file/program/signaler/ui_data(mob/user)
	var/list/data = get_header_data()
	var/obj/item/computer_hardware/radio_card/sensor = computer?.get_modular_computer_part(MC_SIGNALER)
	if(sensor?.check_functionality())
		data["frequency"] = signal_frequency
		data["code"] = signal_code
		data["minFrequency"] = MIN_FREE_FREQ
		data["maxFrequency"] = MAX_FREE_FREQ
	return data

/datum/computer_file/program/signaler/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/obj/item/computer_hardware/radio_card/sensor = computer?.get_modular_computer_part(MC_SIGNALER)
	if(!(sensor?.check_functionality()))
		playsound(src, 'sound/machines/scanbuzz.ogg', 100, FALSE)
		return
	switch(action)
		if("signal")
			INVOKE_ASYNC(src, .proc/signal)
			. = TRUE
		if("freq")
			signal_frequency = unformat_frequency(params["freq"])
			signal_frequency = sanitize_frequency(signal_frequency, TRUE)
			set_frequency(signal_frequency)
			. = TRUE
		if("code")
			signal_code = text2num(params["code"])
			signal_code = round(signal_code)
			. = TRUE
		if("reset")
			if(params["reset"] == "freq")
				signal_frequency = initial(signal_frequency)
			else
				signal_code = initial(signal_code)
			. = TRUE

/datum/computer_file/program/signaler/proc/signal()
	if(!radio_connection)
		return

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)

	var/logging_data
	if(usr)
		logging_data = "[time] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(signal_frequency)]/[signal_code]"
		GLOB.lastsignalers.Add(logging_data)

	var/datum/signal/signal = new(list("code" = signal_code), logging_data = logging_data)
	radio_connection.post_signal(src, signal)

/datum/computer_file/program/signaler/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, signal_frequency)
	signal_frequency = new_frequency
	radio_connection = SSradio.add_object(src, signal_frequency, RADIO_SIGNALER)
	return

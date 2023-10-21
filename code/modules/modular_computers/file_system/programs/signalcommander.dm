/datum/computer_file/program/signal_commander
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
	/// How long do we cooldown before we can send another signal?
	var/signal_cooldown_time =  1 SECONDS
	/// Cooldown store
	COOLDOWN_DECLARE(signal_cooldown)

/datum/computer_file/program/signal_commander/on_start(mob/living/user)
	. = ..()
	set_frequency(signal_frequency)

/datum/computer_file/program/signal_commander/kill_program(mob/user)
	. = ..()
	SSradio.remove_object(computer, signal_frequency)

/datum/computer_file/program/signal_commander/ui_data(mob/user)
	var/list/data = list()
	data["frequency"] = signal_frequency
	data["cooldown"] = signal_cooldown_time
	data["code"] = signal_code
	data["minFrequency"] = MIN_FREE_FREQ
	data["maxFrequency"] = MAX_FREE_FREQ
	return data

/datum/computer_file/program/signal_commander/ui_act(action, list/params)
	switch(action)
		if("signal")
			INVOKE_ASYNC(src, PROC_REF(signal))
			. = TRUE
		if("freq")
			var/new_signal_frequency = sanitize_frequency(unformat_frequency(params["freq"]), TRUE)
			set_frequency(new_signal_frequency)
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

/datum/computer_file/program/signal_commander/proc/signal()
	if(!radio_connection)
		return

	if(!COOLDOWN_FINISHED(src, signal_cooldown))
		computer.balloon_alert(usr, "cooling down!")
		return

	COOLDOWN_START(src, signal_cooldown, signal_cooldown_time)
	computer.balloon_alert(usr, "signaled")

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(computer)

	var/logging_data = "[time] <B>:</B> [key_name(usr)] used the computer '[initial(computer.name)]' @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(signal_frequency)]/[signal_code]"
	add_to_signaler_investigate_log(logging_data)

	var/datum/signal/signal = new(list("code" = signal_code), logging_data = logging_data)
	radio_connection.post_signal(computer, signal)

/datum/computer_file/program/signal_commander/proc/set_frequency(new_frequency)
	SSradio.remove_object(computer, signal_frequency)
	signal_frequency = new_frequency
	radio_connection = SSradio.add_object(computer, signal_frequency, RADIO_SIGNALER)

/datum/computer_file/program/signal_commander
	filename = "signaler"
	filedesc = "SignalCommander"
	downloader_category = PROGRAM_CATEGORY_EQUIPMENT
	program_open_overlay = "signal"
	extended_desc = "A small built-in frequency app that sends out signaller signals with the appropriate hardware."
	size = 2
	tgui_id = "NtosSignaler"
	program_icon = "satellite-dish"
	can_run_on_flags = PROGRAM_PDA | PROGRAM_LAPTOP
	program_flags = /datum/computer_file/program::program_flags | PROGRAM_CIRCUITS_RUN_WHEN_CLOSED
	circuit_comp_type = /obj/item/circuit_component/mod_program/signaler
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

/datum/computer_file/program/signal_commander/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("signal")
			INVOKE_ASYNC(src, PROC_REF(signal), usr)
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

/datum/computer_file/program/signal_commander/proc/signal(atom/source)
	if(!radio_connection)
		return

	var/mob/user
	var/obj/item/circuit_component/signaling
	if(ismob(source))
		user = source
	else if(istype(source, /obj/item/circuit_component))
		signaling = source

	if(!COOLDOWN_FINISHED(src, signal_cooldown))
		if(user)
			computer.balloon_alert(user, "cooling down!")
		return

	COOLDOWN_START(src, signal_cooldown, signal_cooldown_time)
	if(user)
		computer.balloon_alert(user, "signaled")

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(computer)
	var/user_deets
	if(signaling)
		user_deets = "[signaling.parent.get_creator()]"
	else
		user_deets = "[key_name(usr)]"
	var/logging_data = "[time] <B>:</B> [user_deets] used the computer '[initial(computer.name)]' @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(signal_frequency)]/[signal_code]"
	add_to_signaler_investigate_log(logging_data)

	var/datum/signal/signal = new(list("code" = signal_code, "key" = signaling?.parent.owner_id), logging_data = logging_data)
	radio_connection.post_signal(computer, signal)

/datum/computer_file/program/signal_commander/proc/set_frequency(new_frequency)
	SSradio.remove_object(computer, signal_frequency)
	signal_frequency = new_frequency
	radio_connection = SSradio.add_object(computer, signal_frequency, RADIO_SIGNALER)

/obj/item/circuit_component/mod_program/signaler
	associated_program = /datum/computer_file/program/signal_commander
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// Frequency input
	var/datum/port/input/freq
	/// Signal input
	var/datum/port/input/code

/obj/item/circuit_component/mod_program/signaler/populate_ports()
	. = ..()
	freq = add_input_port("Frequency", PORT_TYPE_NUMBER, trigger = PROC_REF(set_freq), default = FREQ_SIGNALER)
	code = add_input_port("Code", PORT_TYPE_NUMBER, trigger = PROC_REF(set_code), default = DEFAULT_SIGNALER_CODE)

/obj/item/circuit_component/mod_program/signaler/proc/set_freq(datum/port/port)
	var/datum/computer_file/program/signal_commander/signaler = associated_program
	signaler.set_frequency(clamp(freq.value, MIN_FREE_FREQ, MAX_FREE_FREQ))

/obj/item/circuit_component/mod_program/signaler/proc/set_code(datum/port/port)
	var/datum/computer_file/program/signal_commander/signaler = associated_program
	signaler.signal_code = round(clamp(code.value, 1, 100))

/obj/item/circuit_component/mod_program/signaler/input_received(datum/port/port)
	INVOKE_ASYNC(associated_program, TYPE_PROC_REF(/datum/computer_file/program/signal_commander, signal), src)

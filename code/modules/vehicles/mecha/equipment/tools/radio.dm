///Mech radio module
/obj/item/mecha_parts/mecha_equipment/radio
	name = "mounted radio"
	desc = "A basic component of every vehicle."
	icon_state = "mecha_radio"
	equipment_slot = MECHA_UTILITY
	///Internal radio item
	var/obj/item/radio/mech/radio

/obj/item/mecha_parts/mecha_equipment/radio/Initialize(mapload)
	. = ..()
	radio = new(src)
	RegisterSignal(radio, COMSIG_QDELETING, PROC_REF(radio_deleted))

/obj/item/mecha_parts/mecha_equipment/radio/Destroy()
	qdel(radio)
	return ..()

/obj/item/mecha_parts/mecha_equipment/radio/get_snowflake_data()
	return list(
		"snowflake_id" = MECHA_SNOWFLAKE_ID_RADIO,
		"microphone" = radio.get_broadcasting(),
		"speaker" = radio.get_listening(),
		"frequency" = radio.get_frequency(),
		"minFrequency" = radio.freerange ? MIN_FREE_FREQ : MIN_FREQ,
		"maxFrequency" = radio.freerange ? MAX_FREE_FREQ : MAX_FREQ,
	)

/obj/item/mecha_parts/mecha_equipment/radio/handle_ui_act(action, list/params)
	switch(action)
		if("toggle_microphone")
			radio.set_broadcasting(!radio.get_broadcasting())
			return TRUE
		if("toggle_speaker")
			radio.set_listening(!radio.get_listening())
			return TRUE
		if("set_frequency")
			var/new_frequency = text2num(params["new_frequency"])
			radio.set_frequency(sanitize_frequency(new_frequency, radio.freerange, (radio.special_channels & RADIO_SPECIAL_SYNDIE)))
			return TRUE
	return FALSE

///Internal radio got deleted, somehow
/obj/item/mecha_parts/mecha_equipment/radio/proc/radio_deleted()
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)

/obj/item/radio/mech
	subspace_transmission = TRUE

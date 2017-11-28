/datum/wires/radio
	holder_type = /obj/item/device/radio
	proper_name = "Radio"

/datum/wires/radio/New(atom/holder)
	wires = list(
		WIRE_SIGNAL,
		WIRE_RX, WIRE_TX
	)
	..()

/datum/wires/radio/interactable(mob/user)
	var/obj/item/device/radio/R = holder
	if(R.b_stat)
		return TRUE

/datum/wires/radio/on_pulse(index)
	var/obj/item/device/radio/R = holder
	switch(index)
		if(WIRE_SIGNAL)
			R.listening = !R.listening
			R.broadcasting = R.listening
		if(WIRE_RX)
			R.listening = !R.listening
		if(WIRE_TX)
			R.broadcasting = !R.broadcasting

/datum/wires/radio
	holder_type = /obj/item/radio
	proper_name = "Radio"

/datum/wires/radio/New(atom/holder)
	wires = list(
		WIRE_SIGNAL,
		WIRE_RX, WIRE_TX
	)
	..()

/datum/wires/radio/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/item/radio/R = holder
	return R.unscrewed

/datum/wires/radio/on_pulse(index)
	var/obj/item/radio/R = holder
	switch(index)
		if(WIRE_SIGNAL)
			R.set_listening(!R.get_listening())
			R.set_broadcasting(R.get_listening())
		if(WIRE_RX)
			R.set_listening(!R.get_listening())
		if(WIRE_TX)
			R.set_broadcasting(!R.get_broadcasting())

/datum/wires/radio
	holder_type = /obj/item/radio
	proper_name = "Radio"

/datum/wires/radio/New(atom/holder)
	wires = list(
		WIRE_SIGNAL,
		WIRE_RX, WIRE_TX,
		WIRE_ANON
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
		if(WIRE_ANON)
			R.set_anon(!R.anonymize)

/datum/wires/radio/on_cut(wire, mend)
	var/obj/item/radio/R = holder
	if(wire == WIRE_ANON)
		R.set_anon(!mend)

/datum/wires/radio/get_status()
	var/obj/item/radio/R = holder
	var/list/status = list()
	status += "The broadcast light is [R.get_broadcasting() ? "on" : "off"]."
	status += "The listening light is [R.get_listening() ? "on" : "off"]."
	status += "The voice recognition chip is [R.anonymize ? "slightly buzzing" : "silent"]."
	return status

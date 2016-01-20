/datum/wires/radio
	var/const/W_SIGNAL = "signal"
	var/const/W_RX = "recieve"
	var/const/W_TX = "transmit"

	holder_type = /obj/item/device/radio

/datum/wires/radio/New(atom/holder)
	wires = list(
		W_SIGNAL,
		W_RX, W_TX
	)
	..()

/datum/wires/radio/interactable(mob/user)
	var/obj/item/device/radio/R = holder
	if(R.b_stat)
		return TRUE

/datum/wires/radio/on_pulse(index)
	var/obj/item/device/radio/R = holder
	switch(index)
		if(W_SIGNAL)
			R.listening = !R.listening
			R.broadcasting = R.listening
		if(W_RX)
			R.listening = !R.listening
		if(W_TX)
			R.broadcasting = !R.broadcasting

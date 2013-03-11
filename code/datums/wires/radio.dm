/datum/wires/radio
	holder_type = /obj/item/device/radio
	wire_count = 3

var/const/WIRE_SIGNAL = 1
var/const/WIRE_RECEIVE = 2
var/const/WIRE_TRANSMIT = 4

/datum/wires/radio/CanUse(var/mob/living/L)
	var/obj/item/device/radio/R = holder
	if(R.b_stat)
		return 1
	return 0

/datum/wires/radio/Interact(var/mob/living/user)
	if(CanUse(user))
		var/obj/item/device/radio/R = holder
		R.interact(user)

/datum/wires/radio/UpdatePulsed(var/index)
	var/obj/item/device/radio/R = holder
	switch(index)
		if(WIRE_SIGNAL)
			R.listening = !R.listening
			R.broadcasting = R.listening

		if(WIRE_RECEIVE)
			R.listening = !R.listening

		if(WIRE_TRANSMIT)
			R.broadcasting = !R.broadcasting
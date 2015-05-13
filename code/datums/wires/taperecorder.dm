/datum/wires/taperecorder
	wire_count = 2
	holder_type = /obj/item/device/taperecorder

var/const/WIRE_PLAY = 1
var/const/WIRE_RECORD = 2


/datum/wires/taperecorder/UpdatePulsed(var/index)
	switch(index)
		if(WIRE_PLAY)
			play()
		if(WIRE_RECORD)
			record()

/datum/wires/taperecorder/CanUse(var/mob/living/L)
	var/obj/item/device/taperecorder/T = holder
	if(T.open_panel)
		return 1
	return 0


/datum/wires/taperecorder/proc/play()
	var/obj/item/device/taperecorder/T = holder
	T.stop()
	T.play()

/datum/wires/taperecorder/proc/record()
	var/obj/item/device/taperecorder/T = holder
	if(T.recording)
		T.stop()
	else
		T.record()

//helpers
/datum/wires/taperecorder/proc/get_play()
	return !(wires_status & WIRE_PLAY)

/datum/wires/taperecorder/proc/get_record()
	return !(wires_status & WIRE_RECORD)
// MBTODO: This is stupid, delete it
/datum/computer/file/embedded_program
	var/state
	var/master

/datum/computer/file/embedded_program/Destroy()
	master = null
	. = ..()

/datum/computer/file/embedded_program/process()
	return 0

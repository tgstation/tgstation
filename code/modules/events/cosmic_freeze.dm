/datum/event/cosmic_freeze
	var/turf/starting_turf = null

/datum/event/cosmic_freeze/start()
	starting_turf = cosmic_freeze_event()

/datum/event/cosmic_freeze/announce()
	command_alert("Thermal scans of [starting_turf.loc] suggest that the close approach of a comet has somehow manifested a snow storm aboard the station. Allowing that storm to propagate through the station might have unforeseen consequences.", "Cosmic Snow Storm")



/*
/obj/structure/snowreader
	name = "snowreader"

/obj/structure/snowreader/New()
	read_snow()

/obj/structure/snowreader/proc/read_snow()
	world << "there are [snow_tiles] tiles covered in snow"
	sleep(30)
	read_snow()
*/
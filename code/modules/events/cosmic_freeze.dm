/datum/event/cosmic_freeze

/datum/event/cosmic_freeze/start()
	cosmic_freeze_event()

/datum/event/cosmic_freeze/announce()
	command_alert("Thermal scans suggest that the close approach of a comet has somehow manifested a snow storm aboard the station. Allowing that storm to propagate through the station might have unforeseen consequences.", "Cosmic freeze")



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
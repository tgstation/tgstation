/client/proc/reset_atmos()
	set name = "Clean Air"
	set category = "Special Verbs"
	set desc = "Cleans the air in a radius of harmful gasses like plasma and N2O"
	var/size = input("How big?", "Input") in list(5, 10, 20, 50, 100, "Cancel")
	if(size == "Cancel")
		return 0
	cleanair(size)
	message_admins("[key_name(src)] cleaned air within [size] tiles.")
	log_game("[key_name(src)] cleaned air within [size] tiles.")

/client/proc/fill_breach()
	set name = "Fill Hull Breach"
	set category = "Special Verbs"
	set desc = "Spawns plating over space breachs"
	var/size = input("How big?", "Input") in list(5, 10, "Cancel")
	if(size == "Cancel")
		return 0
	for(var/turf/open/space/T in range(size))
		T.ChangeTurf(/turf/open/floor/plating)
	cleanair(size)
	message_admins("[key_name(src)] filled the hullbreachs in [size] tiles.")
	log_game("[key_name(src)] filled the hullbreachs in [size] tiles.")

/client/proc/cleanair(var/wrange)
	for(var/turf/open/T in range(wrange))
		if(T.air)
			T.air.parse_gas_string("o2=22;n2=82;TEMP=293.15)

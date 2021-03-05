/datum/refugee
	/// The ckey we're expecting to match to
	var/expected_ckey
	/// I don't care enough to send their entire appearance, just use the character in their preference then overwrite the name
	var/char_name
	/// The direction the person was shot offstation from
	var/launching_dir

/datum/refugee/New(incoming_ckey, incoming_name, heading_dir)
	. = ..()
	expected_ckey = incoming_ckey
	char_name = incoming_name
	launching_dir = heading_dir

/datum/refugee/proc/execute_introduction(mob/dead/new_player/our_new_player)
	var/mob/living/carbon/human/new_body = our_new_player.create_character(TRUE)
	new_body.real_name = char_name

	var/turf/pickedstart
	var/turf/pickedgoal
	var/max_i = 10//number of tries to spawn the incoming body
	for(var/i in 1 to max_i)
		var/startSide = turn(launching_dir, 180)
		var/startZ = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
		pickedstart = spaceDebrisStartLoc(startSide, startZ)
		pickedgoal = pick(GLOB.blobstart) // just chuck em somewhere on station
		if(isspaceturf(pickedstart))
			break

	new_body.forceMove(pickedstart)
	var/obj/machinery/mass_driver/typical_driver = /obj/machinery/mass_driver
	var/throw_speed = initial(typical_driver.power)
	new_body.throw_at(pickedgoal, 50, throw_speed)
	priority_announce("Our scanners are picking up what appears to be a person being flung at your station at high speeds. Please do your best to make sure they don't get their grubby hands on anything.", sender_override = "Nanotrasen Department of Spacings")
	qdel(src)

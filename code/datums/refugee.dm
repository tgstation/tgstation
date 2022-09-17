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
	GLOB.refugees -= src
	var/turf/random_standby = pick(GLOB.blobstart)
	var/mob/living/carbon/human/new_body = our_new_player.create_character(random_standby)
	new_body.real_name = char_name
	deadchat_broadcast("[char_name] has been shot towards this station from another server!", follow_target=new_body)
	message_admins("[ADMIN_LOOKUPFLW(new_body)] has been shot towards this station from another server.")
	ADD_TRAIT(new_body, TRAIT_XRAY_VISION, MAFIA_TRAIT) // so they see the spawn splash screen instead of the spawn box area area
	new_body.status_flags &= GODMODE
	new_body.update_sight()
	addtimer(CALLBACK(src, .proc/delayed_spawn, new_body, our_new_player), 4 SECONDS) // delay actually spawning them and flinging them at the station a bit in case they're loading so they can see it

/datum/refugee/proc/delayed_spawn(mob/living/carbon/human/the_body, mob/dead/new_player/our_new_player)
	testing("doing delayed spawn with [our_new_player] into [the_body]")
	our_new_player.transfer_character()
	testing("transfer complete")
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

	the_body.forceMove(pickedstart)
	the_body.status_flags &= ~GODMODE
	REMOVE_TRAIT(the_body, TRAIT_XRAY_VISION, MAFIA_TRAIT)
	the_body.update_sight()
	var/obj/machinery/mass_driver/typical_driver = /obj/machinery/mass_driver
	var/throw_speed = initial(typical_driver.power)
	the_body.throw_at(pickedgoal, 50, throw_speed)
	priority_announce("Our scanners are picking up what appears to be a person being flung at your station at high speeds. Please do your best to make sure they don't get their grubby hands on anything.", sender_override = "Nanotrasen Department of Spacings")
	qdel(src)

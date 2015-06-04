/datum/game_mode/blob/check_finished()
	if(infected_crew.len > burst)//Some blobs have yet to burst
		return 0
	if(blobwincount <= blobs.len)//Blob took over
		return 1
	if(!blob_cores.len) // blob is dead
		if(config.continuous["blob"])
			continuous_sanity_checked = 1 //Nonstandard definition of "alive" gets past the check otherwise
			SSshuttle.emergencyNoEscape = 0
			if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
				SSshuttle.emergency.mode = SHUTTLE_DOCKED
				SSshuttle.emergency.timer = world.time
				priority_announce("Hostile enviroment resolved. You have 3 minutes to board the Emergency Shuttle.", null, 'sound/AI/shuttledock.ogg', "Priority")
			return ..()
		return 1
	return ..()


/datum/game_mode/blob/declare_completion()
	if(round_converted) //So badmin blobs later don't step on the dead natural blobs metaphorical toes
		..()
	if(blobwincount <= blobs.len)
		feedback_set_details("round_end_result","win - blob took over")
		world << "<FONT size = 3><B>The blob has taken over the station!</B></FONT>"
		world << "<B>The entire station was eaten by the Blob</B>"
		log_game("Blob mode completed with a blob victory.")

	else if(station_was_nuked)
		feedback_set_details("round_end_result","halfwin - nuke")
		world << "<FONT size = 3><B>Partial Win: The station has been destroyed!</B></FONT>"
		world << "<B>Directive 7-12 has been successfully carried out preventing the Blob from spreading.</B>"
		log_game("Blob mode completed with a tie (station destroyed).")

	else if(!blob_cores.len)
		feedback_set_details("round_end_result","loss - blob eliminated")
		world << "<FONT size = 3><B>The staff has won!</B></FONT>"
		world << "<B>The alien organism has been eradicated from the station</B>"
		log_game("Blob mode completed with a crew victory.")
		world << "<span class='notice'>Rebooting in 30s</span>"
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_blob()
	if(istype(ticker.mode,/datum/game_mode/blob) )
		var/datum/game_mode/blob/blob_mode = src
		if(blob_mode.infected_crew.len)
			var/text = "<FONT size = 2><B>The blob[(blob_mode.infected_crew.len > 1 ? "s were" : " was")]:</B></FONT>"

			for(var/datum/mind/blob in blob_mode.infected_crew)
				text += "<br><b>[blob.key]</b> was <b>[blob.name]</b>"
			world << text
		return 1

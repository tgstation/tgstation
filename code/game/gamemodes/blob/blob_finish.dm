/datum/game_mode/blob/check_finished()
	if(blobwincount <= blobs_legit.len)//Blob took over
		return 1
	for(var/datum/mind/blob in blob_overminds)
		if(isovermind(blob.current))
			var/mob/camera/blob/B = blob.current
			if(B.blob_core || !B.placed)
				return 0
	if(!blob_cores.len) //blob is dead
		if(config.continuous["blob"])
			message_sent = FALSE //disable the win count at this point
			continuous_sanity_checked = 1 //Nonstandard definition of "alive" gets past the check otherwise
			SSshuttle.clearHostileEnvironment(src)
			return ..()
		return 1
	return ..()


/datum/game_mode/blob/declare_completion()
	if(round_converted) //So badmin blobs later don't step on the dead natural blobs metaphorical toes
		..()
	if(blobwincount <= blobs_legit.len)
		feedback_set_details("round_end_result","win - blob took over")
		world << "<FONT size = 3><B>The blob has taken over the station!</B></FONT>"
		world << "<B>The entire station was eaten by the Blob!</B>"
		log_game("Blob mode completed with a blob victory.")

		ticker.news_report = BLOB_WIN

	else if(station_was_nuked)
		feedback_set_details("round_end_result","halfwin - nuke")
		world << "<FONT size = 3><B>Partial Win: The station has been destroyed!</B></FONT>"
		world << "<B>Directive 7-12 has been successfully carried out, preventing the Blob from spreading.</B>"
		log_game("Blob mode completed with a tie (station destroyed).")

		ticker.news_report = BLOB_NUKE

	else if(!blob_cores.len)
		feedback_set_details("round_end_result","loss - blob eliminated")
		world << "<FONT size = 3><B>The staff has won!</B></FONT>"
		world << "<B>The alien organism has been eradicated from the station!</B>"
		log_game("Blob mode completed with a crew victory.")

		ticker.news_report = BLOB_DESTROYED

	..()
	return 1

/datum/game_mode/blob/printplayer(datum/mind/ply, fleecheck)
	if((ply in blob_overminds))
		var/text = "<br><b>[ply.key]</b> was <b>[ply.name]</b>"
		if(isovermind(ply.current))
			var/mob/camera/blob/B = ply.current
			text += "<b>(<font color=\"[B.blob_reagent_datum.color]\">[B.blob_reagent_datum.name]</font>)</b> and"
			if(B.blob_core)
				text += " <span class='greenannounce'>survived</span>"
			else
				text += " <span class='boldannounce'>was destroyed</span>"
		else
			text += " and <span class='boldannounce'>was destroyed</span>"
		return text
	return ..()

/datum/game_mode/proc/auto_declare_completion_blob()
	if(istype(ticker.mode,/datum/game_mode/blob) )
		var/datum/game_mode/blob/blob_mode = src
		if(blob_mode.blob_overminds.len)
			var/text = "<FONT size = 2><B>The blob[(blob_mode.blob_overminds.len > 1 ? "s were" : " was")]:</B></FONT>"
			for(var/datum/mind/blob in blob_mode.blob_overminds)
				text += printplayer(blob)
			world << text
		return 1

/datum/game_mode/blob/check_finished()
	if(!declared)//No blobs have been spawned yet
		return 0
	if(blobwincount <= blobs.len)//Blob took over
		return 1
	if(!blob_cores.len) // blob is dead
		return 1
	if(station_was_nuked)//Nuke went off
		return 1
	return 0


/datum/game_mode/blob/declare_completion()
	if(blobwincount <= blobs.len)
		feedback_set_details("round_end_result","loss - blob took over")
		completion_text += {"<br><FONT size = 3><B>The blob has taken over the station!</B></FONT>
<B>The entire station was consumed by the Blob!</B>"}
		check_quarantine()

	else if(station_was_nuked)
		feedback_set_details("round_end_result","halfwin - nuke")
		completion_text += {"<br><FONT size = 3><B>Partial Win: The station has been destroyed!</B></FONT>
<B>Directive 7-12 has been successfully carried out, the Blobs have taken another station but failed to spread any further!</B>"}

	else if(!blob_cores.len)
		feedback_set_details("round_end_result","win - blob eliminated")
		completion_text += {"<br><FONT size = 3><B>The staff has won!</B></FONT>
<B>The alien organism has been eradicated from the station</B>"}

		var/datum/station_state/end_state = new /datum/station_state()
		end_state.count()
		var/percent = round( 100.0 *  start_state.score(end_state), 0.1)
		completion_text += "<br><B>The station is [percent]% intact.</B>"
		log_game("Blob mode was won with station [percent]% intact.")
		to_chat(world, "<br><span class='notice'>Rebooting in 30s</span>")
	..()
	return 1

datum/game_mode/proc/auto_declare_completion_blob()
	if(istype(ticker.mode,/datum/game_mode/blob) )
		var/text = ""
		var/datum/game_mode/blob/blob_mode = src
		if(blob_mode.infected_crew.len)
			text += "<FONT size = 2><B>The blob[(blob_mode.infected_crew.len > 1 ? "s were" : " was")]:</B></FONT>"

			var/icon/logo = icon('icons/mob/blob.dmi', "blob_core")
			end_icons += logo
			var/tempstate = end_icons.len
			for(var/datum/mind/blob in blob_mode.infected_crew)
				text += {"<br><img src="logo_[tempstate].png"> <b>[blob.key]</b> was <b>[blob.name]</b>"}
		text += "<BR><HR>"
		return text

/datum/game_mode/blob/proc/check_quarantine()
	var/numDead = 0
	var/numAlive = 0
	var/numSpace = 0
	var/numOffStation = 0
	for (var/mob/living/silicon/ai/aiPlayer in mob_list)
		for(var/mob/living/carbon/human/M in mob_list)
			if ((M != aiPlayer && M.client))
				if (M.stat == 2)
					numDead += 1
				else if(M in pre_escapees)
					continue
				else
					var/T = M.loc
					if (istype(T, /turf/space))
						numSpace += 1
					else if(istype(T, /turf))
						if (M.z!=1)
							numOffStation += 1
						else
							numAlive += 1
		if (numSpace==0 && numOffStation==0)
			to_chat(world, {"<FONT size = 3><B>The AI has succeeded!</B></FONT>
<B>The AI successfully maintained the quarantine - no players were in space or were off-station (as far as we can tell).</B>"})
			log_game("AI won at Blob mode despite overall loss.")
		else
			to_chat(world, {"<FONT size = 3><B>The AI has failed!</B></FONT>
<B>The AI failed to maintain the quarantine - [numSpace] were in space and [numOffStation] were off-station (as far as we can tell).</B>"})
			log_game("AI lost at Blob mode.")
	log_game("Blob mode was lost.")
	return 1

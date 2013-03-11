/datum/game_mode/blob/check_finished()
	if(!declared)//No blobs have been spawned yet
		return 0
	if(stage >= 3)//Blob took over
		return 1
	if(station_was_nuked)//Nuke went off
		return 1

	for(var/obj/effect/blob/B in blob_cores)
		if(B && B.z != 1)	continue
		return 0

	var/nodes = 0
	for(var/obj/effect/blob/B in blob_nodes)
		if(B && B.z != 1)	continue
		nodes++
		if(nodes > 4)//Perhapse make a new core with a low prob
			return 0

	return 1


/datum/game_mode/blob/declare_completion()
	if(stage >= 3)
		feedback_set_details("round_end_result","loss - blob took over")
		world << "<FONT size = 3><B>The blob has taken over the station!</B></FONT>"
		world << "<B>The entire station was eaten by the Blob</B>"
		check_quarantine()

	else if(station_was_nuked)
		feedback_set_details("round_end_result","halfwin - nuke")
		world << "<FONT size = 3><B>Partial Win: The station has been destroyed!</B></FONT>"
		world << "<B>Directive 7-12 has been successfully carried out preventing the Blob from spreading.</B>"

	else
		feedback_set_details("round_end_result","win - blob eliminated")
		world << "<FONT size = 3><B>The staff has won!</B></FONT>"
		world << "<B>The alien organism has been eradicated from the station</B>"

		var/datum/station_state/end_state = new /datum/station_state()
		end_state.count()
		var/percent = round( 100.0 *  start_state.score(end_state), 0.1)
		world << "<B>The station is [percent]% intact.</B>"
		log_game("Blob mode was won with station [percent]% intact.")
		world << "\blue Rebooting in 30s"
	..()
	return 1


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
			world << "<FONT size = 3><B>The AI has won!</B></FONT>"
			world << "<B>The AI successfully maintained the quarantine - no players were in space or were off-station (as far as we can tell).</B>"
			log_game("AI won at Blob mode despite overall loss.")
		else
			world << "<FONT size = 3><B>The AI has lost!</B></FONT>"
			world << text("<B>The AI failed to maintain the quarantine - [] were in space and [] were off-station (as far as we can tell).</B>", numSpace, numOffStation)
			log_game("AI lost at Blob mode.")
	log_game("Blob mode was lost.")
	return 1

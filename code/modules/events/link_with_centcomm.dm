/datum/event/unlink_from_centcomm
	endWhen = 300

/datum/event/unlink_from_centcomm/start()
	unlink_from_centcomm()

/datum/event/unlink_from_centcomm/end()
	link_to_centcomm()

proc/link_to_centcomm()
	if(!map.linked_to_centcomm)
		map.linked_to_centcomm = 1
		command_alert("A link to Central Command has been established on [station_name()].","Link Established")

proc/unlink_from_centcomm()
	if(map.linked_to_centcomm)
		map.linked_to_centcomm = 0
		command_alert("This is an automated announcement. The link with central command has been lost. Repeat: The link with central command has been lost. Attempting to re-establish communications in T-10.","Automated announcement",1)
		for(var/mob/M in player_list)
			if(!istype(M,/mob/new_player) && M.client)
				M << sound('sound/AI/loss.ogg')

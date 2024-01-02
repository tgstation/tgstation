/**
 * Creates people's characters for ROUNDSTART ONLY
 * Spawns them in on the roundstart ship.
 * Latejoining is handled differently.
 */
/datum/controller/subsystem/ticker/create_characters()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind)
			GLOB.joined_player_list += player.ckey
			var/obj/structure/overmap/ship/roundstart_ship = SSovermap.simulated_ships[1]
			if(!roundstart_ship)
				CRASH("There's no roundstart ship for jobs to spawn on!")
			for(var/datum/job/job as anything in roundstart_ship.job_slots)
				if(player.mind.assigned_role.type != job.type)
					continue
				player.AttemptSpawnOnShip(job, roundstart_ship)
		CHECK_TICK


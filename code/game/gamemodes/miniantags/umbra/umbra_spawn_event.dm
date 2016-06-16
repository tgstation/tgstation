/datum/round_event_control/spawn_umbra
	name = "Spawn Umbra"
	typepath = /datum/round_event/ghost_role/umbra
	weight = 15
	earliest_start = 6000
	max_occurrences = 3

/datum/round_event/ghost_role/umbra
	minimum_required = 1
	role_name = "umbra"

/datum/round_event/ghost_role/umbra/spawn_role()
	message_admins("An unoccupied umbra was created by a random event.")
	var/mob/living/simple_animal/umbra/U = new(pick(xeno_spawn))
	var/image/alert_overlay = image('icons/mob/mob.dmi', "umbra")
	notify_ghosts("An umbra has formed in [get_area(U)]. Interact with it to take control of it.", null, source = U, alert_overlay = alert_overlay)
	return SUCCESSFUL_SPAWN

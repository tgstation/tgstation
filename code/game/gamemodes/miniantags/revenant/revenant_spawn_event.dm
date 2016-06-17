/datum/round_event_control/spawn_revenant
	name = "Spawn Revenant"
	typepath = /datum/round_event/ghost_role/revenant
	weight = 15
	earliest_start = 6000
	max_occurrences = 3

/datum/round_event/ghost_role/revenant
	minimum_required = 1
	role_name = "revenant"

/datum/round_event/ghost_role/revenant/spawn_role()
	message_admins("An unoccupied revenant was created by a random event.")
	var/mob/living/simple_animal/revenant/U = new(pick(xeno_spawn))
	var/image/alert_overlay = image('icons/mob/mob.dmi', "revenant")
	notify_ghosts("An revenant has formed in [get_area(U)]. Interact with it to take control of it.", null, source = U, alert_overlay = alert_overlay)
	spawned_mobs += U
	return SUCCESSFUL_SPAWN

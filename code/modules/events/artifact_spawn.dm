/datum/round_event_control/random_artifact
	name = "Artifact Manifestation"
	description = "Spawns a random artifact somewhere on the station"
	typepath = /datum/round_event/random_artifact
	weight = 10
	max_occurrences = 3
	min_players = 3
	category = EVENT_CATEGORY_ANOMALIES
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_SPOOKY)

/datum/round_event/random_artifact
	announce_when = 0
	start_when = 1
	var/datum/weakref/spawn_location

/datum/round_event/random_artifact/setup()
	spawn_location = WEAKREF(pick(GLOB.generic_event_spawns))

	if(!spawn_location?.resolve())
		return kill()

/datum/round_event_control/random_artifact/can_spawn_event(players_amt, allow_magic = FALSE, fake_check = FALSE)
	. = ..()
	if(!.)
		return
	//just in case
	if(!length(GLOB.generic_event_spawns))
		return FALSE
	else
		return

/datum/round_event/random_artifact/start()
	var/marker = spawn_location.resolve()
	if(!marker)
		return
	var/artifact = spawn_artifact(get_turf(marker))
	do_sparks(4, FALSE, artifact)
	announce_to_ghosts(artifact)

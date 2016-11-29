/datum/round_event_control/mice_migration
	name = "Mice Migration"
	typepath = /datum/round_event/mice_migration
	weight = 0

/datum/round_event/mice_migration
	announceWhen = 0

/datum/round_event/mice_migration/announce()
	priority_announce("Due to space-winter, a number of rodents have \
		migrated into the maintenance tunnels.", "Migration Alert",
		'sound/effects/mousesqueek.ogg', 100, 1)

/datum/round_event/mice_migration/start()
	SSsqueak.trigger_migration(rand(5,15))

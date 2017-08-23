/datum/round_event_control/mice_migration
	name = "Mice Migration"
	typepath = /datum/round_event/mice_migration
	weight = 10

/datum/round_event/mice_migration
	announceWhen = 0
	var/minimum_mice = 5
	var/maximum_mice = 15

/datum/round_event/mice_migration/announce()
	var/cause = SSrng.pick_from_list("space-winter", "budget-cuts", "Ragnarok",
		"space being cold", "\[REDACTED\]", "climate change",
		"bad luck")
	var/plural = SSrng.pick_from_list("a number of", "a horde of", "a pack of", "a swarm of",
		"a whoop of", "not more than [maximum_mice]")
	var/name = SSrng.pick_from_list("rodents", "mice", "squeaking things",
		"wire eating mammals", "\[REDACTED\]", "energy draining parasites")
	var/movement = SSrng.pick_from_list("migrated", "swarmed", "stampeded", "descended")
	var/location = SSrng.pick_from_list("maintenance tunnels", "maintenance areas",
		"\[REDACTED\]", "place with all those juicy wires")

	priority_announce("Due to [cause], [plural] [name] have [movement] \
		into the [location].", "Migration Alert",
		'sound/effects/mousesqueek.ogg', 100, 1)

/datum/round_event/mice_migration/start()
	SSsqueak.trigger_migration(SSrng.random(minimum_mice, maximum_mice))

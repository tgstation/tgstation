/// The subsystem used to play ambience to users every now and then, makes them real excited.
SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	init_order = INIT_ORDER_AMBIENCE
	flags = SS_BACKGROUND|SS_NO_INIT
	priority = FIRE_PRIORITY_AMBIENCE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS

/datum/controller/subsystem/ambience/fire(resumed)
	for(var/i in GLOB.clients)
		var/client/client_iterator = i

		if(!(client_iterator?.prefs.toggles & SOUND_AMBIENCE))
			continue //No interest in ambience huh? alright them, goodbye.

		if(!COOLDOWN_FINISHED(client_iterator, ambience_cooldown))
			continue //Not ready for the next round

		var/area/current_area = get_area(client_iterator.mob)

		var/sound = pick(current_area.ambientsounds)

		SEND_SOUND(client_iterator.mob, sound(sound, repeat = 0, wait = 0, volume = 25, channel = CHANNEL_AMBIENCE))

		COOLDOWN_START(client_iterator, ambience_cooldown, rand(current_area.min_ambience_cooldown, current_area.max_ambience_cooldown))

/// The subsystem used to play ambience to users every now and then, makes them real excited.
SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	flags = SS_BACKGROUND|SS_NO_INIT
	priority = FIRE_PRIORITY_AMBIENCE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS
	///Assoc list of listening client - next ambience time
	var/list/ambience_listening_clients = list()
	///Cache for sanic speed :D
	var/list/currentrun = list()

/datum/controller/subsystem/ambience/fire(resumed)
	if(!resumed)
		currentrun = ambience_listening_clients.Copy()
	var/list/cached_clients = currentrun

	while(cached_clients.len)
		var/client/client_iterator = cached_clients[cached_clients.len]
		cached_clients.len--
		process_ambience_client(client_iterator)

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/ambience/proc/process_ambience_client(client/to_process)
	if(isnull(to_process) || isnewplayer(to_process.mob))
		ambience_listening_clients -= to_process
		return

	if(ambience_listening_clients[to_process] > world.time)
		return //Not ready for the next sound

	var/area/current_area = get_area(to_process.mob)

	if(!current_area) //Something's gone horribly wrong
		stack_trace("[key_name(to_process)] has somehow ended up in nullspace. WTF did you do")
		ambience_listening_clients -= to_process
		return

	var/sound = pick(current_area.ambientsounds)

	SEND_SOUND(to_process.mob, sound(sound, repeat = 0, wait = 0, volume = 25, channel = CHANNEL_AMBIENCE))

	ambience_listening_clients[to_process] = world.time + rand(current_area.min_ambience_cooldown, current_area.max_ambience_cooldown)

/datum/controller/subsystem/ambience/proc/remove_ambience_client(client/to_remove)
	ambience_listening_clients -= to_remove
	currentrun -= to_remove

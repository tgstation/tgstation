// Used to process voice comms.

SUBSYSTEM_DEF(voice)
	name = "Voice Comms"
	priority = 25
	flags = SS_BACKGROUND | SS_NO_INIT
	wait = 2

	// list of z-levels which subspace can reach
	var/list/subspace_zlevels = list(ZLEVEL_STATION_PRIMARY)
	var/next_subspace_check = 1
	var/request_id = 100000

	// queue of clients whose state might have changed
	var/list/client/current_run = list()
	var/list/client/changed = list()

/datum/controller/subsystem/voice/fire(resumed = 0)
	// Populate current_run from queue as needed
	if (!resumed)
		src.current_run = GLOB.clients.Copy()

	// Update subspace status if necessary
	if (next_subspace_check && next_subspace_check <= world.time)
		next_subspace_check = 0 // don't overlap checks
		spawn update_subspace_zlevels()

	// For clients in current_run, mark them as changed if needed
	var/list/client/current_run = src.current_run
	while (current_run.len)
		var/client/C = current_run[current_run.len]
		var/datum/voicestuff/voice = C.voice
		current_run.len--

		// Only check if (marked && not too recent) || very old
		if (!((voice.next_check < world.time - 100) || (voice.next_check < world.time && voice.needs_check)))
			continue

		voice.needs_check = FALSE
		// Only handle a given person every so often
		voice.next_check = world.time + 10

		var/status = C.voice_check()
		if (status == null)
			message_admins("SSvoice: voice_check on [C] crashed, check logs")
		if (status != voice.status)
			voice.status = status
			changed += C

		// This is a hacky way to get these things onto the client's screen,
		// without going through the per-mob HUD. Maybe this means some portion
		// of the voice status discovery code should be moved to mobs instead.
		C.screen |= voice.screen_speak
		C.screen |= voice.screen_hear
		voice.screen_speak.update_voice(voice.status)
		voice.screen_hear.update_voice(voice.status)

		if (MC_TICK_CHECK)
			return

	// Batch every changed client in one shell invocation
	if (changed.len)
		var/output = ""
		for (var/client/C in changed)
			output += "[C.ckey]=[C.voice.status]\n"
		changed.len = 0

		text2file(output, "data/voice/request_[request_id].txt")
		request_id++

/datum/controller/subsystem/voice/proc/update_subspace_zlevels()
	// Based on telecomms_process(), modified to not require an atom
	// Construct the signal
	var/datum/signal/signal = new
	signal.transmission_method = 2 // subspace
	signal.data = list(
		"slow" = 0,
		"message" = "TEST",
		"compression" = rand(45, 50),
		"traffic" = 0,
		"type" = 4,
		"reject" = 0,
		"done" = 0,
		"level" = ZLEVEL_STATION_PRIMARY
	)
	signal.frequency = GLOB.radiochannels["Common"] // Common channel

	// Send the signal to receivers and wait for them to process it
	for (var/obj/machinery/telecomms/receiver/R in GLOB.telecomms_list)
		R.receive_signal(signal)
	sleep(25)

	// Now extract and store the Z-level list
	var/previous = list2params(subspace_zlevels)
	if (!signal.data["done"])
		subspace_zlevels = list()
	else
		subspace_zlevels = signal.data["level"]
	var/current = list2params(subspace_zlevels)
	if (current != previous)
		message_admins("Subspace z-levels have changed: ([previous]) to ([current])")

	// clients will update gradually
	next_subspace_check = world.time + rand(50, 100)

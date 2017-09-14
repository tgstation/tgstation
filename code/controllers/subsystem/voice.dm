// Used to process voice comms. Fires twice per second.

SUBSYSTEM_DEF(voice)
	name = "Voice Comms"
	priority = 25
	flags = SS_BACKGROUND | SS_NO_INIT
	wait = 5

	// queue of clients whose state might have changed
	var/list/client/queue = list()
	var/list/client/currentrun = list()
	var/list/client/changed = list()

	// for debugging, a "full refresh" every so often should catch things we
	// aren't handling yet
	var/force_wait = 50 // how many ds between full refreshes
	var/force_ct = 0 // counter

/datum/controller/subsystem/voice/proc/refresh_client(client/C)
	queue += C

/datum/controller/subsystem/voice/proc/refresh_everybody()
	force_ct = force_wait

/datum/controller/subsystem/voice/fire(resumed = 0)
	// Populate current_run from queue as needed
	if (!resumed)
		force_ct += wait
		if (force_ct >= force_wait)
			force_ct = 0
			currentrun = GLOB.clients.Copy()
		else
			currentrun = queue.Copy()
		queue.len = 0

	// For clients in current_run, mark them as changed if needed
	var/list/client/current_run = currentrun
	while (current_run.len)
		var/client/C = current_run[current_run.len]
		current_run.len--

		var/voice = C.voice_check()
		if (voice != C.voice_last)
			C.voice_last = voice
			changed += C

		if (MC_TICK_CHECK)
			return

	// Batch every changed client in one shell invocation
	if (changed.len)
		var/shell_cmd = "updatevoice.exe"
		for (var/client/C in changed)
			shell_cmd += " [C.ckey]=[C.voice_last]"
		message_admins(shell_cmd) // TODO: actually shell out
		changed.len = 0

// Additions to client

#define VOICE_NONE 0
#define VOICE_SPEAK 1
#define VOICE_HEAR 2
#define VOICE_ALL 3

/client/var/voice_last = VOICE_ALL

/client/proc/voice_check()
	// Fast paths:
	// If the game hasn't started, free-talk.
	if (SSticker.current_state != GAME_STATE_PLAYING)
		return VOICE_ALL
	// Dead men tell no tales.
	if (istype(mob, /mob/dead))
		return VOICE_HEAR

	// In-game comms machinery check
	. = 0
	// TODO: the real checks

#undef VOICE_NONE
#undef VOICE_SPEAK
#undef VOICE_HEAR
#undef VOICE_ALL

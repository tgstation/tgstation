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
		changed.len = 0

		message_admins(shell_cmd) // TODO: actually shell out

// Additions to client

#define VOICE_NONE 0
#define VOICE_SPEAK 1
#define VOICE_HEAR 2
#define VOICE_ALL 3
#define VOICE_LANG /datum/language/common
#define VOICE_FREQ radiochannels["Common"])

/client/var/voice_last = VOICE_ALL

/client/proc/voice_check()
	// Fast paths:
	// If the game hasn't started, free-talk.
	if (SSticker.current_state != GAME_STATE_PLAYING)
		return VOICE_ALL
	// Dead men tell no tales. Includes ghosts and late-joins.
	var/mob/living/mob = src.mob
	if (istype(mob, /mob/dead))
		return VOICE_HEAR
	// Neither living nor dead... err on the side of nope.
	if (!istype(mob))
		return VOICE_NONE
	// Conscious is all-clear, SoftCrit is hear only, Unconcious/Dead is nothing
	if (mob.stat == DEAD || mob.stat == UNCONSCIOUS)
		return VOICE_NONE

	// Those deaf and dumb are thus limited
	var/mob_can_hear = (mob.can_hear() && \
		mob.has_language(VOICE_LANG))
	var/mob_can_speak = (mob.can_speak() && \
		mob.can_speak_in_language(VOICE_LANG) && \
		mob.stat == CONSCIOUS)
		// TODO: consider disable speaking for severe impediments
	if (!mob_can_hear && !mob_can_speak)
		return VOICE_NONE

	// Long path: check the mob
	. = VOICE_ALL

	// Check ears for a headset

	// Check hands for a push-to-talk

	// Check surrounding environment for open mics

	// If we're deaf or dumb, chicken out
	if (!mob_can_hear)
		. &= ~VOICE_HEAR
	if (!mob_can_speak)
		. &= ~VOICE_SPEAK

#undef VOICE_NONE
#undef VOICE_SPEAK
#undef VOICE_HEAR
#undef VOICE_ALL
#undef VOICE_LANG
#undef VOICE_FREQ

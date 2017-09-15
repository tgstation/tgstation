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
		if (voice == null)
			message_admins("voice_check on [C] crashed, check logs")
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
#define VOICE_FREQ GLOB.radiochannels["Common"]
#define VOICE_MAX_RANGE 3   // biggest canhear_range of any radio

/client
	var/voice_last = VOICE_ALL
	var/voice_last_subspace
	var/voice_until_subspace_check = 0

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
	// Conscious is all-clear, softcrit is hear only, unconscious/dead is nothing
	if (mob.stat == DEAD || mob.stat == UNCONSCIOUS)
		return VOICE_NONE

	// While you can whisper in softcrit, this is mangled thoroughly over the
	// radio, so we might as well fully mute it. In-game chat is still there.

	// Those deaf and dumb are thus limited
	var/mob_can_hear = (mob.can_hear() && !!mob.has_language(VOICE_LANG))
	var/mob_can_speak = (mob.can_speak() && mob.can_speak_in_language(VOICE_LANG) && mob.stat == CONSCIOUS)
	// TODO: consider disable speaking for severe impediments (e.g. no tounge)
	var/mob_can = (mob_can_hear ? VOICE_HEAR : 0) | (mob_can_speak ? VOICE_SPEAK : 0)
	if (mob_can == VOICE_NONE)
		return VOICE_NONE

	// Long path: check the mob's environment as needed
	. = 0

	var/subspace_on = TRUE

	var/checked = 0
	// Check ears for a headset (";" prefix)
	if (istype(mob, /mob/living/carbon))
		var/mob/living/carbon/M = mob
		var/obj/item/device/radio/headset/R = M.ears
		if (istype(M.ears))
			checked++
			. |= R.voice_check(mob, subspace_on, ptt=TRUE)

	// Check hands for a headset or SBR (":l", ":r" prefixes)
	if (VOICE_SPEAK & mob_can & ~.)
		for (var/obj/item/device/radio/R in mob.held_items)
			checked++
			. |= R.voice_check(mob, subspace_on, ptt=TRUE)

	// Check surrounding environment for an intercom (":i" prefix)
	// Intercom PTT range is 1 tile
	if (VOICE_SPEAK & mob_can & ~.)
		// should match MODE_INTERCOM check in mob/living/say.dm
		for (var/obj/item/device/radio/intercom/R in view(1, mob))
			checked++
			. |= R.voice_check(mob, subspace_on, ptt=TRUE)

	// Check surrounding environment for open mics...
	if (VOICE_SPEAK & mob_can & ~.)
		for (var/obj/item/device/radio/R in get_hearers_in_view(VOICE_MAX_RANGE, mob))
			checked++
			. |= R.voice_check(mob, subspace_on)

	// ... and for open speakers
	if (VOICE_HEAR & mob_can & ~.)
		for (var/obj/item/device/radio/R in range(VOICE_MAX_RANGE, mob))
			checked++
			. |= R.voice_check(mob, subspace_on)

	// Backup check in case we set a flag incidentally
	//to_chat(src, "checked = [checked]; result = [.]; mob_can = [mob_can]")
	. &= mob_can

/obj/item/device/radio/proc/voice_check(mob/M, subspace_on, ptt=FALSE)
	. = 0

	// receive_range should be checking the frequency and everything else
	var/dist = get_dist(src, M)
	//to_chat(M, "[src]: dist=[dist], recv_range=[receive_range(VOICE_FREQ, M.z)], canhear_range=[canhear_range], subspace=[subspace_transmission], listening=[listening], broadcasting=[broadcasting]")
	if (dist <= receive_range(VOICE_FREQ, list(M.z)))
		. |= VOICE_HEAR

	// manually do all the speaking stuff, corresponds to talk_into
	if (on && dist <= canhear_range && frequency == VOICE_FREQ && !wires.is_cut(WIRE_TX) && (ptt || broadcasting) && (!subspace_transmission || subspace_on))
		. |= VOICE_SPEAK

#undef VOICE_NONE
#undef VOICE_SPEAK
#undef VOICE_HEAR
#undef VOICE_ALL
#undef VOICE_LANG
#undef VOICE_FREQ
#undef VOICE_MAX_RANGE

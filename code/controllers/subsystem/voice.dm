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

		//message_admins("SSvoice: refresh [C]")
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
			message_admins("Voice subsystem suspended")
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

// ---------- Definitions and whatnot

#define VOICE_NONE 0
#define VOICE_HEAR 1
#define VOICE_SPEAK 2
#define VOICE_SPEAK_FREELY 4
#define VOICE_ALL 7

#define VOICE_LANG /datum/language/common
#define VOICE_FREQ GLOB.radiochannels["Common"]
#define VOICE_MAX_RANGE 3   // biggest canhear_range of any radio

/datum/voicestuff
	var/status = VOICE_ALL

	var/next_check = 1
	var/needs_check = TRUE

	var/obj/screen/voicestatus/speak/screen_speak = new
	var/obj/screen/voicestatus/hear/screen_hear = new

/client/var/datum/voicestuff/voice = new

// ---------- Additions to client

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
	var/mob_can = (mob_can_hear ? VOICE_HEAR : 0) | (mob_can_speak ? (VOICE_SPEAK | VOICE_SPEAK_FREELY) : 0)
	if (mob_can == VOICE_NONE)
		return VOICE_NONE

	// Long path: check the mob's environment as needed
	. = 0

	// Subspace checking
	var/turf/position = get_turf(mob)
	var/subspace_on = (position.z in SSvoice.subspace_zlevels)

	//var/checked = 0
	// Check ears for a headset (";" prefix)
	if (istype(mob, /mob/living/carbon))
		var/mob/living/carbon/M = mob
		var/obj/item/device/radio/headset/R = M.ears
		if (istype(M.ears))
			//checked++
			. |= R.voice_check(mob, subspace_on, ptt=TRUE)

	// Check hands for a headset or SBR (":l", ":r" prefixes)
	if (VOICE_SPEAK & mob_can & ~.)
		for (var/obj/item/device/radio/R in mob.held_items)
			//checked++
			. |= R.voice_check(mob, subspace_on, ptt=TRUE)

	// Check surrounding environment for an intercom (":i" prefix)
	// Intercom PTT range is 1 tile
	if (VOICE_SPEAK & mob_can & ~.)
		// should match MODE_INTERCOM check in mob/living/say.dm
		for (var/obj/item/device/radio/intercom/R in view(1, mob))
			//checked++
			. |= R.voice_check(mob, subspace_on, ptt=TRUE)

	// Check surrounding environment for open mics...
	if ((VOICE_SPEAK | VOICE_SPEAK_FREELY) & mob_can & ~.)
		for (var/obj/item/device/radio/R in get_hearers_in_view(VOICE_MAX_RANGE, mob))
			//checked++
			. |= R.voice_check(mob, subspace_on)

	// ... and for open speakers
	if (VOICE_HEAR & mob_can & ~.)
		for (var/obj/item/device/radio/R in range(VOICE_MAX_RANGE, mob))
			//checked++
			. |= R.voice_check(mob, subspace_on)

	// Backup check in case we set a flag incidentally
	//to_chat(src, "checked = [checked]; result = [.]; mob_can = [mob_can]")
	. &= mob_can

// ---------- Additions to mobs and radios

/obj/item/device/radio/proc/voice_check(mob/M, subspace_on, ptt=FALSE)
	if (!on) return 0 // short path

	// radio's good for nothing if it can't reach the station
	var/turf/position = get_turf(M)
	if ((!(position.z in GLOB.station_z_levels) || subspace_transmission) && !subspace_on)
		return 0

	. = 0

	// receive_range should be checking the frequency and everything else
	var/dist = get_dist(src, M)
	//to_chat(M, "[src]: dist=[dist], recv_range=[receive_range(VOICE_FREQ, M.z)], canhear_range=[canhear_range], subspace=[subspace_transmission], listening=[listening], broadcasting=[broadcasting]")
	var/range = receive_range(VOICE_FREQ, list(position.z))
	if (range > -1 && dist <= range && M in get_hearers_in_view(range, src))
		. |= VOICE_HEAR

	// manually do all the speaking stuff, corresponds to talk_into
	if (dist <= canhear_range && frequency == VOICE_FREQ && !wires.is_cut(WIRE_TX) && (ptt || broadcasting))
		. |= VOICE_SPEAK | (broadcasting ? VOICE_SPEAK_FREELY : 0)

/obj/item/device/radio/equipped(mob/user, slot)
	..()
	if (user.client)
		user.client.voice.needs_check = TRUE

/obj/item/device/radio/dropped(mob/user)
	..()
	if (user.client)
		user.client.voice.needs_check = TRUE

/obj/item/device/radio/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if (action in list("frequency", "listen", "broadcast", "channel", "subspace"))
		for (var/mob/living/M in get_hearers_in_view(canhear_range, src))
			if (M.client)
				M.client.voice.needs_check = TRUE

/mob/living/Moved()
	. = ..()
	if (client)
		client.voice.needs_check = TRUE

/mob/living/afterShuttleMove()
	. = ..()
	if (. && client)
		spawn(1) client.voice.needs_check = TRUE

// TODO: cache radio coverage per-turf, recalculate infrequently or only when
// needed, and use that rather than an object lookup.

// ---------- Screen pieces

/obj/screen/voicestatus
	name = "voice indicator"
	icon = 'icons/mob/screen_voice.dmi'
	icon_state = "blank"

/obj/screen/voicestatus/speak
	name = "speech indicator"
	screen_loc = "EAST:-4,SOUTH+2:9"

/obj/screen/voicestatus/speak/proc/update_voice(state)
	icon_state = ((state & VOICE_SPEAK) ? "" : "no") + "speak" + ((state & VOICE_SPEAK_FREELY) ? "2" : "")

/obj/screen/voicestatus/hear
	name = "hearing indicator"
	screen_loc = "EAST:12,SOUTH+2:9"

/obj/screen/voicestatus/hear/proc/update_voice(state)
	icon_state = (state & VOICE_HEAR) ? "hear" : "nohear"

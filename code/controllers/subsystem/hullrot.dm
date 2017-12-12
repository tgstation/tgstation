// Used to manage the Hullrot process.

SUBSYSTEM_DEF(hullrot)
	name = "Hullrot"
	priority = 25
	flags = SS_BACKGROUND
	wait = 2
	init_order = -50  // Very late initialize

	var/const/dll = "hullrot.dll"
	var/const/expected_major = 0  // Major version must be exactly this
	var/const/expected_minor = 0  // Minor version must be at least this
	var/loaded_version  // For VV inspection

	var/currently_playing = -1
	var/checked_events = FALSE
	var/subspace_ticker = 0
	var/subspace_groups

// ----------------------------------------------------------------------------
// Initialization

/datum/controller/subsystem/hullrot/Initialize()
	// Load the DLL and check the version
	var/list/version = get_version()
	if (version == null)
		return abort("[name] could not be loaded and has been disabled.")
	if (version["error"])
		return abort("[name] version check failed: [version["error"]].")
	if (version["major"] != expected_major || version["minor"] < expected_minor)
		return abort("[name] [expected_major].[expected_minor] was expected, but incompatible [version["version"]] was supplied.")
	loaded_version = version["version"]

	var/list/res = debug_decode(call(dll, "hullrot_init")())
	var/error = res["error"] || res["Fatal"] || res["Debug"]
	if (error)
		return abort("[name] failed to initialize: [error]")

	for (var/mob/living/L in GLOB.player_list)
		L.hullrot_reset()

	return ..()

/datum/controller/subsystem/hullrot/proc/get_version()
	return debug_decode(call(dll, "hullrot_dll_version")())

// ----------------------------------------------------------------------------
// Shutdown

/datum/controller/subsystem/hullrot/Shutdown()
	if (loaded_version)
		loaded_version = null
		call(dll, "hullrot_stop")()

// because the DLL starts a thread, we have to make *extra* sure to join it
/world/Del()
	if (SShullrot)
		SShullrot.Shutdown()
	..()

// ----------------------------------------------------------------------------
// General processing

/datum/controller/subsystem/hullrot/proc/abort(msg)
	log_world(msg)
	to_chat(world, "<span class='boldannounce'>[msg]</span>")
	can_fire = FALSE

/datum/controller/subsystem/hullrot/proc/debug_decode(result)
	if (result != "\[\]")
		log_world(result)
	return json_decode(result)

/datum/controller/subsystem/hullrot/proc/warn(msg)
	message_admins("[name] warning: [msg]")

/datum/controller/subsystem/hullrot/proc/control(what, data)
	if (!loaded_version || !can_fire)
		return

	checked_events = TRUE
	var/events
	if (what)
		message_admins("[name] output: [what] [json_encode(data)]")
		events = debug_decode(call(dll, "hullrot_control")(json_encode(list("[what]" = data))))
	else
		events = debug_decode(call(dll, "hullrot_control")())
	for (var/event in events)
		message_admins("[name]: event: [json_encode(event)]")
		if ((data = event["Fatal"]))
			abort("Hullrot has crashed: [data]")

		else if ((data = event["Debug"]))
			warn(data)

		else if ((data = event["Refresh"]))
			var/client/C = GLOB.directory[data]
			var/mob/living/L = C && C.mob
			if (istype(L))
				L.hullrot_reset()

		else if ((data = event["Hear"]))
			var/client/C = GLOB.directory[data["speaker"]]
			var/mob/living/speaker = C && C.mob
			C = GLOB.directory[data["hearer"]]
			var/mob/living/hearer = C && C.mob
			if (istype(speaker) && istype(hearer))
				// Issue forth the textual notification...
				var/atom/movable/abstract_speaker = speaker
				if (data["freq"])
					var/atom/movable/virtualspeaker/virt = new(null)
					virt.source = speaker
					virt.name = speaker.GetVoice()
					virt.verb_say = speaker.verb_say
					virt.verb_ask = speaker.verb_ask
					virt.verb_exclaim = speaker.verb_exclaim
					virt.verb_yell = speaker.verb_yell
					abstract_speaker = virt
				to_chat(hearer, hearer.hullrot_compose(abstract_speaker, speaker.get_default_language(), data["freq"]))

		else if ((data = event["HearSelf"]))
			var/client/C = GLOB.directory[data["who"]]
			var/mob/living/L = C && C.mob
			if (istype(L))
				if (!L.can_hear())
					if (!data["freq"])
						to_chat(L, "<span class='notice'>You can't hear yourself!</span>")
				else if (data["freq"])
					to_chat(L, L.hullrot_compose(L, L.get_default_language(), data["freq"]))

		else if ((data = event["SpeechBubble"]))
			var/client/C = GLOB.directory[data["who"]]
			var/mob/living/speaker = C && C.mob

			var/image/bubble = speaker.hullrot_bubble
			if (!bubble)
				speaker.hullrot_bubble = bubble = image('icons/mob/talk.dmi', speaker, "[speaker.bubble_icon]0", FLY_LAYER - 0.01)
			else
				bubble.icon_state = "[speaker.bubble_icon]0"

			for (var/mob/living/L in GLOB.player_list)
				if (!L.client)
					continue
				if (L.ckey in data["with"])
					L.client.images |= bubble
				else
					L.client.images -= bubble

/datum/controller/subsystem/hullrot/fire()
	checked_events = FALSE

	var/new_playing = SSticker.IsRoundInProgress()
	if (new_playing != currently_playing)
		control("Playing", new_playing)
		currently_playing = new_playing

	if (subspace_ticker >= 0)
		subspace_ticker += wait
		if (subspace_ticker >= 50 || !subspace_groups)
			subspace_ticker = -1
			INVOKE_ASYNC(src, .proc/subspace_update)

	if (!checked_events)
		control()

/datum/controller/subsystem/hullrot/proc/subspace_update()
	var/groups = list()
	var/group = 1

	for(var/z in 1 to world.maxz)
		if ("[z]" in groups)
			continue
		var/datum/signal/subspace/signal = new(list("message" = "TEST"))
		signal.frequency = FREQ_COMMON
		signal.server_type = /obj/machinery/telecomms/broadcaster
		signal.levels = list(z)
		signal.send_to_receivers()
		if (signal.data["done"])
			for(var/level in signal.levels)
				groups["[level]"] = group
			group += 1

	if (list2params(subspace_groups) != list2params(groups))
		subspace_groups = groups
		control("Linkage", groups)
		for (var/mob/living/L in GLOB.player_list)
			L.hullrot_update()
	subspace_ticker = 0

// ----------------------------------------------------------------------------
// Controls

/datum/controller/subsystem/hullrot/proc/set_mob_flags(client/C, can_speak, can_hear)
	control("SetMobFlags", list("who" = C.ckey, "speak" = can_speak, "hear" = can_hear))

/datum/controller/subsystem/hullrot/proc/set_ptt(client/C, freq)
	control("SetPTT", list("who" = C.ckey, "freq" = (freq && text2num(freq))))

/datum/controller/subsystem/hullrot/proc/set_local_with(client/C, keylist)
	control("SetLocalWith", list("who" = C.ckey, "with" = keylist))

/datum/controller/subsystem/hullrot/proc/set_hear_freqs(client/C, freqlist)
	control("SetHearFreqs", list("who" = C.ckey, "hear" = freqlist))

/datum/controller/subsystem/hullrot/proc/set_hot_freqs(client/C, freqlist)
	control("SetHotFreqs", list("who" = C.ckey, "hot" = freqlist))

/datum/controller/subsystem/hullrot/proc/set_z(client/C, z)
	control("SetZ", list("who" = C.ckey, "z" = z))

/datum/controller/subsystem/hullrot/proc/set_ghost(client/C)
	control("SetGhost", C.ckey)

// ----------------------------------------------------------------------------
// Admin management

/datum/controller/subsystem/hullrot/proc/reconnect()
	message_admins("Admin [key_name_admin(usr)] is restarting [name].")
	Shutdown()
	can_fire = TRUE
	currently_playing = initial(currently_playing)  // force a resend
	Initialize(REALTIMEOFDAY)

/**
 * Broadcast a message to all drones in a faction
 *
 * Arguments:
 * * msg - The message to send
 * * dead_can_hear - Boolean that determines if ghosts can hear the message (`FALSE` by default)
 * * source - [/atom] source that created the message
 * * faction_checked_mob - [/mob/living] to determine faction matches from
 * * exact_faction_match - Passed to [/mob/proc/faction_check_atom]
 * * tts_message - Message used in `cast_tts`
 * * tts_seed - TTS seed used in `cast_tts`
 */
/proc/_alert_drones(msg, dead_can_hear = FALSE, atom/source, mob/living/faction_checked_mob, exact_faction_match, tts_message, tts_seed)
	if(dead_can_hear && source)
		for(var/mob/dead_mob in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(dead_mob, source)
			to_chat(dead_mob, "[link] [msg]")
	for(var/global_drone in GLOB.drones_list)
		var/mob/living/basic/drone/drone = global_drone
		if(!istype(drone))
			continue
		if(drone.stat == DEAD)
			continue
		if(faction_checked_mob && !drone.faction_check_atom(faction_checked_mob, exact_faction_match))
			continue
		to_chat(
			drone,
			msg,
			type = MESSAGE_TYPE_RADIO,
			avoid_highlighting = (drone == source),
		)

		// BANDASTATION ADDITION START - TTS
		SStts220.get_tts(
			listener = drone,
			message = tts_message,
			tts_seed = tts_seed,
			is_local = FALSE,
			effect_types = list(/datum/singleton/sound_effect/robot, /datum/singleton/sound_effect/radio),
			channel_override = CHANNEL_TTS_RADIO
		)
		// BANDASTATION ADDITION END

/**
 * Wraps [/proc/_alert_drones] with defaults
 *
 * * source - `src`
 * * faction_check_atom - `src`
 * * dead_can_hear - `TRUE`
 */
/mob/living/basic/drone/proc/alert_drones(msg, dead_can_hear = FALSE)
	_alert_drones(msg, dead_can_hear, src, src, TRUE, tts_seed = (get_tts_seed() || /datum/tts_seed/silero/glados))

/**
 * Wraps [/mob/living/basic/drone/proc/alert_drones] as a Drone Chat
 *
 * Shares the same radio code with binary
 */
/mob/living/basic/drone/proc/drone_chat(message, list/spans = list(), list/message_mods = list())
	log_sayverb_talk(message, message_mods, tag = "drone chat")
	var/message_part = generate_messagepart(message, spans, message_mods)
	alert_drones(span_drone("Drone Chat: [span_name("[name]")] [span_message(message_part)]"), TRUE)

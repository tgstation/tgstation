/// Shared blackboard for AI crew controllers. Stores structured perception
/// data, persona metadata, and configurable timers in bounded ring buffers so
/// we can emit deterministic summaries to planner/parser services.

/datum/ai_blackboard
	/// Persona and trait metadata derived from profile + config.
	var/list/persona_traits = list()
	/// Current zone/location identifier (deck/department).
	var/current_zone
	/// Current high-level goal string.
	var/current_goal
	/// Planned path (list of turfs/waypoints) for macro options.
	var/list/current_path = list()
	/// Bounded buffer of local speech events.
	var/list/local_speech_events = list()
	/// Bounded buffer of radio reception events.
	var/list/radio_events = list()
	/// Rolling list of active alerts/hazard synopsis data.
	var/list/hazard_synopsis = list()
	/// Per-channel talk budget counters (deciseconds until reset).
	var/list/talk_budgets = list()
	/// Named timers for option runner coordination.
	var/list/timers = list()
	/// Current confidence score (0–1 range for planner hints).
	var/confidence_level = 0
	/// Associative bag of admin flags (e.g. muted, frozen).
	var/list/admin_flags = list()
	/// Last N notable alert events (admin directives, panic conditions).
	var/list/alert_events = list()
	/// Maximum entries tracked for speech/radio buffers.
	var/max_local_events = AI_BLACKBOARD_LOCAL_EVENT_LIMIT
	var/max_radio_events = AI_BLACKBOARD_RADIO_EVENT_LIMIT
	var/max_alert_events = AI_BLACKBOARD_ALERT_EVENT_LIMIT

/datum/ai_blackboard/proc/reset()
	persona_traits = list()
	current_zone = null
	current_goal = null
	current_path = list()
	local_speech_events = list()
	radio_events = list()
	hazard_synopsis = list()
	talk_budgets = list()
	timers = list()
	confidence_level = 0
	admin_flags = list()
	alert_events = list()

/datum/ai_blackboard/proc/set_persona_traits(list/traits)
	persona_traits = islist(traits) ? traits.Copy() : list()

/datum/ai_blackboard/proc/get_persona_traits()
	return persona_traits?.Copy()

/datum/ai_blackboard/proc/set_zone(zone)
	current_zone = zone

/datum/ai_blackboard/proc/get_zone()
	return current_zone

/datum/ai_blackboard/proc/set_goal(goal)
	current_goal = goal

/datum/ai_blackboard/proc/get_goal()
	return current_goal

/datum/ai_blackboard/proc/set_path(list/path)
	current_path = islist(path) ? path.Copy() : list()

/datum/ai_blackboard/proc/get_path()
	return current_path?.Copy()

/datum/ai_blackboard/proc/clear_path()
	current_path = list()

/datum/ai_blackboard/proc/set_hazard_synopsis(list/hazards)
	hazard_synopsis = islist(hazards) ? hazards.Copy() : list()

/datum/ai_blackboard/proc/get_hazard_synopsis()
	return hazard_synopsis?.Copy()

/datum/ai_blackboard/proc/set_confidence(value)
	if(!isnum(value))
		value = 0
	confidence_level = clamp(value, 0, 1)

/datum/ai_blackboard/proc/get_confidence()
	return confidence_level

/datum/ai_blackboard/proc/set_talk_budget(channel, deciseconds)
	if(!talk_budgets)
		talk_budgets = list()
	talk_budgets[channel] = max(0, round(deciseconds))

/datum/ai_blackboard/proc/get_talk_budget(channel)
	return talk_budgets?[channel]

/datum/ai_blackboard/proc/set_timer(name, deciseconds)
	if(isnull(name))
		return
	if(!timers)
		timers = list()
	timers[name] = deciseconds

/datum/ai_blackboard/proc/get_timer(name)
	return timers?[name]

/datum/ai_blackboard/proc/clear_timer(name)
	if(timers && name in timers)
		timers -= name

/datum/ai_blackboard/proc/set_admin_flag(flag, state = TRUE)
	if(isnull(flag))
		return
	if(!admin_flags)
		admin_flags = list()
	if(state)
		admin_flags[flag] = TRUE
	else
		admin_flags -= flag

/datum/ai_blackboard/proc/has_admin_flag(flag)
	return !!admin_flags?[flag]

/datum/ai_blackboard/proc/get_admin_flags()
	if(!admin_flags)
		return list()
	var/list/result = list()
	for(var/flag in admin_flags)
		if(admin_flags[flag])
			result += flag
	return result

/datum/ai_blackboard/proc/record_local_speech(atom/movable/speaker, message, datum/language/language, list/spans, list/mods)
	var/list/event = list(
		"timestamp" = world.time,
		"speaker" = speaker ? WEAKREF(speaker) : null,
		"speaker_name" = speaker?.name,
		"language" = language?.name || language,
		"message" = message,
		"spans" = spans?.Copy(),
		"mods" = mods?.Copy(),
	)
	local_speech_events = ensure_buffer_capacity(local_speech_events, max_local_events, event)
	if(message)
		log_ai_perception("local", list(
			"speaker" = event["speaker_name"],
			"language" = event["language"],
			"message" = message,
		))

/datum/ai_blackboard/proc/record_radio_event(obj/item/radio/source, list/data)
	var/list/event = list(
		"timestamp" = world.time,
		"radio" = source ? WEAKREF(source) : null,
		"name" = data?["name"],
		"job" = data?["job"],
		"message" = data?["message"],
		"language" = data?["language"],
		"frequency" = data?["frequency"],
		"channel" = data?["channel"],
		"spans" = data?["spans"]?.Copy(),
		"mods" = data?["mods"]?.Copy(),
	)
	radio_events = ensure_buffer_capacity(radio_events, max_radio_events, event)
	if(event["message"])
		log_ai_perception("radio", list(
			"sender" = event["name"],
			"frequency" = event["frequency"],
			"message" = event["message"],
			"channel" = event["channel"],
		))

/datum/ai_blackboard/proc/record_alert(alert_type, severity, details = null)
	var/list/event = list(
		"timestamp" = world.time,
		"type" = alert_type,
		"severity" = severity,
		"details" = details,
	)
	alert_events = ensure_buffer_capacity(alert_events, max_alert_events, event)
	var/detail_preview = istext(details) ? details : (details ? "[details]" : null)
	log_ai_perception("alert", list(
		"type" = alert_type,
		"severity" = severity,
		"details" = detail_preview,
	))

/datum/ai_blackboard/proc/get_recent_local_speech()
	return copy_event_list(local_speech_events)

/datum/ai_blackboard/proc/get_recent_radio_events()
	return copy_event_list(radio_events)

/datum/ai_blackboard/proc/get_recent_alerts()
	return copy_event_list(alert_events)

/datum/ai_blackboard/proc/ensure_buffer_capacity(list/buffer, limit, list/event)
	if(!islist(buffer))
		buffer = list()
	buffer += list(event)
	if(limit > 0 && buffer.len > limit)
		var/extra = buffer.len - limit
		buffer.Cut(1, extra + 1)
	return buffer

/datum/ai_blackboard/proc/copy_event_list(list/source)
	if(!islist(source))
		return list()
	var/list/result = list()
	for(var/index in 1 to source.len)
		var/list/event = source[index]
		result += list(islist(event) ? event.Copy() : event)
	return result

/datum/ai_blackboard/proc/to_list()
	return list(
		"persona" = get_persona_traits(),
		"zone" = current_zone,
		"goal" = current_goal,
		"path" = get_path(),
		"hazards" = get_hazard_synopsis(),
		"confidence" = confidence_level,
		"talk_budgets" = talk_budgets?.Copy(),
		"timers" = timers?.Copy(),
		"admin_flags" = get_admin_flags(),
		"local_speech" = get_recent_local_speech(),
		"radio_events" = get_recent_radio_events(),
		"alerts" = get_recent_alerts(),
	)

/datum/ai_blackboard/proc/log_ai_perception(channel, list/event)
	if(!event)
		return
	var/list/log_payload = list(
		"channel" = channel,
		"event" = event.Copy(),
	)
	log_game("[AI_PERCEPTION_LOG_PREFIX][json_encode(log_payload)]")

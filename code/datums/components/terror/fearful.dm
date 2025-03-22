/// Fearful component: provides optional handling of fears and phobias for mob's mood
/// Can be applied from multiple sources, and essentially serves as a central controller for fear datums described below

/datum/component/fearful
	dupe_mode = COMPONENT_DUPE_SOURCES

	/// How terrified is the source?
	var/terror_buildup = 0
	/// List of terror handlers we currently have -> sources they're added by
	var/list/terror_handlers = list()
	/// List of overriden handler types, for ease of access
	var/list/overriden_handlers = list()

/*
 * initial_buildup - amount of fear to add to mob from getting scared shitless by whatever added the component
 * handler_types - terror_handler(s) to add to the mob
 * add_defaults - should terror handlers marked as "default" be added to the mob?
 */
/datum/component/fearful/Initialize(initial_buildup, list/handler_types, add_defaults = TRUE)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSdcs, src)
	terror_buildup = initial_buildup

	if (!add_defaults)
		return

	for (var/datum/terror_handler/handler as anything in subtypesof(/datum/terror_handler))
		if (!initial(handler.default))
			continue
		handler = new handler(parent)
		terror_handlers[handler] = list("default")
		for (var/override_type in handler.overrides)
			if (!overriden_handlers[override_type])
				overriden_handlers[override_type] = list()
			overriden_handlers[override_type] += handler.type

/datum/component/fearful/Destroy(force)
	STOP_PROCESSING(SSdcs, src)
	QDEL_LIST(terror_handlers)
	return ..()

/datum/component/fearful/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/fearful/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)

/datum/component/fearful/on_source_add(source, initial_buildup, list/handler_types, add_defaults = TRUE)
	. = ..()
	terror_buildup = clamp(terror_buildup + initial_buildup, 0, TERROR_BUILDUP_MAXIMUM)
	for (var/handler_type in handler_types)
		var/datum/terror_handler/handler = locate(handler_type) in terror_handlers
		if (handler)
			terror_handlers[handler] += source
			continue
		handler = new handler_type(parent)
		terror_handlers[handler] = list(source)
		for (var/override_type in handler.overrides)
			if (!overriden_handlers[override_type])
				overriden_handlers[override_type] = list()
			overriden_handlers[override_type] += handler_type

/datum/component/fearful/on_source_remove(source)
	for (var/datum/terror_handler/handler as anything in terror_handlers)
		terror_handlers[handler] -= source
		if (length(terror_handlers[handler]))
			continue
		terror_handlers -= handler
		for (var/override_type in handler.overrides)
			if (!overriden_handlers[override_type])
				continue
			overriden_handlers[override_type] -= handler.type
			if (!length(overriden_handlers[override_type]))
				overriden_handlers -= override_type
		qdel(handler)
	return ..()

/datum/component/fearful/process(seconds_per_tick)
	var/list/tick_later = list()
	for (var/datum/terror_handler/handler as anything in terror_handlers)
		if (is_type_in_list(handler, overriden_handlers))
			continue
		if (handler.handler_type == TERROR_HANDLER_EFFECT)
			tick_later += handler
			continue
		terror_buildup = clamp(terror_buildup + handler.tick(seconds_per_tick, terror_buildup), 0, TERROR_BUILDUP_MAXIMUM)

	for (var/datum/terror_handler/handler as anything in tick_later)
		terror_buildup = clamp(terror_buildup + handler.tick(seconds_per_tick, terror_buildup), 0, TERROR_BUILDUP_MAXIMUM)

/datum/component/fearful/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if (source.stat >= UNCONSCIOUS)
		return

	if(terror_buildup > TERROR_BUILDUP_HEART_ATTACK)
		examine_list += span_danger("[source.p_They()] [source.p_are()] are seizing up, about to collapse in fear!")
	else if(terror_buildup > TERROR_BUILDUP_PANIC)
		examine_list += span_boldwarning("[source.p_They()] [source.p_are()] are trembling and shaking, barely standing upright!")
	else if(terror_buildup >= TERROR_BUILDUP_TERROR)
		examine_list += span_boldwarning("[source] is visibly trembling and twitching. [source.p_they()] [source.p_are()] are clearly in distress!")
	else if(terror_buildup >= TERROR_BUILDUP_FEAR)
		examine_list += span_warning("[source] looks very worried about something. [source.p_are()] [source.p_they()] alright?")
	else
		examine_list += span_smallnotice("[source] looks rather anxious. [source.p_They()] could probably use a hug...")

/// Perception scaffold responsible for subscribing to speech/radio signals
/// and mirroring structured events into the AI blackboard. Later tasks will
/// replace these logging stubs with planner-facing heuristics.

/datum/ai_perception
	/// Owning controller for lifecycle hooks.
	var/datum/ai_controller/crew_human/owner
	/// Blackboard reference used to store structured perception events.
	var/datum/ai_blackboard/blackboard
	/// Tracked mob reference for signal registration.
	var/mob/living/carbon/human/tracked_mob
	/// Radios currently registered for COMSIG_RADIO_RECEIVE_MESSAGE.
	var/list/registered_radios = list()

/datum/ai_perception/New(datum/ai_controller/crew_human/controller, datum/ai_blackboard/blackboard)
	owner = controller
	src.blackboard = blackboard
	if(owner?.pawn)
		attach_to_mob(owner.pawn)
	return ..()

/datum/ai_perception/Destroy(force)
	detach_listeners()
	owner = null
	blackboard = null
	return ..()

/datum/ai_perception/proc/set_blackboard(datum/ai_blackboard/new_blackboard)
	blackboard = new_blackboard

/datum/ai_perception/proc/set_owner(datum/ai_controller/crew_human/controller)
	if(owner == controller)
		return
	owner = controller
	if(controller?.pawn)
		attach_to_mob(controller.pawn)

/datum/ai_perception/proc/attach_to_mob(atom/new_target)
	if(tracked_mob == new_target)
		return
	detach_listeners()
	if(!istype(new_target, /mob/living/carbon/human))
		return
	tracked_mob = new_target
	RegisterSignal(tracked_mob, COMSIG_MOVABLE_HEAR, PROC_REF(on_local_hear))
	RegisterSignal(tracked_mob, COMSIG_QDELETING, PROC_REF(on_mob_deleted))
	refresh_radio_sources()

/datum/ai_perception/proc/detach_listeners()
	if(tracked_mob)
		UnregisterSignal(tracked_mob, COMSIG_MOVABLE_HEAR)
		UnregisterSignal(tracked_mob, COMSIG_QDELETING)
	tracked_mob = null
	if(!registered_radios)
		return
	for(var/i = registered_radios.len; i >= 1; i--)
		var/obj/item/radio/radio = registered_radios[i]
		if(radio)
			UnregisterSignal(radio, COMSIG_RADIO_RECEIVE_MESSAGE)
			UnregisterSignal(radio, COMSIG_QDELETING)
	registered_radios.Cut()

/datum/ai_perception/proc/refresh_radio_sources()
	if(!tracked_mob)
		return
	var/list/current_sources = gather_radio_sources(tracked_mob)
	// Register new radios.
	for(var/obj/item/radio/radio in current_sources)
		if(!(radio in registered_radios))
			RegisterSignal(radio, COMSIG_RADIO_RECEIVE_MESSAGE, PROC_REF(on_radio_heard))
			RegisterSignal(radio, COMSIG_QDELETING, PROC_REF(on_radio_deleted))
			registered_radios += radio
	// Clean up radios that are no longer equipped/held.
	if(!registered_radios)
		return
	for(var/index = registered_radios.len; index >= 1; index--)
		var/obj/item/radio/radio = registered_radios[index]
		if(!radio || QDELETED(radio) || !(radio in current_sources))
			if(radio)
				UnregisterSignal(radio, COMSIG_RADIO_RECEIVE_MESSAGE)
				UnregisterSignal(radio, COMSIG_QDELETING)
			registered_radios.Cut(index, index + 1)

/datum/ai_perception/proc/gather_radio_sources(mob/living/carbon/human/holder)
	var/list/sources = list()
	if(!holder)
		return sources
	if(istype(holder.ears, /obj/item/radio))
		sources += holder.ears
	if(istype(holder.wear_mask, /obj/item/radio))
		sources += holder.wear_mask
	for(var/obj/item/radio/radio in holder.contents)
		if(!(radio in sources))
			sources += radio
	return sources

/datum/ai_perception/proc/on_local_hear(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	if(!blackboard)
		return
	if(!tracked_mob || tracked_mob != source)
		return
	var/atom/movable/speaker = hearing_args[HEARING_SPEAKER]
	var/datum/language/lang = hearing_args[HEARING_LANGUAGE]
	var/message = hearing_args[HEARING_RAW_MESSAGE]
	var/list/spans = hearing_args[HEARING_SPANS]
	var/list/mods = hearing_args[HEARING_MESSAGE_MODE]
	blackboard.record_local_speech(speaker, message, lang, spans, mods)

/datum/ai_perception/proc/on_radio_heard(datum/source, list/data)
	SIGNAL_HANDLER

	if(!blackboard)
		return
	if(!source || !(source in registered_radios))
		return
	blackboard.record_radio_event(source, islist(data) ? data.Copy() : list())

/datum/ai_perception/proc/on_radio_deleted(datum/source)
	SIGNAL_HANDLER

	if(!(source in registered_radios))
		return
	UnregisterSignal(source, COMSIG_RADIO_RECEIVE_MESSAGE)
	UnregisterSignal(source, COMSIG_QDELETING)
	registered_radios -= source

/datum/ai_perception/proc/on_mob_deleted(datum/source)
	SIGNAL_HANDLER
	detach_listeners()

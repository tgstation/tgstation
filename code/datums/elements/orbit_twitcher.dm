/datum/element/orbit_twitcher
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	/// Chance we have to twitch per second
	var/twitch_chance
	/// Those who are being orbited and should twitch
	var/list/twitchers = list()

/datum/element/orbit_twitcher/Attach(datum/target, twitch_chance)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.twitch_chance = twitch_chance

	RegisterSignal(target, COMSIG_ATOM_ORBIT_BEGIN, PROC_REF(orbit_begin))
	RegisterSignal(target, COMSIG_ATOM_ORBIT_STOP, PROC_REF(orbit_stop))

/datum/element/orbit_twitcher/Detach(datum/source, ...)
	. = ..()

	twitchers.Remove(source)
	UnregisterSignal(source, list(COMSIG_ATOM_ORBIT_BEGIN, COMSIG_ATOM_ORBIT_STOP))

/datum/element/orbit_twitcher/process(seconds_per_tick)
	for(var/mob/living/living as anything in twitchers)
		if(SPT_PROB(twitch_chance, seconds_per_tick))
			if(prob(60))
				living.emote("twitch_s", forced = TRUE)
			else
				living.emote("twitch", forced = TRUE)

/datum/element/orbit_twitcher/proc/orbit_begin(atom/source, atom/orbiter)
	SIGNAL_HANDLER

	twitchers.Add(source)
	// It checks if we're already processing so it's fine to always call
	START_PROCESSING(SSdcs, src)

/datum/element/orbit_twitcher/proc/orbit_stop(atom/source, atom/orbiter)
	SIGNAL_HANDLER

	twitchers.Remove(source)

	if(!twitchers.len)
		STOP_PROCESSING(SSdcs, src)

/datum/element/orbit_twitcher/OnTargetDelete(datum/source)
	twitchers.Remove(source)
	return ..()

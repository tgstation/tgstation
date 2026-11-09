SUBSYSTEM_DEF(augury)
	name = "Augury"
	ss_flags = SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/watchers = list()
	var/list/doombringers = list()

	/// Associative list of observers given action to a boolean
	/// indicating whether or not they have been given action.
	var/list/observers_given_action = list()

/datum/controller/subsystem/augury/stat_entry(msg)
	msg = "W:[watchers.len]|D:[length(doombringers)]"
	return ..()

/datum/controller/subsystem/augury/proc/register_doom(atom/new_doom, severity)
	doombringers[new_doom] = severity
	RegisterSignal(new_doom, COMSIG_QDELETING, PROC_REF(unregister_doom))

/datum/controller/subsystem/augury/proc/unregister_doom(atom/old_doom)
	SIGNAL_HANDLER
	UnregisterSignal(old_doom, COMSIG_QDELETING)
	doombringers -= old_doom

/datum/controller/subsystem/augury/fire()
	var/biggest_doom = null
	var/biggest_threat = null

	for(var/doombringer in doombringers)
		var/datum/doom = doombringer
		if(QDELETED(doom))
			doombringers -= doom
			continue
		var/threat = doombringers[doom]
		if(isnull(biggest_threat) || (biggest_threat < threat))
			biggest_doom = doom
			biggest_threat = threat

	if(doombringers.len)
		for(var/i in GLOB.player_list)
			if(isobserver(i) && (!(observers_given_action[i])))
				var/datum/action/innate/augury/augury_action = new
				augury_action.Grant(i)
				observers_given_action[i] = TRUE
	else
		for(var/mob/dead/observer/key, value in observers_given_action)
			if(value)
				for(var/datum/action/innate/augury/augury_action in key.actions)
					qdel(augury_action)
			observers_given_action -= key

	for(var/watcher in watchers)
		if(!watcher)
			watchers -= watcher
			continue
		var/mob/dead/observer/orbitter = watcher
		if(biggest_doom && (!orbitter.orbiting || orbitter.orbiting.parent != biggest_doom))
			orbitter.ManualFollow(biggest_doom)

/datum/action/innate/augury
	name = "Auto Follow Debris"
	button_icon = 'icons/obj/meteor.dmi'
	button_icon_state = "flaming"

/datum/action/innate/augury/Destroy()
	if(owner)
		SSaugury.watchers -= owner
	return ..()

/datum/action/innate/augury/Activate()
	SSaugury.watchers += owner
	to_chat(owner, span_notice("You are now auto-following debris."))
	active = TRUE

/datum/action/innate/augury/Deactivate()
	SSaugury.watchers -= owner
	to_chat(owner, span_notice("You are no longer auto-following debris."))
	active = FALSE

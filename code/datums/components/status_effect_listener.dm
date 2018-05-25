/datum/component/status_effect_listener
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/effects = list()

/datum/component/status_effect_listener/Initialize()
	RegisterSignal(COMSIG_ATOM_EX_ACT, .proc/explosion)
	RegisterSignal(COMSIG_MOVABLE_MOVED, .proc/movement)
	RegisterSignal(COMSIG_LIVING_RESIST, .proc/resist)
	RegisterSignal(COMSIG_LIVING_IGNITED, .proc/ignited)
	RegisterSignal(COMSIG_LIVING_EXTINGUISHED, .proc/extinguished)

/datum/component/status_effect_listener/proc/signal(var/sigtype)
	for(var/datum/status_effect/effect in effects)
		effect.receiveSignal(sigtype)

/datum/component/status_effect_listener/proc/explosion()
	signal(STATUS_LISTENER_EXPLOSION)

/datum/component/status_effect_listener/proc/movement()
	signal(STATUS_LISTENER_MOVEMENT)

/datum/component/status_effect_listener/proc/resist()
	signal(STATUS_LISTENER_RESIST)

/datum/component/status_effect_listener/proc/ignited()
	signal(STATUS_LISTENER_IGNITED)

/datum/component/status_effect_listener/proc/extinguished()
	signal(STATUS_LISTENER_EXTINGUISHED)

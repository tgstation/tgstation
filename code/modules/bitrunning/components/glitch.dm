/datum/component/glitch

/datum/component/glitch/Initialize(obj/machinery/quantum_server/server)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(server, COMSIG_MACHINERY_BROKEN, PROC_REF(on_death))

	var/mob/living/owner = parent

	owner.add_overlay(mutable_appearance('icons/effects/beam.dmi', "lightning12", ABOVE_MOB_LAYER))

/datum/component/glitch/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_LIVING_STATUS_UNCONSCIOUS, COMSIG_LIVING_DEATH), PROC_REF(on_death))

/datum/component/glitch/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/// We don't want digital entities just lingering around as corpses.
/datum/component/glitch/proc/on_death()
	SIGNAL_HANDLER

	if(QDELETED(parent))
		return

	var/mob/living/owner = parent
	to_chat(owner, span_userdanger("You feel a strange sensation..."))

	addtimer(CALLBACK(src, PROC_REF(dust_mob)), 2 SECONDS, TIMER_UNIQUE|TIMER_DELETE_ME|TIMER_STOPPABLE)

/// Sakujo
/datum/component/glitch/proc/dust_mob()
	if(QDELETED(parent))
		return

	var/mob/living/owner = parent

	owner.dust()

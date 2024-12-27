/**
 * Responds to certain signals and 'explodes' on the person using the item.
 * Differs from `interaction_booby_trap` in that this doesn't actually explode, it just directly calls ex_act on one person.
 */
/datum/component/direct_explosive_trap
	/// An optional mob to inform about explosions
	var/mob/living/saboteur
	/// Amount of force to apply
	var/explosive_force
	/// Colour for examine notification
	var/glow_colour
	/// Optional additional target checks before we go off
	var/datum/callback/explosive_checks
	/// Signals which set off the bomb, must pass a mob as the first non-source argument
	var/list/triggering_signals

/datum/component/direct_explosive_trap/Initialize(
	mob/living/saboteur,
	explosive_force = EXPLODE_HEAVY,
	expire_time = 1 MINUTES,
	glow_colour = COLOR_RED,
	datum/callback/explosive_checks,
	list/triggering_signals = list(COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BUMPED)
)
	. = ..()
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	src.saboteur = saboteur
	src.explosive_force = explosive_force
	src.glow_colour = glow_colour
	src.explosive_checks = explosive_checks
	src.triggering_signals = triggering_signals

	if (expire_time > 0)
		addtimer(CALLBACK(src, PROC_REF(bomb_expired)), expire_time, TIMER_DELETE_ME)

/datum/component/direct_explosive_trap/RegisterWithParent()
	if (!(COMSIG_ATOM_EXAMINE in triggering_signals)) // Maybe you're being extra mean with this one
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignals(parent, triggering_signals, PROC_REF(explode))
	if (!isnull(saboteur))
		RegisterSignal(saboteur, COMSIG_QDELETING, PROC_REF(on_bomber_deleted))

/datum/component/direct_explosive_trap/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE) + triggering_signals)
	if (!isnull(saboteur))
		UnregisterSignal(saboteur, COMSIG_QDELETING)

/datum/component/direct_explosive_trap/Destroy(force)
	if (isnull(saboteur))
		return ..()
	UnregisterSignal(saboteur, COMSIG_QDELETING)
	saboteur = null
	return ..()

/// Called if we sit too long without going off
/datum/component/direct_explosive_trap/proc/bomb_expired()
	if (!isnull(saboteur))
		to_chat(saboteur, span_bolddanger("Failure! Your trap didn't catch anyone this time..."))
	qdel(src)

/// Let people know something is up
/datum/component/direct_explosive_trap/proc/on_examined(datum/source, mob/user, text)
	SIGNAL_HANDLER
	text += span_holoparasite("It glows with a strange <font color=\"[glow_colour]\">light</font>...")

/// Blow up
/datum/component/direct_explosive_trap/proc/explode(atom/source, mob/living/victim)
	SIGNAL_HANDLER
	if (!isliving(victim))
		return
	if (!isnull(explosive_checks) && !explosive_checks.Invoke(victim))
		return
	to_chat(victim, span_bolddanger("[source] was boobytrapped!"))
	if (!isnull(saboteur))
		to_chat(saboteur, span_bolddanger("Success! Your trap on [source] caught [victim.name]!"))
	playsound(source, 'sound/effects/explosion/explosion2.ogg', 200, TRUE)
	new /obj/effect/temp_visual/explosion(get_turf(source))
	EX_ACT(victim, explosive_force)
	qdel(src)

/// Don't hang a reference to the person who placed the bomb
/datum/component/direct_explosive_trap/proc/on_bomber_deleted()
	SIGNAL_HANDLER
	saboteur = null

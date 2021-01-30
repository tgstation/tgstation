/* Various forms of radioactive structures, like uranium walls and floors
 * do not actively emit radiation, unless interacted with. In which case
 * they then trigger a radiation pulse which then ripples across all
 * adjacent turfs, which may then activate THOSE to pulse and so on.
 */
#define RADIATION_EVENT_COOLDOWN 1.5 SECONDS

/datum/component/radiation_ripple
	/// Strength of radiation pulse when triggered
	var/strength

	COOLDOWN_DECLARE(last_event)
	var/active = FALSE

/datum/component/radiation_ripple/Initialize(signal_or_siglist, strength = 150)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.strength = strength

	RegisterSignal(parent, signal_or_siglist, .proc/trigger)
	RegisterSignal(parent, COMSIG_RADIATION_RIPPLE_TRIGGER, .proc/trigger)

/datum/component/radiation_ripple/proc/trigger()
	if(active || !COOLDOWN_FINISHED(src, last_event))
		return

	active = TRUE
	radiation_pulse(parent, strength)

	for(var/atom/A in orange(1, parent))
		SEND_SIGNAL(A, COMSIG_RADIATION_RIPPLE_TRIGGER)

	COOLDOWN_START(src, last_event, RADIATION_EVENT_COOLDOWN)
	active = FALSE

#undef RADIATION_EVENT_COOLDOWN

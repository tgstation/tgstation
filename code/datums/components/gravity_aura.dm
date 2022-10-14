/// Applies a certain gravity level to all mobs in the area.
/// Mobs are alerted with a balloon alert when entering and exiting the radius.
/datum/component/gravity_aura
	/// The range of which to heal
	var/range

	/// Whether or not you must be a visible object of the parent
	var/requires_visibility = TRUE

	/// The level of gravity exerted by the aura
	var/gravity_strength = 1

	/// A list of targets currently being afflicted.
	var/list/current_alerts = list()

/datum/component/gravity_aura/Initialize(range, requires_visibility = TRUE, gravity_strength = 1)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	START_PROCESSING(SSgravity_aura, src)
	src.range = range
	src.requires_visibility = requires_visibility
	src.gravity_strength = gravity_strength

/datum/component/gravity_aura/Destroy(force, silent)
	STOP_PROCESSING(SSgravity_aura, src)
	for(var/mob/living/alert_holder in current_alerts)
		alert_holder.RemoveElement(/datum/element/forced_gravity, gravity_strength)
		alert_holder.balloon_alert(alert_holder, "Gravity returns to normal...")
	current_alerts.Cut()

	return ..()

/datum/component/gravity_aura/process(delta_time)
	var/list/remove_alerts_from = current_alerts.Copy()
	for (var/mob/living/candidate in (requires_visibility ? view(range, parent) : range(range, parent)))
		remove_alerts_from -= candidate
		if(!(candidate in current_alerts))
			candidate.AddElement(/datum/element/forced_gravity, gravity_strength)
			current_alerts += candidate
			candidate.balloon_alert(candidate, "Gravity suddenly changes!")
	for (var/mob/living/alert_holder in remove_alerts_from)
		alert_holder.RemoveElement(/datum/element/forced_gravity, gravity_strength)
		current_alerts -= alert_holder
		alert_holder.balloon_alert(alert_holder, "Gravity returns to normal...")

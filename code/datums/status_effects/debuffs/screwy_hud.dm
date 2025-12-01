/**
 * Screwy hud status.
 *
 * Applied to carbons, it will make their health bar look like it's incorrect -
 * in crit (SCREWYHUD_CRIT), dead (SCREWYHUD_DEAD), or fully healthy (SCREWYHUD_HEALTHY)
 *
 * Grouped status effect, so multiple sources can add a screwyhud without
 * accidentally removing another source's hud.
 */
/datum/status_effect/grouped/screwy_hud
	id = STATUS_EFFECT_ID_ABSTRACT
	alert_type = null
	/// The priority of this screwyhud over other screwyhuds.
	var/priority = -1
	/// The icon we override our owner's healths.icon_state with
	var/override_icon

/datum/status_effect/grouped/screwy_hud/on_apply()
	if(!iscarbon(owner))
		return FALSE

	RegisterSignal(owner, COMSIG_CARBON_UPDATING_HEALTH_HUD, PROC_REF(on_health_hud_updated))
	owner.update_health_hud()
	return TRUE

/datum/status_effect/grouped/screwy_hud/on_remove()
	UnregisterSignal(owner, COMSIG_CARBON_UPDATING_HEALTH_HUD)
	owner.update_health_hud()

/datum/status_effect/grouped/screwy_hud/proc/on_health_hud_updated(mob/living/carbon/source, shown_health_amount)
	SIGNAL_HANDLER

	// Shouldn't even be running if we're dead, but just in case...
	if(source.stat == DEAD)
		return

	// It's entirely possible we have multiple screwy huds on one mob.
	// Defer to priority to determine which to show. If our's is lower, don't show it.
	for(var/datum/status_effect/grouped/screwy_hud/other_screwy_hud in source.status_effects)
		if(other_screwy_hud.priority > priority)
			return

	source.hud_used.healths.icon_state = override_icon
	return COMPONENT_OVERRIDE_HEALTH_HUD

/datum/status_effect/grouped/screwy_hud/fake_dead
	id = "fake_hud_dead"
	priority = 100 // death is absolute
	override_icon = "health7"

/datum/status_effect/grouped/screwy_hud/fake_crit
	id = "fake_hud_crit"
	priority = 90 // crit is almost death, and death is absolute
	override_icon = "health6"

/datum/status_effect/grouped/screwy_hud/fake_healthy
	id = "fake_hud_healthy"
	priority = 10 // fully healthy is the opposite of death, which is absolute
	override_icon = "health0"

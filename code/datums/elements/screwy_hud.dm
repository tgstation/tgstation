
/**
 * Screwy hud element.
 *
 * Applied to carbons, it will make their health bar look like it's incorrect -
 * in crit (SCREWYHUD_CRIT), dead (SCREWYHUD_DEAD), or fully healthy (SCREWYHUD_HEALTHY)
 */
/datum/element/screwy_hud
	element_flags = ELEMENT_BESPOKE
	/// What type of screwyhud we're imparting on our target
	var/screwy_hud_type

/datum/element/screwy_hud/Attach(datum/target, screwy_hud_type = SCREWYHUD_NONE)
	. = ..()
	if(!iscarbon(target))
		return ELEMENT_INCOMPATIBLE

	src.screwy_hud_type = screwy_hud_type
	RegisterSignal(target, COMSIG_CARBON_UPDATING_HEALTH_HUD, .proc/on_health_hud_updated)

/datum/element/screwy_hud/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_CARBON_UPDATING_HEALTH_HUD)
	return ..()

/datum/element/screwy_hud/proc/on_health_hud_updated(mob/living/carbon/source, shown_health_amount)
	SIGNAL_HANDLER

	if(screwy_hud_type == SCREWYHUD_NONE)
		return

	switch(screwy_hud_type)
		if(SCREWYHUD_CRIT)
			source.hud_used.healths.icon_state = "health6"

		if(SCREWYHUD_DEAD)
			source.hud_used.healths.icon_state = "health7"

		if(SCREWYHUD_HEALTHY)
			source.hud_used.healths.icon_state = "health0"

	return COMPONENT_OVERRIDE_HEALTH_HUD

/// Slowly kills the affected when they're on a planet.
/datum/component/planet_allergy/Initialize(...)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ENTER_AREA, PROC_REF(entered_area))

/datum/component/planet_allergy/proc/entered_area(mob/living/parent, area/new_area)
	SIGNAL_HANDLER

	if(is_on_a_planet(parent) && parent.has_gravity())
		parent.apply_status_effect(/datum/status_effect/planet_allergy) //your gamer body cant stand real gravity < Soul
	else
		parent.remove_status_effect(/datum/status_effect/planet_allergy)

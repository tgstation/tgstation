/// Slowly kills the affected when they're on a planet.
/datum/component/planet_allergy
	/// Status effect applied by this component
	var/datum/status_effect/planet_allergy/allergy

/datum/component/planet_allergy/Initialize(...)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ENTER_AREA, PROC_REF(entered_area))
	entered_area(parent, get_area(parent))

/datum/component/planet_allergy/Destroy(force)
	QDEL_NULL(allergy)
	return ..()

/datum/component/planet_allergy/proc/entered_area(mob/living/parent, area/new_area)
	SIGNAL_HANDLER

	if(is_on_a_planet(parent) && parent.has_gravity())
		allergy = parent.apply_status_effect(/datum/status_effect/planet_allergy) //your gamer body cant stand real gravity < Soul
	else
		QDEL_NULL(allergy)

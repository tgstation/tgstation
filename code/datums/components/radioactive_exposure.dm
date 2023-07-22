/// For directly applying to carbons to irradiate them, without pulses
/datum/component/radioactive_exposure
	dupe_mode = COMPONENT_DUPE_ALLOWED

	/// Base irradiation chance
	var/irradiation_chance_base
	/// Chance we have of applying irradiation
	var/irradiation_chance
	/// The amount the base chance is increased after every failed irradiation check
	var/irradiation_chance_increment
	/// Time till we attempt the next irradiation check
	var/irradiation_interval
	/// The source of irradiation, for logging
	var/source

/datum/component/radioactive_exposure/Initialize(
	minimum_exposure_time,
	irradiation_chance_base,
	irradiation_chance_increment,
	irradiation_interval,
	source
	)

	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	src.irradiation_chance_base = irradiation_chance_base
	src.irradiation_chance = irradiation_chance_base
	src.irradiation_chance_increment = irradiation_chance_increment
	src.irradiation_interval = irradiation_interval
	src.source = source

	// We use generally long times, so it's probably easier and more interpretable to just use a timer instead of processing the component
	addtimer(CALLBACK(src, PROC_REF(attempt_irradiate)), minimum_exposure_time)

	var/mob/living/carbon/human/human_parent = parent
	human_parent.throw_alert(ALERT_RADIOACTIVE_AREA, /atom/movable/screen/alert/radioactive_area)

/// Try and irradiate them. If we chance fail, we come back harder
/datum/component/radioactive_exposure/proc/attempt_irradiate()
	if(!SSradiation.wearing_rad_protected_clothing(parent) && SSradiation.can_irradiate_basic(parent))
		if(prob(irradiation_chance))
			SSradiation.irradiate(parent)
			var/atom/atom = parent
			atom.investigate_log("was irradiated by [source].", INVESTIGATE_RADIATION)
		else
			irradiation_chance += irradiation_chance_increment
	else // we're immune, either through species, clothing, already being irradiated, etcetera
		// we slowly decrease the prob chance untill we hit the base probability again
		irradiation_chance = max(irradiation_chance - irradiation_chance_increment, irradiation_chance_base)

	// Even if they are immune, or got irradiated plan a new check in-case they lose their protection or irradiation
	addtimer(CALLBACK(src, PROC_REF(attempt_irradiate)), irradiation_interval)

/datum/component/radioactive_exposure/Destroy(force, silent)
	var/mob/living/carbon/human/human_parent = parent
	human_parent.clear_alert(ALERT_RADIOACTIVE_AREA)

	return ..()

/atom/movable/screen/alert/radioactive_area
	name = "Radioactive Area"
	desc = "This place is no good! We need to get some protection or get out fast!"
	icon_state = ALERT_RADIOACTIVE_AREA

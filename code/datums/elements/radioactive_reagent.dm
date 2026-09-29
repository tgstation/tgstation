/// Simple element to be applied to reagents
/// When those reagents are exposed to mobs with the bug biotype, causes toxins damage
/// If this delivers the killing blow on a non-humanoid mob, it applies a special status effect that does a funny animation
/datum/element/radioactive_reagent
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// How radioactive is this reagent
	var/rad_power = 1
	/// Modifier for how much touch protection affects irradiation chance.
	var/touch_protection_modifier = 1
	/// Modifier for how much the reagent volume affects irradiation chance.
	var/exposed_volume_modifier = 1

/datum/element/radioactive_reagent/Attach(datum/target, rad_power = 1, touch_protection_modifier = 1, exposed_volume_modifier = 1)
	. = ..()
	if(!istype(target, /datum/reagent))
		return ELEMENT_INCOMPATIBLE

	src.rad_power = rad_power
	src.touch_protection_modifier = touch_protection_modifier
	src.exposed_volume_modifier = exposed_volume_modifier
	RegisterSignal(target, COMSIG_REAGENT_EXPOSE_MOB, PROC_REF(on_mob_expose))
	RegisterSignal(target, COMSIG_REAGENT_EXPOSE_OBJ, PROC_REF(on_obj_expose))
	RegisterSignal(target, COMSIG_REAGENT_ON_LIFE, PROC_REF(on_life))

/datum/element/radioactive_reagent/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_REAGENT_EXPOSE_MOB)
	UnregisterSignal(source, COMSIG_REAGENT_EXPOSE_OBJ)
	UnregisterSignal(source, COMSIG_REAGENT_ON_LIFE)

/datum/element/radioactive_reagent/proc/on_mob_expose(
	datum/reagent/source,
	mob/living/exposed_mob,
	methods = TOUCH,
	reac_volume,
	show_message = TRUE,
	touch_protection = 0,
)
	SIGNAL_HANDLER

	if(!SSradiation.can_irradiate_basic(exposed_mob))
		return

	if(!prob(reac_volume * exposed_volume_modifier))
		return

	// First chance for attacking the organs directly
	if(methods & (VAPOR|INHALE))
		var/obj/item/organ/lungs = exposed_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
		lungs?.make_irradiated()

	if(methods & (INGEST))
		var/obj/item/organ/stomach = exposed_mob.get_organ_slot(ORGAN_SLOT_STOMACH)
		stomach?.make_irradiated()

	if(methods & (INJECT|PATCH))
		var/obj/item/organ/liver = exposed_mob.get_organ_slot(ORGAN_SLOT_LIVER)
		liver?.make_irradiated()

	// Second chance for going through bio armor
	if(prob(100 - (100 * touch_protection * touch_protection_modifier)))
		// Uses can_irradiate_human_basic to check if the mob is wearing protective clothing
		if(SSradiation.can_irradiate_human_basic(exposed_mob))
			exposed_mob.make_irradiated()

/datum/element/radioactive_reagent/proc/on_obj_expose(
	datum/reagent/source,
	obj/exposed_obj,
	reac_volume,
	methods = TOUCH,
	show_message = TRUE,
)
	SIGNAL_HANDLER

	if(!SSradiation.can_irradiate_basic(exposed_obj))
		return

	radiation_pulse(
		source = exposed_obj,
		max_range = 0,
		threshold = RAD_VERY_LIGHT_INSULATION,
		chance = (min(reac_volume * exposed_volume_modifier * rad_power, CALCULATE_RAD_MAX_CHANCE(rad_power))),
	)

/datum/element/radioactive_reagent/proc/on_life(
	datum/reagent/source,
	mob/living/affected_mob,
	seconds_per_tick,
	metabolization_ratio,
)
	SIGNAL_HANDLER

	// Only uses can_irradiate_basic to ignore clothing checks
	if(SPT_PROB(min(source.volume / (20 - rad_power * 5), rad_power), seconds_per_tick) && SSradiation.can_irradiate_basic(affected_mob))
		affected_mob.make_irradiated()

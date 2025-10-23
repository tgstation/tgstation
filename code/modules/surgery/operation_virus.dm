/datum/surgery_operation/basic/viral_bonding
	name = "viral bonding"
	desc = "Force a symbiotic relationship between a patient and a virus it is infected with."
	implements = list(
		TOOL_CAUTERY = 1,
		TOOL_WELDER = 0.5,
		/obj/item = 0.3,
	)
	time = 10 SECONDS
	preop_sound = 'sound/items/handling/surgery/cautery1.ogg'
	success_sound = 'sound/items/handling/surgery/cautery2.ogg'
	operation_flags = OPERATION_MORBID | OPERATION_LOCKED

/datum/surgery_operation/basic/viral_bonding/is_available(mob/living/patient, mob/living/surgeon, obj/item/tool)
	if(get_skin_state(patient) < SURGERY_SKIN_OPEN)
		return FALSE
	if(get_vessel_state(patient) < SURGERY_VESSELS_ORGANS_CUT)
		return FALSE
	if(patient.reagents?.get_reagent_amount(/datum/reagent/medicine/spaceacillin) < 1)
		return FALSE
	if(patient.reagents?.get_reagent_amount(/datum/reagent/consumable/virus_food) < 1)
		return FALSE
	if(patient.reagents?.get_reagent_amount(/datum/reagent/toxin/formaldehyde) < 1)
		return FALSE
	for(var/datum/disease/infected_disease as anything in patient.diseases)
		if(infected_disease.severity != DISEASE_SEVERITY_UNCURABLE)
			return TRUE
	return FALSE

/datum/surgery_operation/basic/viral_bonding/tool_check(obj/item/tool)
	return tool.get_temperature() > 0

/datum/surgery_operation/basic/viral_bonding/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("You start heating [patient]'s bone marrow with [tool]..."),
		span_notice("[surgeon] starts heating [patient]'s bone marrow with [tool]..."),
		span_notice("[surgeon] starts heating something in [patient]'s chest with [tool]..."),
	)
	display_pain(patient, "You feel a searing heat spread through your chest!")

/datum/surgery_operation/basic/viral_bonding/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("[patient]'s bone marrow begins pulsing slowly. The viral bonding is complete."),
		span_notice("[patient]'s bone marrow begins pulsing slowly."),
		span_notice("[surgeon] finishes the operation."),
	)
	display_pain(patient, "You feel a faint throbbing in your chest.")
	for(var/datum/disease/infected_disease as anything in patient.diseases)
		if(infected_disease.severity != DISEASE_SEVERITY_UNCURABLE) //no curing quirks, sweaty
			infected_disease.carrier = TRUE
	return TRUE

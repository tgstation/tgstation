/datum/surgery_operation/basic/viral_bonding
	name = "viral bonding"
	rnd_name = "Viroplasty (Viral Bonding)"
	desc = "Force a symbiotic relationship between a patient and a virus it is infected with."
	rnd_desc = "A surgical procedure that forces a symbiotic relationship between a virus and its host. \
		The patient will be completely immune to the effects of the virus, but will carry and spread it to others."
	implements = list(
		TOOL_CAUTERY = 1,
		TOOL_WELDER = 2,
		/obj/item = 3.33,
	)
	time = 10 SECONDS
	preop_sound = 'sound/items/handling/surgery/cautery1.ogg'
	success_sound = 'sound/items/handling/surgery/cautery2.ogg'
	operation_flags = OPERATION_MORBID | OPERATION_LOCKED | OPERATION_NOTABLE
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT
	var/list/required_chems = list(
		/datum/reagent/medicine/spaceacillin,
		/datum/reagent/consumable/virus_food,
		/datum/reagent/toxin/formaldehyde,
	)

/datum/surgery_operation/basic/viral_bonding/get_any_tool()
	return "Any heat source"

/datum/surgery_operation/basic/viral_bonding/all_required_strings()
	. = ..()
	. += "the patient must have a virus to bond"
	for(var/datum/reagent/chem as anything in required_chems)
		. += "the patient must be dosed with >1u [chem::name]"

/datum/surgery_operation/basic/viral_bonding/get_default_radial_image()
	return image(/obj/item/clothing/mask/surgical)

/datum/surgery_operation/basic/viral_bonding/state_check(mob/living/patient)
	for(var/chem in required_chems)
		if(patient.reagents?.get_reagent_amount(chem) < 1)
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

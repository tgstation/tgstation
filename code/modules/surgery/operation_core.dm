/datum/surgery_operation/basic/core_removal
	name = "remove core"
	desc = "Remove the core from a slime."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_CROWBAR = 1,
	)
	time = 1.6 SECONDS

/datum/surgery_operation/basic/core_removal/show_as_next_step(mob/living/potential_patient, body_zone)
	return ..() && is_available(potential_patient)

/datum/surgery_operation/basic/core_removal/is_available(mob/living/patient, mob/living/surgeon, obj/item/tool)
	return isslime(patient) && patient.stat == DEAD && has_surgery_state(patient, SURGERY_SKIN_OPEN)

/datum/surgery_operation/basic/core_removal/on_preop(mob/living/basic/slime/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("You begin to extract [patient]'s core..."),
		span_notice("[surgeon] begins to extract [patient]'s core."),
		span_notice("[surgeon] begins to extract [patient]'s core."),
	)

/datum/surgery_operation/basic/core_removal/on_success(mob/living/basic/slime/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/core_count = patient.cores
	if(core_count && patient.try_extract_cores(count = core_count))
		display_results(
			surgeon,
			patient,
			span_notice("You successfully extract [core_count] core\s from [patient]."),
			span_notice("[surgeon] successfully extracts [core_count] core\s from [patient]!"),
			span_notice("[surgeon] successfully extracts [core_count] core\s from [patient]!"),
		)
	else
		to_chat(surgeon, span_warning("There aren't any cores left in [patient]!"))

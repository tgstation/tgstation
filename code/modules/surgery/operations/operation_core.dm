/datum/surgery_operation/basic/core_removal
	name = "Извлечение ядра"
	rnd_name = "Коректомия (Извлечение ядра)" // source: i made it up
	desc = "Извлечение ядра из слайма."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_CROWBAR = 1,
	)
	time = 1.6 SECONDS
	operation_flags = OPERATION_IGNORE_CLOTHES | OPERATION_STANDING_ALLOWED
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES
	required_biotype = NONE

/datum/surgery_operation/basic/core_removal/get_default_radial_image()
	return image(/mob/living/basic/slime)

/datum/surgery_operation/basic/core_removal/all_required_strings()
	return list("оперирование умершего слайма") + ..()

/datum/surgery_operation/basic/core_removal/state_check(mob/living/patient)
	return isslime(patient) && patient.stat == DEAD

/datum/surgery_operation/basic/core_removal/on_preop(mob/living/basic/slime/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Вы начинаете извлекать ядро из [patient.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает извлекать ядро из [patient.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает извлекать ядро из [patient.declent_ru(GENITIVE)]."),
	)

/datum/surgery_operation/basic/core_removal/on_success(mob/living/basic/slime/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/core_count = patient.cores
	if(core_count && patient.try_extract_cores(count = core_count))
		display_results(
			surgeon,
			patient,
			span_notice("Вы успешно извлекли [declent_ru(core_count, ACCUSATIVE)] ядро из [patient.declent_ru(GENITIVE)]."),
			span_notice("[surgeon] успешно извлек [declent_ru(core_count, ACCUSATIVE)] ядро из [patient.declent_ru(GENITIVE)]!"),
			span_notice("[surgeon] успешно извлек [declent_ru(core_count, ACCUSATIVE)] ядро из [patient.declent_ru(GENITIVE)]!"),
		)
	else
		to_chat(surgeon, span_warning("Не осталось ни одного ядра в [patient.declent_ru(GENITIVE)]!"))

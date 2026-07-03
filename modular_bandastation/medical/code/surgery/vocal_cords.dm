/datum/surgery_operation/limb/tune_vocal_cords
	name = "Настройка голосовых связок"
	desc = "Проведите операцию на связках пациента для изменения голоса."
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/knife = 2,
		TOOL_WIRECUTTER = 2.85,
		/obj/item/pen = 5,
	)
	time = 6.4 SECONDS
	operation_flags = OPERATION_MORBID | OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN

/datum/surgery_operation/limb/tune_vocal_cords/all_required_strings()
	return list("оперируйте голову") + ..()

/datum/surgery_operation/limb/tune_vocal_cords/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_HEAD

/datum/surgery_operation/limb/tune_vocal_cords/get_default_radial_image()
	return image(/obj/item/scalpel)

/datum/surgery_operation/limb/tune_vocal_cords/on_preop(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/patient = get_patient(operating_on)
	if(!patient)
		return ..()

	display_results(
		surgeon,
		patient,
		span_notice("Вы начинаете настраивать голосовые связки [patient.declent_ru(GENITIVE)]..."),
		span_notice("[capitalize(surgeon.declent_ru(NOMINATIVE))] начинает настраивать голосовые связки [patient.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(surgeon.declent_ru(NOMINATIVE))] начинает выполнять операцию на голосовых связках [patient.declent_ru(GENITIVE)].")
	)

/datum/surgery_operation/limb/tune_vocal_cords/on_success(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/patient = get_patient(operating_on)
	if(!patient)
		return ..()

	display_results(
		surgeon,
		patient,
		span_notice("Вам удалось настроить голосовые связки [patient.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(surgeon.declent_ru(NOMINATIVE))] успешно настраивает голосовые связки [patient.declent_ru(GENITIVE)]!"),
		span_notice("[capitalize(surgeon.declent_ru(NOMINATIVE))] завершает операцию на голосовых связках [patient.declent_ru(GENITIVE)]."),
	)

	patient.change_tts_seed(surgeon, TTS_OVERRIDE_GENDER)
	return ..()

/datum/surgery_operation/limb/tune_vocal_cords/on_failure(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/patient = get_patient(operating_on)
	if(!patient)
		return ..()

	var/obj/item/real_tool = tool
	display_results(
		surgeon,
		patient,
		span_warning("Вы случайно вонзаете [real_tool.declent_ru(ACCUSATIVE)] в горло [patient.declent_ru(GENITIVE)]!"),
		span_warning("[capitalize(surgeon.declent_ru(NOMINATIVE))] случайно вонзает [real_tool.declent_ru(ACCUSATIVE)] в горло [patient.declent_ru(GENITIVE)]!"),
		span_warning("[capitalize(surgeon.declent_ru(NOMINATIVE))] случайно вонзает [real_tool.declent_ru(ACCUSATIVE)] в горло [patient.declent_ru(GENITIVE)]!"),
	)

	display_pain(patient, "Вы чувствуете острую колющую боль в горле!")
	patient.apply_damage(20, BRUTE, BODY_ZONE_HEAD, sharpness = TRUE)

/datum/surgery_operation/limb/filter_blood
	name = "Фильтрация крови"
	rnd_name = "Гемодиализ (Фильтрация крови)"
	desc = "Удаление нежелательных химических веществ из кровотока пациента."
	implements = list(/obj/item/blood_filter = 1)
	time = 2.5 SECONDS
	operation_flags = OPERATION_LOOPING
	required_bodytype = ~BODYTYPE_ROBOTIC
	success_sound = 'sound/machines/card_slide.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/filter_blood/all_required_strings()
	. = list()
	. += "операция на груди"
	. += ..()
	. += "пациент не должен быть хаском"

/datum/surgery_operation/limb/filter_blood/get_default_radial_image()
	return image(/obj/item/blood_filter)

/datum/surgery_operation/limb/filter_blood/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_CHEST && !HAS_TRAIT(limb.owner, TRAIT_HUSK)

/datum/surgery_operation/limb/filter_blood/can_loop(mob/living/patient, obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	return ..() && has_filterable_chems(limb.owner, tool)

/datum/surgery_operation/limb/filter_blood/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_pain(limb.owner, "Вы чувствуете пульсирующую боль в груди!")

/datum/surgery_operation/limb/filter_blood/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	var/obj/item/blood_filter/bloodfilter = tool
	for(var/datum/reagent/chem as anything in limb.owner.reagents?.reagent_list)
		if(!length(bloodfilter.whitelist) || !(chem.type in bloodfilter.whitelist))
			limb.owner.reagents.remove_reagent(chem.type, clamp(round(chem.volume * 0.22, 0.2), 0.4, 10))

	display_results(
		surgeon,
		limb.owner,
		span_notice("[capitalize(tool.declent_ru(ACCUSATIVE))] завершает цикл фильтрации крови у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(tool.declent_ru(ACCUSATIVE))] гудит, фильтруя кровь у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[capitalize(tool.declent_ru(ACCUSATIVE))] гудит, пока работает насос."),
	)

	if(surgeon.is_holding_item_of_type(/obj/item/healthanalyzer))
		chemscan(surgeon, limb.owner)

/datum/surgery_operation/limb/filter_blood/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("Вы ошибаетесь, оставляя синяк на груди у [limb.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] ошибается, оставляя синяк на груди у [limb.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] ошибается!"),
	)
	limb.receive_damage(5, damage_source = tool)

/datum/surgery_operation/limb/filter_blood/proc/has_filterable_chems(mob/living/carbon/target, obj/item/blood_filter/bloodfilter)
	if(!length(target.reagents?.reagent_list))
		bloodfilter.audible_message(span_notice("[capitalize(bloodfilter.declent_ru(ACCUSATIVE))] сигнализирует о том, что в крови у [target.declent_ru(GENITIVE)] не обнаружено химических веществ."))
		playsound(target, 'sound/machines/ping.ogg', 75, TRUE, falloff_exponent = 12, falloff_distance = 1)
		return FALSE

	if(!length(bloodfilter.whitelist))
		return TRUE

	for(var/datum/reagent/chem as anything in target.reagents.reagent_list)
		if(chem.type in bloodfilter.whitelist)
			return TRUE

	return FALSE

/datum/surgery_operation/limb/filter_blood/mechanic
	name = "Продувка гидравлики"
	rnd_name = "Продувка гидравлики (Фильтрация крови)"
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

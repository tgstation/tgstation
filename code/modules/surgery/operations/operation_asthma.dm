/datum/surgery_operation/organ/asthmatic_bypass
	name = "Открытие трахеи с усилием"
	// google says the *actual* operation used to relieve asthma is called bronchial thermoplasty but this operation doesn't resemble that at all
	// local doctors suggested "bronchial dilatation" instead
	rnd_name = "Расширение бронхов (Астматическое шунтирование)"
	desc = "Принудительное расширение трахеи пациента, для облегчения симптомов астмы."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP
	implements = list(
		TOOL_RETRACTOR = 1.25,
		TOOL_WIRECUTTER = 2.25,
	)
	time = 8 SECONDS
	preop_sound = 'sound/items/handling/surgery/retractor1.ogg'
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'
	target_type = /obj/item/organ/lungs
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT
	/// The amount of inflammation a failure or success of this surgery will reduce.
	var/inflammation_reduction = 75

/datum/surgery_operation/organ/asthmatic_bypass/all_required_strings()
	return list("пациент должен быть астматиком") + ..()

/datum/surgery_operation/organ/asthmatic_bypass/state_check(obj/item/organ/organ)
	if(!organ.owner.has_quirk(/datum/quirk/item_quirk/asthma))
		return FALSE
	return TRUE

/datum/surgery_operation/organ/asthmatic_bypass/on_preop(obj/item/organ/lungs/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы начинаете растягивать трахею у [organ.owner.declent_ru(GENITIVE)], изо всех сил стараясь избежать попадания в близлежащие кровеносные сосуды..."),
		span_notice("[surgeon] начинает растягивать трахею у [organ.owner.declent_ru(GENITIVE)], стараясь не задеть близлежащие кровеносные сосуды."),
		span_notice("[surgeon] начинает растягивать трахею у [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Вы чувствуете мучительное растяжение в шее!")

/datum/surgery_operation/organ/asthmatic_bypass/on_success(obj/item/organ/lungs/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/quirk/item_quirk/asthma/asthma = organ.owner.get_quirk(/datum/quirk/item_quirk/asthma)
	if(isnull(asthma))
		return

	asthma.adjust_inflammation(-inflammation_reduction)

	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы растягиваете трахею у [organ.owner.declent_ru(GENITIVE)] с помощью [tool.declent_ru(ACCUSATIVE)], умудряясь не задеть близлежащие кровеносные сосуды."),
		span_notice("[surgeon] успешно растягивает трахею у [organ.owner.declent_ru(GENITIVE)] с помощью [tool.declent_ru(ACCUSATIVE)], избегая попадания в близлежащие кровеносные сосуды."),
		span_notice("[surgeon] заканчивает растягивать трахею у [organ.owner.declent_ru(GENITIVE)].")
	)

/datum/surgery_operation/organ/asthmatic_bypass/on_failure(obj/item/organ/lungs/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/quirk/item_quirk/asthma/asthma = organ.owner.get_quirk(/datum/quirk/item_quirk/asthma)
	if(isnull(asthma))
		return

	asthma.adjust_inflammation(-inflammation_reduction)

	display_results(
		surgeon,
		organ.owner,
		span_warning("Вы растягиваете трахею у [organ.owner.declent_ru(GENITIVE)] с помощью [tool.declent_ru(ACCUSATIVE)], но случайно перерезаете несколько артерий!"),
		span_warning("[surgeon] растягивает трахею у [organ.owner.declent_ru(GENITIVE)] с помощью [tool.declent_ru(ACCUSATIVE)], но случайно пережимает несколько артерий!"),
		span_warning("[surgeon] заканчивает растягивать трахею у [organ.owner.declent_ru(GENITIVE)], но облажался!"),
	)

	organ.owner.losebreath++

	if(prob(30))
		organ.owner.cause_wound_of_type_and_severity(WOUND_SLASH, organ.bodypart_owner, WOUND_SEVERITY_MODERATE, WOUND_SEVERITY_CRITICAL, WOUND_PICK_LOWEST_SEVERITY, tool)
	organ.bodypart_owner.receive_damage(brute = 10, wound_bonus = tool.wound_bonus, sharpness = SHARP_EDGED, damage_source = tool)

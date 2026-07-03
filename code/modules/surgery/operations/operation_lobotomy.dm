/datum/surgery_operation/organ/lobotomy
	name = "Лоботомия"
	rnd_name = "Лоботомия (Лоботомия)"
	desc = "Исправление большинства травм мозга пациента с риском вызвать новые постоянные травмы."
	rnd_desc = "Инвазивная хирургическая процедура, которая гарантирует удаление почти всех травм мозга, но может вызвать другую постоянную травму взамен."
	operation_flags = OPERATION_MORBID | OPERATION_AFFECTS_MOOD | OPERATION_LOCKED | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		TOOL_SCALPEL = 1.15,
		/obj/item/melee/energy/sword = 0.55,
		/obj/item/knife = 2.85,
		/obj/item/shard = 4,
		/obj/item = 5,
	)
	target_type = /obj/item/organ/brain
	required_organ_flag = ORGAN_TYPE_FLAGS & ~ORGAN_ROBOTIC
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/organ/lobotomy/get_any_tool()
	return "Любой острый предмет"

/datum/surgery_operation/organ/lobotomy/tool_check(obj/item/tool)
	// Require edged sharpness OR a tool behavior match
	return ((tool.get_sharpness() & SHARP_EDGED) || implements[tool.tool_behaviour])

/datum/surgery_operation/organ/lobotomy/on_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы начинаете проводить лоботомию мозга [organ.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает проводить лоботомию мозга [organ.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает операцию на мозге [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Ваша голова пульсирует от невообразимой боли!")

/datum/surgery_operation/organ/lobotomy/on_success(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Вы успешно провели лоботомию [organ.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] успешно проводит лоботомию [organ.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] завершает операцию на мозге [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Ваша голова на мгновение полностью немеет, боль просто невыносима!")

	organ.cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)
	if (organ.owner)
		organ.owner.mind?.remove_antag_datum(/datum/antagonist/brainwashed)
	else if (organ.brainmob)
		organ.brainmob.mind?.remove_antag_datum(/datum/antagonist/brainwashed)

	if(!prob(75))
		return

	switch(rand(1, 3))//Now let's see what hopefully-not-important part of the brain we cut off
		if(1)
			organ.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_MAGIC)
		if(2)
			if(HAS_TRAIT(organ, TRAIT_SPECIAL_TRAUMA_BOOST) && prob(50))
				organ.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)
			else
				organ.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_MAGIC)
		if(3)
			organ.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)

/datum/surgery_operation/organ/lobotomy/on_failure(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_warning("Вы удалили не ту часть, нанеся еще больше повреждений!"),
		span_notice("[surgeon] безуспешно пытается провести лоботомию [organ.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] завершает операцию на мозге [organ.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(organ.owner, "Боль в вашей голове, кажется, только усиливается!")
	organ.apply_organ_damage(80)
	switch(rand(1, 3))
		if(1)
			organ.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_MAGIC)
		if(2)
			if(HAS_TRAIT(organ, TRAIT_SPECIAL_TRAUMA_BOOST) && prob(50))
				organ.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)
			else
				organ.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_MAGIC)
		if(3)
			organ.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)

/datum/surgery_operation/organ/lobotomy/mechanic
	name = "Проведение нейронной дефрагментации"
	rnd_name = "WetWire ОС деструктивная дефрагментация (Лоботомия)"
	implements = list(
		TOOL_MULTITOOL = 1.15,
		/obj/item/melee/energy/sword = 1.85,
		/obj/item/knife = 2.85,
		/obj/item/shard = 4,
		/obj/item = 5,
	)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

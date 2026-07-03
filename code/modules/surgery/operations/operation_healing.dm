/// Allow brute healing operation
#define BRUTE_SURGERY (1<<0)
/// Allow burn healing operation
#define BURN_SURGERY (1<<1)
/// Allow combo healing operation
#define COMBO_SURGERY (1<<2)

/datum/surgery_operation/basic/tend_wounds
	name = "Обработка ран"
	rnd_name = "Обработка ран"
	desc = "Проведите поверхностный уход за ушибами и ожогами пациента."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_SCREWDRIVER = 1.5,
		TOOL_WIRECUTTER = 1.67,
		/obj/item/pen = 1.8,
	)
	time = 2.5 SECONDS
	operation_flags = OPERATION_LOOPING | OPERATION_IGNORE_CLOTHES
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	required_biotype = MOB_ORGANIC|MOB_HUMANOID
	required_bodytype = NONE
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES
	replaced_by = /datum/surgery_operation/basic/tend_wounds/upgraded
	/// Radial slice datums for every healing option we can provide
	VAR_PRIVATE/list/cached_healing_options
	/// Bitflag of which healing types this operation can perform
	var/can_heal = BRUTE_SURGERY | BURN_SURGERY
	/// Flat amount of healing done per operation
	var/healing_amount = 5
	/// The amount of damage healed scales based on how much damage the patient has times this multiplier
	var/healing_multiplier = 0.07

/datum/surgery_operation/basic/tend_wounds/all_required_strings()
	return ..() + list("у пациента должны быть ушибы или ожоги")

/datum/surgery_operation/basic/tend_wounds/state_check(mob/living/patient)
	return patient.get_brute_loss() > 0 || patient.get_fire_loss() > 0

/datum/surgery_operation/basic/tend_wounds/get_default_radial_image()
	return image(/obj/item/storage/medkit)

/datum/surgery_operation/basic/tend_wounds/get_radial_options(mob/living/patient, obj/item/tool, operating_zone)
	var/list/options = list()

	if(can_heal & COMBO_SURGERY)
		var/datum/radial_menu_choice/all_healing = LAZYACCESS(cached_healing_options, "[COMBO_SURGERY]")
		if(!all_healing)
			all_healing = new()
			all_healing.image = image(/obj/item/storage/medkit/advanced)
			all_healing.name = "Обработайте ушибы и ожоги"
			all_healing.info = "Вылечите поверхностные ушибы, порезы и ожоги пациента."
			LAZYSET(cached_healing_options, "[COMBO_SURGERY]", all_healing)

		options[all_healing] = list(
			"[OPERATION_ACTION]" = "heal",
			"[OPERATION_BRUTE_HEAL]" = healing_amount,
			"[OPERATION_BURN_HEAL]" = healing_amount,
			"[OPERATION_BRUTE_MULTIPLIER]" = healing_multiplier,
			"[OPERATION_BURN_MULTIPLIER]" = healing_multiplier,
		)

	if((can_heal & BRUTE_SURGERY) && patient.get_brute_loss() > 0)
		var/datum/radial_menu_choice/brute_healing = LAZYACCESS(cached_healing_options, "[BRUTE_SURGERY]")
		if(!brute_healing)
			brute_healing = new()
			brute_healing.image = image(/obj/item/storage/medkit/brute)
			brute_healing.name = "Обработка ушибов"
			brute_healing.info = "Вылечите поверхностные ушибы и порезы пациента."
			LAZYSET(cached_healing_options, "[BRUTE_SURGERY]", brute_healing)

		options[brute_healing] = list(
			"[OPERATION_ACTION]" = "heal",
			"[OPERATION_BRUTE_HEAL]" = healing_amount,
			"[OPERATION_BRUTE_MULTIPLIER]" = healing_multiplier,
		)

	if((can_heal & BURN_SURGERY) && patient.get_fire_loss() > 0)
		var/datum/radial_menu_choice/burn_healing = LAZYACCESS(cached_healing_options, "[BURN_SURGERY]")
		if(!burn_healing)
			burn_healing = new()
			burn_healing.image = image(/obj/item/storage/medkit/fire)
			burn_healing.name = "Обработка ожогов"
			burn_healing.info = "Вылечите поверхностные ожоги пациента."
			LAZYSET(cached_healing_options, "[BURN_SURGERY]", burn_healing)

		options[burn_healing] = list(
			"[OPERATION_ACTION]" = "heal",
			"[OPERATION_BURN_HEAL]" = healing_amount,
			"[OPERATION_BURN_MULTIPLIER]" = healing_multiplier,
		)

	return options

/datum/surgery_operation/basic/tend_wounds/can_loop(mob/living/patient, mob/living/operating_on, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	if(!.)
		return FALSE
	var/brute_heal = operation_args[OPERATION_BRUTE_HEAL] > 0
	var/burn_heal = operation_args[OPERATION_BURN_HEAL] > 0
	if(brute_heal && burn_heal)
		return patient.get_brute_loss() > 0 || patient.get_fire_loss() > 0
	else if(brute_heal)
		return patient.get_brute_loss() > 0
	else if(burn_heal)
		return patient.get_fire_loss() > 0
	return FALSE

/datum/surgery_operation/basic/tend_wounds/on_preop(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	var/woundtype
	var/brute_heal = operation_args[OPERATION_BRUTE_HEAL] > 0
	var/burn_heal = operation_args[OPERATION_BURN_HEAL] > 0
	if(brute_heal && burn_heal)
		woundtype = "раны"
	else if(brute_heal)
		woundtype = "ушибы"
	else //why are you trying to 0,0...?
		woundtype = "ожоги"
	display_results(
		surgeon,
		patient,
		span_notice("Вы пытаетесь наложить швы на [woundtype] у [patient.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] пытается наложить швы на [woundtype] у [patient.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] пытается наложить швы на [woundtype] у [patient.declent_ru(GENITIVE)]."),
	)
	display_pain(patient, "Ваши [woundtype] адски болят!")

#define CONDITIONAL_DAMAGE_MESSAGE(brute, burn, combo_msg, brute_msg, burn_msg) "[(brute > 0 && burn > 0) ? combo_msg : (brute > 0 ? brute_msg : burn_msg)]"

/// Returns a string letting the surgeon know roughly how much longer the surgery is estimated to take at the going rate
/datum/surgery_operation/basic/tend_wounds/proc/get_progress(mob/living/surgeon, mob/living/patient, brute_healed, burn_healed)
	var/estimated_remaining_steps = 0
	if(brute_healed > 0)
		estimated_remaining_steps = max(0, (patient.get_brute_loss() / brute_healed))
	if(burn_healed > 0)
		estimated_remaining_steps = max(estimated_remaining_steps, (patient.get_fire_loss() / burn_healed)) // whichever is higher between brute or burn steps

	var/progress_text

	if(show_stats(surgeon, patient))
		if(brute_healed > 0 && patient.get_brute_loss() > 0)
			progress_text += ". Оставшиеся раны: <font color='#ff3333'>[patient.get_brute_loss()]</font>"
		if(burn_healed > 0 && patient.get_fire_loss() > 0)
			progress_text += ". Оставшиеся ожоги: <font color='#ff9933'>[patient.get_fire_loss()]</font>"
		return progress_text

	switch(estimated_remaining_steps)
		if(-INFINITY to 1)
			return
		if(1 to 3)
			progress_text += ", заканчиваю работу над последними [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "признаками повреждения", "ссадинами", "ожогами")]"
		if(3 to 6)
			progress_text += ", считаю последние [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "очаги повреждений", "гематомы", "ожоговые пузыри")]"
		if(6 to 9)
			progress_text += ", продолжаю методично обрабатывать [patient.ru_p_them()] обширные [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "травмы", "разрывы", "ожоги")]"
		if(9 to 12)
			progress_text += ", настраиваясь на долгую операцию впереди"
		if(12 to 15)
			progress_text += ", хотя всё ещё больше напоминает [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "мясное пюре", "говяжий фарш", "обугленный стейк")], чем на человека"
		if(15 to INFINITY)
			progress_text += ", хотя кажется, будто ваши усилия почти не сокращают объём [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "искореженного", "размозжённого", "обугленного")] тела"

	return progress_text

/// Checks whether we show precise damage stats during the surgery
/datum/surgery_operation/basic/tend_wounds/proc/show_stats(mob/living/surgeon, mob/living/patient)
	if(surgeon.is_holding_item_of_type(/obj/item/healthanalyzer))
		return TRUE
	for(var/obj/machinery/vitals_reader/vitals in view(4, patient))
		if(vitals.patient == patient)
			return TRUE
	for(var/obj/machinery/computer/operating/op_pc in range(1, patient))
		if(op_pc.table?.patient == patient)
			return TRUE
	for(var/obj/item/mod/control/modsuit in surgeon.get_equipped_items())
		if(modsuit.active && istype(modsuit.selected_module, /obj/item/mod/module/health_analyzer))
			return TRUE
	return FALSE

#undef CONDITIONAL_DAMAGE_MESSAGE

/datum/surgery_operation/basic/tend_wounds/on_success(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	var/user_msg = "Вам удается залечить некоторые раны [patient.declent_ru(GENITIVE)]" //no period, add initial space to "addons"
	var/target_msg = "[surgeon] залечивает некоторые раны [patient.declent_ru(GENITIVE)]" //see above

	var/brute_healed = operation_args[OPERATION_BRUTE_HEAL]
	var/burn_healed = operation_args[OPERATION_BURN_HEAL]

	var/dead_multiplier = patient.stat == DEAD ? 0.2 : 1.0
	var/accessibility_modifier = 1.0
	if(!patient.is_location_accessible(BODY_ZONE_CHEST, IGNORED_OPERATION_CLOTHING_SLOTS))
		accessibility_modifier = 0.55
		user_msg += " насколько это возможно, пока [patient.ru_p_they()] [patient.ru_p_have()] на себе одежду"
		target_msg += " насколько это возможно, пока [patient.ru_p_they()] [patient.ru_p_have()] на себе одежду"

	var/brute_multiplier = operation_args[OPERATION_BRUTE_MULTIPLIER] * dead_multiplier * accessibility_modifier
	var/burn_multiplier = operation_args[OPERATION_BURN_MULTIPLIER] * dead_multiplier * accessibility_modifier

	brute_healed += round(patient.get_brute_loss() * brute_multiplier, DAMAGE_PRECISION)
	burn_healed += round(patient.get_fire_loss() * burn_multiplier, DAMAGE_PRECISION)

	patient.heal_bodypart_damage(brute_healed, burn_healed)

	user_msg += get_progress(surgeon, patient, brute_healed, burn_healed)

	if(HAS_MIND_TRAIT(surgeon, TRAIT_MORBID) && patient.stat != DEAD) //Morbid folk don't care about tending the dead as much as tending the living
		surgeon.add_mood_event("morbid_tend_wounds", /datum/mood_event/morbid_tend_wounds)

	display_results(
		surgeon,
		patient,
		span_notice("[user_msg]."),
		span_notice("[target_msg]."),
		span_notice("[target_msg]."),
	)

/datum/surgery_operation/basic/tend_wounds/on_failure(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_warning("Вы ошибаетесь!"),
		span_warning("[surgeon] ошибается!"),
		span_notice("[surgeon] залечивает некоторые раны [patient.declent_ru(GENITIVE)]."),
		target_detailed = TRUE,
	)
	var/brute_dealt = operation_args[OPERATION_BRUTE_HEAL] * 0.8
	var/burn_dealt = operation_args[OPERATION_BURN_HEAL] * 0.8
	var/brute_multiplier = operation_args[OPERATION_BRUTE_MULTIPLIER] * 0.5
	var/burn_multiplier = operation_args[OPERATION_BURN_MULTIPLIER] * 0.5

	brute_dealt += round(patient.get_brute_loss() * brute_multiplier, 0.1)
	burn_dealt += round(patient.get_fire_loss() * burn_multiplier, 0.1)

	patient.take_bodypart_damage(brute_dealt, burn_dealt, wound_bonus = CANT_WOUND)

/datum/surgery_operation/basic/tend_wounds/upgraded
	rnd_name = parent_type::rnd_name + "+"
	operation_flags = parent_type::operation_flags | OPERATION_LOCKED
	replaced_by = /datum/surgery_operation/basic/tend_wounds/upgraded/master
	healing_multiplier = 0.1

/datum/surgery_operation/basic/tend_wounds/upgraded/master
	rnd_name = parent_type::rnd_name + "+"
	replaced_by = /datum/surgery_operation/basic/tend_wounds/combo/upgraded/master
	healing_multiplier = 0.2

/datum/surgery_operation/basic/tend_wounds/combo
	rnd_name = "Улучшенная обработка ран"
	operation_flags = parent_type::operation_flags | OPERATION_LOCKED
	replaced_by = /datum/surgery_operation/basic/tend_wounds/combo/upgraded
	can_heal = COMBO_SURGERY
	healing_amount = 3
	time = 1 SECONDS

/datum/surgery_operation/basic/tend_wounds/combo/upgraded
	rnd_name = parent_type::rnd_name + "+"
	operation_flags = parent_type::operation_flags | OPERATION_LOCKED
	replaced_by = /datum/surgery_operation/basic/tend_wounds/combo/upgraded/master
	healing_multiplier = 0.1

/datum/surgery_operation/basic/tend_wounds/combo/upgraded/master
	rnd_name = parent_type::rnd_name + "+"
	healing_amount = 1
	healing_multiplier = 0.4

#undef BRUTE_SURGERY
#undef BURN_SURGERY
#undef COMBO_SURGERY

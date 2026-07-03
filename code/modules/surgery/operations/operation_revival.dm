/datum/surgery_operation/basic/revival
	name = "Дефибрилляция мозга"
	rnd_name = "Дефибриляция мозга (Оживление)"
	desc = "Использование дефибриллятора, чтобы вернуть мозг пациента к жизни."
	implements = list(
		/obj/item/shockpaddles = 1,
		/obj/item/melee/touch_attack/shock = 1,
		/obj/item/melee/baton/security = 1.33,
		/obj/item/gun/energy = 1.67,
	)
	operation_flags = OPERATION_MORBID | OPERATION_NOTABLE
	time = 5 SECONDS
	preop_sound = list(
		/obj/item/shockpaddles = 'sound/machines/defib/defib_charge.ogg',
		/obj/item = null,
	)
	success_sound = 'sound/machines/defib/defib_zap.ogg'
	required_biotype = NONE
	target_zone = BODY_ZONE_HEAD
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED

/datum/surgery_operation/basic/revival/get_default_radial_image()
	return image(/obj/item/shockpaddles)

/datum/surgery_operation/basic/revival/all_required_strings()
	return ..() + list("пациент должен быть мёртв", "пациент должен быть в состоянии, пригодном для реанимации")

/datum/surgery_operation/basic/revival/state_check(mob/living/patient)
	if(patient.stat != DEAD)
		return FALSE
	if(HAS_TRAIT(patient, TRAIT_SUICIDED) || HAS_TRAIT(patient, TRAIT_HUSK) || HAS_TRAIT(patient, TRAIT_DEFIB_BLACKLISTED))
		return FALSE
	if(patient.has_limbs)
		var/obj/item/organ/brain/brain = patient.get_organ_slot(ORGAN_SLOT_BRAIN)
		return !isnull(brain) && brain_check(brain)
	return mob_check(patient)

/datum/surgery_operation/basic/revival/proc/brain_check(obj/item/organ/brain/brain)
	return !IS_ROBOTIC_ORGAN(brain)

/datum/surgery_operation/basic/revival/proc/mob_check(mob/living/patient)
	return !(patient.mob_biotypes & MOB_ROBOTIC)

/datum/surgery_operation/basic/revival/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/shockpaddles))
		var/obj/item/shockpaddles/paddles = tool
		if((paddles.req_defib && !paddles.defib.powered) || !HAS_TRAIT(paddles, TRAIT_WIELDED) || paddles.cooldown || paddles.busy)
			return FALSE

	if(istype(tool, /obj/item/melee/baton/security))
		var/obj/item/melee/baton/security/baton = tool
		return baton.active

	if(istype(tool, /obj/item/gun/energy))
		var/obj/item/gun/energy/egun = tool
		return istype(egun.chambered, /obj/item/ammo_casing/energy/electrode)

	return TRUE

/datum/surgery_operation/basic/revival/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Вы готовитесь дать мозгу [patient] искру жизни с помощью [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("[surgeon] готовится дать мозгу [patient] искру жизни с помощью [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("[surgeon] готовится дать мозгу [patient] искру жизни."),
	)
	patient.notify_revival("Кто‑то пытается дать разряд вашему мозгу.", source = patient)

/datum/surgery_operation/basic/revival/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Вам удаётся успешно ударить мозг [patient] разрядом с помощью [tool.declent_ru(ACCUSATIVE)]..."),
		span_notice("[surgeon] посылает мощный разряд в мозг [patient] с помощью [tool.declent_ru(ACCUSATIVE)]..."),
		span_notice("[surgeon] посылает мощный разряд в мозг [patient]..."),
	)
	patient.grab_ghost()
	patient.adjust_oxy_loss(-50)
	if(iscarbon(patient))
		var/mob/living/carbon/carbon_patient = patient
		carbon_patient.set_heartattack(FALSE)
	if(!patient.revive())
		on_no_revive(surgeon, patient)
		return

	on_revived(surgeon, patient)

/// Called when you have been successfully raised from the dead
/datum/surgery_operation/basic/revival/proc/on_revived(mob/living/surgeon, mob/living/patient)
	patient.visible_message(span_notice("...[patient] приходит в себя - живой и в сознании!"))
	patient.emote("gasp")
	if(HAS_MIND_TRAIT(surgeon, TRAIT_MORBID)) // Contrary to their typical hatred of resurrection, it wouldn't be very thematic if morbid people didn't love playing god
		surgeon.add_mood_event("morbid_revival_success", /datum/mood_event/morbid_revival_success)
	patient.adjust_organ_loss(ORGAN_SLOT_BRAIN, 15, 180)

/// Called when revival fails
/datum/surgery_operation/basic/revival/proc/on_no_revive(mob/living/surgeon, mob/living/patient)
	patient.visible_message(span_warning("...[patient.p_they()] дёргает [patient.p_s()] в конвульсиях и замирает [patient.p_s()]."))
	patient.adjust_organ_loss(ORGAN_SLOT_BRAIN, 50, 199) // MAD SCIENCE

/datum/surgery_operation/basic/revival/on_failure(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_warning("Вы бьёте мозг [patient] разрядом с помощью [tool.declent_ru(ACCUSATIVE)], но [patient.p_they()] никак не реагирует[patient.p_s()]."),
		span_warning("[surgeon] бьёт мозг [patient] разрядом с помощью [tool.declent_ru(ACCUSATIVE)], но [patient.p_they()] никак не реагирует[patient.p_s()]."),
		span_warning("[surgeon] бьёт мозг [patient] разрядом с помощью [tool.declent_ru(ACCUSATIVE)], но [patient.p_they()] никак не реагирует[patient.p_s()]."),
	)

/datum/surgery_operation/basic/revival/mechanic
	name = "Полная перезагрузка системы"
	required_biotype = MOB_ROBOTIC

/datum/surgery_operation/basic/revival/mechanic/brain_check(obj/item/organ/brain/brain)
	return !..()

/datum/surgery_operation/basic/revival/mechanic/mob_check(mob/living/patient)
	return !..()

#define OPERATION_NEW_NAME "chosen_name"

/datum/surgery_operation/limb/plastic_surgery
	name = "Пластическая операция"
	desc = "Изменение формы или восстановление лица пациента в косметических или функциональных целях."
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/knife = 2,
		TOOL_WIRECUTTER = 2.85,
		/obj/item/pen = 5,
	)
	time = 6.4 SECONDS
	operation_flags = OPERATION_MORBID | OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN

/datum/surgery_operation/limb/plastic_surgery/all_required_strings()
	return list("оперируйте голову") + ..()

/datum/surgery_operation/limb/plastic_surgery/get_default_radial_image()
	return image(/obj/item/scalpel)

/datum/surgery_operation/limb/plastic_surgery/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_HEAD

/datum/surgery_operation/limb/plastic_surgery/pre_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(HAS_TRAIT_FROM(limb, TRAIT_DISFIGURED, TRAIT_GENERIC))
		return TRUE //skip name selection if fixing disfigurement

	var/list/names = list()
	if(isabductor(surgeon))
		for(var/j in 1 to 9)
			names += "Объект [limb.owner.gender == MALE ? "i" : "o"]-[pick("a", "b", "c", "d", "e")]-[rand(10000, 99999)]"

		if(limb.owner)
			names += limb.owner.generate_random_mob_name(TRUE) //give one normal name in case they want to do regular plastic surgery
		else
			names += generate_random_name_species_based(pick(MALE, FEMALE), TRUE, GLOB.species_list[limb.limb_id] || /datum/species/human)
	else
		var/advanced = LIMB_HAS_SURGERY_STATE(limb, SURGERY_PLASTIC_APPLIED)
		var/obj/item/offhand = surgeon.get_inactive_held_item()
		if(istype(offhand, /obj/item/photo) && advanced)
			var/obj/item/photo/disguises = offhand
			for(var/namelist in disguises.picture?.names_seen)
				names += namelist
		else
			if(advanced)
				to_chat(surgeon, span_warning("У вас нет фотографии, на которой можно основывать внешний вид!"))

			for(var/i in 1 to 10)
				if(limb.owner)
					names += limb.owner.generate_random_mob_name(TRUE)
				else
					names += generate_random_name_species_based(pick(MALE, FEMALE), TRUE, GLOB.species_list[limb.limb_id] || /datum/species/human)

	operation_args[OPERATION_NEW_NAME] = tgui_input_list(surgeon, "Выберите новое имя", "Пластическая операция", names)
	return !!operation_args[OPERATION_NEW_NAME]

/datum/surgery_operation/limb/plastic_surgery/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете изменять внешность у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает изменять внешность у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает делать разрез на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете режущую боль по всему лицу!")

/datum/surgery_operation/limb/plastic_surgery/on_success(obj/item/bodypart/head/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(!istype(limb))
		CRASH("Plastic surgery finished on a non-head limb [limb]!")

	if(HAS_TRAIT_FROM(limb, TRAIT_DISFIGURED, TRAIT_GENERIC))
		REMOVE_TRAIT(limb, TRAIT_DISFIGURED, TRAIT_GENERIC)
		display_results(
			surgeon,
			limb.owner,
			span_notice("Вы успешно восстанавливаете внешность у [limb.owner.declent_ru(GENITIVE)]."),
			span_notice("[surgeon] успешно восстанавливает внешность у [limb.owner.declent_ru(GENITIVE)]!"),
			span_notice("[surgeon] заканчивает операцию на лице у [limb.owner.declent_ru(GENITIVE)]."),
		)
		display_pain(limb.owner, "Боль утихает, ваше лицо снова кажется нормальным!")
		return

	var/oldname = limb.owner?.real_name || limb.real_name
	if (limb.owner)
		limb.owner.real_name = operation_args[OPERATION_NEW_NAME]
	else
		limb.real_name = operation_args[OPERATION_NEW_NAME]

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы полностью изменили внешность [oldname], теперь это [operation_args[OPERATION_NEW_NAME]]."),
		span_notice("[surgeon] полностью изменил внешность [oldname], теперь это [operation_args[OPERATION_NEW_NAME]]!"),
		span_notice("[surgeon] заканчивает операцию на лице у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Боль утихает, ваше лицо кажется новым и незнакомым!")
	if(ishuman(limb.owner))
		var/mob/living/carbon/human/human_target = limb.owner
		human_target.update_ID_card()
	if(HAS_MIND_TRAIT(surgeon, TRAIT_MORBID))
		surgeon.add_mood_event("morbid_abominable_surgery_success", /datum/mood_event/morbid_abominable_surgery_success)
	limb.remove_surgical_state(SURGERY_PLASTIC_APPLIED)

/datum/surgery_operation/limb/plastic_surgery/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("Вы совершили ошибку, изуродовав внешность у [limb.owner.declent_ru(GENITIVE)]!"),
		span_warning("[surgeon] совершил ошибку, изуродовав внешность у [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] заканчивает операцию на лице у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Ваше лицо кажется ужасно изуродованным и деформированным!")
	ADD_TRAIT(limb.owner, TRAIT_DISFIGURED, TRAIT_GENERIC)

#undef OPERATION_NEW_NAME

/datum/surgery_operation/limb/add_plastic
	name = "Наложение пластика"
	desc = "Наложение пластика на лицо пациента для обеспечения больших возможностей настройки при последующей пластической операции."
	implements = list(
		/obj/item/stack/sheet/plastic = 1,
	)
	time = 4.8 SECONDS
	operation_flags = OPERATION_MORBID | OPERATION_LOCKED | OPERATION_NO_PATIENT_REQUIRED
	preop_sound = 'sound/effects/blob/blobattack.ogg'
	success_sound = 'sound/effects/blob/attackblob.ogg'
	failure_sound = 'sound/effects/blob/blobattack.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_PLASTIC_APPLIED|SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/add_plastic/get_default_radial_image()
	return image(/obj/item/stack/sheet/plastic)

/datum/surgery_operation/limb/add_plastic/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_HEAD

/datum/surgery_operation/limb/add_plastic/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете накладывать пластик на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает накладывать пластик на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает проводить операцию на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете странное ощущение, когда к вашему лицу что-то прикасается!")

/datum/surgery_operation/limb/add_plastic/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_PLASTIC_APPLIED)

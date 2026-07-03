/datum/surgery_operation/limb/add_dental_implant
	name = "add dental implant"
	desc = "Имплантация таблетки в зубы пациента."
	operation_flags = OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		/obj/item/reagent_containers/applicator/pill = 1,
	)
	time = 1.6 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_DRILLED
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/add_dental_implant/all_required_strings()
	. = list()
	. += "операция на рту"
	. += ..()
	. += "во рту должны быть зубы"

/datum/surgery_operation/limb/add_dental_implant/get_default_radial_image()
	return image('icons/hud/implants.dmi', "reagents")

/datum/surgery_operation/limb/add_dental_implant/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	return ..() && surgeon.canUnEquip(tool) && operated_zone == BODY_ZONE_PRECISE_MOUTH

/datum/surgery_operation/limb/add_dental_implant/state_check(obj/item/bodypart/head/limb)
	var/obj/item/bodypart/head/teeth_receptangle = limb
	if(!istype(teeth_receptangle))
		return FALSE
	if(teeth_receptangle.teeth_count <= 0)
		return FALSE
	var/count = 0
	for(var/obj/item/reagent_containers/applicator/pill/dental in limb)
		count++
	if(count >= teeth_receptangle.teeth_count)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/add_dental_implant/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете вставлять [tool.declent_ru(ACCUSATIVE)] в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает вставлять [tool.declent_ru(ACCUSATIVE)] в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает что-то вставлять в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Что-то засовывают вам в [limb.ru_plaintext_zone[PREPOSITIONAL]]!")

/datum/surgery_operation/limb/add_dental_implant/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	// Pills go into head
	surgeon.transferItemToLoc(tool, limb, TRUE)

	var/datum/action/item_action/activate_pill/pill_action = new(tool)
	pill_action.name = "Активировать [declent_ru(tool.name, NOMINATIVE)]"
	pill_action.build_all_button_icons()
	pill_action.Grant(limb.owner) //The pill never actually goes in an inventory slot, so the owner doesn't inherit actions from it

	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы запихиваете [tool.declent_ru(ACCUSATIVE)] в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] запихивает [tool.declent_ru(ACCUSATIVE)] в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] запихивает что-то в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]!"),
	)

/datum/surgery_operation/limb/remove_dental_implant
	name = "Удаление зубного импланта"
	desc = "Удаление зубного имплантата из зубов пациента."
	operation_flags = OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		TOOL_HEMOSTAT = 1,
		IMPLEMENT_HAND = 1,
	)
	time = 3.2 SECONDS
	all_surgery_states_required = SURGERY_BONE_DRILLED|SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/remove_dental_implant/get_default_radial_image()
	return image(/obj/item/reagent_containers/applicator/pill)

/datum/surgery_operation/limb/remove_dental_implant/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	return ..() && operated_zone == BODY_ZONE_PRECISE_MOUTH

/datum/surgery_operation/limb/remove_dental_implant/get_time_modifiers(atom/movable/operating_on, mob/living/surgeon, tool)
	. = ..()
	for(var/obj/item/flashlight/light in surgeon)
		if(light.light_on) // Hey I can see a better!
			. *= 0.8

/datum/surgery_operation/limb/remove_dental_implant/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете искать во рту у [limb.owner.declent_ru(GENITIVE)] зубные импланты..."),
		span_notice("[surgeon] начинает заглядывать в рот [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает осматривать зубы [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете, как пальцы ощупывают ваши зубы.")

/datum/surgery_operation/limb/remove_dental_implant/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/list/pills = list()
	for(var/obj/item/reagent_containers/applicator/pill/dental in limb)
		pills += dental
	if(!length(pills))
		display_results(
			surgeon,
			limb.owner,
			span_notice("Вы не нашли никаких зубных имплантатов в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
			span_notice("[surgeon] не нашел никаких зубных имплантатов в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
			span_notice("[surgeon] заканчивает изучение [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		)
		return

	var/obj/item/reagent_containers/applicator/pill/yoinked = pick(pills)
	for(var/datum/action/item_action/activate_pill/associated_action in limb.owner.actions)
		if(associated_action.target == yoinked)
			qdel(associated_action)

	surgeon.put_in_hands(yoinked)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы аккуратно извлекаете [yoinked.declent_ru(ACCUSATIVE)] из [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] аккуратно извлекает [yoinked.declent_ru(ACCUSATIVE)] из [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] аккуратно извлекает что-то из [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)

// Teeth pill code
/datum/action/item_action/activate_pill
	name = "Активация таблетки"
	check_flags = NONE

/datum/action/item_action/activate_pill/IsAvailable(feedback)
	if(owner.stat > SOFT_CRIT)
		return FALSE
	return ..()

/datum/action/item_action/activate_pill/do_effect(trigger_flags)
	owner.balloon_alert_to_viewers("[owner] скрипит зубами!", "вы стискиваете зубы")
	if(!do_after(owner, owner.stat * (2.5 SECONDS), owner,  IGNORE_USER_LOC_CHANGE | IGNORE_INCAPACITATED))
		return FALSE
	var/obj/item/pill = target
	to_chat(owner, span_notice("Вы стискиваете зубы и раздавливаете имплантированную [declent_ru(pill.name, ACCUSATIVE)]!"))
	owner.log_message("swallowed an implanted pill, [pill]", LOG_ATTACK)
	pill.reagents.trans_to(owner, pill.reagents.total_volume, transferred_by = owner, methods = INGEST)
	qdel(pill)
	return TRUE

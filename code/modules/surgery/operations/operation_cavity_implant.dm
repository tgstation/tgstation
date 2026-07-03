/datum/surgery_operation/limb/prepare_cavity
	name = "Расширение грудной полости"
	desc = "Расширение грудной полости пациента для имплантирования больших вещей."
	implements = list(
		TOOL_RETRACTOR = 1,
		TOOL_CROWBAR = 1.5,
	)
	time = 4.8 SECONDS
	preop_sound = 'sound/items/handling/surgery/retractor1.ogg'
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT
	any_surgery_states_blocked = SURGERY_CAVITY_WIDENED

/datum/surgery_operation/limb/prepare_cavity/get_default_radial_image()
	return image(/obj/item/retractor)

/datum/surgery_operation/limb/prepare_cavity/all_required_strings()
	return list("операция на груди") + ..()

/datum/surgery_operation/limb/prepare_cavity/state_check(obj/item/bodypart/chest/limb)
	return limb.body_zone == BODY_ZONE_CHEST

/datum/surgery_operation/limb/prepare_cavity/on_preop(obj/item/bodypart/chest/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете раскрывать грудную полость у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает раскрывать грудную полость у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает раскрывать грудную полость у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете давление, когда ваша грудь широко расскрывается!")

/datum/surgery_operation/limb/prepare_cavity/on_success(obj/item/bodypart/chest/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_CAVITY_WIDENED)

/datum/surgery_operation/limb/cavity_implant
	name = "Полостное имплантирование"
	desc = "Имплантирование предмета в полость тела пациента."
	operation_flags = OPERATION_NOTABLE
	implements = list(
		/obj/item = 1,
	)
	time = 3.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/organ1.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_CAVITY_WIDENED
	/// Items that bypass normal size restrictions for cavity implantation
	var/list/heavy_cavity_implants

/datum/surgery_operation/limb/cavity_implant/New()
	. = ..()
	heavy_cavity_implants = typecacheof(list(
		/obj/item/transfer_valve,
	))

/datum/surgery_operation/limb/cavity_implant/all_required_strings()
	return list("операция на груди") + ..()

/datum/surgery_operation/limb/cavity_implant/get_default_radial_image()
	return image('icons/hud/screen_gen.dmi', "arrow_large_still")

/datum/surgery_operation/limb/cavity_implant/state_check(obj/item/bodypart/chest/limb)
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	if(!isnull(limb.cavity_item))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/cavity_implant/snowflake_check_availability(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!surgeon.canUnEquip(tool))
		return FALSE
	// Stops accidentally putting a tool you meant to operate with
	// Besides who really wants to put a scalpel or a wrench inside someone that's lame
	if(IS_ROBOTIC_LIMB(limb) && (tool.tool_behaviour in GLOB.all_mechanical_tools))
		return FALSE
	if(IS_ORGANIC_LIMB(limb) && (tool.tool_behaviour in GLOB.all_surgical_tools))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/cavity_implant/tool_check(obj/item/tool)
	if(tool.w_class > WEIGHT_CLASS_NORMAL && !is_type_in_typecache(tool, heavy_cavity_implants))
		return FALSE
	if(tool.item_flags & (ABSTRACT|DROPDEL|HAND_ITEM))
		return FALSE
	if(isorgan(tool))
		return FALSE // use organ manipulation
	return TRUE

/datum/surgery_operation/limb/cavity_implant/on_preop(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете вставлять [tool.declent_ru(ACCUSATIVE)] в грудь у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает вставлять [tool.declent_ru(ACCUSATIVE)] в грудь у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает вставлять [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "что-то"] в грудь у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете, что что-то вставили в вашу грудь. Боль ужасна!")

/datum/surgery_operation/limb/cavity_implant/on_success(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if (!surgeon.transferItemToLoc(tool, limb.owner, force = TRUE)) // shouldn't fail but just in case
		display_results(
			surgeon,
			limb.owner,
			span_warning("Вы не можете вместить [tool.declent_ru(ACCUSATIVE)] в грудь у [limb.owner.declent_ru(GENITIVE)]!"),
			span_warning("[surgeon] не может вместить [tool.declent_ru(ACCUSATIVE)] в грудь у [limb.owner.declent_ru(GENITIVE)]!"),
			span_warning("[surgeon] не может вместить [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "что-то"] в грудь у [limb.owner.declent_ru(GENITIVE)]!"),
		)
		return

	limb.cavity_item = tool
	limb.remove_surgical_state(SURGERY_CAVITY_WIDENED)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы помещаете [tool.declent_ru(ACCUSATIVE)] в грудь у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] помещает [tool.declent_ru(ACCUSATIVE)] в грудь у [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] помещает [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "что-то"] в грудь у [limb.owner.declent_ru(GENITIVE)]."),
	)


/datum/surgery_operation/limb/undo_cavity_implant
	name = "Извлечение импланта из полости"
	desc = "Извлечение предмета из полости в теле."
	implements = list(
		IMPLEMENT_HAND = 1,
		TOOL_HEMOSTAT = 2,
		TOOL_CROWBAR = 2.5,
		/obj/item/kitchen/fork = 5,
	)

	time = 3.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/organ1.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_CAVITY_WIDENED

/datum/surgery_operation/limb/undo_cavity_implant/all_required_strings()
	return list("операция на груди") + ..()

/datum/surgery_operation/limb/undo_cavity_implant/get_default_radial_image()
	return image('icons/hud/screen_gen.dmi', "arrow_large_still")

/datum/surgery_operation/limb/undo_cavity_implant/get_radial_options(obj/item/bodypart/chest/limb, obj/item/tool, operating_zone)
	// Not bothering to cache this as the chance of hitting the same cavity item in the same round is rather low
	var/datum/radial_menu_choice/option = new()
	option.name = "Извлечь [declent_ru(limb.cavity_item, ACCUSATIVE)]"
	option.info = "Заменить [limb.cavity_item.declent_ru(ACCUSATIVE)] имплантированный в грудной полости пациента."
	option.image = get_generic_limb_radial_image(BODY_ZONE_CHEST)
	option.image.overlays += add_radial_overlays(limb.cavity_item)
	return option

/datum/surgery_operation/limb/undo_cavity_implant/state_check(obj/item/bodypart/chest/limb)
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	// unlike implant removal, don't show the surgery as an option unless something is actually implanted
	// it would stand to reason standard implants would be hidden from view (requires a search)
	// while cavity implants would be blatantly visible (no search necessary)
	if(isnull(limb.cavity_item))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/undo_cavity_implant/on_preop(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете извлекать [limb.cavity_item.declent_ru(ACCUSATIVE)] из груди у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает извлекать [limb.cavity_item.declent_ru(ACCUSATIVE)] из груди у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает извлекать что-то из груди у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете сильную боль в своей [limb.ru_plaintext_zone[PREPOSITIONAL]]!")

/datum/surgery_operation/limb/undo_cavity_implant/on_success(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(isnull(limb.cavity_item)) // something else could have removed it mid surgery?
		display_results(
			surgeon,
			limb.owner,
			span_warning("Вы не нашли ничего, что можно было бы извлечь из груди у [limb.owner.declent_ru(GENITIVE)]."),
			span_warning("[surgeon] не нашел ничего, что можно было бы извлечь из груди у [limb.owner.declent_ru(GENITIVE)]."),
			span_warning("[surgeon] не нашел ничего, что можно было бы извлечь из груди у [limb.owner.declent_ru(GENITIVE)]."),
		)
		return

	var/obj/item/implant = limb.cavity_item
	limb.cavity_item = null
	limb.remove_surgical_state(SURGERY_CAVITY_WIDENED)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы извлекаете [implant.declent_ru(ACCUSATIVE)] из груди у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] извлекает [implant.declent_ru(ACCUSATIVE)] из груди у [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] извлекает что-то из груди у [limb.owner.declent_ru(GENITIVE)]!"),
	)
	display_pain(limb.owner, "Вы чувствуете, как из вас достают [implant.declent_ru(ACCUSATIVE)]!")
	surgeon.put_in_hands(implant)

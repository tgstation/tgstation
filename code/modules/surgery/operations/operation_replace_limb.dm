/datum/surgery_operation/limb/replace_limb
	name = "Аугментация конечности"
	rnd_name = "Аугментация"
	desc = "Замена конечности пациента роботизированной или протезом."
	operation_flags = OPERATION_NOTABLE
	implements = list(
		/obj/item/bodypart = 1,
	)
	time = 3.2 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN
	/// Radial slice datums for every augment type
	VAR_PRIVATE/list/cached_augment_options

/datum/surgery_operation/limb/replace_limb/get_recommended_tool()
	return "кибернетическая конечность"

/datum/surgery_operation/limb/replace_limb/get_default_radial_image()
	return image(/obj/item/bodypart/chest/robot)

/datum/surgery_operation/limb/replace_limb/get_radial_options(obj/item/bodypart/limb, obj/item/tool, operating_zone)
	var/datum/radial_menu_choice/option = LAZYACCESS(cached_augment_options, tool.type)
	if(!option)
		option = new()
		option.name = "аугментировать с помощью [initial(tool.name)]"
		option.info = "Заменить [initial(limb.name)] пациента на [initial(tool.name)]."
		option.image = image(tool.type)
		LAZYSET(cached_augment_options, tool.type, option)

	return option

/datum/surgery_operation/limb/replace_limb/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/bodypart/tool, operated_zone)
	if(!surgeon.canUnEquip(tool))
		return FALSE
	if(limb.body_zone != tool.body_zone)
		return FALSE
	if(!tool.can_attach_limb(limb.owner))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/replace_limb/state_check(obj/item/bodypart/limb)
	return !HAS_TRAIT(limb.owner, TRAIT_NO_AUGMENTS) && !(limb.bodypart_flags & BODYPART_UNREMOVABLE)

/datum/surgery_operation/limb/replace_limb/tool_check(obj/item/bodypart/tool)
	if(tool.item_flags & (ABSTRACT|DROPDEL|HAND_ITEM))
		return FALSE
	if(!isbodypart(tool))
		return FALSE
	var/obj/item/bodypart/limb = tool
	if(!IS_ROBOTIC_LIMB(limb))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/replace_limb/pre_preop(atom/movable/operating_on, mob/living/surgeon, obj/item/bodypart/tool, list/operation_args)
	if(!length(tool.contents))
		return TRUE
	// Prevents quickly filling someone with high-tier organs by augmenting them with a pre-stuffed limb
	to_chat(surgeon, span_warning("[tool] needs to be empty in order to be attached!"))
	return FALSE

/datum/surgery_operation/limb/replace_limb/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/bodypart/tool, list/operation_args)
	// purposefully doesn't use plaintext zone for more context on what is being replaced with what
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете аугментировать [limb.name] у [limb.owner.declent_ru(GENITIVE)] с помощью [tool.declent_ru(ACCUSATIVE)]..."),
		span_notice("[surgeon] начинает аугментировать [limb.name] у [limb.owner.declent_ru(GENITIVE)] с помощью [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("[surgeon] начинает аугментировать [limb.name] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете ужасную боль в своей [limb.ru_plaintext_zone[PREPOSITIONAL]]!")

/datum/surgery_operation/limb/replace_limb/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/bodypart/tool, list/operation_args)
	if(!surgeon.temporarilyRemoveItemFromInventory(tool))
		return // should never happen

	var/mob/living/patient = limb.owner // owner's about to be nulled
	if(!tool.replace_limb(patient))
		display_results(
			surgeon,
			patient,
			span_warning("У вас никак не получается подобрать [tool.declent_ru(ACCUSATIVE)] к телу [patient]!"),
			span_warning("[surgeon] никак не может подобрать [tool.declent_ru(ACCUSATIVE)] к телу [patient]!"),
			span_warning("[surgeon] никак не может подобрать [tool.declent_ru(ACCUSATIVE)] к телу [patient]!"),
		)
		tool.forceMove(patient.drop_location())
		return // could possibly happen

	if(tool.check_for_frankenstein(patient))
		tool.bodypart_flags |= BODYPART_IMPLANTED

	display_results(
		surgeon,
		patient,
		span_notice("Вы успешно аугментируете [limb.ru_plaintext_zone[PREPOSITIONAL]] [patient] с помощью [tool.declent_ru(ACCUSATIVE)]!"),
		span_notice("[surgeon] успешно аугментирует [limb.ru_plaintext_zone[PREPOSITIONAL]] [patient] с помощью [tool.declent_ru(ACCUSATIVE)]!"),
		span_notice("[surgeon] завершает аугментацию [limb.ru_plaintext_zone[PREPOSITIONAL]] [patient]."),
	)
	display_pain(patient, "Ваша [limb.ru_plaintext_zone[PREPOSITIONAL]] наполняется непривычными синтетическими ощущениями!", TRUE)
	log_combat(surgeon, patient, "augmented", addition = "выдал новую [tool.declent_ru(ACCUSATIVE)]")

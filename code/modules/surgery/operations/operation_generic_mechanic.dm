// Mechanical equivalents of basic surgical operations
/// Mechanical equivalent of cutting skin
/datum/surgery_operation/limb/mechanical_incision
	name = "Отвинтите корпус"
	desc = "Отвинтите корпус механического пациента, чтобы получить доступ к его внутренним компонентам. \
		Вызывает хирургическое состояние \"кожа разрезана\"."
	implements = list(
		TOOL_SCREWDRIVER = 1,
		TOOL_SCALPEL = 1.33,
		/obj/item/knife = 2,
		/obj/item = 10, // i think this amounts to a 180% chance of failure (clamped to 99%)
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC | OPERATION_NO_PATIENT_REQUIRED
	required_bodytype = BODYTYPE_ROBOTIC
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'
	any_surgery_states_blocked = ALL_SURGERY_SKIN_STATES
	allow_stumps = TRUE

/datum/surgery_operation/limb/mechanical_incision/get_any_tool()
	return "Любой острый предмет"

/datum/surgery_operation/limb/mechanical_incision/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "unscrew_shell")

/datum/surgery_operation/limb/mechanical_incision/tool_check(obj/item/tool)
	// Require any sharpness OR a tool behavior match
	return (tool.get_sharpness() || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/mechanical_incision/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете отвинчивать корпус [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинаете отвинчивать корпус [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинаете отвинчивать корпус [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете, как ваша [limb.ru_plaintext_zone[PREPOSITIONAL]] немеет, когда отвинчивается корпус.", TRUE)

/datum/surgery_operation/limb/mechanical_incision/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_SKIN_CUT)

/// Mechanical equivalent of opening skin and clamping vessels
/datum/surgery_operation/limb/mechanical_open
	name = "Открыть люк"
	desc = "Откройте люк механического пациента, чтобы получить доступ к его внутренним компонентам. \
		Вызывает хирургическое состояние \"кожа раздвинута\" и \"сосуды зажаты\"."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		IMPLEMENT_HAND = 1,
		TOOL_CROWBAR = 1,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC | OPERATION_NO_PATIENT_REQUIRED
	time = 1 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	all_surgery_states_required = SURGERY_SKIN_CUT
	allow_stumps = TRUE

/datum/surgery_operation/limb/mechanical_open/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "open_hatch")

/datum/surgery_operation/limb/mechanical_open/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы приступаете к открытию фиксаторов люка в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] приступает к открытию фиксаторов люка в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] приступает к открытию фиксаторов люка в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Последние слабые покалывания тактильных ощущений исчезают из вашей [limb.ru_plaintext_zone[PREPOSITIONAL]], когда открывается люк.", TRUE)

/datum/surgery_operation/limb/mechanical_open/on_success(obj/item/bodypart/limb)
	. = ..()
	// We get both vessels and skin done at the same time wowee
	limb.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED)
	limb.remove_surgical_state(SURGERY_SKIN_CUT)

/// Mechanical equivalent of cauterizing / closing skin
/datum/surgery_operation/limb/mechanical_close
	name = "Закрутить корпус"
	desc = "Привинтите корпус механического пациента обратно на место. \
		Устраняет большинство хирургических состояний."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_SCREWDRIVER = 1,
		TOOL_SCALPEL = 1.33,
		/obj/item/knife = 2,
		/obj/item = 10,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC | OPERATION_NO_PATIENT_REQUIRED
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES
	allow_stumps = TRUE

/datum/surgery_operation/limb/mechanical_close/get_any_tool()
	return "Любой острый предмет"

/datum/surgery_operation/limb/mechanical_close/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "screw_shell")

/datum/surgery_operation/limb/mechanical_close/tool_check(obj/item/tool)
	// Require any sharpness OR a tool behavior match
	return (tool.get_sharpness() || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/mechanical_close/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_SKIN(limb)

/datum/surgery_operation/limb/mechanical_close/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете завинчивать корпус [limb.ru_plaintext_zone[PREPOSITIONAL]] у[limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает завинчивать корпус [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает завинчивать корпус [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете, как возвращаются слабые ощущения покалывания, когда корпус вашей [limb.ru_plaintext_zone[PREPOSITIONAL]] закручивается.", TRUE)

/datum/surgery_operation/limb/mechanical_close/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.remove_surgical_state(ALL_SURGERY_STATES_UNSET_ON_CLOSE)

// Mechanical equivalent of cutting vessels and organs
/datum/surgery_operation/limb/prepare_electronics
	name = "Подготовьте электронику"
	desc = "Подготовьте внутреннюю электронику механического пациента к операции. \
		Вызывает хирургическое состояние \"орган разрезан\"."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_MULTITOOL = 1,
		TOOL_HEMOSTAT = 1.33,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC | OPERATION_NO_PATIENT_REQUIRED
	time = 2.4 SECONDS
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_ORGANS_CUT
	allow_stumps = TRUE

/datum/surgery_operation/limb/prepare_electronics/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "prepare_electronics")

/datum/surgery_operation/limb/prepare_electronics/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете подготавливать электронику в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает подготавливать электронику в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает подготавливать электронику в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы можете почувствовать слабое жужжание в вашей [limb.ru_plaintext_zone[PREPOSITIONAL]], когда электроника перезагружается", TRUE)

/datum/surgery_operation/limb/prepare_electronics/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_ORGANS_CUT)

// Mechanical equivalent of sawing bone
/datum/surgery_operation/limb/mechanic_unwrench
	name = "Открутить эндоскелет"
	desc = "Открутите эндоскелет механического пациента, чтобы получить доступ к его внутренним элементам. \
		Вызывает хирургическое состояние \"кость распилена\"."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_WRENCH = 1,
		TOOL_RETRACTOR = 1.33,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC | OPERATION_NO_PATIENT_REQUIRED
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED
	allow_stumps = TRUE

/datum/surgery_operation/limb/mechanic_unwrench/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "unwrench_endoskeleton")

/datum/surgery_operation/limb/mechanic_unwrench/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете откручивать несколько болтов в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает откручивать несколько болтов в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает откручивать несколько болтов в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы ощущаете легкое потряхивание в своей [limb.ru_plaintext_zone[PREPOSITIONAL]], когда болты начинают ослабевать", TRUE)

/datum/surgery_operation/limb/mechanic_unwrench/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.add_surgical_state(SURGERY_BONE_SAWED)

// Mechanical equivalent of unsawing bone
/datum/surgery_operation/limb/mechanic_wrench
	name = "Закрутить эндоскелет"
	desc = "Закрутите обратно эндоскелет механического пациента. \
		Убирает хирургические состояния \"кость распилена\"."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_WRENCH = 1,
		TOOL_RETRACTOR = 1.33,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC | OPERATION_NO_PATIENT_REQUIRED
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED
	allow_stumps = TRUE

/datum/surgery_operation/limb/mechanic_wrench/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_BONES(limb)

/datum/surgery_operation/limb/mechanic_wrench/all_required_strings()
	return ..() + list("конечность должна иметь кости")

/datum/surgery_operation/limb/mechanic_wrench/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "wrench_endoskeleton")

/datum/surgery_operation/limb/mechanic_wrench/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете закручивать несколько болтов в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает закручивать несколько болтов в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает закручивать несколько болтов в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы ощущаете легкое потряхивание в своей [limb.ru_plaintext_zone[PREPOSITIONAL]], когда болты начинают затягиваться.", TRUE)

/datum/surgery_operation/limb/mechanic_wrench/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.remove_surgical_state(SURGERY_BONE_SAWED)

// Basic operations for moving back and forth between surgery states
/// First step of every surgery, makes an incision in the skin
/datum/surgery_operation/limb/incise_skin
	name = "Сделать разрез кожи"
	// rnd_name = "Laparotomy / Craniotomy / Myotomy (Make Incision)" // Maybe we keep this one simple
	desc = "Сделайте разрез на коже пациента, чтобы получить доступ к внутренним органам. \
		Вызывает хирургическое состояние \"кожа разрезана\"."
	required_bodytype = ~BODYTYPE_ROBOTIC
	replaced_by = /datum/surgery_operation/limb/incise_skin/abductor
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/melee/energy/sword = 1.33,
		/obj/item/knife = 1.5,
		/obj/item/shard = 2.25,
		/obj/item/screwdriver = 5,
		/obj/item/pen = 5,
		/obj/item = 3.33,
	)
	time = 1.6 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NO_PATIENT_REQUIRED
	any_surgery_states_blocked = ALL_SURGERY_SKIN_STATES
	allow_stumps = TRUE
	/// We can't cut mobs with this biostate
	var/biostate_blacklist = BIO_CHITIN

/datum/surgery_operation/limb/incise_skin/get_any_tool()
	return "Любой острый предмет"

/datum/surgery_operation/limb/incise_skin/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "make_incision")

/datum/surgery_operation/limb/incise_skin/tool_check(obj/item/tool)
	// Require edged sharpness OR a tool behavior match
	if((tool.get_sharpness() & SHARP_EDGED) || implements[tool.tool_behaviour])
		return TRUE
	// these are here by popular demand, even though they don't fit the above criteria
	if(istype(tool, /obj/item/pen) || istype(tool, /obj/item/screwdriver))
		return TRUE
	return FALSE

/datum/surgery_operation/limb/incise_skin/state_check(obj/item/bodypart/limb)
	return !(limb.biological_state & biostate_blacklist)

/datum/surgery_operation/limb/incise_skin/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете делать разрез на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает делать разрез на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает делать разрез на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете покалывание на [limb.ru_plaintext_zone[PREPOSITIONAL]].")

/datum/surgery_operation/limb/incise_skin/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..() // default success message
	limb.add_surgical_state(SURGERY_SKIN_CUT|SURGERY_VESSELS_UNCLAMPED) // ouch, cuts the vessels
	if(!limb.can_bleed())
		return

	/// BANDASTATION REMOVAL START
	// var/blood_name = limb.owner?.get_bloodtype()?.get_blood_name()
	// if(!blood_name && length(limb.blood_dna_info))
	// 	var/datum/blood_type/blood_type = limb.blood_dna_info[limb.blood_dna_info[1]]
	// 	blood_name = blood_type?.get_blood_name()
	// if(!blood_name)
	// 	blood_name = "Blood"
	/// BANDASTATION REMOVAL END

	display_results(
		surgeon,
		limb.owner,
		span_notice("Кровь скапливается у разреза на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("Кровь скапливается у разреза на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("Кровь скапливается у разреза на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)

/// Subtype for thick skinned creatures (Xenomorphs)
/datum/surgery_operation/limb/incise_skin/thick
	name = "Сделать разрез на толстой коже"
	implements = list(
		TOOL_SAW = 1,
		/obj/item/melee/energy/sword = 1.25,
		/obj/item/fireaxe = 1.5,
		/obj/item/knife/butcher = 2.5,
		/obj/item = 5,
	)
	biostate_blacklist = BIO_FLESH|BIO_METAL

/datum/surgery_operation/limb/incise_skin/thick/get_any_tool()
	return "Любой острый предмет, требующий усилия"

/datum/surgery_operation/limb/incise_skin/thick/tool_check(obj/item/tool)
	return ..() && tool.force >= 10

/datum/surgery_operation/limb/incise_skin/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED | OPERATION_NO_WIKI
	required_bodytype = NONE
	biostate_blacklist = NONE // they got laser scalpels

/// Pulls the skin back to access internals
/datum/surgery_operation/limb/retract_skin
	name = "retract skin"
	desc = "Раздвигает кожу пациента, чтобы получить доступ к внутренним органам. \
		Вызывает хирургическое состояние \"кожа раздвинута\"."
	operation_flags = OPERATION_NO_PATIENT_REQUIRED
	required_bodytype = ~BODYTYPE_ROBOTIC
	replaced_by = /datum/surgery_operation/limb/retract_skin/abductor
	implements = list(
		TOOL_RETRACTOR = 1,
		TOOL_SCREWDRIVER = 2.25,
		TOOL_WIRECUTTER = 2.85,
		/obj/item/stack/rods = 2.85,
		/obj/item/kitchen/fork = 2.85,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/retractor1.ogg'
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'
	all_surgery_states_required = SURGERY_SKIN_CUT
	allow_stumps = TRUE

/datum/surgery_operation/limb/retract_skin/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "retract_skin")

/datum/surgery_operation/limb/retract_skin/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете раздвигать кожу на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает раздвигать кожу на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает раздвигать кожу на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете жгучую боль, распространяющуюся по всей вашей [limb.ru_plaintext_zone[PREPOSITIONAL]], когда кожа раздвигается.")

/datum/surgery_operation/limb/retract_skin/on_success(obj/item/bodypart/limb)
	. = ..()
	// the limb SHOULD either have unclamped or clamped vessels if we're retracting skin
	// if it doesn't, some shenanigans happened (likely due to wounds), so we add unclamped if needed - just to be thorough
	limb.add_surgical_state(SURGERY_SKIN_OPEN | (LIMB_HAS_SURGERY_STATE(limb, SURGERY_VESSELS_CLAMPED) ? NONE : SURGERY_VESSELS_UNCLAMPED))
	limb.remove_surgical_state(SURGERY_SKIN_CUT)

/datum/surgery_operation/limb/retract_skin/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED  | OPERATION_NO_WIKI
	required_bodytype = NONE

/// Closes the skin
/datum/surgery_operation/limb/close_skin
	name = "Прижечь разрез кожи"
	desc = "Прижечь разрез на коже пациента, закрывая его. \
		Устраняет большинство хирургических состояний."
	required_bodytype = ~BODYTYPE_ROBOTIC
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	replaced_by = /datum/surgery_operation/limb/close_skin/abductor
	implements = list(
		TOOL_CAUTERY = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/gun/energy/laser = 1.15,
		TOOL_WELDER = 1.5,
		/obj/item = 3.33,
	)
	time = 2.4 SECONDS
	preop_sound = list(
		/obj/item/stack/medical/suture = SFX_SUTURE_BEGIN,
		/obj/item = 'sound/items/handling/surgery/cautery1.ogg',
	)
	success_sound = list(
		/obj/item/stack/medical/suture = SFX_SUTURE_END,
		/obj/item = 'sound/items/handling/surgery/cautery2.ogg',
	)
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES
	allow_stumps = TRUE

/datum/surgery_operation/limb/close_skin/get_any_tool()
	return "Любой источник тепла"

/datum/surgery_operation/limb/close_skin/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "mend_incision")

/datum/surgery_operation/limb/close_skin/all_required_strings()
	return ..() + list("конечность должна иметь кожу")

/datum/surgery_operation/limb/close_skin/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_SKIN(limb)

/datum/surgery_operation/limb/close_skin/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/stack/medical/suture))
		return TRUE

	if(istype(tool, /obj/item/gun/energy/laser))
		var/obj/item/gun/energy/laser/lasergun = tool
		return lasergun.cell?.charge > 0

	return tool.get_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST

/datum/surgery_operation/limb/close_skin/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете прижигать разрез на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает прижигать разрез на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает прижигать разрез на [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вашу [limb.ru_plaintext_zone[PREPOSITIONAL]] начинают [istype(tool, /obj/item/stack/medical/suture) ? "сшивать" : "прижигать"]!")

/datum/surgery_operation/limb/close_skin/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	if(LIMB_HAS_SURGERY_STATE(limb, SURGERY_BONE_SAWED))
		limb.heal_damage(40)
	limb.remove_surgical_state(ALL_SURGERY_STATES_UNSET_ON_CLOSE)

/datum/surgery_operation/limb/close_skin/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED  | OPERATION_NO_WIKI
	required_bodytype = NONE

/// Clamps bleeding blood vessels to prevent blood loss
/datum/surgery_operation/limb/clamp_bleeders
	name = "Зажать сосуды"
	desc = "Накладывает зажим на кровеносных сосудах пациента, чтобы предотвратить потерю крови. \
		Вызывает хирургическое состояние \"сосуды зажаты\"."
	required_bodytype = ~BODYTYPE_ROBOTIC
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	replaced_by = /datum/surgery_operation/limb/clamp_bleeders/abductor
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_WIRECUTTER = 1.67,
		/obj/item/stack/package_wrap = 2.85,
		/obj/item/stack/cable_coil = 6.67,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_UNCLAMPED
	allow_stumps = TRUE

/datum/surgery_operation/limb/clamp_bleeders/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "clamp_bleeders")

/datum/surgery_operation/limb/clamp_bleeders/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете зажимать кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает зажимать кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает зажимать кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете покалывание, когда кровотечение в вашей [limb.ru_plaintext_zone[PREPOSITIONAL]] замедляется.")

/datum/surgery_operation/limb/clamp_bleeders/on_success(obj/item/bodypart/limb)
	. = ..()
	// free brute healing if you do it after sawing bones
	if(LIMB_HAS_SURGERY_STATE(limb, SURGERY_BONE_SAWED))
		limb.heal_damage(20)
	limb.add_surgical_state(SURGERY_VESSELS_CLAMPED)
	limb.remove_surgical_state(SURGERY_VESSELS_UNCLAMPED)

/datum/surgery_operation/limb/clamp_bleeders/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED  | OPERATION_NO_WIKI
	required_bodytype = NONE

/// Unclamps blood vessels to allow blood flow again
/datum/surgery_operation/limb/unclamp_bleeders
	name = "Разжать сосуды"
	desc = "Снять зажимы с кровеносных сосудов в теле пациента, чтобы восстановить кровоток. \
		Убирает хирургическое состояние \"сосуды зажаты\"."
	required_bodytype = ~BODYTYPE_ROBOTIC
	operation_flags = OPERATION_NO_PATIENT_REQUIRED
	replaced_by = /datum/surgery_operation/limb/unclamp_bleeders/abductor
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_WIRECUTTER = 1.67,
		/obj/item/stack/package_wrap = 2.85,
		/obj/item/stack/cable_coil = 6.67,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED
	allow_stumps = TRUE

/datum/surgery_operation/limb/unclamp_bleeders/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "unclamp_bleeders")

/datum/surgery_operation/limb/unclamp_bleeders/all_required_strings()
	return ..() + list("конечность должна иметь кровеносные сосуды")

/datum/surgery_operation/limb/unclamp_bleeders/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_VESSELS(limb)

/datum/surgery_operation/limb/unclamp_bleeders/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете разжимать кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает разжимать кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает разжимать кровеносные сосуды в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете, как снижается давление, когда в [limb.ru_plaintext_zone[PREPOSITIONAL]] начинает течь кровь.")

/datum/surgery_operation/limb/unclamp_bleeders/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.add_surgical_state(SURGERY_VESSELS_UNCLAMPED)
	limb.remove_surgical_state(SURGERY_VESSELS_CLAMPED)

/datum/surgery_operation/limb/unclamp_bleeders/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED  | OPERATION_NO_WIKI
	required_bodytype = NONE

/// Saws through bones to access organs
/datum/surgery_operation/limb/saw_bones
	name = "Распилить кость"
	desc = "Пропилите кость пациента, чтобы получить доступ к внутренним органам. \
		Вызывает хирургическое состояние \"кость распилена\"."
	required_bodytype = ~BODYTYPE_ROBOTIC
	implements = list(
		TOOL_SAW = 1,
		/obj/item/shovel/serrated = 1.33,
		/obj/item/melee/arm_blade = 1.33,
		/obj/item/fireaxe = 2,
		/obj/item/hatchet = 2.85,
		/obj/item/knife/butcher = 2.85,
		/obj/item = 4,
	)
	time = 5.4 SECONDS
	preop_sound = list(
		/obj/item/circular_saw = 'sound/items/handling/surgery/saw.ogg',
		/obj/item/melee/arm_blade = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/fireaxe = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/hatchet = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/knife/butcher = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item = 'sound/items/handling/surgery/scalpel1.ogg',
	)
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NO_PATIENT_REQUIRED
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED
	allow_stumps = TRUE

/datum/surgery_operation/limb/saw_bones/get_any_tool()
	return "Любой острый предмет, требующий усилия"

/datum/surgery_operation/limb/saw_bones/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "saw_bones")

/datum/surgery_operation/limb/saw_bones/tool_check(obj/item/tool)
	// Require edged sharpness and sufficient force OR a tool behavior match
	return (((tool.get_sharpness() & SHARP_EDGED) && tool.force >= 10) || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/saw_bones/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете пилить кости в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает пилить кости в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает пилить кости в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете, как ужасная боль распространяется по [limb.ru_plaintext_zone[PREPOSITIONAL]]!")

/datum/surgery_operation/limb/saw_bones/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_BONE_SAWED)
	limb.receive_damage(50, sharpness = tool.get_sharpness(), wound_bonus = CANT_WOUND, damage_source = tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы распилили кости в [limb.ru_plaintext_zone[PREPOSITIONAL]] [limb.owner.declent_ru(PREPOSITIONAL)]."),
		span_notice("[surgeon] распилил кости в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] распилил кости в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]!"),
	)
	display_pain(limb.owner, "Вы чувствуете, как будто что-то сломалось в [limb.ru_plaintext_zone[PREPOSITIONAL]]!")

/// Fixes sawed bones back together
/datum/surgery_operation/limb/fix_bones
	name = "Фиксация сломанной кости"
	desc = "Соединить рассечённые или зафиксировать сломанные кости. \
		Убирает хирургические состояния \"кость распилена\" и \"кость просверлена\"."
	required_bodytype = ~BODYTYPE_ROBOTIC
	operation_flags = OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/medical/wrap/sticky_tape/surgical = 1,
		/obj/item/stack/medical/wrap/sticky_tape/super = 2,
		/obj/item/stack/medical/wrap/sticky_tape = 3.33,
	)
	preop_sound = list(
		/obj/item/stack/medical/bone_gel = 'sound/misc/soggy.ogg',
		/obj/item/stack/medical/wrap/sticky_tape/surgical = 'sound/items/duct_tape/duct_tape_rip.ogg',
		/obj/item/stack/medical/wrap/sticky_tape/super = 'sound/items/duct_tape/duct_tape_rip.ogg',
		/obj/item/stack/medical/wrap/sticky_tape = 'sound/items/duct_tape/duct_tape_rip.ogg',
	)
	time = 4 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_required = SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED
	allow_stumps = TRUE

/datum/surgery_operation/limb/fix_bones/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "fix_bones")

/datum/surgery_operation/limb/fix_bones/all_required_strings()
	return ..() + list("конечность должна иметь кости")

/datum/surgery_operation/limb/fix_bones/state_check(obj/item/bodypart/limb)
	if(!LIMB_HAS_BONES(limb))
		return FALSE

	// if a wound has given us the broken bone state, don't show this surgery as an option, to prevent confusion
	for(var/datum/wound/wound as anything in limb.wounds)
		if(wound.surgery_states & any_surgery_states_required)
			return FALSE

	return TRUE

/datum/surgery_operation/limb/fix_bones/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете лечить кости в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает лечить кости в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает лечить кости в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете скрежещущее ощущение в своей [limb.ru_plaintext_zone[PREPOSITIONAL]], когда кости встают на место.")

/datum/surgery_operation/limb/fix_bones/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.remove_surgical_state(SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED)
	limb.heal_damage(40)

/datum/surgery_operation/limb/drill_bones
	name = "Сверление кости"
	desc = "Просверливание кости пациента. \
		Вызывает хирургическое состояние \"кость просверлена\"."
	required_bodytype = ~BODYTYPE_ROBOTIC
	operation_flags = OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		TOOL_DRILL = 1,
		/obj/item/screwdriver/power = 1.25,
		/obj/item/pickaxe/drill = 1.67,
		TOOL_SCREWDRIVER = 4,
		/obj/item/kitchen/spoon = 5,
		/obj/item = 6.67,
	)
	time = 3 SECONDS
	preop_sound = 'sound/items/handling/surgery/saw.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED
	allow_stumps = TRUE

/datum/surgery_operation/limb/drill_bones/get_any_tool()
	return "Любой предмет с острым концом, применяемое с усилием"

/datum/surgery_operation/limb/drill_bones/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "drill_bones")

/datum/surgery_operation/limb/drill_bones/tool_check(obj/item/tool)
	// Require pointy sharpness and sufficient force OR a tool behavior match
	return (((tool.get_sharpness() & SHARP_POINTY) && tool.force >= 10) || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/drill_bones/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете просверливать кость в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает просверливать кость в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает просверливать кость в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете ужасную колющую боль в [limb.ru_plaintext_zone[PREPOSITIONAL]]!")

/datum/surgery_operation/limb/drill_bones/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_BONE_DRILLED)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы просверлили кость в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] просверлил кость в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] просверлил кость в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]!"),
	)

/datum/surgery_operation/limb/incise_organs
	name = "Сделать разрез органа"
	desc = "Сделайте разрез на тканях внутренних органов, что позволит вылечить или манипулировать с органом. \
		Вызывает хирургическое состояние \"орган разрезан\"."
	required_bodytype = ~BODYTYPE_ROBOTIC
	operation_flags = OPERATION_NO_PATIENT_REQUIRED
	replaced_by = /datum/surgery_operation/limb/incise_organs/abductor
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/melee/energy/sword = 1.33,
		/obj/item/knife = 1.5,
		/obj/item/shard = 2.25,
		/obj/item/pen = 5,
		/obj/item = 3.33,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_ORGANS_CUT
	allow_stumps = TRUE

/datum/surgery_operation/limb/incise_organs/get_any_tool()
	return "Любой острый предмет"

/datum/surgery_operation/limb/incise_organs/get_default_radial_image()
	return image('icons/hud/surgery_radial.dmi', "incise_organs")

/datum/surgery_operation/limb/incise_organs/tool_check(obj/item/tool)
	// Require edged sharpness OR a tool behavior match. Also saws are a no-go, you'll rip up the organs!
	return ((tool.get_sharpness() & SHARP_EDGED) || implements[tool.tool_behaviour]) && tool.tool_behaviour != TOOL_SAW

/datum/surgery_operation/limb/incise_organs/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы начинаете делать разрез органа в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]..."),
		span_notice("[surgeon] начинает делать разрез органа в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] начинает делать разрез органа в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
	)
	display_pain(limb.owner, "Вы чувствуете покалывание в [limb.ru_plaintext_zone[PREPOSITIONAL]].")

/datum/surgery_operation/limb/incise_organs/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_ORGANS_CUT)
	limb.receive_damage(10, sharpness = tool.get_sharpness(), wound_bonus = CANT_WOUND, damage_source = tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Вы сделали разрез органа в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]."),
		span_notice("[surgeon] сделал надрез органа в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]!"),
		span_notice("[surgeon] сделал надрез органа в [limb.ru_plaintext_zone[PREPOSITIONAL]] у [limb.owner.declent_ru(GENITIVE)]!"),
	)
	display_pain(limb.owner, "Вы чувствуете острую боль внутри [limb.ru_plaintext_zone[PREPOSITIONAL]]!")

/datum/surgery_operation/limb/incise_organs/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED  | OPERATION_NO_WIKI
	required_bodytype = NONE

/datum/surgery_operation/limb/incise_organs/abductor/state_check(obj/item/bodypart/limb)
	return TRUE // You can incise chests without sawing ribs

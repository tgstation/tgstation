
/*
	Piercing wounds
*/
/datum/wound/pierce
	undiagnosed_name = "Puncture"
	threshold_penalty = 5

/datum/wound/pierce/get_self_check_description(self_aware)
	if(!limb.can_bleed())
		return ..()

	switch(severity)
		if(WOUND_SEVERITY_TRIVIAL)
			return span_danger("It's leaking blood from a small [LOWER_TEXT(undiagnosed_name || name)].")
		if(WOUND_SEVERITY_MODERATE)
			return span_warning("It's leaking blood from a [LOWER_TEXT(undiagnosed_name || name)].")
		if(WOUND_SEVERITY_SEVERE)
			return span_boldwarning("It's leaking blood from a serious [LOWER_TEXT(undiagnosed_name || name)]!")
		if(WOUND_SEVERITY_CRITICAL)
			return span_boldwarning("It's leaking blood from a major [LOWER_TEXT(undiagnosed_name || name)]!!")

/datum/wound/pierce/bleed
	name = "Piercing Wound"
	sound_effect = 'sound/items/weapons/slice.ogg'
	processes = TRUE
	treatable_tools = list(TOOL_CAUTERY)
	base_treat_time = 3 SECONDS
	wound_flags = (ACCEPTS_GAUZE | CAN_BE_GRASPED)

	default_scar_file = FLESH_SCAR_FILE

	/// How much blood we start losing when this wound is first applied
	var/initial_flow
	/// How much our blood_flow will naturally decrease per second, even without gauze
	var/clot_rate
	/// If gauzed, what percent of the internal bleeding actually clots of the total absorption rate
	var/gauzed_clot_rate

	/// When hit on this bodypart, we have this chance of losing some blood + the incoming damage
	var/internal_bleeding_chance
	/// A multiplier applied to how much blood is lost from damage to the wounded limb
	var/internal_bleeding_coefficient = 1
	/// If TRUE we are ready to be mended in surgery
	VAR_FINAL/mend_state = FALSE

/datum/wound/pierce/bleed/wound_injury(datum/wound/old_wound = null, attack_direction = null)
	set_blood_flow(initial_flow)
	if(limb.can_bleed() && attack_direction && victim.get_blood_volume() > BLOOD_VOLUME_OKAY)
		victim.spray_blood(attack_direction, severity)

	return ..()

/datum/wound/pierce/bleed/receive_damage(wounding_type, wounding_dmg, wound_bonus, attack_direction, damage_source)
	if(victim.stat == DEAD || wounding_dmg < 5 || !limb.can_bleed() || !victim.get_blood_volume() || !prob(internal_bleeding_chance + wounding_dmg))
		return
	// 20 force attack ~=  5-16 blood loss ~= 1%-3% of blood volume
	// 30 force attack ~= 6-20 blood loss ~= 1%-4% of blood volume
	var/blood_bled = sqrt(wounding_dmg) * internal_bleeding_coefficient * limb.get_splint_factor() * pick(0.75, 1, 1.25, 1.5)
	switch(blood_bled)
		if(8 to 12)
			victim.visible_message(
				span_smalldanger("Капли крови вылетают из отверстия в [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)]!."),
				span_danger("Вы откашливаетесь, выплевывая немного крови из-за удара по вашей [limb.ru_plaintext_zone[DATIVE] || limb.plaintext_zone]."),
				vision_distance = COMBAT_MESSAGE_RANGE,
				visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			)
		if(12 to 18)
			victim.visible_message(
				span_smalldanger("Небольшая струя крови брызгает из дыры в [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)]!!"),
				span_danger("Вы выплевываете струю крови из-за удара по вашей [limb.ru_plaintext_zone[DATIVE] || limb.plaintext_zone]!"),
				vision_distance = COMBAT_MESSAGE_RANGE,
				visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			)
		if(18 to INFINITY)
			victim.visible_message(
				span_danger("Брызги крови струятся из прокола в [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)]!"),
				span_bolddanger("Вы задыхаетесь, выплевывая брызги крови из-за удара по вашей [limb.ru_plaintext_zone[DATIVE] || limb.plaintext_zone]!"),
				vision_distance = COMBAT_MESSAGE_RANGE,
				visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			)
	victim.bleed(blood_bled)
	if(blood_bled >= 18)
		victim.spray_blood(attack_direction)

/datum/wound/pierce/bleed/get_bleed_rate_of_change()
	//basically if a species doesn't bleed, the wound is stagnant and will not heal on its own (nor get worse)
	if(!limb.can_bleed())
		return BLOOD_FLOW_STEADY
	if(HAS_TRAIT(victim, TRAIT_BLOOD_FOUNTAIN))
		return BLOOD_FLOW_INCREASING
	if(LAZYACCESS(limb.applied_items, LIMB_ITEM_GAUZE) || clot_rate > 0)
		return BLOOD_FLOW_DECREASING
	if(clot_rate < 0)
		return BLOOD_FLOW_INCREASING
	return BLOOD_FLOW_STEADY

/datum/wound/pierce/bleed/handle_process(seconds_per_tick)
	if (!victim || HAS_TRAIT(victim, TRAIT_STASIS))
		return


	if(limb.can_bleed())
		if(victim.bodytemperature < (BODYTEMP_NORMAL - 10))
			adjust_blood_flow(-0.1 * seconds_per_tick)
			if(QDELETED(src))
				return
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(victim, span_notice("Вы чувствуете, как [LOWER_TEXT(undiagnosed_name || name)] в вашей [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] сужается от холода!"))

		if(HAS_TRAIT(victim, TRAIT_BLOOD_FOUNTAIN))
			adjust_blood_flow(0.25 * seconds_per_tick) // old heparin used to just add +2 bleed stacks per tick, this adds 0.5 bleed flow to all open cuts which is probably even stronger as long as you can cut them first

	//gauze always reduces blood flow, even for non bleeders
	var/obj/item/stack/medical/wrap/current_gauze = LAZYACCESS(limb.applied_items, LIMB_ITEM_GAUZE)
	if(current_gauze?.absorption_rate)
		var/gauze_power = current_gauze.absorption_rate
		limb.seep_gauze(gauze_power * seconds_per_tick)
		adjust_blood_flow((-clot_rate * seconds_per_tick) + (-gauze_power * gauzed_clot_rate * seconds_per_tick))
	//otherwise, only clot if it's a bleeder
	else if(limb.can_bleed())
		adjust_blood_flow(-clot_rate * seconds_per_tick)

/datum/wound/pierce/bleed/adjust_blood_flow(adjust_by, minimum)
	. = ..()
	if(blood_flow > WOUND_MAX_BLOODFLOW)
		blood_flow = WOUND_MAX_BLOODFLOW
	if(blood_flow <= 0 && !QDELETED(src))
		to_chat(victim, span_green("Отверстия на вашей [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] [!limb.can_bleed() ? "закрылись" : "перестали кровоточить"]!"))
		qdel(src)

/datum/wound/pierce/bleed/check_grab_treatments(obj/item/tool, mob/user)
	// if we're using something hot but not a cautery, we need to be aggro grabbing them first,
	// so we don't try treating someone we're eswording
	return tool.get_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST

/datum/wound/pierce/bleed/treat(obj/item/tool, mob/user)
	if(tool.tool_behaviour == TOOL_CAUTERY || tool.get_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		tool_cauterize(tool, user)

/datum/wound/pierce/bleed/on_xadone(power)
	. = ..()

	if (limb) // parent can cause us to be removed, so its reasonable to check if we're still applied
		adjust_blood_flow(-0.03 * power) // i think it's like a minimum of 3 power, so .09 blood_flow reduction per tick is pretty good for 0 effort

/datum/wound/pierce/bleed/on_synthflesh(reac_volume)
	. = ..()
	adjust_blood_flow(-0.025 * reac_volume) // 20u * 0.05 = -1 blood flow, less than with slashes but still good considering smaller bleed rates

/// If someone is using either a cautery tool or something with heat to cauterize this pierce
/datum/wound/pierce/bleed/proc/tool_cauterize(obj/item/I, mob/user)

	var/improv_penalty_mult = (I.tool_behaviour == TOOL_CAUTERY ? 1 : 1.25) // 25% longer and less effective if you don't use a real cautery
	var/self_penalty_mult = (user == victim ? 1.5 : 1) // 50% longer and less effective if you do it to yourself

	var/treatment_delay = base_treat_time * self_penalty_mult * improv_penalty_mult

	if(HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		treatment_delay *= 0.5
		user.visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] начинает опытно прижигать [limb.ru_plaintext_zone[ACCUSATIVE] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)] с помощью [I.declent_ru(GENITIVE)]..."), span_warning("Вы начинаете прижигать [limb.ru_plaintext_zone[ACCUSATIVE] || limb.plaintext_zone] у [user == victim ? "вас" : "[victim.declent_ru(GENITIVE)]"] с помощью [I.declent_ru(GENITIVE)], держа в голове показатели сканера..."))
	else
		user.visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] начинает прижигать [limb.ru_plaintext_zone[ACCUSATIVE] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)] с помощью [I.declent_ru(GENITIVE)]..."), span_warning("Вы начинаете прижигать [limb.ru_plaintext_zone[ACCUSATIVE] || limb.plaintext_zone] у [user == victim ? "вас" : "[victim.declent_ru(GENITIVE)]"] с помощью [I.declent_ru(GENITIVE)]..."))

	playsound(user, 'sound/items/handling/surgery/cautery1.ogg', 75, TRUE)

	if(!do_after(user, treatment_delay, target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	playsound(user, 'sound/items/handling/surgery/cautery2.ogg', 75, TRUE)

	var/bleeding_wording = (limb.can_bleed() ? "кровотечений" : "дыр")
	user.visible_message(span_green("[capitalize(user.declent_ru(NOMINATIVE))] прижигает часть [bleeding_wording] на [victim.declent_ru(PREPOSITIONAL)]."), span_green("Вы прижигаете часть [bleeding_wording] на [victim.declent_ru(PREPOSITIONAL)]."))
	victim.apply_damage(2 + severity, BURN, limb, wound_bonus = CANT_WOUND)
	if(prob(30))
		victim.emote("scream")
	var/blood_cauterized = (0.6 / (self_penalty_mult * improv_penalty_mult))
	adjust_blood_flow(-blood_cauterized)

	if(blood_flow > 0)
		try_treating(I, user)

/datum/wound_pregen_data/flesh_pierce
	abstract = TRUE

	required_limb_biostate = BIO_FLESH
	required_wounding_type = WOUND_PIERCE

	wound_series = WOUND_SERIES_FLESH_PUNCTURE_BLEED

/datum/wound/pierce/get_limb_examine_description()
	return span_warning("Кожа на этой конечности кажется сильно перфорированной.")

/datum/wound/pierce/bleed/moderate
	name = "Незначительный прокол"
	desc = "Кожа пациента была повреждена, вызвав сильный синяк и незначительное внутреннее кровотечение в пораженной области."
	treat_text = "Перевяжите или зашейте рану, используйте средства для свертывания крови, \
		прижигание или в крайних случаях - воздействие на рану сильным холодом или вакуумом. \
		Следует обеспечить прием пищи и период отдыха."
	treat_text_short = "Примените повязку, швы, средства для свертывания крови или прижигание."
	examine_desc = "имеет небольшое, слегка кровоточащее, разорванное отверстие"
	occur_text = "выбрызгивает тонкую струю крови"
	sound_effect = 'sound/effects/wounds/pierce1.ogg'
	severity = WOUND_SEVERITY_MODERATE
	initial_flow = 1.25
	gauzed_clot_rate = 0.75
	clot_rate = 0.03
	internal_bleeding_chance = 30
	internal_bleeding_coefficient = 1.5
	series_threshold_penalty = 20
	status_effect_type = /datum/status_effect/wound/pierce/moderate
	scar_keyword = "piercemoderate"

	simple_treat_text = "<b>Перевязывание</b> раны уменьшит кровопотерю, поможет ране быстрее закрыться самостоятельно и ускорит период восстановления крови. Саму рану можно медленно <b>зашить</b>."
	homemade_treat_text = "<b>Чай</b> стимулирует естественные лечебные системы организма, слегка ускоряя свёртывание крови. Рану также можно промыть в раковине или под душем. Другие средства не нужны."

/datum/wound/pierce/bleed/moderate/update_descriptions()
	if(!limb.can_bleed())
		examine_desc = "имеет небольшую рваную дыру"
		occur_text = "пробивает небольшую дыру"

/datum/wound_pregen_data/flesh_pierce/breakage
	abstract = FALSE

	wound_path_to_generate = /datum/wound/pierce/bleed/moderate

	threshold_minimum = 30

/datum/wound_pregen_data/flesh_pierce/breakage/get_weight(obj/item/bodypart/limb, woundtype, damage, attack_direction, damage_source)
	if (isprojectile(damage_source))
		return 0
	return weight

/datum/wound/pierce/bleed/moderate/needle_fail //for blood testamajig
	name = "Глубокий прокол"
	desc = "Кожа пациента была глубоко проколота, что привело к небольшому кровотечению."
	treat_text_short = "Наложить повязку или швы."
	examine_desc = "имеет небольшое красное отверстие, слегка кровоточит"
	initial_flow = 0.5 //very minor, mostly there as fluff and "dont do that idiot" reminder
	gauzed_clot_rate = 0.1
	clot_rate = 0.03 // will close quickly on its own
	internal_bleeding_chance = 0
	threshold_penalty = 5

/datum/wound_pregen_data/flesh_pierce/open_puncture/pinprick
	wound_path_to_generate = /datum/wound/pierce/bleed/moderate/needle_fail
	can_be_randomly_generated = FALSE
	abstract = FALSE

/datum/wound/pierce/bleed/moderate/projectile
	name = "Незначительный прокол кожи"
	desc = "Кожа пациента была пробита, что привело к сильным ушибам и небольшому внутреннему кровотечению в поражённой области."
	treat_text = "Наложить повязку или швы на рану, использовать кровоостанавливающие средства, \
		прижечь рану, либо в крайних случаях подвергнуть воздействию экстремального холода или вакуума. \
		Затем обеспечить питание и покой."
	examine_desc = "имеет небольшое круглое отверстие, слегка кровоточит"
	clot_rate = 0

/datum/wound/pierce/bleed/moderate/projectile/update_descriptions()
	if(!limb.can_bleed())
		examine_desc = "имеет небольшое круглое отверстие"
		occur_text = "разрывает небольшое отверстие"

/datum/wound/pierce/bleed/severe
	name = "Открытая колотая рана"
	desc = "Внутренние ткани пациента повреждены, что вызывает значительное внутреннее кровотечение и снижение стабильности конечности."
	treat_text = "Быстро примените повязку или швы к ране, используйте средства для свертывания крови или соляно-глюкозный раствор, \
		прижигание или в крайних случаях - воздействие на рану сильным холодом или вакуумом. \
		Следует дополнить лечение добавками железа и периодом отдыха."
	treat_text_short = "Примените повязку, швы, средства для свертывания крови или прижигание."
	examine_desc = "проколота насквозь, с кусочками ткани, закрывающими открытое отверстие"
	occur_text = "брызжет сильным фонтаном крови, обнажая проколотую рану"
	sound_effect = 'sound/effects/wounds/pierce2.ogg'
	severity = WOUND_SEVERITY_SEVERE
	initial_flow = 2
	gauzed_clot_rate = 0.5
	clot_rate = 0.02
	internal_bleeding_chance = 60
	internal_bleeding_coefficient = 2
	series_threshold_penalty = 35
	status_effect_type = /datum/status_effect/wound/pierce/severe
	scar_keyword = "piercesevere"

	simple_treat_text = "<b>Перевязывание</b> раны необходимо и поможет уменьшить кровотечение. После этого рану можно <b>зашить</b>, предпочтительно когда пациент отдыхает и/или держит свою рану."
	homemade_treat_text = "Простыни можно разорвать, чтобы сделать <b>самодельный бинт</b>. <b>Мука, поваренная соль или соль, смешанная с водой</b> могут быть нанесены непосредственно на рану, чтобы остановить кровотечение, хотя неразмешанная соль будет раздражать кожу и ухудшать естественное заживление. Падение на землю и удерживание раны снизит кровотечение."

/datum/wound/pierce/bleed/severe/update_descriptions()
	if(!limb.can_bleed())
		occur_text = "разрывает отверстие"

/datum/wound_pregen_data/flesh_pierce/open_puncture
	abstract = FALSE

	wound_path_to_generate = /datum/wound/pierce/bleed/severe

	threshold_minimum = 50

/datum/wound_pregen_data/flesh_pierce/open_puncture/get_weight(obj/item/bodypart/limb, woundtype, damage, attack_direction, damage_source)
	if (isprojectile(damage_source))
		return 0
	return weight

/datum/wound/pierce/bleed/severe/projectile
	name = "Открытое пулевое ранение"
	examine_desc = "пробито насквозь, с кусочками ткани, закрывающими аккуратно разорванную дыру"
	clot_rate = 0

/datum/wound_pregen_data/flesh_pierce/open_puncture/projectile
	wound_path_to_generate = /datum/wound/pierce/bleed/severe/projectile

/datum/wound_pregen_data/flesh_pierce/open_puncture/projectile/get_weight(obj/item/bodypart/limb, woundtype, damage, attack_direction, damage_source)
	if (!isprojectile(damage_source))
		return 0
	return weight

/datum/wound/pierce/bleed/severe/eye
	name = "Прокол глазного яблока"
	desc = "Глаз пациента получил серьёзные повреждения, вызывающее сильное кровотечение из глазной полости."
	occur_text = "брызжет кровь, обнажая раздавленное глазное яблоко"
	var/right_side = FALSE

/datum/wound/pierce/bleed/severe/eye/apply_wound(obj/item/bodypart/limb, silent, datum/wound/old_wound, smited, attack_direction, wound_source, replacing, right_side)
	var/obj/item/organ/eyes/eyes = locate() in limb
	if (!istype(eyes))
		return FALSE
	. = ..()
	src.right_side = right_side
	examine_desc = "имеет ранение в [right_side ? "правом" : "левом"] глазу, и из раны течёт кровь"
	RegisterSignal(limb, COMSIG_BODYPART_UPDATE_WOUND_OVERLAY, PROC_REF(wound_overlay))
	limb.update_part_wound_overlay()

/datum/wound/pierce/bleed/severe/eye/remove_wound(ignore_limb, replaced, destroying)
	if (!isnull(limb))
		UnregisterSignal(limb, COMSIG_BODYPART_UPDATE_WOUND_OVERLAY)
	return ..()

/datum/wound/pierce/bleed/severe/eye/proc/wound_overlay(obj/item/bodypart/source, limb_bleed_rate)
	SIGNAL_HANDLER

	if (limb_bleed_rate <= BLEED_OVERLAY_LOW || limb_bleed_rate > BLEED_OVERLAY_GUSH)
		return

	if (blood_flow <= BLEED_OVERLAY_LOW)
		return

	source.bleed_overlay_icon = right_side ? "r_eye" : "l_eye"
	return COMPONENT_PREVENT_WOUND_OVERLAY_UPDATE

/datum/wound_pregen_data/flesh_pierce/open_puncture/eye
	wound_path_to_generate = /datum/wound/pierce/bleed/severe/eye
	viable_zones = list(BODY_ZONE_HEAD)
	can_be_randomly_generated = FALSE

/datum/wound_pregen_data/flesh_pierce/open_puncture/eye/can_be_applied_to(obj/item/bodypart/limb, list/suggested_wounding_types, datum/wound/old_wound, random_roll, duplicates_allowed, care_about_existing_wounds)
	if (isnull(locate(/obj/item/organ/eyes) in limb))
		return FALSE
	return ..()

/datum/wound/pierce/bleed/severe/magicalearpain //what happens if you try to listen to the heartbeat of a corrupt heart while not a heretic
	name = "Кровоточащие уши"
	desc = "Уши пациента сильно кровоточат, так как кровь каким-то неизвестным образом просачивается через внутреннюю поверхность уха."
	examine_desc = "всё покрыто кровью, из ушей течёт чёрно-фиолетовая жидкость"
	occur_text = "промокает полностью, когда из ушей вырываются две струйки чёрной жидкости"
	internal_bleeding_chance = 0 // just your ears

/datum/wound_pregen_data/flesh_pierce/open_puncture/magicalearpain
	wound_path_to_generate = /datum/wound/pierce/bleed/severe/magicalearpain
	viable_zones = list(BODY_ZONE_HEAD)
	can_be_randomly_generated = FALSE

/datum/wound/pierce/bleed/severe/magicalearpain/apply_wound(obj/item/bodypart/limb, silent, datum/wound/old_wound, smited, attack_direction, wound_source, replacing)
	var/obj/item/organ/ears/ears = locate() in limb
	if (!istype(ears))
		return FALSE
	. = ..()

/datum/wound/pierce/bleed/critical
	name = "Разрыв полости"
	desc = "Внутренние ткани и кровеносная система пациента разорваны, что вызывает значительное внутреннее кровотечение и повреждение внутренних органов."
	treat_text = "Быстро примените повязку или швы к ране, используйте средства для свертывания крови или соляно-глюкозный раствор, \
		прижигание или в крайних случаях - воздействие на рану сильным холодом или вакуумом. \
		Затем следует провести контролируемую реинфузию."
	treat_text_short = "Примените повязку, швы, средства для свертывания крови или прижигание."
	examine_desc = "разорвана насквозь, едва удерживается на месте открытой костью"
	occur_text = "разлетается на куски, отправляя части внутренностей во все стороны"
	sound_effect = 'sound/effects/wounds/pierce3.ogg'
	severity = WOUND_SEVERITY_CRITICAL
	initial_flow = 2.5
	gauzed_clot_rate = 0.3
	internal_bleeding_chance = 80
	internal_bleeding_coefficient = 2.5
	threshold_penalty = 15
	status_effect_type = /datum/status_effect/wound/pierce/critical
	scar_keyword = "piercecritical"
	surgery_states = SURGERY_SKIN_CUT | SURGERY_VESSELS_UNCLAMPED // Bad enough to count
	wound_flags = (ACCEPTS_GAUZE | MANGLES_EXTERIOR | CAN_BE_GRASPED)

	simple_treat_text = "<b>Перевязывание</b> раны имеет первостепенное значение, так же как и получение непосредственной медицинской помощи - <b>Смерть</b> наступит, если лечение будет задержано, так как недостаток <b>кислорода</b> убьет пациента, поэтому <b>пища, железо и солево-глюкозный раствор</b> всегда рекомендуются после лечения. Эта рана не заживет самостоятельно."
	homemade_treat_text = "Простыни можно разорвать, чтобы сделать <b>самодельный бинт</b>. <b>Мука, соль и соленая вода</b>, нанесенные на кожу, помогут. Падение на землю и удерживание раны снизит кровотечение."

/datum/wound_pregen_data/flesh_pierce/cavity
	abstract = FALSE

	wound_path_to_generate = /datum/wound/pierce/bleed/critical

	threshold_minimum = 100

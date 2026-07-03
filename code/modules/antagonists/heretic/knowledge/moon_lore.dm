/datum/heretic_knowledge_tree_column/moon
	route = PATH_MOON
	ui_bgr = "node_moon"
	complexity = "Высокая"
	complexity_color = COLOR_RED
	icon = list(
		"icon" = 'icons/obj/weapons/khopesh.dmi',
		"state" = "moon_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"Путь Луны фокусируется на здравомыслии, сея смятение и разлад в головах ваших противников, нарушая привычные правила боя.",
		"Выбирайте этот путь, если у вас уже есть опыт игры на Еретике и хочется попробовать нечто уникальное, или просто хочется отыграть пацифиста (Да, именно так!)."
	)
	pros = list(
		"Богатый набор инструментов для запутывания ваших противников.",
		"Сейте хаос на станции при помощи безумцев.",
		"Невосприимчивость к эффектам оглушения при ношении Блистательного облачения."
	)
	cons = list(
		"Отсутствует мобильность.",
		"Отсутствуют навыки для нанесения урона напрямую.",
		"Зависимость от запутывания и ошеломления противника.",
		"Безумцы могут стать помехой.",
		"Крайне уязвим, несмотря на уникальную механику защиты.",
		"Смерть, во время ношения Блистательного облачения, приведет к крайне кровавому финалу.",
	)
	tips = list(
		"Использование «Хватки Мансуса» накладывает на цель кратковременные галлюцинации, а также метку, активируемую вашим Лунным клинком. Активация Метки усмиряет цель, а также вводит её в замешательство (усмирение спадает, если цель получила слишком много урона).",
		"Ваш Лунный клинок уникален в сравнении с клинками других путей, вы можете пользоваться им даже если подверглись пацификации.",
		"Ваш пассивный навык делает вас полностью невосприимчивым к повреждениям мозга, а также медленно восстанавливают его здоровье. Обязательно улучшите его, чтобы усилить эффект.",
		"Ваше Блистательное облачение значительно меняет правила боя для вас и ваших противников; Вы становитесь полностью неуязвимы для эффектов оглушения, а все полученные повреждения (смертельные или несмертельные) будут преобразованы в повреждения мозга, однако сама мантия не имеет брони и препятствует использованию стрелкового оружия, пацифицируя вас (вы все ещё можете использовать Лунный клинок).",
		"Эффекты вашего Лунного амулета проецируются на Лунный клинок. При активации, ваш Лунный клинок больше не будет наносить смертельный урон, он будет наносить урон рассудку и станет неблокируемым, что также позволит вам использовать его в Блистательном облачении!",
		"Ваш Лунный амулет ключевой элемент вашего снаряжения, при ношении, он удвоит скорость восстановления повреждений мозга.",
		"Если рассудок ваших оппонентов упадет ниже определенного значения, они обезумят. Безумцам будет предложено нападать на всех (в том числе и вас). Если вы захотите принести их в жертву (или заставить их оставить вас в покое), ударьте их еще раз своим Лунным клинком, чтобы усыпить.",
		"«Восшествие Артистов» призывает армию клонов. Они практически не наносят урон, но если на них нападут неверные, они взорвутся, приводя к потере рассудка и нанесению урона мозгу.",
		"Ваше возвышение даст вам ауру, превращающую ближайших к вам людей в верных вам сумасшедших. Однако, если у цели есть имплант защиты разума, то вместо порабощения, через некоторое время их головы просто взорвутся.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_moon
	knowledge_tier1 = /datum/heretic_knowledge/spell/mind_gate
	guaranteed_side_tier1 = /datum/heretic_knowledge/phylactery
	knowledge_tier2 = /datum/heretic_knowledge/moon_amulet
	guaranteed_side_tier2 = /datum/heretic_knowledge/codex_morbus
	robes = /datum/heretic_knowledge/armor/moon
	knowledge_tier3 = /datum/heretic_knowledge/spell/moon_parade
	guaranteed_side_tier3 = /datum/heretic_knowledge/unfathomable_curio
	blade = /datum/heretic_knowledge/blade_upgrade/moon
	knowledge_tier4 = /datum/heretic_knowledge/spell/moon_ringleader
	ascension = /datum/heretic_knowledge/ultimate/moon_final

/datum/heretic_knowledge/limited_amount/starting/base_moon
	name = "Лунная тропа"
	desc = "Открывает перед вами Путь Луны. \
		Позволяет трансмутировать 2 листа стекла и нож в Лунный клинок. \
		Одновременно можно иметь только два."
	gain_text = "Под лунным светом смех отдается эхом."
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/stack/sheet/glass = 2,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/moon)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "moon_blade"
	mark_type = /datum/status_effect/eldritch/moon
	eldritch_passive = /datum/status_effect/heretic_passive/moon

/datum/heretic_knowledge/limited_amount/starting/base_moon/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	user.AddComponentFrom(REF(src), /datum/component/empathy, seen_it = TRUE, visible_info = ALL, self_empath = FALSE, sense_dead = FALSE, sense_whisper = TRUE, smite_target = FALSE)

/datum/heretic_knowledge/limited_amount/starting/base_moon/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(target.can_block_magic(MAGIC_RESISTANCE_MOON))
		to_chat(target, span_danger("Вы слышите эхо смеха сверху... но оно глухое и отдалённое."))
		return

	source.apply_status_effect(/datum/status_effect/moon_grasp_hide)

	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon_target = target
	to_chat(carbon_target, span_danger("Сверху доносится смех, отдающийся эхом."))
	carbon_target.cause_hallucination(/datum/hallucination/delusion/preset/moon, "delusion/preset/moon hallucination caused by mansus grasp")
	carbon_target.mob_mood.adjust_sanity(-30)

/datum/heretic_knowledge/spell/mind_gate
	name = "Врата Разума"
	desc = "Дарует вам «Врата Разума» - заклинание, отнимающее голос, лишающее слуха, зрения, наводящее галлюцинации, \
		смятение, лишающее воздуха и наносящее урон мозгу цели в течение 10с.\
		Заклинатель получает 20 единиц урона мозга за каждое использование."
	gain_text = "Мой разум распахивается, как врата, и его возвышение позволит мне постичь истину."

	action_to_add = /datum/action/cooldown/spell/pointed/mind_gate
	cost = 2

/datum/heretic_knowledge/moon_amulet
	name = "Лунный амулет"
	desc = "Позволяет трансмутировать 2 листа стекла, сердце и галстук, чтобы создать Лунный амулет. \
			Если предметом пользуется человек с слабым рассудком, то он становятся берсерком, нападающим на всех подряд; \
			если рассудок недостаточно низок, то он начнет постепенно убывать. \
			Ношение этого предмета дарует вам способность видеть язычников сквозь стены, а ваши клинки сделает безвредными - они будут калечить разум жертв. \
			Предоставляет термальное зрение и удваивает регенерацию мозга еретика Луны при ношении."
	gain_text = "Во главе парада стоял он, луна сгустилась в единную массу, отражение души."

	required_atoms = list(
		/obj/item/organ/heart = 1,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/clothing/neck/tie = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus/moon_amulet)
	cost = 2

	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "moon_amulette"
	research_tree_icon_frame = 9

/datum/heretic_knowledge/armor/moon
	desc = "Позволяет преобразовать стол (или костюм), маску и два листа стекла для создания Блистательного облачения, эта роба сделает носителя невосприимчивым к эффектам оглушения, преобразует все виды повреждений в урон мозгу, а также пацифицируя носителя, лишая его возможности пользоваться дальнобойным оружием (Лунные клинки обходят пацифизм). \
			Действует как фокусировка, пока надет капюшон."
	gain_text = "Струи света и веселья струились из каждой складки этого великолепного наряда. \
				Труппа кружилась радужными каскадами, ослепляя зрителей истиной, которую они искали. \
				Купаясь в свете, я наблюдал, как обретаю себя."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon)
	research_tree_icon_state = "moon_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/stack/sheet/glass = 2,
	)

/datum/heretic_knowledge/spell/moon_parade
	name = "Лунный парад"
	desc = "Дарует вам «Лунный парад» - заклинание после короткой зарядки, отправляет вперед снаряд \
		при попадании которого, цель присоединяется к параду, и начинает страдать от галюцинаций."
	gain_text = "Музыка, словно отражение души, завораживала их, ведя их за собой, как мотыльков ведет за собой пламя."
	action_to_add = /datum/action/cooldown/spell/pointed/projectile/moon_parade
	cost = 2
	drafting_tier = 5

/datum/heretic_knowledge/blade_upgrade/moon
	name = "Лунный клинок"
	desc = "Ваш клинок теперь наносит урон мозгу и рассудку, а также вызывает случайные галлюцинации. \
			Наносит больше урона мозгу если жертва лишилась рассудка или спит."
	gain_text = "Его остроумие было острым, как клинок, оно прорезало ложь, чтобы принести нам радость."

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_moon"

/datum/heretic_knowledge/blade_upgrade/moon/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	if(target.can_block_magic(MAGIC_RESISTANCE_MOON))
		return

	target.cause_hallucination( \
			get_random_valid_hallucination_subtype(/datum/hallucination/body), \
			"upgraded path of moon blades", \
		)
	target.emote(pick("giggle", "laugh"))
	target.mob_mood?.adjust_sanity(-10)
	if(target.stat == CONSCIOUS && target.mob_mood?.sanity >= SANITY_NEUTRAL)
		target.adjust_organ_loss(ORGAN_SLOT_BRAIN, 10)
		return
	target.adjust_organ_loss(ORGAN_SLOT_BRAIN, 25)

/datum/heretic_knowledge/spell/moon_ringleader
	name = "Восшествие Артистов"
	desc = "Дарует вам «Восшествие Артистов» - заклинание действующее на область, и наносящее урон мозгу, пропорционально недостающему рассудку целей, \
			также вызывает галлюцинации, чем слабее разум цели, тем сильнее галюцинации. \
			Если значение их рассудка достаточно низкое, цель сойдет с ума, лишившись половины имевшегося рассудка."
	gain_text = "Взял его за руку, мы поднялись, и те, кто видел правду, поднялись вместе с нами. \
		Постановщик указал вверх, и тусклый свет правды осветил нас еще больше."

	action_to_add = /datum/action/cooldown/spell/aoe/moon_ringleader
	cost = 2

	research_tree_icon_frame = 5
	is_final_knowledge = TRUE

/datum/heretic_knowledge/ultimate/moon_final
	name = "Последний Акт"
	desc = "Ритуал вознесения Пути луны. \
		Принесите 3 трупа с более чем 50 урона мозгу на руну трансмутации, чтобы завершить ритуал \
		При завершении, вы становитесь предвестником безумия и получаете ауру пассивного снижения рассудка, \
		а члены экипажа с достаточно низким рассудком станут аколитами. \
		Одна пятая экипажа превратится в аколитов и будет следовать вашим приказам, также они получат Moonlight Amulet"
	gain_text = "Мы нырнули вниз, к толпе, его душа отделилась в поисках более великой авантюры, \
		туда, откуда Постановщик начал парад, и я продолжу его до самой кончины солнца \
		УЗРИТЕ МОЕ ВОЗНЕСЕНИЕ, ЛУНА УЛЫБНЕТСЯ РАЗ И НАВСЕГДА!"

	ascension_achievement = /datum/award/achievement/misc/moon_ascension
	announcement_text = "%SPOOKY% Смейтесь, ибо Постановщик %NAME% вознесся! \
						Правда наконец поглотит ложь! %SPOOKY%"
	announcement_sound = 'sound/music/antag/heretic/ascend_moon.ogg'

/datum/heretic_knowledge/ultimate/moon_final/is_valid_sacrifice(mob/living/sacrifice)

	var/brain_damage = sacrifice.get_organ_loss(ORGAN_SLOT_BRAIN)
	// Checks if our target has enough brain damage
	if(brain_damage < 50)
		return FALSE

	return ..()

/datum/heretic_knowledge/ultimate/moon_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	ADD_TRAIT(user, TRAIT_MADNESS_IMMUNE, type)
	user.mind.add_antag_datum(/datum/antagonist/lunatic/master)
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))

	var/amount_of_lunatics = 0
	var/list/lunatic_candidates = list()
	for(var/mob/living/carbon/human/crewmate as anything in shuffle(GLOB.human_list))
		if(QDELETED(crewmate) || isnull(crewmate.client) || isnull(crewmate.mind) || crewmate.stat != CONSCIOUS || crewmate.can_block_magic(MAGIC_RESISTANCE_MIND))
			continue
		var/turf/crewmate_turf = get_turf(crewmate)
		var/crewmate_z = crewmate_turf?.z
		if(!is_station_level(crewmate_z))
			continue
		lunatic_candidates += crewmate

	// Roughly 1/5th of the station will rise up as lunatics to the heretic.
	// We use either the (locked) manifest for the maximum, or the amount of candidates, whichever is larger.
	// If there's more eligible humans than crew, more power to them I guess.
	var/max_lunatics = ceil(max(length(GLOB.manifest.locked), length(lunatic_candidates)) * 0.2)

	for(var/mob/living/carbon/human/crewmate as anything in lunatic_candidates)
		if(amount_of_lunatics > max_lunatics)
			to_chat(crewmate, span_boldwarning("Вы чувствуете неспокойство, как будто на мгновение что-то взглянуло на вас."))
			continue
		if(attempt_conversion(crewmate, user))
			amount_of_lunatics++

/datum/heretic_knowledge/ultimate/moon_final/proc/attempt_conversion(mob/living/carbon/convertee, mob/user)
	// Heretics, lunatics and monsters shouldn't become lunatics because they either have a master or have a mansus grasp
	if(IS_HERETIC_OR_MONSTER(convertee))
		to_chat(convertee, span_boldwarning("Возвышение [user.declent_ru(GENITIVE)] оказывает влияние на тех, чья воля слаба. Их разум будет разрушен." ))
		return FALSE
	// Mindshielded and anti-magic folks are immune against this effect because this is a magical mind effect
	if(HAS_MIND_TRAIT(convertee, TRAIT_UNCONVERTABLE) || convertee.can_block_magic(MAGIC_RESISTANCE))
		to_chat(convertee, span_boldwarning("Вы чувствуете себя защищенным от чего-то." ))
		return FALSE

	if(!convertee.mind)
		return FALSE

	var/datum/antagonist/lunatic/lunatic = convertee.mind.add_antag_datum(/datum/antagonist/lunatic)
	lunatic.set_master(user.mind, user)
	var/obj/item/clothing/neck/heretic_focus/moon_amulet/amulet = new(convertee.drop_location())
	var/static/list/slots = list(
		LOCATION_NECK,
		LOCATION_HANDS,
		LOCATION_RPOCKET,
		LOCATION_LPOCKET,
		LOCATION_BACKPACK,
	)
	convertee.equip_in_one_of_slots(amulet, slots, qdel_on_fail = FALSE)
	INVOKE_ASYNC(convertee, TYPE_PROC_REF(/mob, emote), "laugh")
	return TRUE

/datum/heretic_knowledge/ultimate/moon_final/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	visible_hallucination_pulse(
		center = get_turf(source),
		radius = 7,
		hallucination_duration = 60 SECONDS
	)

	for(var/mob/living/carbon/carbon_view in range(7, source))
		var/carbon_sanity = carbon_view.mob_mood.sanity
		if(carbon_view.stat != CONSCIOUS)
			continue
		if(IS_HERETIC_OR_MONSTER(carbon_view))
			continue
		if(carbon_view.can_block_magic(MAGIC_RESISTANCE_MOON)) //Somehow a shitty piece of tinfoil is STILL able to hold out against the power of an ascended heretic.
			continue
		new /obj/effect/temp_visual/moon_ringleader(get_turf(carbon_view))
		if(carbon_view.has_status_effect(/datum/status_effect/confusion))
			to_chat(carbon_view, span_big(span_hypnophrase("ВАШ РАЗУМ ТРЕЩИТ ОТ ТЫСЯЧИ ГОЛОСОВ, СЛИТЫХ В БЕЗУМНУЮ КАКОФОНИЮ ЗВУКОВ И МУЗЫКИ. КАЖДАЯ ЩЕПКА ВАШЕГО СУЩЕСТВА КРИЧИТ: «БЕГИ».")))
		carbon_view.adjust_confusion(2 SECONDS)
		carbon_view.mob_mood.adjust_sanity(-20)

		if(carbon_sanity >= 10)
			continue
		// So our sanity is dead, time to fuck em up
		if(SPT_PROB(20, seconds_per_tick))
			to_chat(carbon_view, span_warning("оно эхом отдаётся в вас!"))
		visible_hallucination_pulse(
			center = get_turf(carbon_view),
			radius = 7,
			hallucination_duration = 50 SECONDS
		)
		carbon_view.adjust_temp_blindness(5 SECONDS)
		if(should_mind_explode(carbon_view))
			to_chat(carbon_view, span_boldbig(span_red(\
				"ВАШИ ЧУВСТВА ОХВАЧЕНЫ УЖАСОМ, КОГДА В ВАШ РАЗУМ ВТОРГАЕТСЯ ПОТУСТОРОННЯЯ СИЛА, ПЫТАЮЩАЯСЯ ПЕРЕПИСЫВАТЬ ВАШЕ СУЩЕСТВО. \
				ВЫ ДАЖЕ НЕ УСПЕВАЕТЕ КРИКНУТЬ, КАК ВАШ ИМПЛАНТ АКТИВИРУЕТ СВОЮ СИСТЕМУ АВАРИЙНОЙ ПСИОНИЧЕСКОЙ ЗАЩИТЫ, СНОСЯ ВАМ ГОЛОВУ.")))
			var/obj/item/bodypart/head/head = carbon_view.get_bodypart(BODY_ZONE_HEAD)
			if(!head?.dismember())
				carbon_view.gib(DROP_ALL_REMAINS)
			var/datum/effect_system/reagents_explosion/explosion = new(get_turf(carbon_view), 1, 1, 1)
			explosion.start(src)
		else
			attempt_conversion(carbon_view, source)


/datum/heretic_knowledge/ultimate/moon_final/proc/should_mind_explode(mob/living/carbon/target)
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		return TRUE
	if(IS_CULTIST_OR_CULTIST_MOB(target))
		return TRUE
	return FALSE

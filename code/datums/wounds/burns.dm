
/*
	Burn wounds
*/

// TODO: well, a lot really, but specifically I want to add potential fusing of clothing/equipment on the affected area, and limb infections, though those may go in body part code
/datum/wound/burn
	name = "Burn Wound"
	undiagnosed_name = "Burns"
	a_or_from = "from"
	sound_effect = 'sound/effects/wounds/sizzle1.ogg'

/datum/wound/burn/flesh
	name = "Burn (Flesh) Wound"
	a_or_from = "from"
	processes = TRUE
	threshold_penalty = 15

	default_scar_file = FLESH_SCAR_FILE

	// Flesh damage vars
	/// How much damage to our flesh we currently have. Once both this and infection reach 0, the wound is considered healed
	var/flesh_damage = 5
	/// Our current counter for how much flesh regeneration we have stacked from regenerative mesh/synthflesh/whatever, decrements each tick and lowers flesh_damage
	var/flesh_healing = 0

	// Infection vars (only for severe and critical)
	/// How quickly infection breeds on this burn if we don't have disinfectant
	var/infection_rate = 0
	/// Our current level of infection
	var/infection = 0
	/// Our current level of sanitization/anti-infection, from disinfectants/alcohol/UV lights. While positive, totally pauses and slowly reverses infection effects each tick
	var/sanitization = 0

	/// Once we reach infection beyond WOUND_INFECTION_SEPTIC, we get this many warnings before the limb is completely paralyzed (you'd have to ignore a really bad burn for a really long time for this to happen)
	var/strikes_to_lose_limb = 3

/datum/wound/burn/flesh/handle_process(seconds_per_tick)

	if (!victim || HAS_TRAIT(victim, TRAIT_STASIS))
		return

	. = ..()
	if(strikes_to_lose_limb <= 0) // we've already hit sepsis, nothing more to do
		victim.adjust_tox_loss(0.25 * seconds_per_tick)
		if(SPT_PROB(0.5, seconds_per_tick))
			victim.visible_message(span_danger("Инфекция на остатках [limb.ru_plaintext_zone[GENITIVE] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)] тошнотворно пузырится!"), span_warning("Вы чувствуете, как инфекция на остатках вашей [limb.ru_plaintext_zone[GENITIVE] || limb.plaintext_zone] проникает в ваши вены!"), vision_distance = COMBAT_MESSAGE_RANGE)
		return

	for(var/datum/reagent/reagent as anything in victim.reagents.reagent_list)
		if(reagent.chemical_flags & REAGENT_AFFECTS_WOUNDS)
			reagent.on_burn_wound_processing(src)

	if(HAS_TRAIT(victim, TRAIT_VIRUS_RESISTANCE))
		sanitization += 0.9
	if(HAS_TRAIT(victim, TRAIT_IMMUNODEFICIENCY))
		infection += 0.05
		sanitization = max(sanitization - 0.15, 0)
		if(infection_rate <= 0.15 && prob(50))
			infection_rate += 0.001

	var/obj/item/stack/medical/wrap/current_gauze = LAZYACCESS(limb.applied_items, LIMB_ITEM_GAUZE)
	if(current_gauze)
		limb.seep_gauze(WOUND_BURN_SANITIZATION_RATE * seconds_per_tick)

	if(flesh_healing > 0) // good bandages multiply the length of flesh healing
		var/bandage_factor = current_gauze?.burn_cleanliness_bonus || 1
		flesh_damage = max(flesh_damage - (0.5 * seconds_per_tick), 0)
		flesh_healing = max(flesh_healing - (0.5 * bandage_factor * seconds_per_tick), 0) // good bandages multiply the length of flesh healing

	// if we have little/no infection, the limb doesn't have much burn damage, and our nutrition is good, heal some flesh
	if(infection <= WOUND_INFECTION_MODERATE && (limb.burn_dam < 5) && (victim.nutrition >= NUTRITION_LEVEL_FED))
		flesh_healing += 0.2

	// here's the check to see if we're cleared up
	if((flesh_damage <= 0) && (infection <= WOUND_INFECTION_MODERATE))
		to_chat(victim, span_green("Ожоги на вашей [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] зажили!"))
		qdel(src)
		return

	// sanitization is checked after the clearing check but before the actual ill-effects, because we freeze the effects of infection while we have sanitization
	if(sanitization > 0)
		var/bandage_factor = current_gauze?.burn_cleanliness_bonus || 1
		infection = max(infection - (WOUND_BURN_SANITIZATION_RATE * seconds_per_tick), 0)
		sanitization = max(sanitization - (WOUND_BURN_SANITIZATION_RATE * bandage_factor * seconds_per_tick), 0)
		return

	infection += infection_rate * seconds_per_tick
	switch(infection)
		if(0 to WOUND_INFECTION_MODERATE)
			return

		if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
			if(SPT_PROB(15, seconds_per_tick))
				victim.adjust_tox_loss(0.2)
				if(prob(6))
					to_chat(victim, span_warning("Волдыри на вашей [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] выделяют странный гной..."))

		if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
			if(!disabling)
				if(SPT_PROB(1, seconds_per_tick))
					to_chat(victim, span_warning("<b>Ваша [limb.ru_plaintext_zone[ACCUSATIVE] || limb.plaintext_zone] полностью утратила чувствительность, и вы боретесь за контроль над инфекцией!</b>"))
					set_disabling(TRUE)
					return
			else if(SPT_PROB(4, seconds_per_tick))
				to_chat(victim, span_notice("Вы вновь чувствуете свою [limb.ru_plaintext_zone[ACCUSATIVE] || limb.plaintext_zone], но она по-прежнему в ужасном состоянии!"))
				set_disabling(FALSE)
				return

			if(SPT_PROB(10, seconds_per_tick))
				victim.adjust_tox_loss(0.5)

		if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
			if(!disabling)
				if(SPT_PROB(1.5, seconds_per_tick))
					to_chat(victim, span_warning("<b>Вы внезапно теряете все ощущения от гнойной инфекции в вашей [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone]!</b>"))
					set_disabling(TRUE)
					return
			else if(SPT_PROB(1.5, seconds_per_tick))
				to_chat(victim, span_notice("Вы едва чувствуете свою [limb.ru_plaintext_zone[ACCUSATIVE] || limb.plaintext_zone] снова, и вам нужно напрягаться, чтобы сохранить контроль над моторикой!"))
				set_disabling(FALSE)
				return

			if(SPT_PROB(2.48, seconds_per_tick))
				if(prob(20))
					to_chat(victim, span_warning("Вы размышляете о жизни без своей [limb.ru_plaintext_zone[GENITIVE] || limb.plaintext_zone]..."))
					victim.adjust_tox_loss(0.75)
				else
					victim.adjust_tox_loss(1)

		if(WOUND_INFECTION_SEPTIC to INFINITY)
			if(SPT_PROB(0.5 * infection, seconds_per_tick))
				strikes_to_lose_limb--
				switch(strikes_to_lose_limb)
					if(2 to INFINITY)
						to_chat(victim, span_deadsay("<b>Инфекция в вашей [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] буквально сочится, вы чувствуете себя ужасно!</b>"))
					if(1)
						to_chat(victim, span_deadsay("<b>Инфекция почти полностью захватила вашу [limb.ru_plaintext_zone[ACCUSATIVE] || limb.plaintext_zone]!</b>"))
					if(0)
						to_chat(victim, span_deadsay("<b>Последние нервные окончания в вашей [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] увядают, пока инфекция полностью парализует ваш сустав.</b>"))
						threshold_penalty *= 2 // piss easy to destroy
						set_disabling(TRUE)

/datum/wound/burn/flesh/set_disabling(new_value)
	. = ..()
	if(new_value && strikes_to_lose_limb <= 0)
		treat_text_short = "Ампутируйте или аугментируйте конечность немедленно, или поместите пациента в криогенику."
	else
		treat_text_short = initial(treat_text_short)

/datum/wound/burn/flesh/get_wound_description(mob/user)
	if(strikes_to_lose_limb <= 0)
		return span_deadsay("<B>[capitalize(victim.ru_p_them())] [limb.ru_plaintext_zone[NOMINATIVE] || limb.plaintext_zone] полностью обезжизнена и не функционирует.</B>")

	var/obj/item/stack/medical/wrap/current_gauze = LAZYACCESS(limb.applied_items, LIMB_ITEM_GAUZE)
	var/list/condition = list("[capitalize(victim.ru_p_them())] [limb.ru_plaintext_zone[NOMINATIVE] || limb.plaintext_zone] [examine_desc]")
	if(current_gauze)
		var/bandage_condition
		switch(current_gauze.absorption_capacity)
			if(0 to 1.25)
				bandage_condition = "почти спала"
			if(1.25 to 2.75)
				bandage_condition = "сильно износилась"
			if(2.75 to 4)
				bandage_condition = "слегка запачкана кровью"
			if(4 to INFINITY)
				bandage_condition = "чиста"

		condition += ", и перевязана [current_gauze.declent_ru(INSTRUMENTAL)]. Повязка [bandage_condition]."
	else
		switch(infection)
			if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
				condition += ", [span_deadsay("и видны ранние признаки инфекции.")]"
			if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
				condition += ", [span_deadsay("и видны растущие облака инфекции.")]"
			if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
				condition += ", [span_deadsay("и видны полосы гнилой инфекции!")]"
			if(WOUND_INFECTION_SEPTIC to INFINITY)
				return span_deadsay("<B>[capitalize(victim.ru_p_them())] [limb.ru_plaintext_zone[NOMINATIVE] || limb.plaintext_zone] представляет собой мессиво из обожженной кожи и зараженного гниения!</B>")
			else
				condition += "!"

	return "<B>[condition.Join()]</B>"

/datum/wound/burn/flesh/severity_text(simple = FALSE)
	. = ..()
	. += " Ожог / "
	switch(infection)
		if(-INFINITY to WOUND_INFECTION_MODERATE)
			. += "Отсутствует"
		if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
			. += "Умеренная"
		if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
			. += "<b>Серьезная</b>"
		if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
			. += "<b>Критическая</b>"
		if(WOUND_INFECTION_SEPTIC to INFINITY)
			. += "<b>Полностью распространенная</b>"
	. += " инфекция"

/datum/wound/burn/flesh/get_scanner_description(mob/user)
	if(strikes_to_lose_limb <= 0) // Unclear if it can go below 0, best to not take the chance
		var/oopsie = "Тип: [name]<br>Тяжесть: [severity_text()]"
		oopsie += "<div class='ml-3'>Уровень инфекции: [span_deadsay("Часть тела пострадала от полной сепсиса и должна быть удалена. Ампутируйте или аугментируйте конечность немедленно, или поместите пациента в криогенику.")]</div>"
		return oopsie

	. = ..()
	. += "<div class='ml-3'>"

	if(infection <= sanitization && flesh_damage <= flesh_healing)
		. += "Дополнительное лечение не требуется: Ожоги заживут в ближайшее время."
	else
		switch(infection)
			if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
				. += "Уровень инфекции: Умеренный\n"
			if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
				. += "Уровень инфекции: Серьезный\n"
			if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
				. += "Уровень инфекции: [span_deadsay("КРИТИЧЕСКИЙ")]\n"
			if(WOUND_INFECTION_SEPTIC to INFINITY)
				. += "Уровень инфекции: [span_deadsay("ПОТЕРЯ НЕМИУЕМА")]\n"
		if(infection > sanitization)
			. += "\tХирургическая обработка, антибиотики/стерилизаторы или регенеративная сетка избавят от инфекции. Ультрафиолетовые ручные фонарики парамедиков также эффективны.\n"

		if(flesh_damage > 0)
			. += "Обнаружено повреждение ткани: Применение мази, регенеративной сетки, синтплоти или шахтерской мази помогут восстановить поврежденную кожу. Хорошее питание, отдых и поддержание чистоты раны также могут медленно восстановить плоть.\n"
	. += "</div>"

/*
	new burn common procs
*/

/// Checks if the wound is in a state that ointment or flesh will help
/datum/wound/burn/flesh/proc/can_be_ointmented_or_meshed()
	if(infection > 0 && sanitization < infection)
		return TRUE
	if(flesh_damage > 0 && flesh_healing <= flesh_damage)
		return TRUE
	return FALSE

/// Paramedic UV penlights
/datum/wound/burn/flesh/proc/uv(obj/item/flashlight/pen/paramedic/I, mob/user)
	if(!COOLDOWN_FINISHED(I, uv_cooldown))
		to_chat(user, span_notice("[capitalize(I.declent_ru(NOMINATIVE))] еще перезаряжается!"))
		return
	if(infection <= 0 || infection < sanitization)
		to_chat(user, span_notice("Заражение на [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)] уже излечивается, и дополнительная обработка ультрафиолетом не требуется!"))
		return

	user.visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] дезинфицирует ожоги [limb.ru_plaintext_zone[GENITIVE] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)] при помощи [I.declent_ru(GENITIVE)]."), span_notice("Вы дезинфицируете ожоги [limb.ru_plaintext_zone[GENITIVE] || limb.plaintext_zone] у [user == victim ? "вас" : "[victim.declent_ru(GENITIVE)]"] при помощи [I.declent_ru(GENITIVE)]."), vision_distance=COMBAT_MESSAGE_RANGE)
	sanitization += I.uv_power
	COOLDOWN_START(I, uv_cooldown, I.uv_cooldown_length)

/datum/wound/burn/flesh/treat(obj/item/tool, mob/user)
	if(istype(tool, /obj/item/flashlight/pen/paramedic))
		uv(tool, user)

// people complained about burns not healing on stasis beds, so in addition to checking if it's cured, they also get the special ability to very slowly heal on stasis beds if they have the healing effects stored
/datum/wound/burn/flesh/on_stasis(seconds_per_tick)
	. = ..()
	if(strikes_to_lose_limb <= 0) // we've already hit sepsis, nothing more to do
		if(SPT_PROB(0.5, seconds_per_tick))
			victim.visible_message(span_danger("Инфекция на остатках [limb.ru_plaintext_zone[GENITIVE] || limb.plaintext_zone] у [victim.declent_ru(GENITIVE)] тошнотворно пузырится!"), span_warning("Вы чувствуете, как инфекция на остатках вашей [limb.ru_plaintext_zone[GENITIVE] || limb.plaintext_zone] проникает в ваши вены!"), vision_distance = COMBAT_MESSAGE_RANGE)
		return
	if(flesh_healing > 0)
		flesh_damage = max(flesh_damage - (0.1 * seconds_per_tick), 0)
	if((flesh_damage <= 0) && (infection <= 1))
		to_chat(victim, span_green("Ожоги на [limb.ru_plaintext_zone[PREPOSITIONAL] || limb.plaintext_zone] очистились!"))
		qdel(src)
		return
	if(sanitization > 0)
		infection = max(infection - (0.1 * WOUND_BURN_SANITIZATION_RATE * seconds_per_tick), 0)

/datum/wound/burn/flesh/on_synthflesh(reac_volume)
	flesh_healing += reac_volume * 0.5 // 20u patch will heal 10 flesh standard

/datum/wound_pregen_data/flesh_burn
	abstract = TRUE

	required_wounding_type = WOUND_BURN
	required_limb_biostate = BIO_FLESH

	wound_series = WOUND_SERIES_FLESH_BURN_BASIC

/datum/wound/burn/get_limb_examine_description()
	return span_warning("Плоть на конечности ужасно обуглена.")

// we don't even care about first degree burns, straight to second
/datum/wound/burn/flesh/moderate
	name = "Ожог второй степени"
	desc = "Пациент страдает от значительных ожогов с незначительным поражением кожи, что ослабляет целостность конечности и вызывает уязвимость к ожогам."
	treat_text = "Нанесите мазь на кожу или регенеративную сетку на рану."
	treat_text_short = "Нанесите средство для лечения, например, регенеративную сетку."
	examine_desc = "сильно обожжёна и покрывается волдырями"
	occur_text = "покрывается ярко-красными ожогами"
	severity = WOUND_SEVERITY_MODERATE
	damage_multiplier_penalty = 1.1
	series_threshold_penalty = 30 // burns cause significant decrease in limb integrity compared to other wounds
	status_effect_type = /datum/status_effect/wound/burn/flesh/moderate
	flesh_damage = 5
	scar_keyword = "burnmoderate"

	simple_desc = "Кожа пациента обожжена, что ослабляет конечность и увеличивает ощущаемый урон!"
	simple_treat_text = "Мазь ускорит восстановление, как и регенеративная сетка. Риск заражения незначителен."
	homemade_treat_text = "Полезный чай ускорит восстановление. Соль или, предпочтительно, соленая вода, продезинфицируют рану, но использование соли может вызвать раздражение кожи и увеличить риск заражения."

/datum/wound_pregen_data/flesh_burn/second_degree
	abstract = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/moderate

	threshold_minimum = 40

/datum/wound/burn/flesh/severe
	name = "Ожог третьей степени"
	desc = "Пациент страдает от сильнейших ожогов с полным проникновением в кожу, что создает серьезный риск инфекции и значительно снижает целостность конечности."
	treat_text = "Немедленно примените лечебные средства, такие как синтплоть или регенеративная сетка, к ране. \
		Продезинфицируйте рану и хирургически удалите инфицированную кожу, затем оберните чистой марлей или используйте мазь для предотвращения дальнейшего заражения. \
		Если конечность отмерла, ее необходимо ампутировать, заменить имплантатом или лечить криогеникой."
	treat_text_short = "Примените лечебные средства, такие как регенеративная сетка, синтплоть или криогеника, и продезинфицируйте / удалите инфицированные участки. \
		Чистая марля или мазь замедлят скорость распространения инфекции."
	examine_desc = "выглядит сильно обугленной, с агрессивными красными пятнами"
	occur_text = "обугливается, обнажая разрушенные ткани и распространяя ярко-красные ожоги"
	severity = WOUND_SEVERITY_SEVERE
	damage_multiplier_penalty = 1.2
	series_threshold_penalty = 40
	status_effect_type = /datum/status_effect/wound/burn/flesh/severe
	treatable_by = list(/obj/item/flashlight/pen/paramedic)
	infection_rate = 0.07 // appx 9 minutes to reach sepsis without any treatment
	flesh_damage = 12.5
	scar_keyword = "burnsevere"

	simple_desc = "Кожа пациента сильно обожжена, что значительно ослабляет конечность и усугубляет дальнейшие повреждения!!"
	simple_treat_text = "<b>Бинты ускорят восстановление</b>, как и <b>мазь или регенеративная сетка</b>. <b>Спейсациллин, стерилизин и шахтерская мазь</b> помогут справиться с инфекцией."
	homemade_treat_text = "<b>Полезный чай</b> ускорит восстановление. <b>Соль</b> или, предпочтительно, <b>соленная вода</b>, продезинфицируют рану, но особенно первая вызовет раздражение кожи и обезвоживание, что ускорит развитие инфекции. <b>Космический очиститель</b> можно использовать в качестве дезинфицирующего средства в крайнем случае."

/datum/wound_pregen_data/flesh_burn/third_degree
	abstract = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/severe

	threshold_minimum = 80

/datum/wound/burn/flesh/critical
	name = "Катастрофический ожог"
	desc = "Пациент страдает от почти полного разрушения тканей, с серьезными обугленными мышцами и костями, что создает угрожающую жизни опасность инфекции и практически нулевую целостность конечности."
	treat_text = "Немедленно нанесите лечебные средства, такие как Синтплоть или регенеративную сетку, на рану. \
		Продезинфицируйте рану и хирургически удалите инфицированные участки кожи, затем оберните чистой марлей / используйте мазь для предотвращения дальнейшей инфекции. \
		Если конечность отмерла, её необходимо ампутировать, заменить на имплант или лечить с помощью криогенной терапии."
	treat_text_short = "Нанесите лечебное средство, такое как регенеративная сетка, Синтплоть или используйте криогенику и продезинфицируйте / удалите инфицированные участки. \
		Чистая марля или мазь замедлит скорость инфицирования."
	examine_desc = "выглядит как разрушенный беспорядок из обесцвеченных костей, расплавленного жира и обугленной ткани"
	occur_text = "источает дымок, когда плоть, кости и жир плавятся в ужасающую массу"
	severity = WOUND_SEVERITY_CRITICAL
	damage_multiplier_penalty = 1.3
	sound_effect = 'sound/effects/wounds/sizzle2.ogg'
	threshold_penalty = 25
	status_effect_type = /datum/status_effect/wound/burn/flesh/critical
	treatable_by = list(/obj/item/flashlight/pen/paramedic)
	infection_rate = 0.075 // appx 4.33 minutes to reach sepsis without any treatment
	flesh_damage = 20
	scar_keyword = "burncritical"

	simple_desc = "Кожа пациента разрушена, ткани обуглены, конечность почти лишена <b>целостности</b> и подвержена крайне высокой вероятности <b>инфекции</b>!!!"
	simple_treat_text = "Немедленно <b>перевяжите</b> рану и обработайте её <b>мазью или регенеративной сеткой</b>. <b>Спейсациллин, стерилизин или шахтерская мазь</b> помогут предотвратить инфекцию. Обратитесь за профессиональной помощью <b>немедленно</b>, до того как начнётся сепсис и рана станет неизлечимой."
	homemade_treat_text = "<b>Целебный чай</b> поможет с восстановлением. <b>Соленая вода</b>, нанесенный на кожу, может временно предотвратить инфекцию, но чистая поваренная соль НЕ рекомендуется. <b>Космический очиститель</b> можно использовать в качестве дезинфицирующего средства в крайнем случае."

/datum/wound_pregen_data/flesh_burn/fourth_degree
	abstract = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/critical

	threshold_minimum = 140

///special severe wound caused by sparring interference or other god related punishments.
/datum/wound/burn/flesh/severe/brand
	name = "Святое клеймо"
	desc = "Пациент страдает от сильных ожогов от загадочного клейма, что создают серьезный риск инфекции и сильно снижают целостность конечности."
	examine_desc = "похоже, что на коже были выжжены священные символы, оставившие сильные ожоги."
	occur_text = "быстро обугливается в странный узор из священных символов, выжженных на коже"

	simple_desc = "На коже пациента выжжены странные метки, что значительно ослабляет конечность и усугубляет дальнейшие повреждения!!"

/datum/wound_pregen_data/flesh_burn/third_degree/holy
	abstract = FALSE
	can_be_randomly_generated = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/severe/brand
/// special severe wound caused by the cursed slot machine.

/datum/wound/burn/flesh/severe/cursed_brand
	name = "Древнее клеймо"
	desc = "Пациент страдает от сильных ожогов нанесённых клеймом с причудливым орнаментом, что создают серьезный риск инфекции и сильно снижают целостность конечности."
	examine_desc = "похоже, что на коже были выжжены причудливые символы, оставившие сильные ожоги."
	occur_text = "быстро обугливается в узор, который можно описать только как сочетание нескольких финансовых символов, выжженных на коже"

/datum/wound/burn/flesh/severe/cursed_brand/get_limb_examine_description()
	return span_warning("На коже этой конечности выжжены причудливые символы, с углублениями по всей поверхности.")

/datum/wound_pregen_data/flesh_burn/third_degree/cursed_brand
	abstract = FALSE
	can_be_randomly_generated = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/severe/cursed_brand

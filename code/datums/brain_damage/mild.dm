//Mild traumas are the most common; they are generally minor annoyances.
//They can be cured with mannitol and patience, although brain surgery still works.
//Most of the old brain damage effects have been transferred to the dumbness trauma.

/datum/brain_trauma/mild
	abstract_type = /datum/brain_trauma/mild

/datum/brain_trauma/mild/hallucinations
	name = "Галлюцинации"
	desc = "Пациент страдает от постоянных галлюцинаций."
	scan_desc = "шизофрения"
	symptoms = "Испытывает частые галлюцинации (зрительные или слуховые) либо бредовые идеи, \
		которые ослабевают при введении токсина Mindbreaker."
	gain_text = span_warning("Вы чувствуете, что ваша связь с реальностью ослабевает...")
	lose_text = span_notice("Вы чувствуете себя более приземленным.")
	/// Whether the hallucinations we give are uncapped, ie all the wacky ones
	var/uncapped = FALSE

/datum/brain_trauma/mild/hallucinations/on_life(seconds_per_tick)
	if(owner.stat >= UNCONSCIOUS)
		return
	if(HAS_TRAIT(owner, TRAIT_RDS_SUPPRESSED))
		owner.remove_language(/datum/language/aphasia, source = LANGUAGE_APHASIA)
		owner.adjust_hallucinations(-10 SECONDS * seconds_per_tick)
		return

	owner.grant_language(/datum/language/aphasia, source = LANGUAGE_APHASIA)
	owner.adjust_hallucinations_up_to(((uncapped ? 12 SECONDS : 5 SECONDS) * seconds_per_tick), (uncapped ? 240 SECONDS : 60 SECONDS))

/datum/brain_trauma/mild/hallucinations/on_lose()
	owner.remove_status_effect(/datum/status_effect/hallucination)
	if(!QDELING(owner))
		owner.remove_language(/datum/language/aphasia, source = LANGUAGE_APHASIA)
	return ..()

/datum/brain_trauma/mild/stuttering
	name = "Заикание"
	desc = "Пациент не может нормально говорить."
	scan_desc = "пониженная координация речи"
	symptoms = "Испытывает трудности с плавной речью, часто повторяя или растягивая звуки или слоги."
	gain_text = span_warning("Говорить четко становится все труднее.")
	lose_text = span_notice("Вы чувствуете, что контролируете свою речь.")

/datum/brain_trauma/mild/stuttering/on_life(seconds_per_tick)
	owner.adjust_stutter_up_to(5 SECONDS * seconds_per_tick, 50 SECONDS)

/datum/brain_trauma/mild/stuttering/on_lose()
	owner.remove_status_effect(/datum/status_effect/speech/stutter)
	return ..()

/datum/brain_trauma/mild/dumbness
	name = "Отупение"
	desc = "У пациента снижена мозговая активность, что приводит к снижению его интеллекта."
	symptoms = "Демонстрирует заметное снижение когнитивных функций, включая речь, память, моторику и способности к решению задач."
	scan_desc = "снижение мозговой активности"
	gain_text = span_warning("Вы чувствуете себя глупее.")
	lose_text = span_notice("Вы снова чувствуете себя умным.")

/datum/brain_trauma/mild/dumbness/on_gain()
	ADD_TRAIT(owner, TRAIT_DUMB, TRAUMA_TRAIT)
	owner.add_mood_event("dumb", /datum/mood_event/oblivious)
	return ..()

/datum/brain_trauma/mild/dumbness/on_life(seconds_per_tick)
	owner.adjust_derpspeech_up_to(5 SECONDS * seconds_per_tick, 50 SECONDS)
	if(SPT_PROB(1.5, seconds_per_tick))
		owner.emote("drool")
	else if(owner.stat == CONSCIOUS && SPT_PROB(1.5, seconds_per_tick))
		owner.say(pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage"), forced = "brain damage", filterproof = TRUE)

/datum/brain_trauma/mild/dumbness/on_lose()
	REMOVE_TRAIT(owner, TRAIT_DUMB, TRAUMA_TRAIT)
	owner.remove_status_effect(/datum/status_effect/speech/stutter/derpspeech)
	owner.clear_mood_event("dumb")
	return ..()

/datum/brain_trauma/mild/speech_impediment
	name = "Дефект речи"
	desc = "Пациент не в состоянии составлять связные предложения."
	scan_desc = "коммуникативное расстройство"
	symptoms = "Испытывает трудности с выражением мыслей в связной речи, что часто приводит к спутанным или бессмысленным предложениям."
	gain_text = span_danger("Кажется, вы не можете сформулировать ни одной связной мысли!")
	lose_text = span_danger("Ваш разум становится более ясным.")

/datum/brain_trauma/mild/speech_impediment/on_gain()
	ADD_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, TRAUMA_TRAIT)
	. = ..()

/datum/brain_trauma/mild/speech_impediment/on_lose()
	REMOVE_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/mild/concussion
	name = "Сотрясение"
	desc = "У пациента сотрясение мозга."
	symptoms = "Испытывает головные боли, головокружение, тошноту, спутанность сознания и периодическую потерю сознания."
	scan_desc = "сотрясение"
	gain_text = span_warning("У вас болит голова!")
	lose_text = span_notice("TДавление в вашей голове начинает ослабевать.")

/datum/brain_trauma/mild/concussion/on_life(seconds_per_tick)
	if(SPT_PROB(2.5, seconds_per_tick))
		switch(rand(1,11))
			if(1)
				owner.vomit(VOMIT_CATEGORY_DEFAULT)
			if(2,3)
				owner.adjust_dizzy(20 SECONDS)
			if(4,5)
				owner.adjust_confusion(10 SECONDS)
				owner.set_eye_blur_if_lower(20 SECONDS)
			if(6 to 9)
				owner.adjust_slurring(1 MINUTES)
			if(10)
				to_chat(owner, span_notice("На мгновение вы забываете, что делали."))
				owner.Stun(20)
			if(11)
				to_chat(owner, span_warning("Вы теряете сознание."))
				owner.Unconscious(80)

	..()

/datum/brain_trauma/mild/healthy
	name = "Анозогнозия"
	desc = "Пациент всегда чувствует себя здоровым, независимо от своего состояния."
	scan_desc = "дефицит самосознания"
	symptoms = "Проявляет отсутствие осознания или отрицание собственных медицинских состояний, \
		часто настаивая на том, что он полностью здоров, несмотря на явные доказательства обратного."
	gain_text = span_notice("Вы чувствуете себя прекрасно!")
	lose_text = span_warning("Вы больше не чувствуете себя совершенно здоровым.")

/datum/brain_trauma/mild/healthy/on_gain()
	owner.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
	return ..()

/datum/brain_trauma/mild/healthy/on_life(seconds_per_tick)
	owner.adjust_stamina_loss(-6 * seconds_per_tick) //no pain, no fatigue

/datum/brain_trauma/mild/healthy/on_lose()
	owner.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
	return ..()

/datum/brain_trauma/mild/muscle_weakness
	name = "Мышечная слабость"
	desc = "Время от времени пациент испытывает приступы мышечной слабости."
	scan_desc = "слабый сигнал двигательного нерва"
	symptoms = "Испытывает внезапные эпизоды мышечной слабости, приводящие к ослабленному хвату, трудностям при движении и периодическим падениям."
	gain_text = span_warning("Ваши мышцы ощущаются странно слабыми.")
	lose_text = span_notice("Вы снова чувствуете контроль над своими мышцами.")

/datum/brain_trauma/mild/muscle_weakness/on_life(seconds_per_tick)
	var/fall_chance = 1
	if(owner.move_intent == MOVE_INTENT_RUN)
		fall_chance += 2
	if(SPT_PROB(0.5 * fall_chance, seconds_per_tick) && owner.body_position == STANDING_UP)
		to_chat(owner, span_warning("У вас подкашивается нога!"))
		owner.Paralyze(35)

	else if(owner.get_active_held_item())
		var/drop_chance = 1
		var/obj/item/I = owner.get_active_held_item()
		drop_chance += I.w_class
		if(SPT_PROB(0.5 * drop_chance, seconds_per_tick) && owner.dropItemToGround(I))
			to_chat(owner, span_warning("Вы роняете [I.declent_ru(ACCUSATIVE)]!"))

	else if(SPT_PROB(1.5, seconds_per_tick))
		to_chat(owner, span_warning("Вы чувствуете внезапную слабость в мышцах!"))
		owner.adjust_stamina_loss(50)
	..()

/datum/brain_trauma/mild/muscle_spasms
	name = "Мышечные спазмы"
	desc = "У пациента периодически возникают мышечные спазмы, заставляющие его двигаться непроизвольно."
	scan_desc = "нервные припадки"
	symptoms = "Испытывает непроизвольные мышечные сокращения, приводящие к внезапным кратковременным движениям или подёргиваниям, \
		которые могут мешать нормальным двигательным функциям."
	gain_text = span_warning("Ваши мышцы ощущаются странно слабыми.")
	lose_text = span_notice("Вы снова чувствуете контроль над своими мышцами.")

/datum/brain_trauma/mild/muscle_spasms/on_gain()
	owner.apply_status_effect(/datum/status_effect/spasms)
	. = ..()

/datum/brain_trauma/mild/muscle_spasms/on_lose()
	owner.remove_status_effect(/datum/status_effect/spasms)
	..()

/datum/brain_trauma/mild/nervous_cough
	name = "Нервный кашель"
	desc = "Пациент испытывает постоянную потребность откашляться."
	scan_desc = "нервный кашель"
	symptoms = "Испытывает постоянное, неконтролируемое желание кашлять, что может нарушать нормальную деятельность и социальные взаимодействия."
	gain_text = span_warning("У вас постоянно чешется горло...")
	lose_text = span_notice("Ваше горло перестает чесаться.")

/datum/brain_trauma/mild/nervous_cough/on_life(seconds_per_tick)
	if(SPT_PROB(6, seconds_per_tick) && !HAS_TRAIT(owner, TRAIT_SOOTHED_THROAT))
		if(prob(5))
			to_chat(owner, span_warning("[pick("У вас приступ кашля!", "Вы не можете перестать кашлять!")]"))
			owner.Immobilize(20)
			owner.emote("cough")
			addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/, emote), "cough"), 0.6 SECONDS)
			addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/, emote), "cough"), 1.2 SECONDS)
		owner.emote("cough")
	..()

/datum/brain_trauma/mild/expressive_aphasia
	name = "Экспрессивная афазия"
	desc = "Пациент страдает частичной потерей речи, что приводит к сокращению словарного запаса."
	scan_desc = "неспособность составлять сложные предложения"
	symptoms = "Испытывает трудности с вербальным выражением мыслей, часто заменяя сложные слова более простыми или бессмысленными звуками."
	gain_text = span_warning("Вы теряете способность понимать сложные слова.")
	lose_text = span_notice("Вы чувствуете, что ваш словарный запас снова возвращается к норме.")

/datum/brain_trauma/mild/expressive_aphasia/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		var/list/message_split = splittext(message, " ")
		var/list/new_message = list()

		for(var/word in message_split)
			var/suffix = ""
			var/suffix_foundon = 0
			for(var/potential_suffix in list("." , "," , ";" , "!" , ":" , "?"))
				suffix_foundon = findtext(word, potential_suffix, -length(potential_suffix))
				if(suffix_foundon)
					suffix = potential_suffix
					break

			if(suffix_foundon)
				word = copytext(word, 1, suffix_foundon)
			word = html_decode(word)

			if(GLOB.most_common_words_alphabetical[LOWER_TEXT(word)])
				new_message += word + suffix
			else
				if(prob(30) && message_split.len > 2)
					new_message += pick("uh","erm")
					break
				else
					var/list/charlist = text2charlist(word)
					charlist.len = round(charlist.len * 0.5, 1)
					shuffle_inplace(charlist)
					new_message += jointext(charlist, "") + suffix

		message = jointext(new_message, " ")

	speech_args[SPEECH_MESSAGE] = trim(message)

/datum/brain_trauma/mild/mind_echo
	name = "Мысленное эхо"
	desc = "Языковые нейроны пациента функционируют некорректно, в результате чего предыдущие речевые структуры иногда спонтанно всплывают на поверхность."
	scan_desc = "циклическая нейронная структура"
	symptoms = "Испытывает непроизвольное повторение ранее услышанных или произнесённых фраз, что приводит к частым ощущениям дежавю как при слухе, так и при речи."
	gain_text = span_warning("Вы чувствуете слабое эхо своих мыслей...")
	lose_text = span_notice("Слабое эхо затихает вдали.")
	var/list/hear_dejavu = list()
	var/list/speak_dejavu = list()

/datum/brain_trauma/mild/mind_echo/handle_hearing(datum/source, list/hearing_args)
	if(HAS_TRAIT(owner, TRAIT_DEAF) || owner == hearing_args[HEARING_SPEAKER])
		return

	if(hear_dejavu.len >= 5)
		if(prob(25))
			var/deja_vu = pick_n_take(hear_dejavu)
			var/static/regex/quoted_spoken_message = regex("\".+\"", "gi")
			hearing_args[HEARING_RAW_MESSAGE] = quoted_spoken_message.Replace(hearing_args[HEARING_RAW_MESSAGE], "\"[deja_vu]\"") //Quotes included to avoid cases where someone says part of their name
			return
	if(hear_dejavu.len >= 15)
		if(prob(50))
			popleft(hear_dejavu) //Remove the oldest
			hear_dejavu += hearing_args[HEARING_RAW_MESSAGE]
	else
		hear_dejavu += hearing_args[HEARING_RAW_MESSAGE]

/datum/brain_trauma/mild/mind_echo/handle_speech(datum/source, list/speech_args)
	if(speak_dejavu.len >= 5)
		if(prob(25))
			var/deja_vu = pick_n_take(speak_dejavu)
			speech_args[SPEECH_MESSAGE] = deja_vu
			return
	if(speak_dejavu.len >= 15)
		if(prob(50))
			popleft(speak_dejavu) //Remove the oldest
			speak_dejavu += speech_args[SPEECH_MESSAGE]
	else
		speak_dejavu += speech_args[SPEECH_MESSAGE]

/datum/brain_trauma/mild/color_blindness
	name = "Ахроматопсия"
	desc = "Затылочная доля мозга пациента неспособна распознавать и интерпретировать цвета, в результате пациент полностью теряет цветовое зрение."
	scan_desc = "цветовая слепота"
	symptoms = "Проявляет полную неспособность воспринимать цвета, видя мир в оттенках серого, чёрного и белого."
	gain_text = span_warning("Кажется, что мир вокруг вас теряет свои краски.")
	lose_text = span_notice("Мир снова кажется ярким и красочным.")

/datum/brain_trauma/mild/color_blindness/on_gain()
	owner.add_client_colour(/datum/client_colour/monochrome, TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/mild/color_blindness/on_lose(silent)
	owner.remove_client_colour(TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/mild/possessive
	name = "Собственничество"
	desc = "Пациент чрезвычайно бережно относится к своим вещам."
	scan_desc = "собственничество"
	symptoms = "Испытывает непреодолимую потребность держать личные вещи рядом с собой, \
		часто проявляя сильное сцепление с предметами, которое сохраняется даже при принуждении отпустить их."
	gain_text = span_warning("Вы начинаете беспокоиться о своих вещах.")
	lose_text = span_notice("Вы меньше беспокоитесь о своих вещах.")

/datum/brain_trauma/mild/possessive/on_lose(silent)
	. = ..()
	for(var/obj/item/thing in owner.held_items)
		clear_trait(thing)

/datum/brain_trauma/mild/possessive/on_life(seconds_per_tick)
	if(!SPT_PROB(5, seconds_per_tick))
		return

	var/obj/item/my_thing = pick(owner.held_items) // can pick null, that's fine
	if(isnull(my_thing) || HAS_TRAIT(my_thing, TRAIT_NODROP) || (my_thing.item_flags & (HAND_ITEM|ABSTRACT)))
		return

	ADD_TRAIT(my_thing, TRAIT_NODROP, TRAUMA_TRAIT)
	RegisterSignals(my_thing, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED), PROC_REF(clear_trait))
	to_chat(owner, span_warning("Вы чувствуете потребность держать [my_thing.declent_ru(ACCUSATIVE)] при себе..."))
	addtimer(CALLBACK(src, PROC_REF(relax), my_thing), rand(30 SECONDS, 3 MINUTES), TIMER_DELETE_ME)

/datum/brain_trauma/mild/possessive/proc/relax(obj/item/my_thing)
	if(QDELETED(my_thing))
		return
	if(HAS_TRAIT_FROM_ONLY(my_thing, TRAIT_NODROP, TRAUMA_TRAIT)) // in case something else adds nodrop, somehow?
		to_chat(owner, span_notice("Вы чувствуете себя более комфортно, отпуская [my_thing.declent_ru(ACCUSATIVE)]."))
	clear_trait(my_thing)

/datum/brain_trauma/mild/possessive/proc/clear_trait(obj/item/my_thing, ...)
	SIGNAL_HANDLER

	REMOVE_TRAIT(my_thing, TRAIT_NODROP, TRAUMA_TRAIT)
	UnregisterSignal(my_thing, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED))

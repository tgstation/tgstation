/datum/brain_trauma/hypnosis
	name = "Гипноз"
	desc = "Сознания пациента полностью поглощено каким-то словом или предложением, фокусируя мысли и поступки вокруг него."
	scan_desc = "повторяющийся мыслительный паттерн"
	symptoms = "Зацикливается на конкретном слове или фразе. Эта фиксация может приводить к изменению поведения, \
		например к приоритету действий, связанных с этой фразой, над другими задачами, при одновременном пренебрежении работой, \
		личными потребностями или социальными взаимодействиями."
	gain_text = ""
	lose_text = ""
	resilience = TRAUMA_RESILIENCE_SURGERY
	/// Associated antag datum, used for displaying objectives and antag hud
	var/datum/antagonist/hypnotized/antagonist
	var/hypnotic_phrase = ""
	var/regex/target_phrase

/datum/brain_trauma/hypnosis/New(phrase)
	if(!phrase)
		qdel(src)
		return
	hypnotic_phrase = phrase
	try
		target_phrase = new("(\\b[REGEX_QUOTE(hypnotic_phrase)]\\b)","ig")
	catch(var/exception/e)
		stack_trace("[e] on [e.file]:[e.line]")
		qdel(src)
	..()

/datum/brain_trauma/hypnosis/on_gain()
	message_admins("[ADMIN_LOOKUPFLW(owner)] was hypnotized with the phrase '[hypnotic_phrase]'.")
	owner.log_message("was hypnotized with the phrase '[hypnotic_phrase]'.", LOG_GAME)
	to_chat(owner, span_reallybig(span_hypnophrase("[hypnotic_phrase]")))
	to_chat(owner, span_notice("[pick(list(
			"В этом что-то есть... и, по какой-то причине, это кажется правильным. Вам кажется, что вы должны следовать этим словам.",
			"Эти слова продолжают звучать у вас в голове. Вы обнаруживаете, что совершенно очарованы ими.",
			"Вы чувствуете, как часть вашего сознания повторяет это снова и снова. Вам нужно следовать этим словам.",
			"Вы чувствуете, что ваши мысли сосредотачиваются на этой фразе... Кажется, вы не можете выбросить её из головы.",
			"Болит голова, но это все, о чем вы можете думать. Должно быть, это жизненно важно.",
	))]"))
	to_chat(owner, span_boldwarning("Вы были загипнотизированы этим предложением. Вы должны следовать этим словам. \
		Если это не четкий приказ, вы можете свободно интерпретировать, как именно действовать, главное — вести себя так, будто эти слова являются для вас наивысшим приоритетом."))
	var/atom/movable/screen/alert/hypnosis/hypno_alert = owner.throw_alert(ALERT_HYPNOSIS, /atom/movable/screen/alert/hypnosis)
	owner.mind.add_antag_datum(/datum/antagonist/hypnotized)
	antagonist = owner.mind.has_antag_datum(/datum/antagonist/hypnotized)
	antagonist.trauma = src

	// Add the phrase to objectives
	var/datum/objective/fixation = new ()
	fixation.explanation_text = hypnotic_phrase
	fixation.completed = TRUE
	antagonist.objectives = list(fixation)

	hypno_alert.desc = "\"[hypnotic_phrase]\"... кажется, ваш разум зациклился на этой концепции."
	. = ..()

/datum/brain_trauma/hypnosis/on_lose()
	message_admins("[ADMIN_LOOKUPFLW(owner)] is no longer hypnotized with the phrase '[hypnotic_phrase]'.")
	owner.log_message("is no longer hypnotized with the phrase '[hypnotic_phrase]'.", LOG_GAME)
	to_chat(owner, span_userdanger("Вы внезапно выходите из состояния гипноза. Фраза '[hypnotic_phrase]' больше не кажется вам важной."))
	owner.clear_alert(ALERT_HYPNOSIS)
	..()
	if (!isnull(antagonist))
		antagonist.trauma = null
	owner.mind.remove_antag_datum(/datum/antagonist/hypnotized)
	antagonist = null

/datum/brain_trauma/hypnosis/on_life(seconds_per_tick)
	..()
	if(SPT_PROB(1, seconds_per_tick))
		if(prob(50))
			to_chat(owner, span_hypnophrase("<i>...[LOWER_TEXT(hypnotic_phrase)]...</i>"))
		else
			owner.cause_hallucination( \
				/datum/hallucination/chat, \
				"hypnosis", \
				force_radio = TRUE, \
				specific_message = span_hypnophrase("[hypnotic_phrase]"), \
			)

/datum/brain_trauma/hypnosis/handle_hearing(datum/source, list/hearing_args)
	if(HAS_TRAIT(owner, TRAIT_DEAF) || owner == hearing_args[HEARING_SPEAKER])
		return
	hearing_args[HEARING_RAW_MESSAGE] = target_phrase.Replace(hearing_args[HEARING_RAW_MESSAGE], span_hypnophrase("$1"))

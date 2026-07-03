/datum/quirk/social_anxiety
	name = "Social Anxiety"
	desc = "Вам очень трудно разговаривать с людьми, заикаясь или даже запираясь в себе."
	icon = FA_ICON_COMMENT_SLASH
	value = -3
	gain_text = span_danger("Вы начинаете беспокоиться о том, что говорите.")
	lose_text = span_notice("Вам снова легко разговаривать.") //if only it were that easy!
	medical_record_text = "Пациент обычно испытывает тревогу при социальных контактах и предпочитает их избегать."
	medical_symptom_text = "Experiences intense anxiety and discomfort in social situations, \
		leading to avoidance of social interactions and difficulty in communication."
	hardcore_value = 4
	mob_trait = TRAIT_ANXIOUS
	mail_goodies = list(/obj/item/storage/pill_bottle/psicodine)
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_TRAUMALIKE
	var/dumb_thing = TRUE

/datum/quirk/social_anxiety/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_MOB_EYECONTACT, PROC_REF(eye_contact))
	RegisterSignal(quirk_holder, COMSIG_MOB_EXAMINATE, PROC_REF(looks_at_floor))
	RegisterSignal(quirk_holder, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	quirk_holder.apply_status_effect(/datum/status_effect/speech/stutter/anxiety, INFINITY)

/datum/quirk/social_anxiety/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_MOB_EYECONTACT, COMSIG_MOB_EXAMINATE, COMSIG_MOB_SAY))
	quirk_holder.remove_status_effect(/datum/status_effect/speech/stutter/anxiety)

/// Calculates how much to modifiy our effects based on our mood level
/datum/quirk/social_anxiety/proc/calculate_mood_mod()
	var/nearby_people = 0
	for(var/mob/living/carbon/human/listener in oview(3, quirk_holder))
		if(listener.client || listener.mind)
			nearby_people++

	var/mod = 1
	if(quirk_holder.mob_mood)
		mod = 1 + 0.02 * (50 - (max(50, quirk_holder.mob_mood.mood_level * (SANITY_LEVEL_MAX + 1 - quirk_holder.mob_mood.sanity_level)))) //low sanity levels are better, they max at 6
	else
		mod = 1 + 0.02 * (50 - (max(50, 0.1 * quirk_holder.nutrition)))

	return mod * nearby_people * 12.5

/datum/quirk/social_anxiety/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(HAS_TRAIT(quirk_holder, TRAIT_FEARLESS))
		return
	if(HAS_TRAIT(source, TRAIT_SIGN_LANG)) // No modifiers for signers, so you're less anxious when you go non-verbal
		return

	var/moodmod = calculate_mood_mod()
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		var/list/message_split = splittext(message, " ")
		var/list/new_message = list()
		for(var/word in message_split)
			if(prob(max(5, moodmod)) && word != message_split[1]) //Minimum 1/20 chance of filler
				new_message += pick("ээ,","эмм,","ам,")
				if(prob(min(5, moodmod))) //Max 1 in 20 chance of cutoff after a successful filler roll, for 50% odds in a 15 word sentence
					quirk_holder.set_silence_if_lower(6 SECONDS)
					to_chat(quirk_holder, span_danger("Вы чувствуете себя неловко и перестаете говорить. Вам нужно время, чтобы прийти в себя!"))
					break
			new_message += word

		message = jointext(new_message, " ")

	if(prob(min(50, (0.50 * moodmod)))) //Max 50% chance of not talking
		if(dumb_thing)
			to_chat(quirk_holder, span_userdanger("Вы вспоминаете глупость, которую сказали давным-давно, и внутренне кричите."))
			dumb_thing = FALSE //only once per life
			if(prob(1))
				new/obj/item/food/spaghetti/pastatomato(get_turf(quirk_holder)) //now that's what I call spaghetti code
		else
			to_chat(quirk_holder, span_warning("Вы думаете, что это не добавит ничего нового к разговору, и решаете не говорить об этом."))
			if(prob(min(25, (0.25 * moodmod)))) //Max 25% chance of silence stacks after successful not talking roll
				to_chat(quirk_holder, span_danger("Вы уходите в себя. Вы <i>действительно<i> не настроены на разговор."))
				quirk_holder.set_silence_if_lower(10 SECONDS)

		speech_args[SPEECH_MESSAGE] = pick("Ээ.","Эмм.","Ам.")
	else
		speech_args[SPEECH_MESSAGE] = message

// small chance to make eye contact with inanimate objects/mindless mobs because of nerves
/datum/quirk/social_anxiety/proc/looks_at_floor(datum/source, atom/A)
	SIGNAL_HANDLER

	var/mob/living/mind_check = A
	if(prob(85) || (istype(mind_check) && mind_check.mind))
		return

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), quirk_holder, span_smallnotice("Вы смотрите в глаза [A].")), 0.3 SECONDS)

/datum/quirk/social_anxiety/proc/eye_contact(datum/source, mob/living/other_mob, triggering_examiner)
	SIGNAL_HANDLER

	if(prob(75))
		return
	var/msg
	if(triggering_examiner)
		msg = "Вы смотрите в глаза [other_mob], "
	else
		msg = "[other_mob] смотрит вам в глаза, "

	switch(rand(1,3))
		if(1)
			quirk_holder.set_jitter_if_lower(20 SECONDS)
			msg += "что заставляет вас нервничать!"
		if(2)
			quirk_holder.set_stutter_if_lower(6 SECONDS)
			msg += "что заставляет вас заикаться!"
		if(3)
			quirk_holder.Stun(2 SECONDS)
			msg += "что заставляет вас застыть на месте!"

	quirk_holder.add_mood_event("anxiety_eyecontact", /datum/mood_event/anxiety_eyecontact)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), quirk_holder, span_userdanger("[msg]")), 3) // so the examine signal has time to fire and this will print after
	return COMSIG_BLOCK_EYECONTACT

/datum/mood_event/anxiety_eyecontact
	description = "Иногда взгляд в глаза заставляет меня нервничать..."
	mood_change = -5
	timeout = 3 MINUTES

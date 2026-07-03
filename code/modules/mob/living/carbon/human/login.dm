/mob/living/carbon/human/Login()
	. = ..()

	dna?.species?.on_owner_login(src)

	if(SStts.tts_enabled && !voice)
		voice = SStts.random_tts_voice(gender)

	if(!LAZYLEN(afk_thefts))
		return

	var/list/print_msg = list()
	print_msg += span_userdanger("Когда вы возвращаетесь в сознание, вы вспоминаете, как люди копались у вас в вещах...")

	afk_thefts = reverse_range(afk_thefts)

	for(var/list/iter_theft as anything in afk_thefts)
		if(!islist(iter_theft) || LAZYLEN(iter_theft) != AFK_THEFT_TIME)
			stack_trace("[src] ([ckey]) returned to their body and had a null/malformed afk_theft entry. Contents: [json_encode(iter_theft)]")
			continue

		var/thief_name = iter_theft[AFK_THEFT_NAME]
		var/theft_message = iter_theft[AFK_THEFT_MESSAGE]
		var/time_since = world.time - iter_theft[AFK_THEFT_TIME]

		if(time_since > AFK_THEFT_FORGET_DETAILS_TIME)
			print_msg += "\t[span_danger("<b>Кто-то [theft_message], но это было как минимум [DisplayTimeText(AFK_THEFT_FORGET_DETAILS_TIME)] назад.</b>")]"
		else
			print_msg += "\t[span_danger("<b>Кто-то под именем [thief_name] [theft_message] примерно [DisplayTimeText(time_since, 10)] назад.</b>")]"

	if(LAZYLEN(afk_thefts) >= AFK_THEFT_MAX_MESSAGES)
		print_msg += span_warning("Возможно кто-то еще мог быть замешан, но это всё, что вы можете вспомнить...")

	to_chat(src, boxed_message(print_msg.Join("\n")))
	LAZYNULL(afk_thefts)

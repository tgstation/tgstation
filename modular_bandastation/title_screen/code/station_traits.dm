/datum/station_trait/proc/on_lobby_button_click(mob/dead/new_player/user, button_id)
	return // No SCUB and Pet Day

// STANDARD JOB TRAIT HANDLING
/datum/station_trait/job/on_lobby_button_click(mob/dead/new_player/user, button_id)
	if(SSticker.HasRoundStarted())
		to_chat(user, span_redtext("Раунд уже начался!"))
		return

	if(LAZYFIND(lobby_candidates, user))
		LAZYREMOVE(lobby_candidates, user)
		to_chat(user, span_redtext("Вы были убраны из списка кандидатов на роль [name]."))
		SStitle.title_output(user.client, list2params(list("false", button_id)), "traitSignup")
	else
		LAZYADD(lobby_candidates, user)
		to_chat(user, span_greentext("Вы были добавлены в список кандидатов на роль [name]."))
		SStitle.title_output(user.client, list2params(list("true", button_id)), "traitSignup")

/datum/station_trait/job/New()
	. = ..()
	SStitle.title_output_to_all(list2params(list(src.name, src.button_desc)), "createTraitButton")

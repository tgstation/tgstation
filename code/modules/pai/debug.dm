ADMIN_VERB(makepAI, R_FUN, "Make pAI", "Specify a location to spawn a pAI device, then specify a key to play that pAI", ADMIN_CATEGORY_FUN)
	VERB_ARG_TYPED(target, VERB_ARG_TYPE_TURF, VERB_ARG_SOURCE_VIEW, /turf)

	var/list/available = list()
	for(var/mob/player as anything in GLOB.player_list)
		if(player.client && player.key)
			available.Add(player)
	var/mob/choice = tgui_input_list(user, "Choose a player to play the pAI", "Spawn pAI", sort_names(available))
	if(isnull(choice))
		return

	if(!isobserver(choice))
		var/confirm = tgui_alert(user, "[choice.key] isn't ghosting right now. Are you sure you want to yank them out of their body and place them in this pAI?", "Spawn pAI Confirmation", list("Yes", "No"))
		if(confirm != "Yes")
			return

	BLACKBOX_LOG_ADMIN_VERB("Make pAI")

	var/obj/item/pai_card/card = new(target)
	var/mob/living/silicon/pai/pai = new(card)

	pai.PossessByPlayer(choice.key)
	card.set_personality(pai)
	if(SSpai.candidates[user.key])
		SSpai.candidates -= user.key

	var/chosen_name = tgui_input_text(choice, "Enter your pAI name:", "pAI Name", "Personal AI", MAX_NAME_LEN)
	if(chosen_name)
		pai.name = chosen_name
		pai.real_name = pai.name

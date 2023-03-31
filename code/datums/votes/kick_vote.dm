#define CHOICE_NOKICK "No, don't kick them"

/datum/vote/kick_vote
	name = "Votekick"
	message = "Vote to kick someone"
	contains_vote_in_name = TRUE
	count_method = VOTE_COUNT_METHOD_SINGLE
	var/client/lucky_contender = null

/datum/vote/kick_vote/is_accessible_vote()
	return TRUE

/datum/vote/kick_vote/create_vote(mob/vote_creator)
	var/list/clients = list()
	var/list/clients_assoc = list()
	for(var/client/client in GLOB.clients)
		if(client.holder && client.holder.fakekey)
			clients += client.holder.fakekey
			clients_assoc[client.holder.fakekey] = client
		else
			clients += client.key
			clients_assoc[client.key] = client
	var/selected_player = tgui_input_list(vote_creator, "Who would you like to kick?", "Votekick", sort_list(clients))
	lucky_contender = clients_assoc[selected_player]
	message_admins("VOTEKICK: [vote_creator.client] initiated a kick vote for [lucky_contender]")
	override_question = "Kick [selected_player]?"
	default_choices = list(
		"Yes, kick [selected_player]!",
		CHOICE_NOKICK,
	)
	return ..()

/datum/vote/kick_vote/finalize_vote(winning_option)
	if(!lucky_contender)
		message_admins("VOTEKICK: No player to kick!")
		return

	var/display_name = lucky_contender?.holder?.fakekey || lucky_contender.key
	if(winning_option == CHOICE_NOKICK)
		to_chat(world, span_boldannounce("Vote kicking [display_name] failed! There weren't enough votes!"))
		return

	to_chat(world, span_boldannounce("Vote kicking [display_name] succeeded!"))

	if(!lucky_contender.holder)
		to_chat(lucky_contender, span_danger("You have been vote kicked from the server!"), confidential = TRUE)
		message_admins("VOTEKICK: [lucky_contender] has been kicked by the votekick system")
		QDEL_IN(lucky_contender, 1 DECISECONDS)
	else
		message_admins("VOTEKICK: [lucky_contender] was not kicked as they are an admin")

#undef CHOICE_NOKICK

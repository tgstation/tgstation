/obj/item/toy/eightball
	name = "magic eightball"
	desc = "A black ball with a stenciled number eight in white on the side. It seems full of dark liquid.\nThe instructions state that you should ask your question aloud, and then shake."

	icon = 'icons/obj/toys/toy.dmi'
	icon_state = "eightball"
	w_class = WEIGHT_CLASS_TINY

	verb_say = "rattles"

	var/shaking = FALSE
	var/on_cooldown = FALSE

	var/shake_time = 5 SECONDS
	var/cooldown_time = 10 SECONDS

	var/static/list/possible_answers = list(
		"It is certain",
		"It is decidedly so",
		"Without a doubt",
		"Yes definitely",
		"You may rely on it",
		"As I see it, yes",
		"Most likely",
		"Outlook good",
		"Yes",
		"Signs point to yes",
		"Reply hazy try again",
		"Ask again later",
		"Better not tell you now",
		"Cannot predict now",
		"Concentrate and ask again",
		"Don't count on it",
		"My reply is no",
		"My sources say no",
		"Outlook not so good",
		"Very doubtful")

/obj/item/toy/eightball/Initialize(mapload)
	. = ..()
	if(MakeHaunted())
		return INITIALIZE_HINT_QDEL

/obj/item/toy/eightball/proc/MakeHaunted()
	if(prob(1))
		new /obj/item/toy/eightball/haunted(loc)
		return TRUE
	return FALSE

/obj/item/toy/eightball/attack_self(mob/user)
	if(..())
		return

	. = TRUE
	if(shaking)
		return

	if(on_cooldown)
		to_chat(user, span_warning("[src] was shaken recently, it needs time to settle."))
		return

	user.visible_message(span_notice("[user] starts shaking [src]."), span_notice("You start shaking [src]."), span_hear("You hear shaking and sloshing."))

	shaking = TRUE

	if (!start_shaking(user))
		return

	if(do_after(user, shake_time))
		say(get_answer())

		on_cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, on_cooldown, FALSE), cooldown_time)

	shaking = FALSE

/obj/item/toy/eightball/proc/start_shaking(mob/user)
	return TRUE

/obj/item/toy/eightball/proc/get_answer()
	return pick(possible_answers)

// A broken magic eightball, it only says "YOU SUCK" over and over again.

/obj/item/toy/eightball/broken
	name = "broken magic eightball"
	desc = "A black ball with a stenciled number eight in white on the side. It is cracked and seems empty."
	var/fixed_answer

/obj/item/toy/eightball/broken/Initialize(mapload)
	. = ..()
	fixed_answer = pick(possible_answers)

/obj/item/toy/eightball/broken/get_answer()
	return fixed_answer

// Haunted eightball is identical in description and function to toy,
// except it actually ASKS THE DEAD (wooooo)

/obj/item/toy/eightball/haunted
	shake_time = 30 SECONDS
	cooldown_time = 3 MINUTES
	var/selected_message = "Nothing!"
	//these kind of store the same thing but one is easier to work with.
	var/list/votes = list()
	var/list/voted = list()
	var/static/list/haunted_answers = list(
		"yes" = list(
			"It is certain",
			"It is decidedly so",
			"Without a doubt",
			"Yes definitely",
			"You may rely on it",
			"As I see it, yes",
			"Most likely",
			"Outlook good",
			"Yes",
			"Signs point to yes"
		),
		"maybe" = list(
			"Reply hazy try again",
			"Ask again later",
			"Better not tell you now",
			"Cannot predict now",
			"Concentrate and ask again"
		),
		"no" = list(
			"Don't count on it",
			"My reply is no",
			"My sources say no",
			"Outlook not so good",
			"Very doubtful"
		)
	)

/obj/item/toy/eightball/haunted/Initialize(mapload)
	. = ..()
	for (var/answer in haunted_answers)
		votes[answer] = 0
	SSpoints_of_interest.make_point_of_interest(src)

/obj/item/toy/eightball/haunted/MakeHaunted()
	return FALSE

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/item/toy/eightball/haunted/attack_ghost(mob/user)
	if(!shaking)
		to_chat(user, span_warning("[src] is not currently being shaken."))
		return
	interact(user)
	return ..()

/obj/item/toy/eightball/haunted/start_shaking(mob/user)
	// notify ghosts that someone's shaking a haunted eightball
	// and inform them of the message, (hopefully a yes/no question)
	selected_message = tgui_input_text(user, "What is your question?", "Eightball", max_length = MAX_MESSAGE_LEN) || initial(selected_message)
	if (!(src in user.held_items))
		return FALSE
	notify_ghosts(
		"[user] is shaking [src], hoping to get an answer to \"[selected_message]\"",
		source = src,
		header = "Magic eightball",
		click_interact = TRUE,
	)
	return TRUE

/obj/item/toy/eightball/haunted/get_answer()
	var/top_amount = 0
	var/top_vote

	for(var/vote in votes)
		var/amount_of_votes = votes[vote]
		if(amount_of_votes > top_amount)
			top_vote = vote
			top_amount = amount_of_votes
		//If one option actually has votes and there's a tie, pick between them 50/50
		else if(top_amount && amount_of_votes == top_amount && prob(50))
			top_vote = vote
			top_amount = amount_of_votes

	if(isnull(top_vote))
		top_vote = pick(votes)

	for(var/vote in votes)
		votes[vote] = 0

	voted.Cut()

	var/list/top_options = haunted_answers[top_vote]
	return pick(top_options)

// Only ghosts can interact because only ghosts can open the ui
/obj/item/toy/eightball/haunted/can_interact(mob/living/user)
	return isobserver(user)

/obj/item/toy/eightball/haunted/ui_state(mob/user)
	return GLOB.observer_state

/obj/item/toy/eightball/haunted/ui_interact(mob/user, datum/tgui/ui)
	if(!isobserver(user))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EightBallVote", name)
		ui.open()

/obj/item/toy/eightball/haunted/ui_data(mob/user)
	var/list/data = list()
	data["shaking"] = shaking
	data["question"] = selected_message

	data["answers"] = list()
	for(var/vote in haunted_answers)
		var/list/answer_data = list()
		answer_data["answer"] = vote
		answer_data["amount"] = votes[vote]
		answer_data["selected"] = voted[user.ckey]

		data["answers"] += list(answer_data)
	return data

/obj/item/toy/eightball/haunted/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = usr

	switch(action)
		if("vote")
			var/selected_answer = params["answer"]
			if(!(selected_answer in haunted_answers))
				return
			var/oldvote = voted[user.ckey]
			if(oldvote)
				// detract their old vote
				votes[oldvote] -= 1

			votes[selected_answer] += 1
			voted[user.ckey] = selected_answer
			return TRUE

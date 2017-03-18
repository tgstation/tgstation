/obj/item/toy/eightball
	name = "magic eightball"
	desc = "A black ball with a stenciled number eight in white on the side. It seems full of dark liquid.\nThe instructions state that you should ask your question aloud, and then shake."

	icon = 'icons/obj/toy.dmi'
	icon_state = "eightball"

	verb_say = "rattles"

	var/shaking = FALSE
	var/on_cooldown = FALSE

	var/shake_time = 150
	var/cooldown_time = 1800

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
	..()
	if(prob(1))
		new /obj/item/toy/eightball/haunted(get_turf(src))
		qdel(src)

/obj/item/toy/eightball/attack_self(mob/user)
	if(shaking)
		return

	if(on_cooldown)
		to_chat(user, "<span class='warning'>[src] was shaken recently, it needs time to settle.</span>")
		return

	user.visible_message("<span class='notice'>[user] starts shaking [src].</span>", "<span class='notice'>You start shaking [src].</span>", "<span class='italics'>You hear shaking and sloshing.</span>")

	shaking = TRUE

	start_shaking(user)
	if(do_after(user, shake_time, needhand=TRUE, target=src, progress=TRUE))
		var/answer = get_answer()
		say(answer)

		on_cooldown = TRUE
		addtimer(CALLBACK(src, .proc/clear_cooldown), cooldown_time)

	shaking = FALSE

/obj/item/toy/eightball/proc/start_shaking(user)
	return

/obj/item/toy/eightball/proc/get_answer()
	return pick(possible_answers)

/obj/item/toy/eightball/proc/clear_cooldown()
	on_cooldown = FALSE

// A broken magic eightball, it only says "YOU SUCK" over and over again.

/obj/item/toy/eightball/broken
	name = "broken magic eightball"
	desc = "A black ball with a stenciled number eight in white on the side. It is cracked and seems empty."
	var/fixed_answer

/obj/item/toy/eightball/broken/Initialize(mapload)
	..()
	fixed_answer = pick(possible_answers)

/obj/item/toy/eightball/broken/get_answer()
	return fixed_answer

// Haunted eightball is identical in description and function to toy,
// except it actually ASKS THE DEAD (wooooo)

/obj/item/toy/eightball/haunted
	flags = HEAR
	var/last_message
	var/selected_message
	var/list/votes

/obj/item/toy/eightball/haunted/Initialize(mapload)
	..()
	votes = list()
	poi_list |= src

/obj/item/toy/eightball/haunted/Destroy()
	poi_list -= src
	. = ..()

/obj/item/toy/eightball/haunted/attack_ghost(mob/user)
	if(!shaking)
		to_chat(user, "<span class='warning'>[src] is not currently being shaken.</span>")
		return
	interact(user)

/obj/item/toy/eightball/haunted/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans)
	last_message = raw_message

/obj/item/toy/eightball/haunted/start_shaking(mob/user)
	// notify ghosts that someone's shaking a haunted eightball
	// and inform them of the message, (hopefully a yes/no question)
	selected_message = last_message
	notify_ghosts("[user] is shaking [src], hoping to get an answer to \"[selected_message]\"", source=src, enter_link="<a href=?src=\ref[src];interact=1>(Click to help)</a>", action=NOTIFY_ATTACK)

/obj/item/toy/eightball/haunted/Topic(href, href_list)
	if(href_list["interact"])
		if(isobserver(usr))
			interact(usr)

/obj/item/toy/eightball/haunted/proc/get_vote_tallies()
	var/list/answers = list()
	for(var/ckey in votes)
		var/selected = votes[ckey]
		if(selected in answers)
			answers[selected]++
		else
			answers[selected] = 1

	return answers


/obj/item/toy/eightball/haunted/get_answer()
	if(!votes.len)
		return pick(possible_answers)

	var/list/tallied_votes = get_vote_tallies()

	// I miss python sorting, then I wouldn't have to muck about with
	// all this
	var/most_popular_answer
	var/most_amount = 0
	// yes, if there is a tie, there is an arbitary decision
	// but we never said the spirit world was fair
	for(var/A in tallied_votes)
		var/amount = tallied_votes[A]
		if(amount > most_amount)
			most_popular_answer = A

	return most_popular_answer

/obj/item/toy/eightball/haunted/ui_interact(mob/user, ui_key="main", datum/tgui/ui=null, force_open=0, datum/tgui/master_ui=null, datum/ui_state/state=observer_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "eightball", name, 400, 600, master_ui, state)
		ui.open()

/obj/item/toy/eightball/haunted/ui_data(mob/user)
	var/list/data = list()
	data["shaking"] = shaking
	data["question"] = selected_message
	var/list/tallied_votes = get_vote_tallies()

	data["answers"] = list()

	for(var/pa in possible_answers)
		var/list/L = list()
		L["answer"] = pa
		var/amount = 0
		if(pa in tallied_votes)
			amount = tallied_votes[pa]
		L["amount"] = amount
		var/selected = FALSE
		if(votes[user.ckey] == pa)
			selected = TRUE
		L["selected"] = selected

		data["answers"] += list(L)
	return data

/obj/item/toy/eightball/haunted/ui_act(action, params)
	if(..())
		return
	var/mob/user = usr

	switch(action)
		if("vote")
			var/selected_answer = params["answer"]
			if(!selected_answer in possible_answers)
				return
			else
				votes[user.ckey] = selected_answer
				. = TRUE

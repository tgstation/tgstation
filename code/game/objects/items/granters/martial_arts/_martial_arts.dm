/obj/item/book/granter/martial
	/// The martial arts type we give
	var/datum/martial_art/martial
	/// The name of the martial arts, formatted in a more text-friendly way.
	var/martial_name = ""
	/// The text given to the user when they learn the martial arts
	var/greet = ""

/obj/item/book/granter/martial/can_learn(mob/user)
	if(!martial)
		CRASH("Someone attempted to learn [type], which did not have a martial arts set.")
	if(user.mind.has_martialart(initial(martial.id)))
		to_chat(user, span_warning("You already know [martial_name]!"))
		return FALSE
	return TRUE

/obj/item/book/granter/martial/on_reading_start(mob/user)
	to_chat(user, span_notice("You start reading about [martial_name]..."))
	return TRUE

/obj/item/book/granter/martial/on_reading_finished(mob/user)
	to_chat(user, "[greet]")
	var/datum/martial_art/martial_to_learn = new martial()
	martial_to_learn.teach(user)
	user.log_message("learned the martial art [martial_name] ([martial_to_learn])", LOG_ATTACK, color = "orange")

/obj/item/book/granter/martial
	/// The martial arts type we give
	var/datum/martial_art/martial
	/// The name of the martial arts, formatted in a more text-friendly way.
	var/martial_name = ""
	/// The text given to the user when they learn the martial arts
	var/greet = ""

/obj/item/book/granter/martial/can_learn(mob/living/user)
	if(!martial)
		CRASH("Someone attempted to learn [type], which did not have a martial arts set.")
	if(!isliving(user))
		return FALSE
	if(locate(martial) in user.martial_arts)
		to_chat(user, span_warning("You already know [martial_name]!"))
		return FALSE
	return TRUE

/obj/item/book/granter/martial/on_reading_start(mob/user)
	to_chat(user, span_notice("You start reading about [martial_name]..."))
	return TRUE

/obj/item/book/granter/martial/on_reading_finished(mob/user)
	if(user.mind)
		if(!user.mind.AddComponent(/datum/component/mindbound_martial_arts, martial))
			to_chat(user, span_warning("You attempt to learn [martial_name] from [src], but it doesn't stick."))
			uses += 1 // Return the use
			return
	else
		var/datum/martial_art/martial_art = new martial(user)
		martial_art.teach(user)

	to_chat(user, "[greet]")
	user.log_message("learned the martial art [martial_name] ([martial])", LOG_ATTACK, color = "orange")

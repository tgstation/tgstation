/mob/living/silicon/examine(mob/user) //Displays a silicon's laws to ghosts
<<<<<<< HEAD
	. = ..()
	if(laws && isobserver(user))
		. += "<b>[src] has the following laws:</b>"
		for(var/law in laws.get_law_list(include_zeroth = TRUE))
			. += law
=======
	if(laws && isobserver(user))
		to_chat(user, "<b>[src] has the following laws:</b>")
		laws.show_laws(user)
>>>>>>> Updated this old code to fork

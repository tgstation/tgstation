/mob/living/silicon/examine(mob/user) //Displays a silicon's laws to ghosts
	if(laws && isobserver(user))
		to_chat(user, "<b>[src] has the following laws:</b>")
		laws.show_laws(user)
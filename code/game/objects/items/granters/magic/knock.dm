/obj/item/book/granter/action/spell/knock
	granted_action = /datum/action/cooldown/spell/aoe/knock
	action_name = "knock"
	icon_state ="bookknock"
	desc = "This book is hard to hold closed properly."
	remarks = list(
		"Open Sesame!",
		"So THAT'S the magic password!",
		"Slow down, book. I still haven't finished this page...",
		"The book won't stop moving!",
		"I think this is hurting the spine of the book...",
		"I can't get to the next page, it's stuck t- I'm good, it just turned to the next page on it's own.",
		"Yeah, staff of doors does the same thing. Go figure...",
	)

/obj/item/book/granter/action/spell/knock/recoil(mob/living/user)
	. = ..()
	to_chat(user, span_warning("You're knocked down!"))
	user.Paralyze(4 SECONDS)

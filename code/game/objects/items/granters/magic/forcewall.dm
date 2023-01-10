/obj/item/book/granter/action/spell/forcewall
	granted_action = /datum/action/cooldown/spell/forcewall
	action_name = "forcewall"
	icon_state ="bookforcewall"
	desc = "This book has a dedication to mimes everywhere inside the front cover."
	remarks = list(
		"I can go through the wall! Neat.",
		"Why are there so many mime references...?",
		"This would cause much grief in a hallway...",
		"This is some surprisingly strong magic to create a wall nobody can pass through...",
		"Why the dumb stance? It's just a flick of the hand...",
		"Why are the pages so hard to turn, is this even paper?",
		"I can't mo Oh, i'm fine...",
	)

/obj/item/book/granter/action/spell/forcewall/recoil(mob/living/user)
	. = ..()
	to_chat(user, span_warning("You suddenly feel very solid!"))
	user.Stun(4 SECONDS, ignore_canstun = TRUE)
	user.petrify(6 SECONDS)

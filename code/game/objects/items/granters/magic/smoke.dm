/obj/item/book/granter/action/spell/smoke
	granted_action = /datum/action/cooldown/spell/smoke
	action_name = "smoke"
	icon_state ="booksmoke"
	desc = "This book is overflowing with the dank arts."
	remarks = list(
		"Smoke Bomb! Heh...",
		"Smoke bomb would do just fine too...",
		"Wait, there's a machine that does the same thing in chemistry?",
		"This book smells awful...",
		"Why all these weed jokes? Just tell me how to cast it...",
		"Wind will ruin the whole spell, good thing we're in space... Right?",
		"So this is how the spider clan does it...",
	)

/obj/item/book/granter/action/spell/smoke/recoil(mob/living/user)
	. = ..()
	to_chat(user,span_warning("Your stomach rumbles..."))
	if(user.nutrition)
		user.set_nutrition(200)
		if(user.nutrition <= 0)
			user.set_nutrition(0)

// Chaplain's smoke book
/obj/item/book/granter/action/spell/smoke/lesser
	granted_action = /datum/action/cooldown/spell/smoke/lesser

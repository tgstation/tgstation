/obj/item/book/granter/action/spell/blind
	granted_action = /datum/action/cooldown/spell/pointed/blind
	action_name = "blind"
	icon_state = "bookblind"
	desc = "This book looks blurry, no matter how you look at it."
	remarks = list(
		"Well I can't learn anything if I can't read the damn thing!",
		"Why would you use a dark font on a dark background...",
		"Ah, I can't see an Oh, I'm fine...",
		"I can't see my hand...!",
		"I'm manually blinking, damn you book...",
		"I can't read this page, but somehow I feel like I learned something from it...",
		"Hey, who turned off the lights?",
	)

/obj/item/book/granter/action/spell/blind/recoil(mob/living/user)
	. = ..()
	to_chat(user, span_warning("You go blind!"))
	user.blind_eyes(10)

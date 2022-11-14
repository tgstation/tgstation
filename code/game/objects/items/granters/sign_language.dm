/// Sign language book adds the sign language component to the reading Human.
/// Grants reader the ability to toggle sign language using a HUD button.
/obj/item/book/granter/action/sign_language
	name = "Galactic Standard Sign Language"
	desc = "A comprehensive guide to learning sign language and finger-spelling."
	remarks = list(
		"Signing comprises a range of techniques...",
		"Words can be spelled out through sequences of signs...",
		"The way your palm faces?",
		"With questions, the eyebrows are lowered...",
		"Cool! Extensive coverage of common phrases!",
		"You can communicate just about anything through signing...",
	)
	granted_action = /datum/action/innate/sign_language
	action_name = "sign language"

/obj/item/book/granter/action/sign_language/can_learn(mob/living/user)
	return iscarbon(user) && ..()

/obj/item/book/granter/action/sign_language/recoil(mob/living/user)
	to_chat(user, span_warning("You can't read it, the pages are too faded and smudged!"))

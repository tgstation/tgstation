/// Sign language book adds the sign language component to the reading Human.
/// Grants reader the ability to toggle sign language using a HUD button.
/obj/item/book/granter/sign_language
	name = "Galactic Standard Sign Language"
	desc = "A comprehensive guide to learning sign language and finger-spelling."
	remarks = list(
		"Signing comprises a range of techniques...",
		"Words can be spelled out through sequences of signs...",
		"The way your palm faces?",
		"With questions, the eyebrows are lowered...",
		"Cool! Extensive coverage of common phrases!",
		"Communicate just about anything through signing...",
	)

/obj/item/book/granter/sign_language/can_learn(mob/living/user)
	if (!iscarbon(user))
		return
	if (user.GetComponent(/datum/component/sign_language))
		to_chat(user, span_warning("You already know all about sign language!"))
		return
	return TRUE

/obj/item/book/granter/sign_language/recoil(mob/living/user)
	to_chat(user, span_warning("You can't read it, the pages are too faded and smudged!"))

/// Called when the reading is completely finished. This is where the actual granting should happen.
/obj/item/book/granter/sign_language/on_reading_finished(mob/living/user)
	..()
	user.AddComponent(/datum/component/sign_language)

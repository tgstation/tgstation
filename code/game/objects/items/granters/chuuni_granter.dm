/// Turns the user into a chuunibyou.
/obj/item/book/granter/chuunibyou
	name = "I Found a Mysterious Book in the Library That Teaches Me How to Become a Chuunibyou, But It Turns Out It's Actually a Grimoire That Unlocks My Hidden Powers!"
	desc = "I'd rather get caught holding a syndicate revolver, honestly."
	remarks = list(
		"How can anyone believe this stuff?",
		"...Why am I wasting my time on this?",
		"Coming up with the invocations on demand is actually a skill...",
		"I can't believe I'm reading this!",
		"According to this manga, my power goes up by 5000% by using invocations...",
	)

/obj/item/book/granter/chuunibyou/can_learn(mob/living/user)
	if (!isliving(user))
		return
	if (user.GetComponent(/datum/component/chuunibyou))
		to_chat(user, span_warning("You're already a chuunibyou!"))
		return
	return TRUE

/obj/item/book/granter/chuunibyou/recoil(mob/living/user)
	to_chat(user, span_warning("You just can't bring yourself to read it... it's just not worth the cringe..."))

/obj/item/book/granter/chuunibyou/on_reading_finished(mob/living/user)
	..()
	user.AddComponent(/datum/component/chuunibyou/no_healing)

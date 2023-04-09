/obj/item/book/granter/crafting_recipe/pipegun_prime
	name = "diary of a dead assistant"
	desc = "A battered journal. Looks like he had a pretty rough life."
	crafting_recipe_types = list(
		/datum/crafting_recipe/pipegun_prime
	)
	icon_state = "book1"
	remarks = list(
		"He apparently mastered some lost guncrafting technique.",
		"Why do I have to go through so many hoops to get this shitty gun?",
		"That much Grey Bull cannot be healthy...",
		"Did he drop this into a moisture trap? Yuck.",
		"Toolboxing techniques, huh? I kinda just want to know how to make the gun.",
		"What the hell does he mean by 'ancient warrior tradition'?",
	)

/obj/item/book/granter/crafting_recipe/pipegun_prime/recoil(mob/living/user)
	to_chat(user, span_warning("The book turns to dust in your hands."))
	qdel(src)

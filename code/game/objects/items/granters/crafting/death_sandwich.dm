/obj/item/book/granter/crafting_recipe/death_sandwich
	name = "\improper SANDWICH OF DEATH SECRET RECIPE"
	desc = "An ancient composition notebook with the instructions for an ancient and ultimate sandwich scrawled upon its loose-leaf pages. The title has been scrawled onto it with permanent marker."
	crafting_recipe_types = list(
		/datum/crafting_recipe/food/death_sandwich
	)
	icon_state = "cooking_learning_sandwich"
	remarks = list(
		"A meatball sub, but what makes it so special?",
		"I just need to grease back my hair...?",
		"What kind of ancient civilization wore jorts?",
		"So it DOES matter what angle you fold the salami in...",
	)

/obj/item/book/granter/crafting_recipe/death_sandwich/recoil(mob/living/user)
	to_chat(user, span_warning("The book comically explodes in your hands, leaving no trace."))
	qdel(src)

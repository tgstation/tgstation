/obj/item/book/granter/crafting_recipe/maintgodgranter
	name = "maintenance encyclopedia"
	icon_state = "book1"
	desc = "A burnt and damaged tome? Where did this come from?"
	crafting_recipe_types = list(
		/datum/crafting_recipe/pipegun_prime,
		/datum/crafting_recipe/laser_musket_prime,
		/datum/crafting_recipe/smoothbore_disabler_prime,
		/datum/crafting_recipe/trash_cannon,
		/datum/crafting_recipe/trashball,
	)
	remarks = list(
		"I never knew assistants could be this creative.",
		"You can make that with what?",
		"Why would I make these when I can just buy a gun from cargo?", // Maybe needs more.
	)

/obj/item/book/granter/crafting_recipe/maintgodgranter/recoil(mob/living/user)
	to_chat(user, span_warning("The book turns to dust in your hands."))
	qdel(src)

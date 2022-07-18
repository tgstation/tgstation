/obj/item/book/granter/crafting_recipe/trash_cannon
	name = "diary of a demoted engineer"
	desc = "A lost journal. The engineer seems very deranged about their demotion."
	crafting_recipe_types = list(
		/datum/crafting_recipe/trash_cannon,
		/datum/crafting_recipe/trashball,
	)
	icon_state = "book1"
	remarks = list(
		"\"I'll show them! I'll build a CANNON!\"",
		"\"Gunpowder is ideal, but i'll have to improvise...\"",
		"\"I savor the look on the CE's face when I BLOW down the walls to engineering!\"",
		"\"If the supermatter gets loose from my rampage, so be it!\"",
		"\"I'VE GONE COMPLETELY MENTAL!\"",
	)

/obj/item/book/granter/crafting_recipe/trash_cannon/recoil(mob/living/user)
	to_chat(user, span_warning("The book turns to dust in your hands."))
	qdel(src)

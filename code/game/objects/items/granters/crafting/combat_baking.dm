/obj/item/book/granter/crafting_recipe/combat_baking
	name = "the anarchist's cookbook"
	desc = "A widely illegal recipe book, which will teach you how to bake croissants to die for."
	crafting_recipe_types = list(
		/datum/crafting_recipe/food/throwing_croissant,
	)
	icon_state = "cooking_learing_illegal"
	remarks = list(
		"\"Austrian? Not French?\"",
		"\"Got to get the butter ratio right...\"",
		"\"This is the greatest thing since sliced bread!\"",
		"\"I'll leave no trace except crumbs!\"",
		"\"Who knew that bread could hurt a man so badly?\"",
	)

/obj/item/book/granter/crafting_recipe/combat_baking/recoil(mob/living/user)
	to_chat(user, span_warning("The book dissolves into burnt flour!"))
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

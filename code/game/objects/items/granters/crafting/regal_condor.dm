/obj/item/book/granter/crafting_recipe/regal_condor
	name = "memoirs of a fallen agent"
	desc = "A battered journal. It seems like it is covered in donkpocket crumbs."
	crafting_recipe_types = list(
		/datum/crafting_recipe/deagle_prime,
		/datum/crafting_recipe/deagle_prime_mag,
	)
	icon_state = "book1"
	remarks = list(
		"It says that she was once an assistant, before she was activated...",
		"I don't think you can make a pistol 'absorb' other pistols, but whatever...",
		"Wait, how much gold do you need to make this?",
		"So the Tiger Co-op can come up with some interesting things every now and again...",
		"Why not just give me an Ansem pistol? I'll just go find a bucket of black paint...",
		"Cleanse, or die trying...",
	)

/obj/item/book/granter/crafting_recipe/regal_condor/recoil(mob/living/user)
	to_chat(user, span_warning("The book turns to dust in your hands."))
	qdel(src)

/obj/structure/aquarium/lawyer/Initialize(mapload)
	. = ..()

	new /obj/item/aquarium_prop/seaweed(src)

	new /obj/item/fish/goldfish/gill(src)

/obj/item/fish/goldfish/gill
	name = "McGill"
	desc = "A great rubber duck tool for Lawyers who can't get a grasp over their case."
	stable_population = 1
	random_case_rarity = FISH_RARITY_NOPE

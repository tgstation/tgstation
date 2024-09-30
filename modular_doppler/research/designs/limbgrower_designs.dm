/obj/machinery/limbgrower/Initialize(mapload)
	categories += list(SPECIES_SNAIL, SPECIES_SLUGCAT, SPECIES_ANTHROMORPH, SPECIES_INSECTOID, SPECIES_AQUATIC)
	return ..()

/datum/design/leftarm/New()
	category += list(SPECIES_SNAIL, SPECIES_SLUGCAT, SPECIES_ANTHROMORPH, SPECIES_INSECTOID, SPECIES_AQUATIC)
	return ..()

/datum/design/rightarm/New()
	category += list(SPECIES_SNAIL, SPECIES_SLUGCAT, SPECIES_ANTHROMORPH, SPECIES_INSECTOID, SPECIES_AQUATIC)
	return ..()

/datum/design/leftleg/New()
	category += list(SPECIES_SNAIL, SPECIES_SLUGCAT, SPECIES_ANTHROMORPH, SPECIES_INSECTOID, SPECIES_AQUATIC)
	return ..()

/datum/design/rightleg/New()
	category += list(SPECIES_SNAIL, SPECIES_SLUGCAT, SPECIES_ANTHROMORPH, SPECIES_INSECTOID, SPECIES_AQUATIC)
	return ..()

/datum/design/tongue/snail
	name = "Snail Tongue"
	id = "snailtongue"
	build_path = /obj/item/organ/internal/tongue/snail
	category = list(
		SPECIES_SNAIL,
		RND_CATEGORY_INITIAL,
	)

/datum/design/liver/snail
	name = "Snail Liver"
	id = "snailliver"
	build_path = /obj/item/organ/internal/liver/snail
	category = list(
		SPECIES_SNAIL,
		RND_CATEGORY_INITIAL,
	)

/datum/design/heart/snail
	name = "Snail Heart"
	id = "snailheart"
	build_path = /obj/item/organ/internal/heart/snail
	category = list(
		SPECIES_SNAIL,
		RND_CATEGORY_INITIAL,
	)

/datum/design/ears/cat
	name = "Cat Ears, Variety"
	id = "catears"
	build_path = /obj/item/organ/internal/ears/cat
	category = list(
		SPECIES_HUMAN,
		RND_CATEGORY_INITIAL,
	)

/datum/design/ears/lizard
	name = "Lizard Ears"
	id = "lizardears"
	build_path = /obj/item/organ/internal/ears/lizard
	category = list(
		SPECIES_HUMAN,
		RND_CATEGORY_INITIAL,
	)

/datum/design/ears/fox
	name = "Fox Ears"
	id = "foxears"
	build_path = /obj/item/organ/internal/ears/fox
	category = list(
		SPECIES_HUMAN,
		RND_CATEGORY_INITIAL,
	)

/datum/design/ears/dog
	name = "Dog Ears"
	id = "dogears"
	build_path = /obj/item/organ/internal/ears/dog
	category = list(
		SPECIES_HUMAN,
		RND_CATEGORY_INITIAL,
	)

/datum/design/ears/bunny
	name = "Bunny Ears"
	id = "bunnyears"
	build_path = /obj/item/organ/internal/ears/bunny
	category = list(
		SPECIES_HUMAN,
		RND_CATEGORY_INITIAL,
	)

/datum/design/ears/bird
	name = "Bird Ears"
	id = "birdears"
	build_path = /obj/item/organ/internal/ears/bird
	category = list(
		SPECIES_HUMAN,
		RND_CATEGORY_INITIAL,
	)

/datum/design/ears/mouse
	name = "Mouse Ears"
	id = "mouseears"
	build_path = /obj/item/organ/internal/ears/mouse
	category = list(
		SPECIES_HUMAN,
		RND_CATEGORY_INITIAL,
	)

/datum/design/ears/monkey
	name = "Monkey Ears"
	id = "monkeyears"
	build_path = /obj/item/organ/internal/ears/monkey
	category = list(
		SPECIES_HUMAN,
		RND_CATEGORY_INITIAL,
	)

/datum/design/ears/deer
	name = "Deer Ears"
	id = "deerears"
	build_path = /obj/item/organ/internal/ears/deer
	category = list(
		SPECIES_HUMAN,
		RND_CATEGORY_INITIAL,
	)

/datum/design/ears/fish
	name = "Fish Ears"
	id = "fishears"
	build_path = /obj/item/organ/internal/ears/fish
	category = list(
		SPECIES_HUMAN,
		RND_CATEGORY_INITIAL,
	)

/datum/design/ears/bug
	name = "Bug Ears"
	id = "bugears"
	build_path = /obj/item/organ/internal/ears/bug
	category = list(
		SPECIES_HUMAN,
		RND_CATEGORY_INITIAL,
	)

/datum/design/ears/humanoid
	name = "Humanoid Ears"
	id = "humanoidears"
	build_path = /obj/item/organ/internal/ears/humanoid
	category = list(
		SPECIES_HUMAN,
		RND_CATEGORY_INITIAL,
	)

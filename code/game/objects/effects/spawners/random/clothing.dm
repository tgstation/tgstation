/obj/effect/spawner/random/clothing
	name = "clothing loot spawner"
	desc = "Time to look pretty."

/obj/effect/spawner/random/clothing/costume
	name = "random costume spawner"
	spawn_all_loot = TRUE

/obj/effect/spawner/random/costume/Initialize()
	loot = list()
	for(var/path in subtypesof(/obj/effect/spawner/bundle/costume))
		loot[path] = TRUE
	. = ..()

/obj/effect/spawner/random/clothing/beret_or_rabbitears
	name = "beret or rabbit ears spawner"
	loot = list(
	/obj/item/clothing/head/beret = 1,
	/obj/item/clothing/head/rabbitears = 1,
	)

/obj/effect/spawner/random/clothing/bowler_or_that
	name = "bowler or top hat spawner"
	loot = list(
	/obj/item/clothing/head/bowler = 1,
	/obj/item/clothing/head/that = 1,
	)

/obj/effect/spawner/random/clothing/kittyears_or_rabbitears
	name = "kitty ears or rabbit ears spawner"
	loot = list(
	/obj/item/clothing/head/kitty = 1,
	/obj/item/clothing/head/rabbitears = 1,
	)

/obj/effect/spawner/random/clothing/pirate_or_bandana
	name = "pirate hat or bandana spawner"
	loot = list(
	/obj/item/clothing/head/pirate = 1,
	/obj/item/clothing/head/bandana = 1,
	)

/obj/effect/spawner/random/clothing/twentyfive_percent_cyborg_mask
	name = "25% cyborg mask spawner"
	loot = list(
		"" = 75,
	/obj/item/clothing/mask/gas/cyborg = 25,
	)

/obj/effect/spawner/random/clothing/mafia_outfit
	name = "mafia outfit spawner"
	loot = list(
	/obj/effect/spawner/bundle/costume/mafia = 20,
	/obj/effect/spawner/bundle/costume/mafia/white = 5,
	/obj/effect/spawner/bundle/costume/mafia/beige = 5,
	/obj/effect/spawner/bundle/costume/mafia/checkered = 2,
	)

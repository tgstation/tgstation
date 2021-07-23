/obj/effect/spawner/lootdrop/clothing
name = "clothing loot spawner"
desc = "Time to look pretty."

/obj/effect/spawner/lootdrop/clothing/costume
	name = "random costume spawner"

/obj/effect/spawner/lootdrop/costume/Initialize()
	loot = list()
	for(var/path in subtypesof(/obj/effect/spawner/bundle/costume))
		loot[path] = TRUE
	. = ..()

/obj/effect/spawner/lootdrop/clothing/beret_or_rabbitears
	name = "beret or rabbit ears spawner"
	loot = list(
		/obj/item/clothing/head/beret = 1,
		/obj/item/clothing/head/rabbitears = 1,
	)

/obj/effect/spawner/lootdrop/clothing/bowler_or_that
	name = "bowler or top hat spawner"
	loot = list(
		/obj/item/clothing/head/bowler = 1,
		/obj/item/clothing/head/that = 1,
	)

/obj/effect/spawner/lootdrop/clothing/kittyears_or_rabbitears
	name = "kitty ears or rabbit ears spawner"
	loot = list(
		/obj/item/clothing/head/kitty = 1,
		/obj/item/clothing/head/rabbitears = 1,
	)

/obj/effect/spawner/lootdrop/clothing/pirate_or_bandana
	name = "pirate hat or bandana spawner"
	loot = list(
		/obj/item/clothing/head/pirate = 1,
		/obj/item/clothing/head/bandana = 1,
	)

/obj/effect/spawner/lootdrop/clothing/twentyfive_percent_cyborg_mask
	name = "25% cyborg mask spawner"
	loot = list(
		"" = 75,
		/obj/item/clothing/mask/gas/cyborg = 25,
	)

/obj/effect/spawner/lootdrop/clothing/mafia_outfit
	name = "mafia outfit spawner"
	loot = list(
		/obj/effect/spawner/bundle/costume/mafia = 20,
		/obj/effect/spawner/bundle/costume/mafia/white = 5,
		/obj/effect/spawner/bundle/costume/mafia/beige = 5,
		/obj/effect/spawner/bundle/costume/mafia/checkered = 2,
	)

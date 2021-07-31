/obj/effect/spawner/random/clothing
	name = "clothing loot spawner"
	desc = "Time to look pretty."

/obj/effect/spawner/random/clothing/costume
	name = "random costume spawner"

/obj/effect/spawner/random/clothing/costume/Initialize()
	loot = list()
	for(var/path in subtypesof(/obj/effect/spawner/costume))
		loot[path] = TRUE
	. = ..()

/obj/effect/spawner/random/clothing/beret_or_rabbitears
	name = "beret or rabbit ears spawner"
	loot = list(
		/obj/item/clothing/head/beret,
		/obj/item/clothing/head/rabbitears,
	)

/obj/effect/spawner/random/clothing/bowler_or_that
	name = "bowler or top hat spawner"
	loot = list(
		/obj/item/clothing/head/bowler,
		/obj/item/clothing/head/that,
	)

/obj/effect/spawner/random/clothing/kittyears_or_rabbitears
	name = "kitty ears or rabbit ears spawner"
	loot = list(
		/obj/item/clothing/head/kitty,
		/obj/item/clothing/head/rabbitears,
	)

/obj/effect/spawner/random/clothing/pirate_or_bandana
	name = "pirate hat or bandana spawner"
	loot = list(
		/obj/item/clothing/head/pirate,
		/obj/item/clothing/head/bandana,
	)

/obj/effect/spawner/random/clothing/twentyfive_percent_cyborg_mask
	name = "25% cyborg mask spawner"
	spawn_loot_chance = 25
	loot = list(/obj/item/clothing/mask/gas/cyborg)

/obj/effect/spawner/random/clothing/mafia_outfit
	name = "mafia outfit spawner"
	loot = list(
		/obj/effect/spawner/costume/mafia = 20,
		/obj/effect/spawner/costume/mafia/white = 5,
		/obj/effect/spawner/costume/mafia/beige = 5,
		/obj/effect/spawner/costume/mafia/checkered = 2,
	)

/obj/effect/spawner/random/clothing/syndie
	name = "syndie outfit spawner"
	loot = list(
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/under/syndicate/skirt,
		/obj/item/clothing/under/syndicate/bloodred,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/clothing/under/syndicate/tacticool/skirt,
		/obj/item/clothing/under/syndicate/sniper,
		/obj/item/clothing/under/syndicate/camo,
		/obj/item/clothing/under/syndicate/soviet,
		/obj/item/clothing/under/syndicate/combat,
		/obj/item/clothing/under/syndicate/rus_army,
		/obj/item/clothing/under/syndicate/bloodred/sleepytime,
	)

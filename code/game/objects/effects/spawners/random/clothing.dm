/obj/effect/spawner/random/clothing
	name = "clothing loot spawner"
	desc = "Time to look pretty."
	icon_state = "hat"

/obj/effect/spawner/random/clothing/costume
	name = "random costume spawner"
	icon_state = "costume"
	loot_subtype_path = /obj/effect/spawner/costume
	loot = list()

/obj/effect/spawner/random/clothing/beret_or_rabbitears
	name = "beret or rabbit ears spawner"
	loot = list(
		/obj/item/clothing/head/beret,
		/obj/item/clothing/head/costume/rabbitears,
	)

/obj/effect/spawner/random/clothing/bowler_or_that
	name = "bowler or top hat spawner"
	loot = list(
		/obj/item/clothing/head/hats/bowler,
		/obj/item/clothing/head/hats/tophat,
	)

/obj/effect/spawner/random/clothing/kittyears_or_rabbitears
	name = "kitty ears or rabbit ears spawner"
	loot = list(
		/obj/item/clothing/head/costume/kitty,
		/obj/item/clothing/head/costume/rabbitears,
	)

/obj/effect/spawner/random/clothing/pirate_or_bandana
	name = "pirate hat or bandana spawner"
	loot = list(
		/obj/item/clothing/head/costume/pirate,
		/obj/item/clothing/head/costume/pirate/bandana,
	)

/obj/effect/spawner/random/clothing/twentyfive_percent_cyborg_mask
	name = "25% cyborg mask spawner"
	spawn_loot_chance = 25
	loot = list(/obj/item/clothing/mask/gas/cyborg)

/obj/effect/spawner/random/clothing/mafia_outfit
	name = "mafia outfit spawner"
	icon_state = "costume"
	loot = list(
		/obj/effect/spawner/costume/mafia = 20,
		/obj/effect/spawner/costume/mafia/white = 5,
		/obj/effect/spawner/costume/mafia/beige = 5,
		/obj/effect/spawner/costume/mafia/checkered = 2,
	)

/obj/effect/spawner/random/clothing/syndie
	name = "syndie outfit spawner"
	icon_state = "syndicate"
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

/obj/effect/spawner/random/clothing/gloves
	name = "random gloves"
	desc = "These gloves are supposed to be a random color..."
	icon_state = "gloves"
	loot = list(
		/obj/item/clothing/gloves/color/orange,
		/obj/item/clothing/gloves/color/red,
		/obj/item/clothing/gloves/color/blue,
		/obj/item/clothing/gloves/color/purple,
		/obj/item/clothing/gloves/color/green,
		/obj/item/clothing/gloves/color/grey,
		/obj/item/clothing/gloves/color/light_brown,
		/obj/item/clothing/gloves/color/brown,
		/obj/item/clothing/gloves/color/white,
		/obj/item/clothing/gloves/color/rainbow,
	)

/obj/effect/spawner/random/clothing/lizardboots
	name = "random lizard boot quality"
	desc = "Which ever gets picked, the lizard race loses"
	icon_state = "lizard_boots"
	loot = list(
		/obj/item/clothing/shoes/cowboy/lizard = 7,
		/obj/item/clothing/shoes/cowboy/lizard/masterwork = 1
	)

/obj/effect/spawner/random/clothing/wardrobe_locker
	name = "wardrobe locker spawner"
	icon_state = "locker_clothing"
	loot = list(
		/obj/structure/locker/gmlocker,
		/obj/structure/locker/cheflocker,
		/obj/structure/locker/jlocker,
		/obj/structure/locker/lawlocker,
		/obj/structure/locker/wardrobe/chaplain_black,
		/obj/structure/locker/wardrobe/red,
		/obj/structure/locker/wardrobe/cargotech,
		/obj/structure/locker/wardrobe/atmospherics_yellow,
		/obj/structure/locker/wardrobe/engineering_yellow,
		/obj/structure/locker/wardrobe/white/medical,
		/obj/structure/locker/wardrobe/robotics_black,
		/obj/structure/locker/wardrobe/chemistry_white,
		/obj/structure/locker/wardrobe/genetics_white,
		/obj/structure/locker/wardrobe/virology_white,
		/obj/structure/locker/wardrobe/science_white,
		/obj/structure/locker/wardrobe/botanist,
		/obj/structure/locker/wardrobe/curator,
		/obj/structure/locker/wardrobe/pjs,
	)

/obj/effect/spawner/random/clothing/wardrobe_locker_colored
	name = "colored uniform locker spawner"
	icon_state = "locker_clothing"
	loot = list(
		/obj/structure/locker/wardrobe/mixed,
		/obj/structure/locker/wardrobe,
		/obj/structure/locker/wardrobe/pink,
		/obj/structure/locker/wardrobe/black,
		/obj/structure/locker/wardrobe/green,
		/obj/structure/locker/wardrobe/orange,
		/obj/structure/locker/wardrobe/yellow,
		/obj/structure/locker/wardrobe/white,
		/obj/structure/locker/wardrobe/grey,
	)

/obj/effect/spawner/random/clothing/backpack
	name = "backpack spawner"
	icon_state = "backpack"
	loot = list(
		/obj/item/storage/backpack,
		/obj/item/storage/backpack/clown,
		/obj/item/storage/backpack/explorer,
		/obj/item/storage/backpack/mime,
		/obj/item/storage/backpack/medic,
		/obj/item/storage/backpack/security,
		/obj/item/storage/backpack/industrial,
		/obj/item/storage/backpack/botany,
		/obj/item/storage/backpack/chemistry,
		/obj/item/storage/backpack/genetics,
		/obj/item/storage/backpack/science,
		/obj/item/storage/backpack/virology,
		/obj/item/storage/backpack/satchel,
		/obj/item/storage/backpack/satchel/leather,
		/obj/item/storage/backpack/satchel/eng,
		/obj/item/storage/backpack/satchel/med,
		/obj/item/storage/backpack/satchel/vir,
		/obj/item/storage/backpack/satchel/chem,
		/obj/item/storage/backpack/satchel/gen,
		/obj/item/storage/backpack/satchel/science,
		/obj/item/storage/backpack/satchel/hyd,
		/obj/item/storage/backpack/satchel/sec,
		/obj/item/storage/backpack/satchel/explorer,
		/obj/item/storage/backpack/duffelbag,
		/obj/item/storage/backpack/duffelbag/med,
		/obj/item/storage/backpack/duffelbag/explorer,
		/obj/item/storage/backpack/duffelbag/hydroponics,
		/obj/item/storage/backpack/duffelbag/chemistry,
		/obj/item/storage/backpack/duffelbag/genetics,
		/obj/item/storage/backpack/duffelbag/science,
		/obj/item/storage/backpack/duffelbag/virology,
		/obj/item/storage/backpack/duffelbag/sec,
		/obj/item/storage/backpack/duffelbag/engineering,
		/obj/item/storage/backpack/duffelbag/clown,
	)

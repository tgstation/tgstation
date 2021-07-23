/obj/effect/spawner/lootdrop/space
	name = "generic space ruin loot spawner"
	lootcount = 1

/// Randomly picks 5 wads of space cash.
/obj/effect/spawner/lootdrop/space/cashmoney
	lootcount = 5
	fan_out_items = TRUE
	loot = list(
	/obj/item/stack/spacecash/c1 = 100,
	/obj/item/stack/spacecash/c10 = 80,
	/obj/item/stack/spacecash/c20 = 60,
	/obj/item/stack/spacecash/c50 = 40,
	/obj/item/stack/spacecash/c100 = 30,
	/obj/item/stack/spacecash/c200 = 20,
	/obj/item/stack/spacecash/c500 = 10,
	/obj/item/stack/spacecash/c1000 = 5,
	/obj/item/stack/spacecash/c10000 = 1,
	)

/// Couple of random bits of technology-adjacent stuff including anomaly cores and BEPIS techs.
/obj/effect/spawner/lootdrop/space/fancytech
	lootcount = 2
	loot = list(
	/obj/item/raw_anomaly_core/random = 1,
	/obj/item/disk/tech_disk/spaceloot = 1,
	/obj/item/camera_bug = 1,
	)

/// A bunch of rarer seeds. /obj/item/seeds/random is not a random seed, but an exotic seed.
/obj/effect/spawner/lootdrop/space/rareseed
	lootcount = 5
	loot = list(
	/obj/item/seeds/random = 30,
	/obj/item/seeds/liberty = 5,
	/obj/item/seeds/replicapod = 5,
	/obj/item/seeds/reishi = 5,
	/obj/item/seeds/nettle/death = 1,
	/obj/item/seeds/plump/walkingmushroom = 1,
	/obj/item/seeds/cannabis/rainbow = 1,
	/obj/item/seeds/cannabis/death = 1,
	/obj/item/seeds/cannabis/white = 1,
	/obj/item/seeds/cannabis/ultimate = 1,
	/obj/item/seeds/kudzu = 1,
	/obj/item/seeds/angel = 1,
	/obj/item/seeds/glowshroom/glowcap = 1,
	/obj/item/seeds/glowshroom/shadowshroom = 1,
	)

/// A single roundstart species language book.
/obj/effect/spawner/lootdrop/space/languagebook
	lootcount = 1
	loot = list(
	/obj/item/language_manual/roundstart_species = 100,
	/obj/item/language_manual/roundstart_species/five = 3,
	/obj/item/language_manual/roundstart_species/unlimited = 1,
	)

/// Random selecton of a few rarer materials.
/obj/effect/spawner/lootdrop/space/material
	lootcount = 3
	loot = list(
	/obj/item/stack/sheet/runed_metal/ten = 20,
	/obj/item/stack/sheet/mineral/diamond{amount = 15} = 15,
	/obj/item/stack/sheet/mineral/uranium{amount = 15} = 15,
	/obj/item/stack/sheet/mineral/plasma{amount = 15} = 15,
	/obj/item/stack/sheet/mineral/gold{amount = 15} = 15,
	/obj/item/stack/sheet/runed_metal/fifty = 5,
	/obj/item/stack/sheet/plastic/fifty = 5,
	)

/// Some sort of random and rare tool. Only a single drop.
/obj/effect/spawner/lootdrop/space/fancytool
	lootcount = 1
	loot = list(
	/obj/item/wrench/abductor = 1,
	/obj/item/wirecutters/abductor = 1,
	/obj/item/screwdriver/abductor = 1,
	/obj/item/crowbar/abductor = 1,
	/obj/item/weldingtool/abductor = 1,
	/obj/item/multitool/abductor = 1,
	/obj/item/scalpel/alien = 1,
	/obj/item/hemostat/alien = 1,
	/obj/item/retractor/alien = 1,
	/obj/item/circular_saw/alien = 1,
	/obj/item/surgicaldrill/alien = 1,
	/obj/item/cautery/alien = 1,
	/obj/item/wrench/caravan = 1,
	/obj/item/wirecutters/caravan = 1,
	/obj/item/screwdriver/caravan = 1,
	/obj/item/crowbar/red/caravan = 1,
	)

/// Mail loot spawner. Some sort of random and rare building tool. No alien tech here.
/obj/effect/spawner/lootdrop/space/fancytool/engineonly
	loot = list(
	/obj/item/wrench/caravan = 1,
	/obj/item/wirecutters/caravan = 1,
	/obj/item/screwdriver/caravan = 1,
	/obj/item/crowbar/red/caravan = 1,
	)

/// Mail loot spawner. Drop pool of advanced medical tools typically from research. Not endgame content.
/obj/effect/spawner/lootdrop/space/fancytool/advmedicalonly
	loot = list(
	/obj/item/scalpel/advanced = 1,
	/obj/item/retractor/advanced = 1,
	/obj/item/cautery/advanced = 1,
	)

/// Mail loot spawner. Some sort of random and rare surgical tool. Alien tech found here.
/obj/effect/spawner/lootdrop/space/fancytool/raremedicalonly
	loot = list(
	/obj/item/scalpel/alien = 1,
	/obj/item/hemostat/alien = 1,
	/obj/item/retractor/alien = 1,
	/obj/item/circular_saw/alien = 1,
	/obj/item/surgicaldrill/alien = 1,
	/obj/item/cautery/alien = 1,
	)

/// A selection of cosmetic syndicate items. Just a couple. No hardsuits or weapons.
/obj/effect/spawner/lootdrop/space/syndiecosmetic
	lootcount = 2
	loot = list(
	/obj/item/clothing/under/syndicate = 10,
	/obj/item/clothing/under/syndicate/skirt = 10,
	/obj/item/clothing/under/syndicate/bloodred = 10,
	/obj/item/clothing/under/syndicate/tacticool = 10,
	/obj/item/clothing/under/syndicate/tacticool/skirt = 10,
	/obj/item/clothing/under/syndicate/sniper = 10,
	/obj/item/clothing/under/syndicate/camo = 10,
	/obj/item/clothing/under/syndicate/soviet = 10,
	/obj/item/clothing/under/syndicate/combat = 10,
	/obj/item/clothing/under/syndicate/rus_army = 10,
	/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 7,
	/obj/item/clothing/under/syndicate/bloodred/sleepytime = 5,
	/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
	/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
	/obj/item/storage/fancy/cigarettes/cigpack_candy = 2,
	/obj/item/storage/fancy/cigarettes/cigpack_robust = 2,
	/obj/item/storage/fancy/cigarettes/cigpack_midori = 1,
	)

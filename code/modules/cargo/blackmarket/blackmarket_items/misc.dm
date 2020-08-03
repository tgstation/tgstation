/datum/blackmarket_item/misc
	category = "Miscellaneous"

/datum/blackmarket_item/misc/cap_gun
	name = "Cap Gun"
	desc = "Prank your friends with this harmless gun! Harmlessness guranteed."
	item = /obj/item/toy/gun

	price_min = 50
	price_max = 200
	stock_max = 6
	availability_prob = 80

/datum/blackmarket_item/misc/shoulder_holster
	name = "Shoulder holster"
	desc = "Yeehaw, hardboiled friends! This holster is the first step in your dream of becoming a detective and being allowed to shoot real guns!"
	item = /obj/item/storage/belt/holster

	price_min = 400
	price_max = 800
	stock_max = 8
	availability_prob = 60

/datum/blackmarket_item/misc/holywater
	name = "Flask of holy water"
	desc = "Father Lootius' own brand of ready-made holy water."
	item = /obj/item/reagent_containers/food/drinks/bottle/holywater

	price_min = 400
	price_max = 600
	stock_max = 3
	availability_prob = 40

/datum/blackmarket_item/misc/holywater/spawn_item(loc)
	if (prob(6.66))
		return new /obj/item/reagent_containers/glass/beaker/unholywater(loc)
	return ..()

/datum/blackmarket_item/misc/strange_seed
	name = "Strange Seeds"
	desc = "An Exotic Variety of seed that can contain anything from glow to acid."
	item = /obj/item/seeds/random

	price_min = 320
	price_max = 360
	stock_min = 2
	stock_max = 5
	availability_prob = 50

/datum/blackmarket_item/misc/smugglers_satchel
	name = "Smuggler's Satchel"
	desc = "This easily hidden satchel can become a versatile tool to anybody with the desire to keep certain items out of sight and out of mind."
	item = /obj/item/storage/backpack/satchel/flat/empty

	price_min = 750
	price_max = 1000
	stock_max = 2
	availability_prob = 40

/datum/blackmarket_item/misc/telecrystal
	name = "Telecrystal"
	desc = "Turns out Syndicate agents find these things valuable for some reason. Unlike the Syndicate, we don't know that reason, so buy 'em from us instead!"
	item = /obj/item/stack/telecrystal

	price_min = 2000
	price_max = 3500
	stock_min = 2
	stock_max = 5
	availability_prob = 75

/datum/blackmarket_item/misc/telecrystal/spawn_item(loc)
	if (prob(1))
		return new /obj/item/stack/telecrystal/twenty(loc)
	return ..()

/datum/blackmarket_item/misc/random
	name = "Random Item"
	desc = "Picking this will purchase a random item from our fourty seven packed warehouses! Most of these items aren't even on our main stock list, so roll the dice if you dare!"
	item = /obj/effect/gibspawner/generic
	price_min = 3000
	price_max = 6000
	availability_prob = 100
	stock_min = 3
	stock_max = 7

/datum/blackmarket_item/misc/random/spawn_item(loc)
	var/list/gamers = list(/obj/item/storage/box/syndie_kit/chameleon,
	/obj/item/storage/box/syndie_kit/sleepytime,
	/obj/item/storage/box/syndie_kit/imp_stealth,
	/obj/item/storage/box/syndie_kit/imp_microbomb,
	/obj/item/gun/medbeam,
	/obj/item/flashlight/lantern/syndicate,
	/obj/item/grenade/hypnotic,
	/obj/item/grenade/chem_grenade/glitter/blue,
	/obj/item/pen/edagger,
	/obj/item/pen/sleepy,
	/mob/living/simple_animal/pet/fox/Rose,
	/obj/item/storage/box/syndicate/bundle_a,
	/obj/item/storage/box/syndicate/bundle_b,
	/obj/item/storage/box/syndie_kit/plushies,
	/obj/item/clothing/gloves/rapid,
	/obj/item/gun/ballistic/automatic/toy/pistol/riot,
	/obj/item/clothing/gloves/krav_maga/combatglovesplus,
	/obj/item/book/granter/martial/cqc,
	/obj/item/toy/plush/carpplushie/dehy_carp,
	/obj/item/book/granter/martial/carp,
	/obj/item/book/granter/spell/knock,
	/obj/item/book/granter/spell/barnyard,
	/obj/item/extendohand,
	/obj/item/gun/energy/kinetic_accelerator/crossbow,
	/obj/item/storage/box/syndie_kit/origami_bundle,
	/obj/item/ammo_box/foambox/riot,
	/obj/item/grenade/c4,
	/obj/item/pizzabox/bomb,
	/obj/item/grenade/chem_grenade/teargas/moustache,
	/obj/item/antag_spawner/nuke_ops/clown,
	/obj/mecha/combat/gygax/dark/loaded,
	/obj/item/card/id/syndicate,
	/obj/item/multitool/ai_detect,
	/obj/item/codespeak_manual/unlimited,
	/obj/item/flashlight/emp,
	/obj/item/flashlight,
	/obj/item/reagent_containers/syringe/mulligan,
	/obj/item/storage/box/syndie_kit/cutouts,
	/obj/item/encryptionkey/binary,
	/obj/item/storage/briefcase/launchpad,
	/obj/item/camera_bug,
	/obj/item/card/emag/doorjack,
	/obj/item/disk/nuclear/fake,
	/obj/item/cartridge/virus/frame,
	/obj/item/reagent_containers/hypospray/medipen/stimulants,
	/obj/item/soap/syndie,
	/obj/item/soap,
	/obj/item/encryptionkey/syndicate,
	/obj/item/clothing/glasses/thermal/syndi,
	/obj/item/storage/box/hug/reverse_revolver,
	/obj/item/storage/box/syndie_kit/chameleon/broken,
	/obj/item/storage/box/syndie_kit/centcom_costume,
	/obj/item/storage/backpack/duffelbag/clown/syndie,
	/obj/item/toy/balloon/syndicate,
	/obj/item/storage/secure/briefcase/syndie,
	/obj/item/toy/cards/deck/syndicate,
	/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
	/obj/item/dnainjector/clumsymut,
	/obj/item/ammo_box/magazine/m9mm,
	/obj/item/ammo_box/magazine/m9mm/hp,
	/obj/item/ammo_box/magazine/m12g,
	/obj/item/ammo_box/a357,
	/obj/item/ammo_casing/a40mm,
	/obj/item/storage/backpack/duffelbag/syndie/ammo/smg,
	/obj/item/ammo_box/magazine/smgm45/incen,
	/mob/living/simple_animal/hostile/gorilla,
	/mob/living/simple_animal/hostile/asteroid/goliath,
	/obj/item/onetankbomb,
	/obj/item/clothing/under/costume/yakuza,
	/obj/item/clothing/under/rank/prisoner,
	/obj/item/kitchen/knife/shiv,
	/obj/item/storage/pill_bottle/dice,
	/obj/item/a_gift,
	/obj/item/latexballon,
	/obj/item/book/manual/nuclear,
	/obj/item/toy/crayon/spraycan/lubecan,
	/obj/item/sharpener,
	/obj/item/trash/chips,
	/obj/item/trash/boritos,
	/obj/item/trash/candy,
	/obj/item/toy/waterballoon,
	/obj/item/toy/balloon,
	/obj/item/toy/balloon/corgi,
	/obj/item/toy/spinningtoy,
	/obj/item/toy/gun,
	/obj/item/toy/ammo/gun,
	/obj/item/toy/sword,
	/obj/item/toy/foamblade,
	/obj/item/dualsaber/toy,
	/obj/item/toy/snappop/phoenix,
	/obj/machinery/computer/arcade/amputation,
	/mob/living/simple_animal/bot/vibebot,
	/mob/living/simple_animal/bot/honkbot,
	/obj/item/card/id/syndicate,
	/mob/living/simple_animal/cow/milker,
	)
	var/marketrandom = pick(gamers)
	return new marketrandom(loc)
	return ..()


/datum/blackmarket_item/misc/cat
	name = "Cat"
	desc = "Who's cat is this?"
	item = /mob/living/simple_animal/pet/cat

	price_min = 10
	price_max = 50
	stock_max = 1
	availability_prob = 50

/datum/blackmarket_item/misc/cat/spawn_item(loc)
	if (prob(1))
		return new /mob/living/simple_animal/pet/cat/bolty(loc)
	return ..()


/datum/blackmarket_item/misc/gorilla
	name = "Primate"
	desc = "Perfect for any xenobiologist or geneticist who needs to get their science on! Not Quality Tested."
	item = /mob/living/simple_animal/hostile/gorilla


	price_min = 1000
	price_max = 1500
	stock_min = 1
	stock_max = 3
	availability_prob = 100

/datum/blackmarket_item/misc/gorilla/spawn_item(loc)
	if (prob(95))
		return new /mob/living/carbon/monkey(loc)
	return ..()


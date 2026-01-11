/**
 * Abandoned Crate Loot Spawner
 *
 * Base spawner for generating loot contents in abandoned crates
 */
/obj/effect/spawner/abandoned_crate
	name = "abandoned crate loot spawner"
	desc = "i feel lucky"
	/// Associative list with actual loot: item_type = quantity
	var/list/loot

/obj/effect/spawner/abandoned_crate/Initialize(mapload)
	. = ..()

	if(LAZYLEN(loot))
		for(var/atom in loot)
			for(var/i in 1 to loot[atom])
				new atom(loc)

/obj/effect/spawner/abandoned_crate/booze
	loot = list(
		/obj/item/reagent_containers/cup/glass/bottle/rum = 1,
		/obj/item/reagent_containers/cup/glass/bottle/whiskey = 2,
		/obj/item/lighter = 1,
		/obj/item/reagent_containers/cup/glass/bottle/absinthe/premium = 1,
		/obj/item/cigarette/rollie = 3
		)

/obj/effect/spawner/abandoned_crate/diamonds
	loot = list(
		/obj/item/stack/ore/diamond = 10
		)

/obj/effect/spawner/abandoned_crate/posters
	loot = list(
		/obj/item/poster/random_contraband = 5
		)

/obj/effect/spawner/abandoned_crate/boda
	loot = list(
		/obj/item/vending_refill/sovietsoda = 1,
		/obj/item/circuitboard/machine/vendor = 1
		)

/obj/effect/spawner/abandoned_crate/boda/Initialize(mapload)
	. = ..()

	for(var/obj/item/circuitboard/machine/vendor/board in loc)
		board.set_type(/obj/machinery/vending/sovietsoda)

/obj/effect/spawner/abandoned_crate/snappop
	loot = list(
		/obj/item/toy/snappop/phoenix = 5
		)

/obj/effect/spawner/abandoned_crate/mecha
	loot = list()

/obj/effect/spawner/abandoned_crate/mecha/Initialize(mapload)
	var/mecha = pick(subtypesof(/obj/item/toy/mecha))
	loot[mecha] = 1

	return ..()

/obj/effect/spawner/abandoned_crate/space_suit
	loot = list(
		/obj/item/borg/upgrade/modkit/aoe/mobs = 1,
		/obj/item/clothing/suit/space = 1,
		/obj/item/clothing/head/helmet/space = 1
		)

/obj/effect/spawner/abandoned_crate/kitty
	loot = list(
		/obj/item/clothing/head/costume/kitty = 5,
		/obj/item/clothing/neck/petcollar = 5
		)

/obj/effect/spawner/abandoned_crate/fursuit
	loot = list(
		/obj/item/clothing/suit/costume/wellworn_shirt/graphic/ian = 1,
		/obj/item/clothing/suit/hooded/ian_costume = 1
		)

/obj/effect/spawner/abandoned_crate/gibtonite
	loot = list(
		/obj/item/gibtonite = 1,
		)

/obj/effect/spawner/abandoned_crate/gibtonite/Initialize(mapload)
	. = ..()

	for(var/obj/item/gibtonite/free_bomb in loc)
		free_bomb.quality = rand(GIBTONITE_QUALITY_LOW, GIBTONITE_QUALITY_HIGH)
		free_bomb.GibtoniteReaction(null, "A secure loot closet has spawned a live")

/obj/effect/spawner/abandoned_crate/bluespace_crystal
	loot = list(
		/obj/item/stack/ore/bluespace_crystal = 5
		)

/obj/effect/spawner/abandoned_crate/bananium
	loot = list(
		/obj/item/stack/sheet/mineral/bananium = 10
		)

/obj/effect/spawner/abandoned_crate/weed
	loot = list()

/obj/effect/spawner/abandoned_crate/weed/Initialize(mapload)
	var/seed_type = pick(typesof(/obj/item/seeds/cannabis))
	var/cannabis_type= pick(typesof(/obj/item/food/grown/cannabis))
	var/weed_amount = rand(2, 4)

	for(var/i in 1 to weed_amount)
		loot[seed_type] = (loot[seed_type] || 0) + 1
		loot[cannabis_type] = (loot[cannabis_type] || 0) + 1

	return ..()

/obj/effect/spawner/abandoned_crate/bloodroaches
	loot = list(
		/mob/living/basic/cockroach/bloodroach = 30
		)

/obj/effect/spawner/abandoned_crate/mimic
	loot = list(
		/mob/living/basic/mimic/crate = 1
		)

/obj/effect/spawner/abandoned_crate/mimic/Initialize(mapload)
	. = ..()

	var/obj/structure/closet/crate/secure/loot/parent_crate = loc
	if(istype(parent_crate))
		parent_crate.qdel_on_open = TRUE

/obj/effect/spawner/abandoned_crate/bwoink
	loot = list(
		/obj/item/banhammer = 1,
		/obj/effect/mine/sound/bwoink = 3
		)

/obj/effect/spawner/abandoned_crate/bwoink/Initialize(mapload)
	. = ..()

	for(var/obj/effect/mine/sound/bwoink/mine in loc)
		mine.set_anchored(FALSE)
		mine.move_resist = MOVE_RESIST_DEFAULT

/obj/effect/spawner/abandoned_crate/pay_day
	loot = list(
		/obj/item/clothing/mask/balaclava = 4,
		/obj/item/gun/ballistic/shotgun/toy = 1,
		/obj/item/gun/ballistic/automatic/pistol/toy = 1,
		/obj/item/gun/ballistic/automatic/toy = 1,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted = 1,
		/obj/item/ammo_box/foambox = 1
		)

/obj/effect/spawner/abandoned_crate/bees
	loot = list(
		/mob/living/basic/bee/toxin = 3
		)

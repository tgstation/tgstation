/**
 * Datum for spawning multiple different atoms or applying some special spawning behavior
 */
/datum/loot
	/// Actual loot. loot[typepath] = amount
	var/list/loot = list()

/datum/loot/New(container)
	. = ..()
	if(isnull(container))
		CRASH("[/datum/loot] created with no container!")
	spawn_loot(container)
	qdel(src)

/datum/loot/proc/spawn_loot(container)
	for(var/atom in loot)
		for(var/i in 1 to loot[atom])
			new atom(container)

/datum/loot/booze_n_cigs
	loot = list(
		/obj/item/reagent_containers/cup/glass/bottle/rum = 1,
		/obj/item/reagent_containers/cup/glass/bottle/absinthe/premium = 1,
		/obj/item/reagent_containers/cup/glass/bottle/whiskey = 2,
		/obj/item/lighter = 1,
		/obj/item/cigarette/rollie = 3
	)

/datum/loot/posters
	loot = list(
		/obj/item/poster/random_contraband = 5
	)

/datum/loot/soda/spawn_loot(container)
	new /obj/item/vending_refill/sovietsoda(container)
	var/obj/item/circuitboard/machine/vendor/board = new (container)
	board.set_type(/obj/machinery/vending/sovietsoda)

/datum/loot/snappop
	loot = list(
		/obj/item/toy/snappop/phoenix = 5
	)

/datum/loot/mecha_toy/spawn_loot(container)
	var/newitem = pick(subtypesof(/obj/item/toy/mecha))
	new newitem(container)

/datum/loot/space_suit
	loot = list(
		/obj/item/clothing/suit/space = 1,
		/obj/item/clothing/head/helmet/space = 1,
		/obj/item/borg/upgrade/modkit/aoe/mobs = 1,
	)

/datum/loot/cats
	loot = list(
		/obj/item/clothing/head/costume/kitty = 5,
		/obj/item/clothing/neck/petcollar = 5
	)

/datum/loot/ian
	loot = list(
		/obj/item/clothing/suit/costume/wellworn_shirt/graphic/ian = 1,
		/obj/item/clothing/suit/hooded/ian_costume = 1
	)

/datum/loot/gibtonite/spawn_loot(container)
	var/obj/item/gibtonite/free_bomb = new /obj/item/gibtonite(container)
	free_bomb.quality = rand(1, 3)
	free_bomb.GibtoniteReaction(null, "A secure loot closet has spawned a live")

/datum/loot/weed/spawn_loot(container)
	var/list/cannabis_seeds = typesof(/obj/item/seeds/cannabis)
	var/list/cannabis_plants = typesof(/obj/item/food/grown/cannabis)
	for(var/i in 1 to rand(2, 4))
		var/seed_type = pick(cannabis_seeds)
		new seed_type(container)
	for(var/i in 1 to rand(2, 4))
		var/cannabis_type = pick(cannabis_plants)
		new cannabis_type(container)

/datum/loot/cockroaches
	loot = list(
		/mob/living/basic/cockroach = 30
	)

/datum/loot/mimic/spawn_loot(container)
	new /mob/living/simple_animal/hostile/mimic/crate(container)
	qdel(container)

/datum/loot/banhammer/spawn_loot(container)
	new /obj/item/banhammer(container)
	for(var/i in 1 to 3)
		var/obj/effect/mine/sound/bwoink/mine = new (container)
		mine.set_anchored(FALSE)
		mine.move_resist = MOVE_RESIST_DEFAULT

/datum/loot/heist
	loot = list(
		/obj/item/clothing/mask/balaclava = 4,
		/obj/item/gun/ballistic/shotgun/toy = 1,
		/obj/item/gun/ballistic/automatic/pistol/toy = 1,
		/obj/item/gun/ballistic/automatic/toy/unrestricted = 1,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted = 1,
		/obj/item/ammo_box/foambox = 1
	)

/datum/loot/bees
	loot = list(
		/mob/living/basic/bee/toxin = 3
	)

/datum/loot/diamond/spawn_loot(container)
	new /obj/item/stack/ore/diamond(container, 10)

/datum/loot/bscrystal/spawn_loot(container)
	new /obj/item/stack/ore/bluespace_crystal(container, 5)

/datum/loot/bananium/spawn_loot(container)
	new /obj/item/stack/sheet/mineral/bananium(container, 10)

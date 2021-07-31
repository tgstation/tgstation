/obj/effect/spawner/random/trash
	name = "trash spawner"
	desc = "Ewwwwwww gross."

/obj/effect/spawner/random/trash/garbage
	name = "garbage spawner"
	loot = list(
		/obj/effect/spawner/random/trash/food_packaging = 56,
		/obj/item/trash/can = 8,
		/obj/item/shard = 8,
		/obj/effect/spawner/random/trash/botanical_waste = 8,
		/obj/effect/spawner/random/trash/cigbutt = 8,
		/obj/item/reagent_containers/syringe = 5,
		/obj/item/light/tube/broken = 3,
		/obj/item/food/deadmouse = 2,
		/obj/item/light/tube/broken = 1,
		/obj/item/trash/candle = 1,
	)

/obj/effect/spawner/random/trash/cigbutt
	name = "cigarette butt spawner"
	loot = list(
		/obj/item/cigbutt = 65,
		/obj/item/cigbutt/roach = 20,
		/obj/item/cigbutt/cigarbutt = 15,
	)

/obj/effect/spawner/random/trash/food_packaging
	name = "empty food packaging spawner"
	loot = list(
		/obj/item/trash/raisins = 20,
		/obj/item/trash/cheesie = 10,
		/obj/item/trash/candy = 10,
		/obj/item/trash/chips = 10,
		/obj/item/trash/sosjerky = 10,
		/obj/item/trash/pistachios = 10,
		/obj/item/trash/boritos = 8,
		/obj/item/trash/can/food/beans = 6,
		/obj/item/trash/popcorn = 5,
		/obj/item/trash/energybar = 5,
		/obj/item/trash/can/food/peaches/maint = 4,
		/obj/item/trash/semki = 2,
	)

/obj/effect/spawner/random/trash/botanical_waste
	name = "botanical waste spawner"
	loot = list(
		/obj/item/grown/bananapeel = 6,
		/obj/item/grown/corncob = 3,
		/obj/item/food/grown/bungopit = 1,
	)

/obj/effect/spawner/random/trash/grille_or_waste
	name = "grille or waste spawner"
	loot = list(
		/obj/structure/grille = 5,
		/obj/item/cigbutt = 1,
		/obj/item/trash/cheesie = 1,
		/obj/item/trash/candy = 1,
		/obj/item/trash/chips = 1,
		/obj/item/food/deadmouse = 1,
		/obj/item/trash/pistachios = 1,
		/obj/item/trash/popcorn = 1,
		/obj/item/trash/raisins = 1,
		/obj/item/trash/sosjerky = 1,
		/obj/item/trash/syndi_cakes = 1,
	)

/obj/effect/spawner/random/trash/hobo_squat
	name = "hobo squat spawner"
	spawn_all_loot = TRUE
	loot = list(
		/obj/structure/bed/maint,
		/obj/effect/spawner/random/trash/grime,
		/obj/effect/spawner/random/entertainment/drugs,
	)

/obj/effect/spawner/random/trash/moisture_trap
	name = "moisture trap spawner"
	spawn_all_loot = TRUE
	loot = list(
		/obj/effect/spawner/random/trash/moisture,
		/obj/structure/moisture_trap,
	)

/obj/effect/spawner/random/trash/mess
	name = "gross decal spawner"
	icon_state = "random_trash"
	loot = list(
		/obj/effect/decal/cleanable/dirt = 6,
		/obj/effect/decal/cleanable/garbage = 3,
		/obj/effect/decal/cleanable/vomit/old = 3,
		/obj/effect/decal/cleanable/blood/gibs/old = 3,
		/obj/effect/decal/cleanable/insectguts = 1,
		/obj/effect/decal/cleanable/greenglow/ecto = 1,
		/obj/effect/decal/cleanable/wrapping = 1,
		/obj/effect/decal/cleanable/plastic = 1,
		/obj/effect/decal/cleanable/glass = 1,
		/obj/effect/decal/cleanable/ants = 1,
	)

/obj/effect/spawner/random/trash/grime
	name = "trash and grime spawner"
	lootcount = 5
	spawn_scatter_radius = 2
	loot = list( // This spawner will scatter garbage around a dirty site.
		/obj/effect/spawner/random/trash/garbage = 6,
		/mob/living/simple_animal/hostile/cockroach = 5,
		/obj/effect/decal/cleanable/garbage = 4,
		/obj/effect/decal/cleanable/vomit/old = 3,
		/obj/effect/spawner/random/trash/cigbutt = 2,
	)

/obj/effect/spawner/random/trash/moisture
	name = "water hazard spawner"
	lootcount = 2
	spawn_scatter_radius = 1
	loot = list( // This spawner will scatter water related items around a moist site.
		/obj/item/clothing/head/cone = 7,
		/obj/item/clothing/suit/caution = 3,
		/mob/living/simple_animal/hostile/retaliate/frog = 2,
		/obj/item/reagent_containers/glass/rag = 2,
		/obj/item/reagent_containers/glass/bucket = 2,
		/obj/effect/decal/cleanable/blood/old = 2,
		/obj/structure/mopbucket = 2,
	)

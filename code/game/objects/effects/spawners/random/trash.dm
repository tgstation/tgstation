/obj/effect/spawner/random/trash
	name = "trash spawner"
	desc = "Ewwwwwww gross."

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
		/obj/effect/spawner/scatter/grime,
		obj/effect/spawner/random/entertainment/drugs,
	)

/obj/effect/spawner/random/trash/moisture_trap
	name = "moisture trap spawner"
	spawn_all_loot = TRUE
	loot = list(
		/obj/effect/spawner/scatter/moisture,
		/obj/structure/moisture_trap,
	)

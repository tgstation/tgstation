/obj/effect/spawner/random/trash
	name = "trash spawner"
	desc = "Ewwwwwww gross."

/obj/effect/spawner/random/trash/hobo_squat
	name = "hobo squat spawner"
	spawn_all_items = TRUE
	loot = list(
		/obj/structure/bed/maint,
		/obj/effect/spawner/scatter/grime,
		/obj/effect/spawner/random/entertainment/drugs,
	)

/obj/effect/spawner/random/trash/moisture_trap
	name = "moisture trap spawner"
	spawn_all_items = TRUE
	loot = list(
		/obj/effect/spawner/scatter/moisture,
		/obj/structure/moisture_trap,
	)

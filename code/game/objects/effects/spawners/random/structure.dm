/obj/effect/spawner/random/structure
	name = "structure spawner"
	desc = "Now you see me, now you don't..."

/obj/effect/spawner/random/structure/crate
	name = "boring crate spawner"
	loot_table = list(
	/obj/structure/closet/crate/maint = 35,
	/obj/structure/closet/crate/trashcart/filled = 5,
	/obj/effect/spawner/random/trash/mess = 5,
	/obj/effect/spawner/random/trash/moisture_trap  = 3,
	/obj/effect/spawner/random/trash/hobo_squat = 3,
	/obj/structure/closet/mini_fridge = 3,
	/obj/structure/closet/crate/decorations = 1
	)

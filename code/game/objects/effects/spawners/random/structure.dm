obj/effect/spawner/random/structure
	name = "structure spawner"
	desc = "Now you see me, now you don't..."

/obj/effect/spawner/random/structure/crate
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "loot_site"
	loot = list(
		/obj/structure/closet/crate/maint = 75,
		/obj/structure/closet/crate/trashcart/filled = 7,
		/obj/effect/spawner/random/trash/moisture_trap = 5,
		/obj/effect/spawner/random/trash/hobo_squat = 3,
		/obj/structure/closet/mini_fridge = 3,
		/obj/effect/spawner/random/trash/mess = 3,
		/obj/structure/closet/crate/decorations = 1,
	)

/obj/effect/spawner/random/structure/crate_abandoned
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "loot_site"
	spawn_loot_chance = 20
	loot = list(/obj/structure/closet/crate/secure/loot)

obj/effect/spawner/random/structure
	name = "structure spawner"
	desc = "Now you see me, now you don't..."

/obj/effect/spawner/random/structure/crate
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "loot_site"
	loot = list( ///This is the loot table for the spawner. Try to make sure the weights add up to 1000, so it is easy to understand.
		/obj/structure/closet/crate/maint = 765,
		/obj/structure/closet/crate/trashcart/filled = 75,
		/obj/effect/spawner/random/trash/moisture_trap = 50,
		/obj/effect/spawner/random/trash/hobo_squat = 30,
		/obj/structure/closet/mini_fridge = 35,
		/obj/effect/spawner/lootdrop/gross_decal_spawner = 30,
		/obj/structure/closet/crate/decorations = 15,
	)

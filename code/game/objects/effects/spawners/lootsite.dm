///this spawner usually spawns a boring crate, but has a chance to replace the crate with "loot crate" with a different loot table or a decorative site.
/obj/effect/loot_site_spawner
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "loot_site"
	///This is the loot table for the spawner. Try to make sure the weights add up to 1000, so it is easy to understand.
	var/list/loot_table = list(/obj/structure/closet/crate/maint = 765,
							/obj/structure/closet/crate/trashcart/filled = 75,
							/obj/effect/spawner/bundle/moisture_trap = 50,
							/obj/effect/spawner/bundle/hobo_squat = 30,
							/obj/structure/closet/mini_fridge = 35,
							/obj/effect/spawner/lootdrop/gross_decal_spawner = 30,
							/obj/structure/closet/crate/decorations = 15)


/obj/effect/loot_site_spawner/Initialize()
	..()
	if(!length(loot_table))
		return INITIALIZE_HINT_QDEL

	var/spawned_object = pickweight(loot_table)
	new spawned_object(get_turf(src))

	return INITIALIZE_HINT_QDEL

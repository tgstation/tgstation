/obj/effect/spawner/random/peel_or_nana
	name = "peel or banana spawner"
	icon_state = "peel"
	spawn_random_offset =  TRUE
	loot = list(
		/obj/item/grown/bananapeel = 3,
		/obj/item/food/grown/banana = 2,
	)

/obj/effect/spawner/random/bananas_or_nothing
	name = "bananas or nothing spawner"
	icon_state = "bunch"
	spawn_random_offset =  TRUE
	spawn_loot_chance = 66
	loot = list(
		/obj/item/food/grown/banana/bunch = 6,
		/obj/item/food/grown/banana = 4,
	)

/obj/effect/spawner/clownana
	name = "clownana loot spawner"
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "bunch"
	var/list/spawns = list(
		/obj/effect/spawner/random/bananas_or_nothing,
		/obj/effect/spawner/random/peel_or_nana,
	)

/obj/effect/spawner/clownana/Initialize(mapload)
	. = ..()
	if(spawns?.len)
		for(var/path in spawns)
			new path(loc)

/obj/effect/spawner/random/chance_for_freedom
	name = "freedom heart or nothing spawner"
	icon_state = "cap"
	spawn_loot_chance = 40
	loot = list(
		/obj/item/organ/heart/freedom = 1,
	)

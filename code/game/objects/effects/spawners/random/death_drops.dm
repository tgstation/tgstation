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
	loot = list(
		/obj/item/food/grown/banana/bunch = 4,
		/obj/item/food/grown/banana = 3,
		null = 3,

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
	loot = list(
		/obj/item/organ/heart/freedom = 4,
		null = 6,
	)

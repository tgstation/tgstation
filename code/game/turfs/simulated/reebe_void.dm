/turf/open/indestructible/reebe_void
	name = "void"
	icon_state = "reebemap"
	layer = SPACE_LAYER
	baseturfs = /turf/open/indestructible/reebe_void
	planetary_atmos = TRUE
	bullet_bounce_sound = null //forever falling
	tiled_dirt = FALSE

/turf/open/indestructible/reebe_void/Initialize(mapload)
	. = ..()
	icon_state = "reebegame"

/turf/open/indestructible/reebe_void/spawning
	icon_state = "reebespawn"

/turf/open/indestructible/reebe_void/spawning/Initialize(mapload)
	. = ..()
	if(mapload)
		for(var/i in 1 to 3)
			if(prob(1))
				new /obj/item/clockwork/alloy_shards/large(src)
			if(prob(2))
				new /obj/item/clockwork/alloy_shards/medium(src)
			if(prob(3))
				new /obj/item/clockwork/alloy_shards/small(src)

/turf/open/indestructible/reebe_void/spawning/lattices
	icon_state = "reebelattice"

/turf/open/indestructible/reebe_void/spawning/lattices/Initialize(mapload)
	. = ..()
	if(mapload)
		if(prob(2.5))
			new /obj/structure/lattice/catwalk/clockwork(src)
		else if(prob(5))
			new /obj/structure/lattice/clockwork(src)

/turf/open/indestructible/reebe_void/Enter(atom/movable/AM, atom/old_loc)
	if(!..())
		return FALSE
	else
		if(istype(AM, /obj/structure/window))
			return FALSE
		if(istype(AM, /obj/item/projectile))
			return TRUE
		if((locate(/obj/structure/lattice) in src))
			return TRUE
		return FALSE

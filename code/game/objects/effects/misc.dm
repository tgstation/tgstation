//The effect when you wrap a dead body in gift wrap
/obj/effect/spresent
	name = "strange present"
	desc = "It's a ... present?"
	icon = 'icons/obj/storage/wrapping.dmi'
	icon_state = "strangepresent"
	density = TRUE
	anchored = FALSE

/obj/effect/beam
	name = "beam"
	var/def_zone
	pass_flags = PASSTABLE

/obj/effect/beam/singularity_act()
	return

/obj/effect/beam/singularity_pull(atom/singularity, current_size)
	return

/obj/effect/spawner
	name = "object spawner"

// Brief explanation:
// Rather then setting up and then deleting spawners, we block all atomlike setup
// and do the absolute bare minimum
// This is with the intent of optimizing mapload
/obj/effect/spawner/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/Destroy(force)
	SHOULD_CALL_PARENT(FALSE)
	moveToNullspace()
	return QDEL_HINT_QUEUE

/obj/effect/spawner/forceMove(atom/destination)
	if(destination && QDELETED(src)) // throw a warning if we try to forceMove a qdeleted spawner to somewhere other than nullspace
		stack_trace("Warning: something tried to forceMove() a qdeleted [src]([type]) to non-null destination [destination]([destination.type])!")
	return ..()

/// Override to define loot blacklist behavior
/obj/effect/spawner/proc/can_spawn(atom/loot)
	if(!ispath(loot))
		// Means its something evil like /obj/item/stack/sheet/mineral/diamond{amount = 15}
		// (modified instances?) which is not a path and cannot be checked as one
		return TRUE
	if(loot.abstract_type == loot)
		return FALSE
	if(loot.spawn_blacklisted)
		return FALSE
	return TRUE

/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list()

//Makes a tile fully lit no matter what
/obj/effect/fullbright
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	plane = LIGHTING_PLANE
	layer = LIGHTING_ABOVE_ALL
	blend_mode = BLEND_ADD
	luminosity = 1

/obj/effect/abstract/marker
	name = "marker"
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	icon_state = "wave3"
	layer = RIPPLE_LAYER
	plane = ABOVE_GAME_PLANE

/obj/effect/abstract/marker/Initialize(mapload)
	. = ..()
	GLOB.all_abstract_markers += src

/obj/effect/abstract/marker/Destroy()
	GLOB.all_abstract_markers -= src
	. = ..()

/obj/effect/abstract/marker/at
	name = "active turf marker"

/obj/effect/abstract/marker/intercom
	name = "intercom range marker"
	color = COLOR_YELLOW

/obj/effect/abstract/marker/powernet
	name = "powernet run marker"
	var/powernet_owner

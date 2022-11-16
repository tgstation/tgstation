/// Abstract effect, that when a mob touches it, it will forceMove them to the teleporter-exit point (that matches the ID set map-side).
/obj/effect/bump_teleporter
	name = "bump teleporter (forceMove)"
	desc = "Use me when you want to move every single mob without any exceptions."
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x2"
	invisibility = INVISIBILITY_ABSTRACT //nope, can't see this
	anchored = TRUE
	density = TRUE
	opacity = FALSE
	/// id of this bump_teleporter.
	var/id = null
	/// id of bump_teleporter which this moves you to.
	var/id_target = null
	/// List of all teleporters in the world.
	var/static/list/AllTeleporters

/obj/effect/bump_teleporter/Initialize(mapload)
	. = ..()
	LAZYADD(AllTeleporters, src)

/obj/effect/bump_teleporter/Destroy()
	LAZYREMOVE(AllTeleporters, src)
	return ..()

/obj/effect/bump_teleporter/singularity_act()
	return

/obj/effect/bump_teleporter/singularity_pull()
	return

/obj/effect/bump_teleporter/Bumped(atom/movable/concerned_party)
	if(!validate_setup(concerned_party))
		return

	for(var/obj/effect/bump_teleporter/teleporter in AllTeleporters)
		if(teleporter.id == src.id_target)
			concerned_party.forceMove(teleporter.loc)
			return

	stack_trace("Bump_teleporter [src] could not find a teleporter with id [src.id_target]!")

/// Check to see if our teleporter was set up correctly mapside. Return TRUE if everything is fine, FALSE if not.
/obj/effect/bump_teleporter/proc/validate_setup(atom/movable/checkable)
	var/message = ""

	if(!ismob(checkable))
		return FALSE

	if(!id_target)
		message = "Bump teleporter [src] at [AREACOORD(src)] has no id_target set."
		stack_trace(message)
		log_mapping(message)
		return FALSE

	return TRUE

/// Subtype that uses do_teleport instead, to leverage any NO_TELEPORT traits that you might need to add in a given map
/obj/effect/bump_teleporter/filtering
	name = "bump teleporter (do_teleport)"
	desc = "Use me for when you want to avoid moving mobs with certain traits, like NO_TELEPORT."
	icon_state = "x4"

/obj/effect/bump_teleporter/filtering/Bumped(atom/movable/concerned_party)
	if(!validate_setup(concerned_party))
		return

	for(var/obj/effect/bump_teleporter/teleporter in AllTeleporters)
		if(teleporter.id == src.id_target)
			do_teleport(concerned_party, get_turf(teleporter), channel = TELEPORT_CHANNEL_QUANTUM) //Teleport to location with correct id.
			return

	stack_trace("Bump_teleporter [src] could not find a teleporter with id [src.id_target]!")

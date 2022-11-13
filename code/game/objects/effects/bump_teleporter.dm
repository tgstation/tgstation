/obj/effect/bump_teleporter
	name = "bump-teleporter"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x2"
	var/id = null //id of this bump_teleporter.
	var/id_target = null //id of bump_teleporter which this moves you to.
	invisibility = INVISIBILITY_ABSTRACT //nope, can't see this
	anchored = TRUE
	density = TRUE
	opacity = FALSE

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
	if(!ismob(concerned_party))
		return
	if(!id_target)
		return

	for(var/obj/effect/bump_teleporter/teleporter in AllTeleporters)
		if(teleporter.id == src.id_target)
			concerned_party.do_teleport(teleporter.loc) //Teleport to location with correct id.

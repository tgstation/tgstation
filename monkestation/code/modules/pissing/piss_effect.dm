/obj/effect/decal/cleanable/piss_stain
	name = "piss puddle"
	desc = "Who would piss on the floor?"

	icon = 'monkestation/icons/effects/decals.dmi'
	icon_state = "piss_puddle"

/obj/effect/decal/cleanable/piss_stain/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(delete)), 10 MINUTES)

/obj/effect/decal/cleanable/piss_stain/proc/delete()
	qdel(src)

//Created from the Simulacrum ability. Runs in a straight line until destroyed.
/obj/effect/simulacrum
	name = "an illusion!"
	desc = "What are you hiding?!"
	icon_state = "static"
	density = TRUE
	atom_integrity = 25
	var/mob/living/mimicking

/obj/effect/simulacrum/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	QDEL_IN(src, 100)

/obj/effect/simulacrum/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/*/obj/effect/simulacrum/examine(mob/user) //I can't currently get this to work properly
	if(mimicking)
		mimicking.examine(user)
		return
	. = ..() */

/obj/effect/simulacrum/process()
	var/turf/T = get_step(src, dir)
	Move(T)

/obj/effect/simulacrum/proc/mimic(mob/living/L)
	mimicking = L
	name = L.name
	desc = "A lifelike illusion of [L]."
	icon = L.icon
	icon_state = L.icon_state
	overlays = L.overlays
	setDir(L.dir)

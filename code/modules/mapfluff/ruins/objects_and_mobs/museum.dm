/obj/machinery/computer/terminal/museum
	name = "exhibit info terminal"
	desc = "A relatively low-tech info board. Not as low-tech as an actual sign though. Appears to be quite old."
	upperinfo = "Nanotrasen Museum Exhibit Info"
	content = list("Congratulations on your purchase of a NanoSoft-TM terminal! Further instructions on setup available in \
	user manual. For license and registration, please contact your licensed NanoSoft vendor and repair service representative.")
	icon_state = "plaque"
	icon_screen = "plaque_screen"
	icon_keyboard = null

/obj/effect/replica_spawner
	name = "replica creator"
	desc = "This creates a fluff object that looks exactly like the input, but like obviously a replica. Do not for the love of god use with stuff that has Initialize sideeffects."
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x2"
	invisibility = INVISIBILITY_ABSTRACT //nope, can't see this
	anchored = TRUE
	density = TRUE
	opacity = FALSE
	var/replica_path = /obj/structure/fluff
	var/target_path
	var/obvious_replica = TRUE

/obj/effect/replica_spawner/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(create_replica))
	return INITIALIZE_HINT_QDEL

/obj/effect/replica_spawner/proc/create_replica()
	var/atom/appearance_object = new target_path
	var/atom/new_replica = new replica_path(loc)

	new_replica.icon = appearance_object.icon
	new_replica.icon_state = appearance_object.icon_state
	new_replica.copy_overlays(appearance_object.appearance, cut_old = TRUE)
	new_replica.density = appearance_object.density //for like nondense showers and stuff

	new_replica.name = "[appearance_object.name] [obvious_replica ? "replica" : ""]"
	new_replica.desc = "[appearance_object.desc] [obvious_replica ? "..except this one is a replica.": ""]"
	qdel(appearance_object)
	qdel(src)

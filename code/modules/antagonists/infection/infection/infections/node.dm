/obj/structure/infection/node
	name = "infection node"
	icon = 'icons/mob/infection.dmi'
	icon_state = "infectionnode"
	desc = "A large, pulsating mass."
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 65, "acid" = 90)
	health_regen = 3
	point_return = 25


/obj/structure/infection/node/Initialize()
	GLOB.infection_nodes += src
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/infection/node/scannerreport()
	return "Gradually expands and sustains nearby infection spores and infesternauts."

/obj/structure/infection/node/update_icon()
	cut_overlays()
	color = null
	var/mutable_appearance/infection_overlay = mutable_appearance('icons/mob/blob.dmi', "blob")
	if(overmind)
		infection_overlay.color = overmind.infection_color
	add_overlay(infection_overlay)
	add_overlay(mutable_appearance('icons/mob/blob.dmi', "blob_node_overlay"))

/obj/structure/infection/node/Destroy()
	GLOB.infection_nodes -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/infection/node/Life()
	if(overmind && world.time >= next_pulse)
		overmind.infection_core.topulse += src
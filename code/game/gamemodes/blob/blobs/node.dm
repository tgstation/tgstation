/obj/structure/blob/node
	name = "blob node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "A large, pulsating yellow mass."
	obj_integrity = 200
	max_integrity = 200
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 65, acid = 90)
	health_regen = 3
	point_return = 25


/obj/structure/blob/node/New(loc)
	blob_nodes += src
	START_PROCESSING(SSobj, src)
	..()

/obj/structure/blob/node/scannerreport()
	return "Gradually expands and sustains nearby blob spores and blobbernauts."

/obj/structure/blob/node/update_icon()
	cut_overlays()
	color = null
	var/image/I = new('icons/mob/blob.dmi', "blob")
	if(overmind)
		I.color = overmind.blob_reagent_datum.color
	add_overlay(I)
	var/image/C = new('icons/mob/blob.dmi', "blob_node_overlay")
	add_overlay(C)

/obj/structure/blob/node/Destroy()
	blob_nodes -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blob/node/Life()
	Pulse_Area(overmind, 10, 3, 2)


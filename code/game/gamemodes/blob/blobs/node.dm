/obj/effect/blob/node
	name = "blob node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "A large, pulsating yellow mass."
	health = 200
	maxhealth = 200
	health_regen = 3
	point_return = 25
	atmosblock = 1


/obj/effect/blob/node/New(loc, var/h = 100)
	blob_nodes += src
	SSobj.processing |= src
	..(loc, h)

/obj/effect/blob/node/update_icon()
	overlays.Cut()
	color = null
	var/image/I = new('icons/mob/blob.dmi', "blob")
	if(overmind)
		I.color = overmind.blob_reagent_datum.color
	src.overlays += I
	var/image/C = new('icons/mob/blob.dmi', "blob_node_overlay")
	src.overlays += C

/obj/effect/blob/node/PulseAnimation()
	return

/obj/effect/blob/node/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/node/Destroy()
	blob_nodes -= src
	SSobj.processing.Remove(src)
	return ..()

/obj/effect/blob/node/Life()
	Pulse_Area(overmind, 10, 3, 2)
	color = null

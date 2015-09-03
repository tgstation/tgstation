/obj/effect/blob/node
	name = "blob node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "A large, pulsating yellow mass."
	health = 100
	fire_resist = 2

/obj/effect/blob/node/New(loc, var/h = 100)
	blob_nodes += src
	SSobj.processing |= src
	..(loc, h)

/obj/effect/blob/node/adjustcolors(a_color)
	overlays.Cut()
	color = null
	var/image/I = new('icons/mob/blob.dmi', "blob")
	I.color = a_color
	src.overlays += I
	var/image/C = new('icons/mob/blob.dmi', "blob_node_overlay")
	src.overlays += C

/obj/effect/blob/node/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/node/Destroy()
	blob_nodes -= src
	SSobj.processing.Remove(src)
	return ..()

/obj/effect/blob/node/Life()
	pulseLoop(5)
	health = min(initial(health), health + 1)
	color = null

/obj/effect/blob/node/update_icon()
	if(health <= 0)
		qdel(src)
		return
	return
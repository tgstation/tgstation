/obj/effect/blob/resource
	name = "resource blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_node"
	health = 100
	brute_resist = 1
	fire_resist = 2
	var/mob/camera/blob/overmind = null

	update_icon()
		if(health <= 0)
			playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
			del(src)
			return
		return

	run_action()
		if(overmind)
			overmind.add_points(2)


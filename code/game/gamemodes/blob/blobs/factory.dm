/obj/effect/blob/factory
	name = "porous blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_factory"
	health = 100
	brute_resist = 1
	fire_resist = 2
	var/list/spores = list()
	var/max_spores = 4


	update_icon()
		if(health <= 0)
			playsound(src.loc, 'splat.ogg', 50, 1)
			del(src)
			return
		return


	run_action()
		if(spores.len >= max_spores)	return 0
		new/obj/effect/critter/blob(src.loc, src)
		return 1

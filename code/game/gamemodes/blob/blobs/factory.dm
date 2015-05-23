/obj/effect/blob/factory
	name = "factory blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_factory"
	health = 100
	fire_resist = 2
	var/list/spores = list()
	var/max_spores = 3
	var/spore_delay = 0
	var/mob/camera/blob/overmind

/obj/effect/blob/factory/update_icon()
	if(health <= 0)
		qdel(src)

/obj/effect/blob/factory/Destroy()
	for(var/mob/living/simple_animal/hostile/blob/blobspore/spore in spores)
		if(spore.factory == src)
			spore.factory = null
	spores = null
	..()

/obj/effect/blob/factory/PulseAnimation(var/activate = 0)
	if(activate)
		..()
	return

/obj/effect/blob/factory/run_action()
	if(spores.len >= max_spores)
		return 0
	if(spore_delay > world.time)
		return 0
	spore_delay = world.time + 100 // 10 seconds
	PulseAnimation(1)
	var/mob/living/simple_animal/hostile/blob/blobspore/BS = new/mob/living/simple_animal/hostile/blob/blobspore(src.loc, src)
	BS.color = color
	BS.overmind = overmind
	overmind.blob_mobs.Add(BS)
	return 0


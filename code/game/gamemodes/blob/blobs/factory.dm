/obj/effect/blob/factory
	name = "factory blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_factory"
	health = 100
	fire_resist = 2
	var/list/spores = list()
	var/max_spores = 2
	var/spore_delay = 50

/obj/effect/blob/factory/update_icon()
	if(health <= 0)
		playsound(get_turf(src), 'sound/effects/blobsplatspecial.ogg', 50, 1)
		qdel(src)
		return
	return

/obj/effect/blob/factory/run_action()
	if(spores.len >= max_spores)
		return 0
	if(spore_delay > world.time)
		return 0
	spore_delay = world.time + (40 SECONDS) // 30 seconds
	new/mob/living/simple_animal/hostile/blobspore(src.loc, src)
	return 1

/obj/effect/blob/factory/Destroy()
	if(spores.len)
		var/mob/living/simple_animal/hostile/blobspore/S
		S.Die()
	..()

/mob/living/simple_animal/hostile/blobspore
	name = "Blob Spore"
	desc = "A form of blob antibodies that attack foreign entities."
	icon = 'icons/mob/blob.dmi'
	icon_state = "blobpod"
	icon_living = "blobpod"
	pass_flags = PASSBLOB
	health = 30
	maxHealth = 30
	melee_damage_lower = 2
	melee_damage_upper = 4
	attacktext = "hits"
	attack_sound = 'sound/weapons/rapidslice.ogg'
	var/obj/effect/blob/factory/factory = null
	faction = "blob"
	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = 360

/mob/living/simple_animal/hostile/blobspore/New(loc, var/obj/effect/blob/factory/linked_node)
	if(istype(linked_node))
		factory = linked_node
		factory.spores += src
	..()

/mob/living/simple_animal/hostile/blobspore/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	adjustBruteLoss(Clamp(0.01 * exposed_temperature, 1, 5))

/mob/living/simple_animal/hostile/blobspore/blob_act()
	return

/mob/living/simple_animal/hostile/blobspore/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover, /obj/effect/blob))
		return 1
	return ..()

/mob/living/simple_animal/hostile/blobspore/Die()
	var/sound = pick('sound/effects/gib1.ogg','sound/effects/gib2.ogg','sound/effects/gib3.ogg')
	playsound(get_turf(src), sound, 50, 1)
	qdel(src)

/mob/living/simple_animal/hostile/blobspore/Destroy()
	if(factory)
		factory.spores -= src
	..()

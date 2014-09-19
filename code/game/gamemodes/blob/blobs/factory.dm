/obj/effect/blob/factory
	name = "factory blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_factory"
	health = 100
	fire_resist = 2
	var/list/spores = list()
	var/max_spores = 3
	var/spore_delay = 0

	update_icon()
		if(health <= 0)
			playsound(get_turf(src), 'sound/effects/blobsplatspecial.ogg', 50, 1)
			Delete()
			return
		return


	run_action()
		if(spores.len >= max_spores)
			return 0
		if(spore_delay > world.time)
			return 0
		spore_delay = world.time + 100 // 10 seconds
		new/mob/living/simple_animal/hostile/blobspore(src.loc, src)
		return 1


/mob/living/simple_animal/hostile/blobspore
	name = "blob"
	desc = "Some blob thing."
	icon = 'icons/mob/blob.dmi'
	icon_state = "blobpod"
	icon_living = "blobpod"
	pass_flags = PASSBLOB
	health = 40
	maxHealth = 40
	melee_damage_lower = 2
	melee_damage_upper = 4
	attacktext = "hits"
	attack_sound = 'sound/weapons/rapidslice.ogg'
	var/obj/effect/blob/factory/factory = null
	faction = "blob"
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 360

	fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		..()
		adjustBruteLoss(Clamp(0.01 * exposed_temperature, 1, 5))

	blob_act()
		return

	CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
		if(istype(mover, /obj/effect/blob))
			return 1
		return ..()

	New(loc, var/obj/effect/blob/factory/linked_node)
		if(istype(linked_node))
			factory = linked_node
			factory.spores += src
		..()

	Die()
		del(src)

	Destroy()
		if(factory)
			factory.spores -= src
		..()

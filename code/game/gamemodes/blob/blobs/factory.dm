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
			playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
			del(src)
			return
		return


	run_action()
		if(spores.len >= max_spores)	return 0
		new/mob/living/simple_animal/hostile/blobspore(src.loc, src)
		return 1


/mob/living/simple_animal/hostile/blobspore
	name = "blob"
	desc = "Some blob thing."
	icon = 'icons/mob/critter.dmi'
	icon_state = "blobsquiggle"
	icon_living = "blobsquiggle"
	pass_flags = PASSBLOB
	health = 20
	maxHealth = 20
	melee_damage_lower = 4
	melee_damage_upper = 8
	attacktext = "hits"
	attack_sound = 'sound/weapons/genhit1.ogg'
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


	New(loc, var/obj/effect/blob/factory/linked_node)
		..()
		if(istype(linked_node))
			factory = linked_node
			factory.spores += src
		..(loc)
		return
	Die()
		..()
		if(factory)
			factory.spores -= src
		..()
		del(src)


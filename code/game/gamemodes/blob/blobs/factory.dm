/obj/effect/blob/factory
	name = "factory blob"
	icon_state = "factory"
	desc = "Some antibodies-producing blob creature thingy"
	health = 100
	maxhealth = 100
	fire_resist = 2
	var/list/spores = list()
	var/max_spores = 2
	var/spore_delay = 50
	spawning = 0
	layer = 6.6

	layer_new = 6.6
	icon_new = "factory"
	icon_classic = "blob_factory"

/obj/effect/blob/factory/New(loc,newlook = "new")
	..()
	if(blob_looks[looks] == 64)
		flick("morph_factory",src)
		spore_delay = world.time + (2 SECONDS)

/obj/effect/blob/factory/update_health()
	if(health <= 0)
		dying = 1
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

	if(blob_looks[looks] == 64)
		flick("factorypulse",src)
		anim(target = loc, a_icon = icon, flick_anim = "sporepulse", sleeptime = 15, lay = 7.2, offX = -16, offY = -16, alph = 220)
		spawn(10)
			new/mob/living/simple_animal/hostile/blobspore(src.loc, src)
	else
		new/mob/living/simple_animal/hostile/blobspore(src.loc, src)

	return 1

/obj/effect/blob/factory/Destroy()
	if(spores.len)
		for(var/mob/living/simple_animal/hostile/blobspore/S in spores)
			S.Die()
	if(!manual_remove && overmind)
		to_chat(overmind,"<span class='warning'>A factory blob that you had created has been destroyed.</span>")
	..()

/obj/effect/blob/factory/update_icon(var/spawnend = 0)
	if(blob_looks[looks] == 64)
		spawn(1)
			overlays.len = 0

			overlays += image(icon,"roots", layer = 3)

			if(!spawning)
				for(var/obj/effect/blob/B in orange(src,1))
					overlays += image(icon,"factoryconnect",dir = get_dir(src,B), layer = layer+0.1)
			if(spawnend)
				spawn(10)
					update_icon()

			..()

/////////////BLOB SPORE///////////////////////////////////////////////////////////////////////////////////////////////

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
	can_butcher = 0
	var/obj/effect/blob/factory/factory = null
	faction = "blob"
	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = 360
	layer = 7.2

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
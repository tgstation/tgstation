

////////////////
// BLOB SPORE //
////////////////

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
	attack_sound = 'sound/weapons/genhit1.ogg'
	var/obj/effect/blob/factory/factory = null
	var/is_zombie = 0
	faction = list("blob")
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

/mob/living/simple_animal/hostile/blobspore/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	adjustBruteLoss(Clamp(0.01 * exposed_temperature, 1, 5))

/mob/living/simple_animal/hostile/blobspore/blob_act()
	return

/mob/living/simple_animal/hostile/blobspore/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover, /obj/effect/blob))
		return 1
	return ..()

/mob/living/simple_animal/hostile/blobspore/New(loc, var/obj/effect/blob/factory/linked_node)
	if(istype(linked_node))
		factory = linked_node
		factory.spores += src
	..()

/mob/living/simple_animal/hostile/blobspore/Life()

	if(!is_zombie && isturf(src.loc))
		for(var/mob/living/carbon/human/H in oview(src,1)) //Only for corpse right next to/on same tile
			if(H.stat == DEAD)
				Zombify(H)
				break
	..()

/mob/living/simple_animal/hostile/blobspore/proc/Zombify(var/mob/living/carbon/human/H)
	if(H.wear_suit)
		var/obj/item/clothing/suit/armor/A = H.wear_suit
		if(A.armor && A.armor["melee"])
			maxHealth += A.armor["melee"] //That zombie's got armor, I want armor!
	maxHealth += 40
	health = maxHealth
	name = "blob zombie"
	desc = "A shambling corpse animated by the blob."
	melee_damage_lower = 10
	melee_damage_upper = 15
	icon = H.icon
	icon_state = "husk_s"
	H.hair_style = null
	H.update_hair()
	overlays = H.overlays
	overlays += image('icons/mob/blob.dmi', icon_state = "blob_head")
	H.loc = src
	is_zombie = 1
	loc.visible_message("<span class='warning'> The corpse of [H.name] suddenly rises!</span>")

/mob/living/simple_animal/hostile/blobspore/Die()
	// On death, create a small smoke of harmful gas (s-Acid)
	var/datum/effect/effect/system/chem_smoke_spread/S = new
	var/turf/location = get_turf(src)

	// Create the reagents to put into the air, s-acid is yellow and stings a little
	create_reagents(25)
	reagents.add_reagent("spore", 25)

	// Attach the smoke spreader and setup/start it.
	S.attach(location)
	S.set_up(reagents, 1, 1, location, 15, 1) // only 1-2 smoke cloud
	S.start()

	qdel(src)

/mob/living/simple_animal/hostile/blobspore/Destroy()
	if(factory)
		factory.spores -= src
	if(contents)
		for(var/mob/M in contents)
			M.loc = src.loc
	..()


/mob/living/simple_animal/hostile/blobbernaut
	name = "blobbernaut"
	desc = "Some HUGE blob thing."
	icon = 'icons/mob/blob.dmi'
	icon_state = "blobbernaut"
	icon_living = "blobbernaut"
	icon_dead = "blobbernaut_death"
	pass_flags = PASSBLOB
	health = 240
	maxHealth = 240
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "hits"
	attack_sound = 'sound/effects/blobattack.ogg'
	faction = list("blob")
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
	force_threshold = 10
	environment_smash = 3
	mob_size = 2


/mob/living/simple_animal/hostile/blobbernaut/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent("spore_burning", 10)


/mob/living/simple_animal/hostile/blobbernaut/blob_act()
	return

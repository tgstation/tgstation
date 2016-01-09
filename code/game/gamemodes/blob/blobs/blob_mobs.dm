
////////////////
// BASE TYPE //
////////////////

//Do not spawn
/mob/living/simple_animal/hostile/blob
	icon = 'icons/mob/blob.dmi'
	pass_flags = PASSBLOB
	faction = list("blob")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 360
	var/mob/camera/blob/overmind = null

/mob/living/simple_animal/hostile/blob/update_icons()
	if(overmind)
		color = overmind.blob_reagent_datum.color

/mob/living/simple_animal/hostile/blob/blob_act()
	return

////////////////
// BLOB SPORE //
////////////////

/mob/living/simple_animal/hostile/blob/blobspore
	name = "blob spore"
	desc = "A floating, fragile spore."
	icon_state = "blobpod"
	icon_living = "blobpod"
	health = 40
	maxHealth = 40
	melee_damage_lower = 2
	melee_damage_upper = 4
	attacktext = "hits"
	attack_sound = 'sound/weapons/genhit1.ogg'
	speak_emote = list("pulses")
	var/obj/effect/blob/factory/factory = null
	var/list/human_overlays = list()
	var/is_zombie = 0
	gold_core_spawnable = 1

/mob/living/simple_animal/hostile/blob/blobspore/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	adjustBruteLoss(Clamp(0.01 * exposed_temperature, 1, 5))


/mob/living/simple_animal/hostile/blob/blobspore/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover, /obj/effect/blob))
		return 1
	return ..()

/mob/living/simple_animal/hostile/blob/blobspore/New(loc, var/obj/effect/blob/factory/linked_node)
	if(istype(linked_node))
		factory = linked_node
		factory.spores += src
	..()

/mob/living/simple_animal/hostile/blob/blobspore/Life()
	if(!is_zombie && isturf(src.loc))
		for(var/mob/living/carbon/human/H in oview(src,1)) //Only for corpse right next to/on same tile
			if(H.stat == DEAD)
				Zombify(H)
				break
	if(factory && z != factory.z)
		death()
	..()

/mob/living/simple_animal/hostile/blob/blobspore/proc/Zombify(mob/living/carbon/human/H)
	is_zombie = 1
	if(H.wear_suit)
		var/obj/item/clothing/suit/armor/A = H.wear_suit
		if(A.armor && A.armor["melee"])
			maxHealth += A.armor["melee"] //That zombie's got armor, I want armor!
	maxHealth += 40
	health = maxHealth
	name = "blob zombie"
	desc = "A shambling corpse animated by the blob."
	melee_damage_lower += 8
	melee_damage_upper += 11
	icon = H.icon
	speak_emote = list("groans")
	icon_state = "zombie_s"
	H.hair_style = null
	H.update_hair()
	human_overlays = H.overlays
	update_icons()
	H.loc = src
	loc.visible_message("<span class='warning'>The corpse of [H.name] suddenly rises!</span>")

/mob/living/simple_animal/hostile/blob/blobspore/death(gibbed)
	..(1)
	// On death, create a small smoke of harmful gas (s-Acid)
	var/datum/effect_system/smoke_spread/chem/S = new
	var/turf/location = get_turf(src)

	// Create the reagents to put into the air
	create_reagents(10)

	if(overmind && overmind.blob_reagent_datum)
		reagents.add_reagent(overmind.blob_reagent_datum.id, 10)
	else
		reagents.add_reagent("spore", 10)

	// Attach the smoke spreader and setup/start it.
	S.attach(location)
	S.set_up(reagents, 0, location, silent=1)
	S.start()

	ghostize()
	qdel(src)

/mob/living/simple_animal/hostile/blob/blobspore/Destroy()
	if(factory)
		factory.spores -= src
	factory = null
	if(contents)
		for(var/mob/M in contents)
			M.loc = src.loc
	return ..()

/mob/living/simple_animal/hostile/blob/blobspore/update_icons()
	..()
	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('icons/mob/blob.dmi', icon_state = "blob_head")
		I.color = color
		color = initial(color)//looks better.
		overlays += I

/mob/living/simple_animal/hostile/blob/blobspore/weak
	name = "fragile blob spore"
	health = 20
	maxHealth = 20
	melee_damage_lower = 1
	melee_damage_upper = 2

/////////////////
// BLOBBERNAUT //
/////////////////

/mob/living/simple_animal/hostile/blob/blobbernaut
	name = "blobbernaut"
	desc = "A hulking, mobile chunk of blobmass."
	icon_state = "blobbernaut"
	icon_living = "blobbernaut"
	icon_dead = "blobbernaut_dead"
	health = 240
	maxHealth = 240
	melee_damage_lower = 20
	melee_damage_upper = 20
	attacktext = "slams"
	attack_sound = 'sound/effects/blobattack.ogg'
	speak_emote = list("gurgles")
	minbodytemp = 0
	maxbodytemp = 360
	force_threshold = 10
	mob_size = MOB_SIZE_LARGE
	gold_core_spawnable = 1

/mob/living/simple_animal/hostile/blob/blobbernaut/AttackingTarget()
	if(isliving(target))
		if(overmind)
			var/mob/living/L = target
			var/mob_protection = L.get_permeability_protection()
			overmind.blob_reagent_datum.reaction_mob(L, VAPOR, 17.5, 0, mob_protection)//this will do between 7 and 17 damage(reduced by mob protection), depending on chemical, plus 4 from base brute damage.
	if(target)
		..()

/mob/living/simple_animal/hostile/blob/blobbernaut/update_icons()
	..()
	if(overmind) //if we have an overmind, we're doing chemical reactions instead of pure damage
		melee_damage_lower = 4
		melee_damage_upper = 4
		attacktext = overmind.blob_reagent_datum.blobbernaut_message
	else
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		attacktext = initial(attacktext)

/mob/living/simple_animal/hostile/blob/blobbernaut/death(gibbed)
	..(gibbed)
	flick("blobbernaut_death", src)

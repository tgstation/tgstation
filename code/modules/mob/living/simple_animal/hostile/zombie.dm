/mob/living/simple_animal/hostile/zombie
	name = "zombie"
	desc = "When Observe is full, the dead shall walk the station."
	icon = 'icons/mob/human.dmi'
	icon_state = "zombie_s"
	icon_living = "zombie_s"
	icon_dead = "zombie_dead"
	turns_per_move = 5
	emote_see = list("groans")
	a_intent = "harm"
	maxHealth = 100
	health = 100
	speed = 1
	harm_intent_damage = 8
	melee_damage_lower = 20
	melee_damage_upper = 20
	attacktext = "claws"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 350
	unsuitable_atmos_damage = 10
	environment_smash = 1
	robust_searching = 1
	stat_attack = 2
	gold_core_spawnable = 1
	faction = list("zombie")
	var/mob/living/carbon/human/stored_corpse = null



/mob/living/simple_animal/hostile/zombie/AttackingTarget()
	..()
	if(istype(target, /mob/living))
		var/mob/living/L = target
		if(ishuman(L) && L.stat)
			var/mob/living/carbon/human/H = L
			Zombify(H)
		else if (L.stat) //So they don't get stuck hitting a corpse
			L.gib()
			visible_message("<span class='danger'>[src] tears [L] to pieces!</span>")
			src << "<span class='userdanger'>You feast on [L], restoring your health!</span>"
			src.revive()

/mob/living/simple_animal/hostile/zombie/death()
	..()
	if(stored_corpse)
		stored_corpse.loc = loc
		if(ckey)
			stored_corpse.ckey = src.ckey
		qdel(src)
		return
	src << "<span class='userdanger'>You're down, but not quite out. You'll be back on your feet within a minute or two.</span>"
	spawn(rand(800,1200))
		visible_message("<span class='danger'>[src] staggers to their feet!</span>")
		src.revive()

/mob/living/simple_animal/hostile/zombie/proc/Zombify(mob/living/carbon/human/H)
	H.set_species(/datum/species/zombie)
	var/mob/living/simple_animal/hostile/zombie/Z = new /mob/living/simple_animal/hostile/zombie(H.loc)
	Z.faction = src.faction
	Z.appearance = H.appearance
	Z.transform = matrix()
	Z.pixel_y = 0
	if(H.ckey)
		Z.ckey = H.ckey
	H.stat = DEAD
	H.loc = Z
	Z.stored_corpse = H
	visible_message("<span class='danger'>[Z] staggers to their feet!</span>")
	Z << "<span class='userdanger'>You are now a zombie! Follow your creators lead!</span>"


/mob/living/simple_animal/hostile/spawner/zombie
	name = "corpse pit"
	desc = "A pit full of zombies."
	icon_state = "tombstone"
	icon_living = "tombstone"
	icon = 'icons/mob/nest.dmi'
	health = 200
	maxHealth = 200
	list/spawned_mobs = list()
	max_mobs = 40
	spawn_time = 150
	mob_type = /mob/living/simple_animal/hostile/zombie
	spawn_text = "emerges from"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("zombie")


/mob/living/simple_animal/hostile/spawner/zombie/lesser
	name = "lesser corpse pit"
	desc = "A pit full of less zombies."
	max_mobs = 10
	spawn_time = 150

/mob/living/simple_animal/hostile/spawner/zombie/death()
	visible_message("<span class='danger'>[src] collapes, stopping the flow of zombies!</span>")
	qdel(src)


/obj/item/weapon/shovel/cursed
	name = "cursed shovel"
	desc = "You probably shouldn't use this particular shovel."
	var/used = FALSE
	force = 15

/obj/item/weapon/shovel/cursed/attack_self(mob/living/user)
	if(used == FALSE)
		visible_message("<span class='danger'>[user] digs a pit to Hell!</span>")
		new /mob/living/simple_animal/hostile/spawner/zombie(get_turf(src.loc))
		used = TRUE
	else
		user << "The unearthly energies that once powered this shovel are now dormant. Still sharp though."

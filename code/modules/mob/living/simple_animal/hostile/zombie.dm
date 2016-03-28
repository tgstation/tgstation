/mob/living/simple_animal/hostile/zombie
	name = "zombie"
	desc = "When Observe is full, the dead shall walk the station."
	icon = 'icons/mob/human.dmi'
	icon_state = "zombie_s"
	icon_living = "zombie_s"
	icon_dead = "zombie_dead"
	turns_per_move = 5
	speak_emote = list("groans")
	emote_see = list("groans")
	a_intent = "harm"
	maxHealth = 180
	health = 180
	speed = 2
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
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie = 3)
	see_invisible = SEE_INVISIBLE_MINIMUM
	see_in_dark = 8
	layer = MOB_LAYER - 0.1



/mob/living/simple_animal/hostile/zombie/AttackingTarget()
	..()
	if(istype(target, /mob/living))
		var/mob/living/L = target
		if(ishuman(L) && L.stat)
			var/mob/living/carbon/human/H = L
			for(var/mob/living/simple_animal/hostile/zombie/holder/Z in H) //No instant heals for people who are already zombies
				src << "<span class='userdanger'>They'll be getting up on their own, just give them a minute!</span>"
				Z.faction = src.faction //Just in case zombies somehow ended up on different "teams"
				H.faction = src.faction
				return
			Zombify(H)
		else if (L.stat) //So they don't get stuck hitting a corpse
			L.gib()
			visible_message("<span class='danger'>[src] tears [L] to pieces!</span>")
			src << "<span class='userdanger'>You feast on [L], restoring your health!</span>"
			revive(full_heal = 1)
			
	if(istype(target, /obj/machinery/door/airlock))
		src << "<span class='notice'>You start tearing apart the airlock...</span>"
		playsound(src.loc, 'sound/hallucinations/growl3.ogg', 50, 1)
		if(do_after(src, 250, target))
			playsound(src.loc, 'sound/hallucinations/far_noise.ogg', 50, 1)
			qdel(target)
			var/obj/machinery/door/airlock/A = target
			var/obj/structure/door_assembly/door = new A.doortype(target.loc)
			door.density = 0
			door.anchored = 1
			door.name = "ravaged airlock"
			door.desc = "An airlock that has been torn apart. Looks like it wont be keeping much out now."

/mob/living/simple_animal/hostile/zombie/death()
	..()
	if(stored_corpse)
		stored_corpse.loc = loc
		if(ckey)
			stored_corpse.ckey = src.ckey
			stored_corpse << "<span class='userdanger'>You're down, but not quite out. You'll be back on your feet within a minute or two.</span>"
			var/mob/living/simple_animal/hostile/zombie/holder/D = new/mob/living/simple_animal/hostile/zombie/holder(stored_corpse)
			D.faction = src.faction
		qdel(src)
		return
	src << "<span class='userdanger'>You're down, but not quite out. You'll be back on your feet within a minute or two.</span>"
	spawn(rand(600,900))
		if(src)
			visible_message("<span class='danger'>[src] staggers to their feet!</span>")
			revive(full_heal = 1)

/mob/living/simple_animal/hostile/zombie/proc/Zombify(mob/living/carbon/human/H)
	H.set_species(/datum/species/zombie)
	if(H.head) //So people can see they're a zombie
		var/obj/item/clothing/helmet = H.head
		if(!H.unEquip(helmet))
			qdel(helmet)
	if(H.wear_mask)
		var/obj/item/clothing/mask = H.wear_mask
		if(!H.unEquip(mask))
			qdel(mask)
	var/mob/living/simple_animal/hostile/zombie/Z = new /mob/living/simple_animal/hostile/zombie(H.loc)
	Z.faction = src.faction
	Z.appearance = H.appearance
	Z.transform = matrix()
	Z.pixel_y = 0
	for(var/mob/dead/observer/ghost in player_list)
		if(H.real_name == ghost.real_name)
			ghost.reenter_corpse()
			break
	Z.ckey = H.ckey
	H.stat = DEAD
	H.butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie = 3) //So now you can carve them up when you kill them. Maybe not a good idea for the human versions.
	H.loc = Z
	Z.stored_corpse = H
	for(var/mob/living/simple_animal/hostile/zombie/holder/D in H) //Dont want to revive them twice
		qdel(D)
	visible_message("<span class='danger'>[Z] staggers to their feet!</span>")
	Z << "<span class='userdanger'>You are now a zombie! Follow your creators lead!</span>"


/mob/living/simple_animal/hostile/spawner/zombie
	name = "corpse pit"
	desc = "A pit full of zombies."
	icon_state = "tombstone"
	icon_living = "tombstone"
	icon = 'icons/mob/nest.dmi'
	health = 400
	maxHealth = 400
	list/spawned_mobs = list()
	max_mobs = 40
	spawn_time = 100
	mob_type = /mob/living/simple_animal/hostile/zombie
	spawn_text = "emerges from"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("zombie")
	del_on_death = 1

/mob/living/simple_animal/hostile/spawner/zombie/lesser
	name = "lesser corpse pit"
	desc = "A pit full of less zombies."
	max_mobs = 10
	spawn_time = 150
	health = 200
	maxHealth = 200

/mob/living/simple_animal/hostile/spawner/zombie/New()
	..()
	deathmessage = "[src] collapes, stopping the flow of zombies!"


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


/mob/living/simple_animal/hostile/zombie/holder
	name = "infection holder"
	icon_state = "none"
	icon_living = "none"
	icon_dead = "none"
	desc = "You shouldn't be seeing this."
	invisibility = 101
	unsuitable_atmos_damage = 0
	stat_attack = 2
	gold_core_spawnable = 0
	AIStatus = AI_OFF
	stop_automated_movement = 1
	density = 0

/mob/living/simple_animal/hostile/zombie/holder/New()
	..()
	spawn(rand(800,1200))
		if(src && istype(loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = loc
			Zombify(H)
		qdel(src)

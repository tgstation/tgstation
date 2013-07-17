/obj/structure/statue
	name = "statue"
	desc = "An incredibly lifelike granite carving"
	icon = 'icons/obj/statue.dmi'
	icon_state = "human_male"
	density = 1
	anchored = 1
	flags = FPRINT
	var/health = 200 //destroying the statue kills the person within
	var/timer = 240 //eventually the person will be freed

/obj/structure/statue/New()

	for(var/atom/movable/AM in src.loc)
		if(istype(AM, /mob/living))
			var/mob/living/L = AM
			if((ishuman(L) || ismonkey(L) || iscorgi(L)) && (!L.mind || L.mind.special_role != "Wizard"))
				if(L.buckled)
					L.buckled = 0
				if(L.client)
					L.client.perspective = EYE_PERSPECTIVE
					L.client.eye = src
				AM.loc = src
				L.sdisabilities += MUTE
				L.status_flags += GODMODE
				if(ishuman(L))
					name = "statue of [L.name]"
					if(L.gender == "female")
						icon_state = "human_female"
				else if(ismonkey(L))
					name = "statue of a monkey"
					icon_state = "monkey"
				else if(iscorgi(L))
					name = "statue of a corgi"
					icon_state = "corgi"
					desc = "If it takes forever, I will wait for you..."
				break
			else
				del(src)

	processing_objects.Add(src)
	..()

/obj/structure/statue/process()
	timer--
	if (timer <= 0)
		dump_contents()
		processing_objects.Remove(src)
		del(src)

/obj/structure/statue/alter_health()
	return get_turf(src)

/obj/structure/statue/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || height==0) return 1
	return (!density)

/obj/structure/statue/proc/dump_contents()

	for(var/obj/O in src)
		O.loc = src.loc

	for(var/mob/M in src)
		M.loc = get_turf(src) //src.loc not used to avoid an edge case where the mob was recursively stored
		M.sdisabilities -= MUTE
		M.status_flags -= GODMODE
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE
		for(var/mob/living/simple_animal/hostile/mimic/copy/C in M.loc) //destroy animated statue if there is one
			C.health = 0
		visible_message("\blue [M.name] returns to flesh and blood!.")


/obj/structure/statue/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	if(health <= 0)
		for(var/mob/M in src)
			shatter(M)

	return

/obj/structure/statue/attack_animal(mob/living/simple_animal/user as mob)
	if(user.wall_smash)
		for(var/mob/M in src)
			shatter(M)

/obj/structure/statue/blob_act()
	for(var/mob/M in src)
		shatter(M)

/obj/structure/statue/meteorhit(obj/O as obj)
	if(O.icon_state == "flaming")
		for(var/mob/M in src)
			M.meteorhit(O)
			shatter(M)

/obj/structure/statue/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/))
		health -= W.force
		visible_message("\red [user] strikes [src] with [W].")
		if(health <= 0)
			for(var/mob/M in src)
				shatter(M)

/obj/structure/statue/proc/shatter(mob/user as mob)
	if (user)
		user.status_flags -= GODMODE
		user.dust()
	dump_contents()
	visible_message("\red [src] shatters!. ")
	del(src)
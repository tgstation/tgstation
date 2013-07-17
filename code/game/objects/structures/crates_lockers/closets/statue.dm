/obj/structure/closet/statue
	name = "statue"
	desc = "An incredibly lifelike marble carving"
	icon = 'icons/obj/statue.dmi'
	icon_state = "human_male"
	density = 1
	anchored = 1
	flags = FPRINT
	health = 200 //destroying the statue kills the mob within
	var/intialTox = 0 	//these are here to keep the mob from taking damage from things that logically wouldn't affect a rock
	var/intialFire = 0	//it's a little sloppy I know but it was this or the GODMODE flag. Lesser of two evils.
	var/intialBrute = 0
	var/intialOxy = 0
	var/timer = 240 //eventually the person will be freed

/obj/structure/closet/statue/New()

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
				health = L.health + 100 //stoning damaged mobs will result in easier to shatter statues
				intialTox = L.getToxLoss()
				intialFire = L.getFireLoss()
				intialBrute = L.getBruteLoss()
				intialOxy = L.getOxyLoss()
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

/obj/structure/closet/statue/process()
	timer--
	for(var/mob/living/M in src) //Gp-go gadget stasis field
		M.setToxLoss(intialTox)
		M.adjustFireLoss(intialFire - M.getFireLoss())
		M.adjustBruteLoss(intialBrute - M.getBruteLoss())
		M.setOxyLoss(intialOxy)
	if (timer <= 0)
		dump_contents()
		processing_objects.Remove(src)
		del(src)

/obj/structure/closet/statue/dump_contents()

	for(var/obj/O in src)
		O.loc = src.loc

	for(var/mob/living/M in src)
		M.loc = get_turf(src) //src.loc not used to avoid an edge case where the mob was recursively stored
		M.sdisabilities -= MUTE
		M.take_overall_damage((M.health - health - 100),0) //any new  the statue incurred is transfered to the mob
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE
		for(var/mob/living/simple_animal/hostile/mimic/copy/C in M.loc) //destroy animated statue if there is one
			C.health = 0

/obj/structure/closet/statue/take_contents()
	return

/obj/structure/closet/statue/open()
	return

/obj/structure/closet/statue/take_contents()
	return

/obj/structure/closet/statue/open()
	return

/obj/structure/closet/statue/insert()
	return

/obj/structure/closet/statue/close()
	return

/obj/structure/closet/statue/toggle()
	return

/obj/structure/closet/statue/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	if(health <= 0)
		for(var/mob/M in src)
			shatter(M)

	return

/obj/structure/closet/statue/attack_animal(mob/living/simple_animal/user as mob)
	if(user.wall_smash)
		for(var/mob/M in src)
			shatter(M)

/obj/structure/closet/statue/blob_act()
	for(var/mob/M in src)
		shatter(M)

/obj/structure/closet/statue/meteorhit(obj/O as obj)
	if(O.icon_state == "flaming")
		for(var/mob/M in src)
			M.meteorhit(O)
			shatter(M)

/obj/structure/closet/statue/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/))
		health -= W.force
		visible_message("\red [user] strikes [src] with [W].")
		if(health <= 0)
			for(var/mob/M in src)
				shatter(M)

/obj/structure/closet/statue/place()
	return

/obj/structure/closet/statue/MouseDrop_T()
	return

/obj/structure/closet/statue/relaymove()
	return

/obj/structure/closet/statue/attack_hand()
	return

/obj/structure/closet/statue/verb_toggleopen()
	return

/obj/structure/closet/statue/update_icon()
	return

/obj/structure/closet/statue/proc/shatter(mob/user as mob)
	if (user)
		user.dust()
	dump_contents()
	visible_message("\red [src] shatters!. ")
	del(src)
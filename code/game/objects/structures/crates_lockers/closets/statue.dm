/obj/structure/closet/statue
	name = "statue"
<<<<<<< HEAD
	desc = "An incredibly lifelike marble carving."
=======
	desc = "An incredibly lifelike marble carving"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	icon = 'icons/obj/statue.dmi'
	icon_state = "human_male"
	density = 1
	anchored = 1
	health = 0 //destroying the statue kills the mob within
	var/intialTox = 0 	//these are here to keep the mob from taking damage from things that logically wouldn't affect a rock
	var/intialFire = 0	//it's a little sloppy I know but it was this or the GODMODE flag. Lesser of two evils.
	var/intialBrute = 0
	var/intialOxy = 0
<<<<<<< HEAD
	var/timer = 240 //eventually the person will be freed
=======
	var/timer = 80 // time in seconds = 2.5(timer) - 50, this makes 150 seconds = 2.5m
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/structure/closet/statue/New(loc, var/mob/living/L)

	if(ishuman(L) || ismonkey(L) || iscorgi(L))
<<<<<<< HEAD
		if(L.buckled)
			L.buckled.unbuckle_mob(L,force=1)
		L.reset_perspective(src)
		L.loc = src
		L.disabilities += MUTE
		L.faction += "mimic" //Stops mimics from instaqdeling people in statues
		L.visible_message("<span class='warning'>[L]'s skin rapidly turns to marble!</span>", "<span class='userdanger'>Your body freezes up! Can't... move... can't...  think...</span>")

=======
		if(L.locked_to)
			L.locked_to = 0
			L.anchored = 0
		if(L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src
		L.loc = src
		L.sdisabilities |= MUTE
		L.delayNextAttack(timer)
		L.click_delayer.setDelay(timer)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		health = L.health + 100 //stoning damaged mobs will result in easier to shatter statues
		intialTox = L.getToxLoss()
		intialFire = L.getFireLoss()
		intialBrute = L.getBruteLoss()
		intialOxy = L.getOxyLoss()
		if(ishuman(L))
<<<<<<< HEAD
			var/mob/living/carbon/human/H = L
			name = "statue of [H.name]"
			H.bleedsuppress = 1
			if(H.gender == "female")
				icon_state = "human_female"
		else if(ismonkey(L))
			name = "statue of a monkey"
			icon_state = "monkey"
		else if(iscorgi(L))
			name = "statue of a corgi"
			icon_state = "corgi"
			desc = "If it takes forever, I will wait for you..."

=======
			name = "statue of [L.name]"
			if(L.gender == "female")
				icon_state = "human_female"
		else if(ismonkey(L))
			name = "statue of [L.name]"
			icon_state = "monkey"
		else if(iscorgi(L))
			name = "statue of [L.name]"
			icon_state = "corgi"
			desc = "If it takes forever, I will wait for you..."

		processing_objects.Add(src)

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(health == 0) //meaning if the statue didn't find a valid target
		qdel(src)
		return

<<<<<<< HEAD
	START_PROCESSING(SSobj, src)
	..()
	icon = L.icon
	icon_state = L.icon_state
	overlays = L.overlays
	color = list(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
=======
	..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/structure/closet/statue/process()
	timer--
	for(var/mob/living/M in src) //Go-go gadget stasis field
		M.setToxLoss(intialTox)
		M.adjustFireLoss(intialFire - M.getFireLoss())
		M.adjustBruteLoss(intialBrute - M.getBruteLoss())
		M.setOxyLoss(intialOxy)
<<<<<<< HEAD
		M.Stun(1) //So they can't do anything while petrified
	if(timer <= 0)
		dump_contents()
		STOP_PROCESSING(SSobj, src)
=======
	if (timer <= 0)
		dump_contents()
		processing_objects.Remove(src)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		qdel(src)

/obj/structure/closet/statue/dump_contents()

<<<<<<< HEAD
	if(istype(src.loc, /mob/living/simple_animal/hostile/statue))
		var/mob/living/simple_animal/hostile/statue/S = src.loc
		src.loc = S.loc
		if(S.mind)
			for(var/mob/M in contents)
				S.mind.transfer_to(M)
				M.Weaken(5)
				M << "<span class='notice'>You slowly come back to your senses. You are in control of yourself again!</span>"
				break
		qdel(S)


=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	for(var/obj/O in src)
		O.loc = src.loc

	for(var/mob/living/M in src)
		M.loc = src.loc
<<<<<<< HEAD
		M.disabilities -= MUTE
		M.take_overall_damage((M.health - health - 100),0) //any new damage the statue incurred is transfered to the mob
		M.faction -= "mimic"
		M.reset_perspective(null)
=======
		M.sdisabilities &= ~MUTE
		M.take_overall_damage((M.health - health - 100),0) //any new damage the statue incurred is transfered to the mob
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

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

<<<<<<< HEAD
/obj/structure/closet/statue/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	if(health <= 0)
		shatter()

/obj/structure/closet/statue/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash)
		shatter()

/obj/structure/closet/statue/blob_act(obj/effect/blob/B)
	shatter()

/obj/structure/closet/statue/attacked_by(obj/item/I, mob/living/user)
	if(I.damtype != STAMINA)
		health -= I.force
	visible_message("<span class='danger'>[user] strikes [src] with [I].</span>")
	if(health <= 0)
		shatter()
=======
/obj/structure/closet/statue/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	if(health <= 0)
		for(var/mob/M in src)
			shatter(M)

	return

/obj/structure/closet/statue/attack_animal(mob/living/simple_animal/user as mob)
	if(user.environment_smash)
		for(var/mob/M in src)
			shatter(M)

/obj/structure/closet/statue/blob_act()
	for(var/mob/M in src)
		shatter(M)

/obj/structure/closet/statue/attackby(obj/item/I as obj, mob/user as mob)
	health -= I.force
	visible_message("<span class='warning'>[user] strikes [src] with [I].</span>")
	user.delayNextAttack(10)
	if(health <= 0)
		for(var/mob/M in src)
			shatter(M)

/obj/structure/closet/statue/place()
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

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

<<<<<<< HEAD
/obj/structure/closet/statue/proc/shatter()
	for(var/mob/living/M in src)
		M.dust()
	dump_contents()
	visible_message("<span class='danger'>[src] shatters!.</span>")
=======
/obj/structure/closet/statue/proc/shatter(mob/user as mob)
	if (user)
		user.gib()
	dump_contents()
	visible_message("<span class='warning'>[src] shatters into pieces!. </span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	qdel(src)

/obj/structure/closet/statue/container_resist()
	return
<<<<<<< HEAD

/mob/living/proc/petrify()
	if(istype(loc, /obj/structure/closet/statue)) //If they're already petrified
		return 0
	new /obj/structure/closet/statue(get_turf(src), src)
	return 1
=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

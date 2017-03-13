var/global/totaltribbles = 0

/mob/living/simple_animal/tribble
	name = "tribble"
	desc = "It's a small furry creature that makes a soft trill."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "tribble1"
	icon_living = "tribble1"
	icon_dead = "tribble1_dead"
	speak = list("Prrrrr...")
	speak_emote = list("purrs", "trills")
	emote_hear = list("shuffles", "purrs")
	emote_see = list("trundles around", "rolls")
	speak_chance = 10
	turns_per_move = 5
	maxHealth = 10
	health = 10
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "whacks"
	harm_intent_damage = 5
	var/gestation = 0
	var/maxtribbles = 50
	wander = 1

/mob/living/simple_animal/tribble/New()
	..()
	var/list/types = list("tribble1","tribble2","tribble3")
	src.icon_state = pick(types)
	src.icon_living = src.icon_state
	src.icon_dead = "[src.icon_state]_dead"
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)
	totaltribbles += 1

/obj/item/toy/tribble
	name = "tribble"
	desc = "It's a small furry creature that makes a soft trill."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "tribble1"
	item_state = "tribble1"
	var/gestation = 0

/obj/item/toy/tribble/attack_self(mob/user as mob)
	..()
	new /mob/living/simple_animal/tribble(user.loc)
	for(var/mob/living/simple_animal/tribble/T in user.loc)
		T.icon_state = src.icon_state
		T.icon_living = src.icon_state
		T.icon_dead = "[src.icon_state]_dead"
		T.gestation = src.gestation
		totaltribbles += 1

	user << "<span class='notice'>You place the tribble on the floor.</span>"
	del(src)

/obj/item/toy/tribble/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	..()
	if(istype(O, /obj/item/weapon/scalpel) && src.gestation != null)
		gestation = null
		user << "<span class='notice'>You neuter the tribble so that it can no longer re-produce.</span>"
	else if (istype(O, /obj/item/weapon/cautery) && src.gestation == null)
		gestation = 0
		user << "<span class='notice'>You fuse some recently cut tubes together, it should be able to reproduce again.</span>"

/mob/living/simple_animal/tribble/attack_hand(mob/user as mob)
	..()
	if(src.stat != DEAD)
		new /obj/item/toy/tribble(user.loc)
		for(var/obj/item/toy/tribble/T in user.loc)
			T.icon_state = src.icon_state
			T.item_state = src.icon_state
			T.gestation = src.gestation
			T.pickup(user)
			user.put_in_active_hand(T)
			totaltribbles -= 1
			del(src)

/mob/living/simple_animal/tribble/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/scalpel))
		gestation = null
		user << "<span class='notice'>You try to neuter the tribble so that it can no longer re-produce, but it's moving too much, and you fail!</span>"
	..()


/mob/living/simple_animal/tribble/proc/procreate()
	..()
	if(totaltribbles <= maxtribbles)
		for(var/mob/living/simple_animal/tribble/F in src.loc)
			if(!F || F == src)
				new /mob/living/simple_animal/tribble(src.loc)
				gestation = 0


/mob/living/simple_animal/tribble/Life()
	..()
	if(src.health > 0)
		if(gestation != null)
			if(gestation < 30)
				gestation++
			else if(gestation >= 30)
				if(prob(80))
					src.procreate()

/mob/living/simple_animal/tribble/Die()
	..()
	totaltribbles -= 1


/obj/structure/tribble
	name = "Lab Cage"
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "labcage1"
	desc = "A glass lab container for storing interesting creatures."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete tribble
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

/obj/structure/tribble/ex_act(severity)
	switch(severity)
		if (1)
			new /obj/item/weapon/shard( src.loc )
			Break()
			del(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()


/obj/structure/tribble/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	src.healthcheck()
	return


/obj/structure/tribble/blob_act()
	if (prob(75))
		new /obj/item/weapon/shard( src.loc )
		Break()
		del(src)


/obj/structure/tribble/meteorhit(obj/O as obj)
		new /obj/item/weapon/shard( src.loc )
		Break()
		del(src)


/obj/structure/tribble/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.density = 0
			src.destroyed = 1
			new /obj/item/weapon/shard( src.loc )
			playsound(src, "shatter", 70, 1)
			Break()
	else
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
	return

/obj/structure/tribble/update_icon()
	if(src.destroyed)
		src.icon_state = "labcageb[src.occupied]"
	else
		src.icon_state = "labcage[src.occupied]"
	return


/obj/structure/tribble/attackby(obj/item/weapon/W as obj, mob/user as mob)
	src.health -= W.force
	src.healthcheck()
	..()
	return

/obj/structure/tribble/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/tribble/attack_hand(mob/user as mob)
	if (src.destroyed)
		return
	else
		usr << text("\blue You kick the lab cage.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] kicks the lab cage.", usr)
		src.health -= 2
		healthcheck()
		return

/obj/structure/tribble/proc/Break()
	if(occupied)
		new /mob/living/simple_animal/tribble( src.loc )
		occupied = 0
	update_icon()
	return
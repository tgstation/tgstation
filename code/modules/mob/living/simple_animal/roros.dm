var/global/totalroros = 0   //global variable so it updates for all roros, not just the new one being made.


/mob/living/simple_animal/roro
	name = "roro"
	desc = "It's a small furry creature that makes a soft trill."
	icon = 'icons/mob/roros.dmi'
	icon_state = "roro1"
	icon_living = "roro1"
	icon_dead = "roro1_dead"
	speak = list("Prrrrr...")
	speak_emote = list("purrs", "trills")
	emote_hear = list("shuffles", "purrs")
	emote_see = list("trundles around", "rolls")
	speak_chance = 10
	turns_per_move = 5
	maxHealth = 10
	health = 10
	meat_type = /obj/item/stack/sheet/fur
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "whacks"
	harm_intent_damage = 5
	var/gestation = 0
	var/maxroros = 20     //change this to change the max limit
	wander = 1


/mob/living/simple_animal/roro/New()
	..()
	var/list/types = list("roro1","roro2","roro3")
	src.icon_state = pick(types)
	src.icon_living = src.icon_state
	src.icon_dead = "[src.icon_state]_dead"
	//random pixel offsets so they cover the floor
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)
	totalroros += 1


/mob/living/simple_animal/roro/attack_hand(mob/user as mob)
	..()
	if(src.stat != DEAD)
		new /obj/item/toy/roro(user.loc)
		for(var/obj/item/toy/roro/T in user.loc)
			T.icon_state = src.icon_state
			T.item_state = src.icon_state
			T.gestation = src.gestation
			T.pickup(user)
			user.put_in_active_hand(T)
			del(src)


/mob/living/simple_animal/roro/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/scalpel))
		user << "<span class='notice'>You try to neuter the roro, but it's moving too much and you fail!</span>"
	else if(istype(O, /obj/item/weapon/cautery))
		user << "<span class='notice'>You try to un-neuter the roro, but it's moving too much and you fail!</span>"
	..()


/mob/living/simple_animal/roro/proc/procreate()
	..()
	if(totalroros <= maxroros)
		for(var/mob/living/simple_animal/roro/F in src.loc)
			if(!F || F == src)
				new /mob/living/simple_animal/roro(src.loc)
				gestation = 0


/mob/living/simple_animal/roro/Life()
	..()
	if(src.health > 0) //no mostly dead procreation
		if(gestation != null) //neuter check
			if(gestation < 30)
				gestation++
			else if(gestation >= 30)
				if(prob(80))
					src.procreate()


/mob/living/simple_animal/roro/Die() // Gotta make sure to remove roros from the list on death
	..()
	totalroros -= 1


//||Item version of the trible ||
/obj/item/toy/roro
	name = "roro"
	desc = "It's a small furry creature that makes a soft trill."
	icon = 'icons/mob/roros.dmi'
	icon_state = "roro1"
	item_state = "roro1"
	w_class = 10.0
	var/gestation = 0

/obj/item/toy/roro/attack_self(mob/user as mob) //hug that roro (and play a sound if we add one)
	..()
	user << "<span class='notice'>You nuzzle the roro and it trills softly.</span>"

/obj/item/toy/roro/dropped(mob/user as mob) //now you can't item form them to get rid of them all so easily
	..()
	new /mob/living/simple_animal/roro(user.loc)
	for(var/mob/living/simple_animal/roro/T in user.loc)
		T.icon_state = src.icon_state
		T.icon_living = src.icon_state
		T.icon_dead = "[src.icon_state]_dead"
		T.gestation = src.gestation

	user << "<span class='notice'>The roro gets up and wanders around.</span>"
	del(src)

/obj/item/toy/roro/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob) //neutering and un-neutering
	..()
	if(istype(O, /obj/item/weapon/scalpel) && src.gestation != null)
		gestation = null
		user << "<span class='notice'>You neuter the roro so that it can no longer re-produce.</span>"
	else if (istype(O, /obj/item/weapon/cautery) && src.gestation == null)
		gestation = 0
		user << "<span class='notice'>You fuse some recently cut tubes together, it should be able to reproduce again.</span>"



//|| roro Cage - Lovingly lifted from the lamarr-cage ||
/obj/structure/roro_cage
	name = "Lab Cage"
	icon = 'icons/mob/roros.dmi'
	icon_state = "labcage1"
	desc = "A glass lab container for storing interesting creatures."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete roro
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

/obj/structure/roro_cage/ex_act(severity)
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


/obj/structure/roro_cage/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	src.healthcheck()
	return


/obj/structure/roro_cage/blob_act()
	if (prob(75))
		new /obj/item/weapon/shard( src.loc )
		Break()
		del(src)


/obj/structure/roro_cage/meteorhit(obj/O as obj)
		new /obj/item/weapon/shard( src.loc )
		Break()
		del(src)


/obj/structure/roro_cage/proc/healthcheck()
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

/obj/structure/roro_cage/update_icon()
	if(src.destroyed)
		src.icon_state = "labcageb[src.occupied]"
	else
		src.icon_state = "labcage[src.occupied]"
	return


/obj/structure/roro_cage/attackby(obj/item/weapon/W as obj, mob/user as mob)
	src.health -= W.force
	src.healthcheck()
	..()
	return

/obj/structure/roro_cage/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/roro_cage/attack_hand(mob/user as mob)
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

/obj/structure/roro_cage/proc/Break()
	if(occupied)
		new /mob/living/simple_animal/roro( src.loc )
		occupied = 0
	update_icon()
	return


//||Fur and Fur Products ||

/obj/item/stack/sheet/fur //basic fur sheets (very lumpy furry piles of sheets)
	name = "pile of fur"
	desc = "The by-product of roros."
	singular_name = "fur piece"
	icon = 'icons/mob/roros.dmi'
	icon_state = "sheet-fur"
	origin_tech = "materials=2"
	max_amount = 50

/obj/item/clothing/ears/earmuffs/roromuffs //earmuffs but with roros
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon = 'icons/mob/roros.dmi'
	icon_state = "roromuffs"
	item_state = "roromuffs"

/obj/item/clothing/gloves/furgloves
	desc = "These gloves are warm and furry."
	name = "fur gloves"
	icon = 'icons/mob/roros.dmi'
	icon_state = "furglovesico"
	item_state = "furgloves"

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT

/obj/item/clothing/head/furcap
	name = "fur cap"
	desc = "A warm furry cap."
	icon = 'icons/mob/roros.dmi'
	icon_state = "furcap"
	item_state = "furcap"

	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT

/obj/item/clothing/shoes/furboots
	name = "fur boots"
	desc = "Warm, furry boots."
	icon = 'icons/mob/roros.dmi'
	icon_state = "furboots"
	item_state = "furboots"

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT

/obj/item/clothing/suit/furcoat
	name = "fur coat"
	desc = "A trenchcoat made from fur. You could put an oxygen tank in one of the pockets."
	icon = 'icons/mob/roros.dmi'
	icon_state = "furcoat"
	item_state = "furcoat"
	blood_overlay_type = "armor"

	body_parts_covered = CHEST|LEGS|ARMS|GROIN
	allowed = list (/obj/item/weapon/tank/emergency_oxygen)
	cold_protection = CHEST | GROIN | LEGS | ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/furcape
	name = "fur cape"
	desc = "A cape made from fur. You'll really be stylin' now."
	icon = 'icons/mob/roros.dmi'
	icon_state = "furcape"
	item_state = "furcape"
	blood_overlay_type = "armor"

	body_parts_covered = CHEST|LEGS|ARMS
	cold_protection = CHEST | LEGS | ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT

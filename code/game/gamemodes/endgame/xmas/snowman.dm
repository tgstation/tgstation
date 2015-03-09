/mob/living/simple_animal/hostile/retaliate/snowman
	name = "snowman"
	desc = "Good day sir."
	icon_state = "snowman"
	icon_living = "snowman"
	icon_dead = ""
	icon='icons/mob/snowman.dmi'
	speak = list("Good day sir.","Would you happen to have a carrot for my nose?","Cold day, isn't it?","What a pleasant weather.")
	speak_emote = list("says")
	emote_hear = list("says")
	emote_see = list("hums")
	speak_chance = 2.5
	turns_per_move = 3
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "hugs"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"
	friendly = "hugs"
	faction = "snow"
	health = 40
	ranged = 1
	retreat_distance = 5
	minimum_distance = 3
	projectilesound = 'sound/weapons/punchmiss.ogg'
	projectiletype = /obj/item/projectile/snowball
	environment_smash = 0

	minbodytemp = 0
	maxbodytemp = MELTPOINT_SNOW
	heat_damage_per_tick = 5
	bodytemperature = 270

	var/obj/item/hat = null
	var/obj/item/carrot = null

/mob/living/simple_animal/hostile/retaliate/snowman/Life()
	..()
	if(!ckey && !stat)
		if(isturf(src.loc) && !resting && !buckled)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				Move(get_step(src,pick(4,8)))
				turns_since_move = 0

	if(!stat && enemies.len && prob(5))
		enemies = list()
		LoseTarget()
		src.say("Whatever.")

	if(stat)
		visible_message("<span class='game say'><span class='name'>[src.name]</span> murmurs, [pick("Oh my snowballs...","I will...be back...")]</span>")
		visible_message("\the [src] collapses in a pile of snow.")
		var/turf/T = get_turf(src)
		new /obj/item/stack/sheet/snow(T, 1)
		new /obj/item/stack/sheet/snow(T, 1)
		new /obj/item/stack/sheet/snow(T, 1)
		if(hat)
			hat.loc = T
		if(carrot)
			carrot.loc = T
		del(src)

	else if(fire_alert)
		src.say(pick("Oh god the heat...","I'm meltiiinggg...","Someone turn off the heater!"))

	regenerate_icons()

/mob/living/simple_animal/hostile/retaliate/snowman/Retaliate()
	..()
	if(!stat)
		src.say(pick("You, come fight me!","I say!","Coward!"))

/mob/living/simple_animal/hostile/retaliate/snowman/attackby(var/obj/item/W, var/mob/user)
	if(!carrot && istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/carrot))
		visible_message("<span class='notice'>[user] puts \a [W] on \the [src]'s nose.</span>")
		user.drop_item(src)
		carrot = W
		overlays += "snowman_carrot"
		speak -= "Would you happen to have a carrot for my nose?"
		src.say("Ah, most excellent!")
		if(prob(30))
			call(/obj/item/weapon/winter_gift/proc/pick_a_gift)(src.loc)

	else if(istype(W,/obj/item/clothing/head/))
		if(hat)
			hat.loc = get_turf(src)
			overlays -= image('icons/mob/head.dmi', hat.icon_state)
			hat = null
		else
			speak += "I feel so dandy!"
		user.drop_item(src)
		hat = W

		overlays += image('icons/mob/head.dmi', hat.icon_state)

	else	..()

/obj/item/projectile/snowball
	name = "flying snowball"
	desc = "Think fast!"
	icon = 'icons/obj/items.dmi'
	icon_state = "snow"
	nodamage = 1
	stun = 1
	weaken = 1
	stutter = 1

/obj/item/projectile/snowball/Bump(atom/A as mob|obj|turf|area)
	.=..()
	if(.)
		playsound(A.loc, "swing_hit", 50, 1)
		if(istype(A,/mob/living/carbon/))
			var/mob/living/carbon/C = A
			if(C.bodytemperature >= SNOWBALL_MINIMALTEMP)
				C.bodytemperature -= 5
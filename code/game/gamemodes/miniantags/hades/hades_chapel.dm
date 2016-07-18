/area/hades
	name = "Chapel of Sin"
	icon_state = "yellow"
	requires_power = 0
	has_gravity = 1

/turf/open/floor/plasteel/hades
	name = "Sin-touched Floor"
	icon_state = "cult"

/obj/structure/chair/hades
	name = "Cross of Hades"
	desc = "An inverted cross, with straps on it to support the weight of a living being."
	icon_state = "chair_hades"
	var/list/watchedSpikes = list()

/obj/structure/chair/hades/New()
	..()
	flags |= NODECONSTRUCT
	for(var/obj/structure/kitchenspike/KS in range(12))
		watchedSpikes += KS

/obj/structure/chair/hades/proc/considerReady()
	//buckled_mobs seems to work inconsistently, so we're doing some custom searching here.
	if(!buckled_mobs)
		return FALSE
	if(!buckled_mobs.len)
		return FALSE
	for(var/obj/structure/kitchenspike/KS in watchedSpikes)
		var/mob/living/M = locate(/mob/living) in get_turf(KS)
		if(!M)
			return FALSE
	return TRUE

/obj/structure/chair/hades/proc/completeRitual()
	for(var/obj/structure/kitchenspike/KS in watchedSpikes)
		var/mob/living/M = locate(/mob/living) in get_turf(KS)
		M.gib()
	playsound(get_turf(src), 'sound/effects/pope_entry.ogg', 100, 1)
	sleep(100)
	playsound(get_turf(src), 'sound/effects/hyperspace_end.ogg', 100, 1)
	new/obj/item/weapon/hades_staff/imbued(get_turf(src))
	src.visible_message("<span class='warning'>[src] shatters into a thousand shards, a staff falling from it.</span>")
	qdel(src)

/obj/structure/chair/hades/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/hades_staff))
		var/obj/item/weapon/hades_staff/HS = W
		if(!HS.isKey)
			return
		src.visible_message("<span class='warning'>[user] inserts the [W] into the [src], giving it a quick turn.</span>")
		if(considerReady())
			qdel(W)
			src.visible_message("<span class='warning'>[src] shudders, the sound of moving gears arising...</span>")
			for(var/mob/living/M in buckled_mobs)
				M.gib()
			for(var/i in 1 to 4)
				addtimer(GLOBAL_PROC, "playsound", i*10, FALSE, get_turf(src), 'sound/effects/clang.ogg', 100, 1)
			spawn(50)
				src.visible_message("<span class='warning'>[src] begins to lower into the ground...</span>")
				icon_state = "chair_hades_slide"
				addtimer(src, "completeRitual", 50, FALSE)
		else
			src.visible_message("<span class='warning'>[src] clunks, the sound of grinding gears arising. Nothing happens.</span>")

/obj/structure/ladder/unbreakable/hades
	name = "Dimensional Rift"
	desc = "Where does it lead?"
	icon = 'icons/mob/EvilPope.dmi'
	icon_state = "popedeath"
	anchored = TRUE

/obj/structure/ladder/unbreakable/hades/update_icon()
	return

/obj/item/weapon/paper/hades_instructions
	name = "paper- 'Hastily Scrawled Letter'"
	info = "The Master has instructed us to collect corpses for the ritual, and told us to deposity them in the Ritual Room, behind a bookcase in the library. The Master has locked the device to only work with his key, so no more accidents happen."

/obj/item/weapon/hades_staff
	name = "Staff of Hades"
	desc = "A large, dark staff, with a set of key-like prongs on the end."
	icon_state = "staffofchange"
	icon = 'icons/obj/guns/magic.dmi'
	item_state = "staffofchange"
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 25
	throwforce = 5
	w_class = 3
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slapped", "shattered", "blasphemed", "smashed", "whacked", "crushed", "hammered")
	block_chance = 25
	var/isKey = 1

/obj/item/weapon/hades_staff/fake
	name = "Inert Staff of Hades"
	desc = "A large, dark staff."
	isKey = 0

/obj/item/weapon/hades_staff/imbued
	name = "Imbued Staff of Hades"
	desc = " Bestowed with the power of wayward souls, this Staff allows the wielder to judge a target."
	force = 75
	throwforce = 35
	block_chance = 75
	var/lastJudge = 0
	var/judgeCooldown = 150

/obj/item/weapon/hades_staff/imbued/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(!istype(M))
		return ..()

	if(world.time > lastJudge + judgeCooldown)
		var/mob/living/sinPerson = M
		lastJudge = world.time
		var/sinPersonchoice = pick("Greed","Gluttony","Pride","Lust","Envy","Sloth","Wrath")

		src.say("Your sin, [sinPerson], is [sinPersonchoice].")
		var/isIndulged = prob(50)
		if(isIndulged)
			src.say("I will indulge your sin, [sinPerson].")
		else
			src.say("Your sin will be punished, [sinPerson]!")

		switch(sinPersonchoice)
			if("Greed")
				sin_Greed(sinPerson, isIndulged)
			if("Gluttony")
				sin_Gluttony(sinPerson, isIndulged)
			if("Pride")
				sin_Pride(sinPerson, isIndulged)
			if("Lust")
				sin_Lust(sinPerson, isIndulged)
			if("Envy")
				sin_Envy(sinPerson, isIndulged)
			if("Sloth")
				sin_Sloth(sinPerson, isIndulged)
			if("Wrath")
				sin_Wrath(sinPerson, isIndulged)
	else
		..()
		user << "The [src] is still recharging."

/obj/item/weapon/staff/hades
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

/obj/item/weapon/staff/hades/fake
	name = "Inert Staff of Hades"
	desc = "A large, dark staff."
	isKey = 0

/obj/item/weapon/staff/hades/imbued
	desc = "Bestowed with the power of wayward souls, this Staff allows the wielder to judge a target."
	throwforce = 20
	block_chance = 50
	var/lastJudge = 0
	var/judgeCooldown = 150

/obj/item/weapon/staff/hades/imbued/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
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
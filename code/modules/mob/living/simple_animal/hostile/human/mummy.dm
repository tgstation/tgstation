//Mummies
//Very slow mobs with a lot of health
//On death, create a cloud of toxins

/mob/living/simple_animal/hostile/humanoid/mummy
	name = "mummy"
	desc = "A mummified corpse of a common man, most likely a slave who was buried with their master."

	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "mummy"

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	health = 70
	maxHealth = 70

	move_to_delay = 20
	speed = 4

	melee_damage_lower = 3
	melee_damage_upper = 6
	stat_attack = UNCONSCIOUS //Attack unconscious dudes too

	faction = "mummy"
	corpse = /obj/effect/landmark/corpse/mummy

	heat_damage_per_tick = 20

/obj/effect/landmark/corpse/mummy
	name = "mummy"

	husk = 1
	corpseuniform = /obj/item/clothing/under/mummy_rags
	corpsehelmet = /obj/item/clothing/head/mummy_rags

/mob/living/simple_animal/hostile/humanoid/mummy/Die()
	if(!isturf(loc))
		return

	visible_message("<span class='danger'>\The [src] emits a cloud of miasma before being laid to rest.</span>")
	var/datum/effect/effect/system/smoke_spread/chem/rot/S = new /datum/effect/effect/system/smoke_spread/chem/rot
	S.attach(loc)
	S.set_up(src, 10, 0, loc)
	spawn(0)
		S.start()

	..()

/datum/effect/effect/system/smoke_spread/chem/rot/set_up(var/mob/M, n = 5, c = 0, loca, direct)
	if(n > 20)
		n = 20
	number = n
	cardinals = c

	chemholder.reagents.add_reagent(TOXIN, 40)
	chemholder.reagents.add_reagent(CYANIDE, 16)
	chemholder.reagents.add_reagent(BLACKCOLOR, 120) //For the color

	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct

//Mummy priests
//Less health than normal mummies, can curse their enemies with blindness, deafness, hallucinations or damage from distance

/mob/living/simple_animal/hostile/humanoid/mummy/priest
	name = "mummy priest"
	desc = "A mummified priest, wearing ceremonial garb. Death and pestilence follow him wherever he goes."
	icon_state = "mummy_priest"

	health = 40
	maxHealth = 40

	melee_damage_lower = 12
	melee_damage_upper = 15
	attacktext = "slices"

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5

	ranged_message = "invokes a curse"

	ranged_cooldown_cap = 30
	stat_attack = 0 //Only attack living dudes

	items_to_drop = list(/obj/item/weapon/hatchet/unathiknife)

/mob/living/simple_animal/hostile/humanoid/mummy/priest/Shoot()
	var/mob/living/L = target
	if(L.isUnconscious()) return

	switch(rand(0,3))
		if(0) //damage
			var/dmg = rand(10,20)
			to_chat(L, "<span class='userdanger'>Pain surges through your body!</span>")
			L.emote("scream", , , 1)
			L.adjustBruteLoss(dmg)
		if(1) //deaf
			var/mob/living/carbon/human/H = L
			if(!istype(H)) return

			H.ear_damage += rand(1, 3)

			if(H.ear_deaf <= 0)
				to_chat(L, "<span class='userdanger'>A horrifying scream deafens you!</span>")
				H.ear_deaf += rand(15,30)
				H << 'sound/effects/creepyshriek.ogg'
		if(2) //blindness
			L.flash_eyes(visual = 1)
			to_chat(L, "<span class='userdanger'>A flash blinds you for a moment!</span>")

			var/mob/living/carbon/human/H = L
			if(!istype(H)) return

			var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
			E.damage += rand(5,15)
		if(3) //hallucinations + brain damage
			var/mob/living/carbon/human/H = L
			if(!istype(H)) return

			to_chat(L, "<span class='userdanger'>Your mind feels weak.</span>")
			H.adjustBrainLoss(rand(1,12))
			H.hallucination += 20

	return 1

//Mummy warriors
//More health, they wield a spear and a shield. They're still slow though

/mob/living/simple_animal/hostile/humanoid/mummy/warrior
	name = "mummy warrior"
	desc = "A mummified warrior, wielding a buckler and a shield. It's his duty to protect the tomb from invaders."
	icon_state = "mummy_warrior"

	health = 100
	maxHealth = 100

	melee_damage_lower = 15
	melee_damage_upper = 20
	attacktext = "stabs"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	items_to_drop = list(/obj/item/weapon/shield/riot/buckler, /obj/item/weapon/spear/wooden)

//Mummy high priests
//A lot of health. Can shoot bolts of change and invoke a stronger version of mummy curses

/mob/living/simple_animal/hostile/humanoid/mummy/high_priest
	name = "mummy high priest"
	desc = "The high priest of Riniel. He is immune to fire, and he possesses the power to polymorph his foes."
	icon_state = "mummy_high_priest"

	health = 150
	maxHealth = 150

	melee_damage_lower = 15
	melee_damage_upper = 18
	attacktext = "slices"

	ranged = 1

	move_to_delay = 15 //Faster than normal mummies
	speed = 2

	ranged_message = "invokes a powerful curse"
	stat_attack = 0 //Only attack living dudes

	ranged_cooldown_cap = 20
	projectilesound = 'sound/weapons/radgun.ogg'
	projectiletype = /obj/item/projectile/change

	heat_damage_per_tick = 0

	items_to_drop = list(/obj/item/weapon/hatchet/unathiknife, /obj/item/weapon/coin/adamantine)

/mob/living/simple_animal/hostile/humanoid/mummy/high_priest/Shoot()
	if(prob(50)) //50% chance to shoot a normal projectile
		return ..()

	var/mob/living/L = target
	if(L.isUnconscious()) return

	switch(rand(0,3))
		if(0) //damage
			var/dmg = rand(10,20)
			to_chat(L, "<span class='userdanger'>You writhe in agony!</span>")
			L.emote("scream", , , 1)
			L.adjustBruteLoss(dmg)
		if(1) //deaf
			var/mob/living/carbon/human/H = L
			if(!istype(H)) return

			H.ear_damage += rand(3, 6)

			if(H.ear_deaf <= 0)
				to_chat(L, "<span class='userdanger'>A horrifying scream deafens you!</span>")
				H.ear_deaf += rand(30,45)
				H << 'sound/effects/creepyshriek.ogg'
		if(2) //blindness
			L.flash_eyes(visual = 1)
			to_chat(L, "<span class='userdanger'>A flash blinds you!</span>")

			var/mob/living/carbon/human/H = L
			if(!istype(H)) return

			var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
			E.damage += rand(15,30)
		if(3) //hallucinations + brain damage
			var/mob/living/carbon/human/H = L
			if(!istype(H)) return

			to_chat(L, "<span class='userdanger'>Your mind is crumbling.</span>")
			H.adjustBrainLoss(rand(6,24))
			H.hallucination += 40

	return 1

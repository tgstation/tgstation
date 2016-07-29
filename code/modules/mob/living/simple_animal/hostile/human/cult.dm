/mob/living/simple_animal/hostile/humanoid/cult
	name = "cultist"
	desc = "A humble servant of Nar-Sie."

	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "cultist"

	corpse = /obj/effect/landmark/corpse/cult
	faction = "cult"

//Champion of Nar-Sie - melee fighter
/mob/living/simple_animal/hostile/humanoid/cult/champion
	name = "champion of Nar-Sie"
	desc = "A trained fighter, he wields a cult blade to spread the word of Nar-Sie through fire and sword."

	icon_state = "cultist_armor"
	visible_items = list('icons/mob/in-hand/right/items_righthand.dmi' = "cultblade")

	melee_damage_lower = 20
	melee_damage_upper = 35
	attacktext = "stabbed"
	attack_sound = 'sound/weapons/bloodyslice.ogg'

	corpse = /obj/effect/landmark/corpse/cult/champion
	items_to_drop = list(/obj/item/weapon/melee/cultblade)

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0

//Priest of Nar-Sie - stays back, uses cult magic (EMP, deafening, damage)
/mob/living/simple_animal/hostile/humanoid/cult/priest
	name = "priest of Nar-Sie"
	desc = "A servant of Nar-Sie, trained in blood magic. He can summon EMPs, deafen nearby foes or smite them with unholy power."

	icon_state = "cultist_hood"
	visible_items = list('icons/mob/in-hand/right/items_righthand.dmi' = "necrostaff")

	corpse = /obj/effect/landmark/corpse/cult/priest

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5

	ranged_message = "invokes a curse"

	ranged_cooldown_cap = 9

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0

/mob/living/simple_animal/hostile/humanoid/cult/priest/Shoot()
	var/mob/living/L = target
	if(L.isUnconscious()) return

	switch(rand(0,2))
		if(0) //damage
			var/dmg = rand(10,20)
			to_chat(L, "<span class='userdanger'>Pain surges through your body and horrible visions flash through your mind!</span>")
			L.emote("scream", , , 1)
			L.adjustBruteLoss(dmg)
		if(1) //deaf
			var/mob/living/carbon/human/H = L
			if(!istype(H)) return

			H.ear_damage += rand(1, 3)

			if(H.ear_deaf <= 0)
				to_chat(L, "<span class='userdanger'>All of the sudden, horrifying screams start filling your head. You can't hear anything else aside from them!</span>")
				H.ear_deaf += rand(3,10)
				H << 'sound/effects/creepyshriek.ogg'
		if(2) //emp
			empulse(get_turf(src), 3, 5, 7)

/obj/effect/landmark/corpse/cult
	name = "cultist"
	corpseshoes = /obj/item/clothing/shoes/cult
	corpsesuit = /obj/item/clothing/suit/cultrobes
	corpsemask = /obj/item/clothing/mask/gas/death_commando
	corpseback = /obj/item/weapon/storage/backpack/cultpack

/obj/effect/landmark/corpse/cult/New()
	corpseuniform = existing_typesof(/obj/item/clothing/under/color)

	return ..()

/obj/effect/landmark/corpse/cult/champion
	name = "champion of Nar-Sie"

	corpsesuit = /obj/item/clothing/suit/space/cult
	corpsehelmet = /obj/item/clothing/head/helmet/space/cult

/obj/effect/landmark/corpse/cult/priest
	name = "priest of Nar-Sie"

	corpsehelmet = /obj/item/clothing/head/culthood

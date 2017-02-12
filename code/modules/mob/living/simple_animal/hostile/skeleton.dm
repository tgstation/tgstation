/mob/living/simple_animal/hostile/skeleton
	name = "reanimated skeleton"
	desc = "A real bonefied skeleton, doesn't seem like it wants to socialize."
	icon_state = "skeleton"
	icon_living = "skeleton"
	icon_dead = "skeleton"
	gender = NEUTER
	turns_per_move = 5
	speak_emote = list("rattles")
	emote_see = list("rattles")
	a_intent = INTENT_HARM
	maxHealth = 40
	health = 40
	speed = 1
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	minbodytemp = 0
	maxbodytemp = 1500
	healable = 0 //they're skeletons how would bruise packs help them??
	attacktext = "slashes"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	robust_searching = 1
	stat_attack = 1
	gold_core_spawnable = 1
	faction = list("skeleton")
	see_invisible = SEE_INVISIBLE_MINIMUM
	see_in_dark = 8
	deathmessage = "collapses into a pile of bones!"
	del_on_death = 1
	loot = list(/obj/effect/decal/remains/human)

/mob/living/simple_animal/hostile/skeleton/eskimo
	name = "undead eskimo"
	desc = "The reanimated remains of some poor traveler."
	icon_state = "eskimo"
	icon_living = "eskimo"
	icon_dead = "eskimo_dead"
	maxHealth = 55
	health = 55
	gold_core_spawnable = 0
	melee_damage_lower = 17
	melee_damage_upper = 20
	deathmessage = "collapses into a pile of bones, its gear falling to the floor!"
	loot = list(/obj/effect/decal/remains/human,
				/obj/item/weapon/twohanded/spear,
				/obj/item/clothing/shoes/winterboots,
				/obj/item/clothing/suit/hooded/wintercoat)


/mob/living/simple_animal/hostile/skeleton/templar
	name = "undead templar"
	desc = "The reanimated remains of a holy templar knight."
	icon_state = "templar"
	icon_living = "templar"
	icon_dead = "templar_dead"
	maxHealth = 150
	health = 150
	speed = 2
	gold_core_spawnable = 0
	speak_chance = 1
	speak = list("THE GODS WILL IT!","DEUS VULT!","REMOVE KABAB!")
	force_threshold = 10 //trying to simulate actually having armor
	obj_damage = 50
	melee_damage_lower = 25
	melee_damage_upper = 30
	deathmessage = "collapses into a pile of bones, its gear clanging as it hits the ground!"
	loot = list(/obj/effect/decal/remains/human,
				/obj/item/clothing/suit/armor/riot/knight/templar,
				/obj/item/clothing/head/helmet/knight/templar,
				/obj/item/weapon/claymore/weak{name = "holy sword"})

/mob/living/simple_animal/hostile/skeleton/ice
	name = "ice skeleton"
	desc = "A reanimated skeleton protected by a thick sheet of natural ice armor. Looks slow, though."
	speed = 5
	maxHealth = 75
	health = 75
	color = rgb(114,228,250)
	loot = list(/obj/effect/decal/remains/human{color = rgb(114,228,250)})
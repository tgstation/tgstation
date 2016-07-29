/mob/living/simple_animal/hostile/humanoid/diona
	name = "diona"
	desc = "A grown diona. It's very slow."

	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "diona"

	heat_damage_per_tick = 10
	cold_damage_per_tick = 0

	health = 140
	maxHealth = 140

	move_to_delay = 30
	speed = 5

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 0

	faction = "diona"

	corpse = /obj/effect/landmark/corpse/diona

/mob/living/simple_animal/hostile/humanoid/diona/Life()
	.=..()

	if(health < maxHealth)
		health++

/mob/living/simple_animal/hostile/humanoid/diona/spearman
	name = "diona spearman"
	desc = "A grown diona, armed with a crude spear."

	visible_items = list('icons/mob/in-hand/right/items_righthand.dmi' = "spearglass1")

	attacktext = "impales"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	melee_damage_lower = 14
	melee_damage_upper = 18

	corpse = /obj/effect/landmark/corpse/diona
	items_to_drop = list(/obj/item/weapon/spear)

/mob/living/simple_animal/hostile/humanoid/diona/junkie //based on a true story
	name = "diona chemist"
	desc = "A grown diona, with a mask on its face, a tank on its back and a hatchet in each of its hands. A bunch of tubes are constantly injecting a toxic green fluid into it."
	icon_state = "diona_chemist"

	health = 180
	maxHealth = 180

	move_to_delay = 2
	speed = -1

	attacktext = "chops"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	melee_damage_lower = 6
	melee_damage_upper = 12

	corpse = /obj/effect/landmark/corpse/diona/junkie
	items_to_drop = list(/obj/item/weapon/hatchet, /obj/item/weapon/hatchet)

/mob/living/simple_animal/hostile/humanoid/diona/junkie/AttackingTarget() //Dual wielding hatchets ftw
	target.attack_animal(src)

	spawn(5)
		target.attack_animal(src)

/obj/effect/landmark/corpse/diona
	name = "diona"
	mutantrace = "Diona"
	burn_dmg = 60 //these fuckers resurrect without this

/obj/effect/landmark/corpse/diona/junkie
	corpsesuit = /obj/item/clothing/suit/storage/labcoat/chemist
	corpseback = /obj/item/weapon/reagent_containers/chempack
	corpseshoes = /obj/item/clothing/shoes/swat
	corpsegloves = /obj/item/clothing/gloves/swat

	toxin_dmg = 1300

/obj/effect/landmark/corpse/diona/junkie/New()
	..()

	var/turf/T = get_turf(src)
	T.visible_message("<span class='danger'>Some green fluid flows out of the chemical pack!</span>") //because the pack spawns empty
	getFromPool(/obj/effect/decal/cleanable/greenglow, T)

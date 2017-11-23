/mob/living/simple_animal/hostile/netherworld
	name = "creature"
	desc = "A sanity-destroying otherthing from the netherworlds."
	icon_state = "otherthing"
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	health = 80
	maxHealth = 80
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 50
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("creature")
	speak_emote = list("screams")
	gold_core_spawnable = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

/mob/living/simple_animal/hostile/netherworld/migo
	name = "mi-go"
	desc = "A pinkish, fungoid crustacean-like creature with numerous pairs of clawed appendages and a head covered with waving antennae."
	icon_state = "mi-go"
	icon_living = "mi-go"
	icon_dead = "mi-go-dead"
	attacktext = "lacerates"
	var/list/migo_sounds

/mob/living/simple_animal/hostile/netherworld/migo/Initialize()
    . = ..()
    migo_sounds = world.file2list("strings/migo_sounds.txt")

/mob/living/simple_animal/hostile/netherworld/migo/say()
	..()
	var/chosen_sound = pick(migo_sounds)

/mob/living/simple_animal/hostile/netherworld/migo/Life()
	..()
	if(prob(10))
		var/chosen_sound = pick(migo_sounds)

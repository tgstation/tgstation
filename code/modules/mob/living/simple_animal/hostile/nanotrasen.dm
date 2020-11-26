/mob/living/simple_animal/hostile/nanotrasen
	name = "\improper Nanotrasen Private Security Officer"
	desc = "An officer part of Nanotrasen's private security force, he seems rather unpleased to meet you."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "nanotrasen"
	icon_living = "nanotrasen"
	icon_dead = null
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	speak_chance = 0
	turns_per_move = 5
	speed = 0
	stat_attack = HARD_CRIT
	robust_searching = 1
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 15
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	loot = list(/obj/effect/mob_spawn/human/corpse/nanotrasensoldier)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list(ROLE_DEATHSQUAD)
	check_friendly_fire = TRUE
	status_flags = CANPUSH
	del_on_death = TRUE
	dodging = TRUE
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/nanotrasen/screaming
	icon_state = "nanotrasen"
	icon_living = "nanotrasen"

/mob/living/simple_animal/hostile/nanotrasen/screaming/Aggro()
	..()
	summon_backup(15)
	say("411 in progress, requesting backup!")


/mob/living/simple_animal/hostile/nanotrasen/ranged
	icon_state = "nanotrasenranged"
	icon_living = "nanotrasenranged"
	ranged = 1
	retreat_distance = 3
	minimum_distance = 5
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/gun/pistol/shot_alt.ogg'


/mob/living/simple_animal/hostile/nanotrasen/ranged/smg
	icon_state = "nanotrasenrangedsmg"
	icon_living = "nanotrasenrangedsmg"
	rapid = 3
	casingtype = /obj/item/ammo_casing/c46x30mm
	projectilesound = 'sound/weapons/gun/smg/shot.ogg'

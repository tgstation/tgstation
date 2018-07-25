/mob/living/simple_animal/hostile/zombie
	name = "Sickly looking individual."
	desc = "Needs a hug."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "syndicate"
	icon_living = "syndicate"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speak_chance = 0
	stat_attack = UNCONSCIOUS //braains
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	status_flags = CANPUSH
	del_on_death = 1
	var/zombiejob = "Medical Doctor"
	var/infection_chance = 0
	var/obj/effect/mob_spawn/human/corpse/delayed/corpse

/mob/living/simple_animal/hostile/zombie/Initialize(mapload)
	. = ..()
	setup_visuals()

/mob/living/simple_animal/hostile/zombie/proc/setup_visuals()
	var/datum/preferences/dummy_prefs = new
	dummy_prefs.pref_species = new /datum/species/zombie
	dummy_prefs.be_random_body = TRUE
	var/datum/job/J = SSjob.GetJob(zombiejob)
	var/icon/P = get_flat_human_icon("zombie_[zombiejob]", J , dummy_prefs, "zombie")
	icon = P
	corpse = new(src)
	corpse.outfit = J.outfit
	corpse.mob_species = /datum/species/zombie
	corpse.mob_name = name

/mob/living/simple_animal/hostile/zombie/AttackingTarget()
	. = ..()
	if(. && ishuman(target) && prob(infection_chance))
		try_to_zombie_infect(target)

/mob/living/simple_animal/hostile/zombie/drop_loot()
	. = ..()
	corpse.forceMove(drop_location())
	corpse.create()
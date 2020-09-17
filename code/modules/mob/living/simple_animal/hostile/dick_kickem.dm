/mob/living/simple_animal/hostile/dick_kickem
	name = "DICK KICKEM"
	desc = "HE'S HERE TO EAT ASS."
	icon = 'icons/mob/dick_kickem.dmi'
	icon_state = "dick"
	icon_living = "dick"
	icon_dead = "dead"
	gender = MALE

	maxHealth = 2000
	health = 2000
	turns_per_move = 5

	melee_damage_lower = 20
	melee_damage_upper = 25
	attack_verb_simple = "kick"
	attack_verb_continuous = "kicks"
	speak_emote = list("yells")
	attack_sound = 'sound/effects/hit_punch.ogg'
	speak = list(
			"SOME PEOPLE CALL ME AN ASSHOLE. IT'S BECAUSE THERE IS A HOLE IN MY ASS.",
			"YEAH YOU KEEP SHITTING YOURSELF.",
			"I'M JUST ANOTHER HUGE FAT BITCH IN A SEA OF GAMERS.",
			"OH, YOU THINK YOU'RE HOT SHIT?",
			"ANIME? MORE LIKE HAVE TO PEE.",
			"IT'S TIME TO GET NUDE AND BE OUTDOORS.",
			"I'M HERE TO KICK.",
			"IT'S TIME TO ASS.",
			"I'M DICK KICKEM.",
			"I'M GOING TO MAINTAIN AN ERECTION.",
			"I'M GOING TO RIP OFF YOUR HEAD AND FAINT AT THE SIGHT OF BLOOD.",
			"THOSE DAMN ALIEN BASTARDS FUCKED MY CAR.",
			"IT'S TIME TO KICK GUM AND CHEW ASS. AND I'M ALL OUT OF ASS."
		)
	speak_chance = 20

	// Immune admin spawn
	footstep_type = FOOTSTEP_MOB_SHOE
	weather_immunities = list("lava","ash")
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	loot = list(/obj/effect/decal/remains/human)
	environment_smash = ENVIRONMENT_SMASH_NONE

	var/base_melee_damage = 20
	var/dick_melee_damage_modifier = 5

/mob/living/simple_animal/hostile/dick_kickem/SelectTargetZone()
	zone_selected = BODY_ZONE_PRECISE_GROIN

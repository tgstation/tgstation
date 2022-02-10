/mob/living/simple_animal/hostile/zombie
	name = "Shambling Corpse"
	desc = "When there is no more room in hell, the dead will walk in outer space."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "zombie"
	icon_living = "zombie"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	speak_chance = 0
	stat_attack = HARD_CRIT //braains
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 21
	melee_damage_upper = 21
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	combat_mode = TRUE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	status_flags = CANPUSH
	del_on_death = 1
	var/zombiejob = JOB_MEDICAL_DOCTOR
	var/infection_chance = 0

/mob/living/simple_animal/hostile/zombie/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, .proc/setup_visuals)

/mob/living/simple_animal/hostile/zombie/proc/setup_visuals()
	var/datum/job/job = SSjob.GetJob(zombiejob)

	var/datum/outfit/outfit = new job.outfit
	outfit.l_hand = null
	outfit.r_hand = null

	var/mob/living/carbon/human/dummy/dummy = new
	dummy.equipOutfit(outfit)
	dummy.set_species(/datum/species/zombie)
	COMPILE_OVERLAYS(dummy)
	icon = getFlatIcon(dummy)
	qdel(dummy)

/mob/living/simple_animal/hostile/zombie/AttackingTarget()
	. = ..()
	if(. && ishuman(target) && prob(infection_chance))
		try_to_zombie_infect(target)

/mob/living/simple_animal/hostile/retaliate/dolphin
	name = "space dolphin"
	desc = "That's LIEUTENANT commander to you!" //sounds like a reference but is not
	icon = 'icons/mob/broadMobs.dmi'
	icon_state = "dolp"
	icon_living = "dolp"
	icon_dead = "dolp_dead"
	icon_gib = "dolp_gib"
	pixel_x = -16
	mob_size = MOB_SIZE_LARGE
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/organ/brain = 4) //dolphins are intelligent beings
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	emote_taunt = list("gnashes")
	taunt_chance = 30
	speed = 0
	maxHealth = 60 //as strong as megacarp
	health = 60
	a_intent = "harm"

	environment_smash = 0
	harm_intent_damage = 8
	melee_damage_lower = 20 //dolphins are bitches
	melee_damage_upper = 20
	pass_flags = PASSTABLE
	attacktext = "bites"
	attack_sound = 'sound/creatures/dolphinasshole.ogg'
	speak_emote = list("Chitters", "Squeeks", "Clicks")


	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500

	faction = list("dolphin")
	flying = 1

/mob/living/simple_animal/hostile/retaliate/dolphin/Process_Spacemove(movement_dir = 0)
	return 1

/mob/living/simple_animal/hostile/retaliate/dolphin/AttackingTarget()
	..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjustStaminaLoss(8)

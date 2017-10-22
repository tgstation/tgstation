/mob/living/simple_animal/hostile/vampire_bat
	name = "vampire bat"
	desc = "A bat that sucks blood. Keep away from medical bays."
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	turns_per_move = 1
	response_help = "brushes aside"
	response_disarm = "flails at"
	response_harm = "hits"
	speak_chance = 0
	maxHealth = 20
	health = 20
	see_in_dark = 10
	harm_intent_damage = 7
	melee_damage_lower = 5
	melee_damage_upper = 7
	attacktext = "bites"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 1)
	pass_flags = PASSTABLE
	faction = list("hostile", "vampire")
	attack_sound = 'sound/weapons/bite.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	movement_type = FLYING
	speak_emote = list("squeaks")
	var/max_co2 = 0 //to be removed once metastation map no longer use those for Sgt Araneus
	var/min_oxy = 0
	var/max_tox = 0

	var/mob/living/controller


	//Space bats need no air to fly in.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

/mob/living/simple_animal/hostile/vampire_bat/CanAttack(atom/the_target)
	. = ..()
	if(isliving(the_target) && is_vampire(the_target))
		return FALSE

/mob/living/simple_animal/hostile/vampire_bat/death()
	if(isliving(controller))
		controller.loc = loc
		mind.transfer_to(controller)
		controller.Knockdown(120)
		to_chat(controller, "<span class='userdanger'>The force of being exiled from your bat form knocks you down!</span>")
	. = ..()
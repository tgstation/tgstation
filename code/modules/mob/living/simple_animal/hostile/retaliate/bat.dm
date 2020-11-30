/mob/living/simple_animal/hostile/retaliate/bat
	name = "Space Bat"
	desc = "A rare breed of bat which roosts in spaceships, probably not vampiric."
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	turns_per_move = 1
	response_help_continuous = "brushes aside"
	response_help_simple = "brush aside"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_chance = 0
	maxHealth = 15
	health = 15
	see_in_dark = 10
	harm_intent_damage = 6
	melee_damage_lower = 6
	melee_damage_upper = 5
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	butcher_results = list(/obj/item/food/meat/slab = 1)
	pass_flags = PASSTABLE
	faction = list("hostile")
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
	//Space bats need no air to fly in.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

/mob/living/simple_animal/hostile/retaliate/bat/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)

/mob/living/simple_animal/hostile/retaliate/bat/sgt_araneus //Despite being a bat for... reasons, this is now a spider, and is one of the HoS' pets.
	name = "Sergeant Araneus"
	real_name = "Sergeant Araneus"
	desc = "A fierce companion of the Head of Security, this spider has been carefully trained by Nanotrasen specialists. Its beady, staring eyes send shivers down your spine."
	emote_hear = list("chitters")
	faction = list("spiders")
	harm_intent_damage = 3
	health = 200
	icon_dead = "guard_dead"
	icon_gib = "guard_dead"
	icon_living = "guard"
	icon_state = "guard"
	maxHealth = 250
	max_co2 = 5
	max_tox = 2
	melee_damage_lower = 15
	melee_damage_upper = 20
	min_oxy = 5
	movement_type = GROUND
	response_help_continuous = "pets"
	response_help_simple = "pet"
	turns_per_move = 10
	pet_bonus = TRUE
	pet_bonus_emote = "chitters proudly!"

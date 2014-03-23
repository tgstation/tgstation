/mob/living/simple_animal/hostile/retaliate/bat
	name = "Space Bat"
	desc = "A rare breed of bat which roosts in spaceships, probably not vampiric."
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	turns_per_move = 1
	response_help = "brushes aside"
	response_disarm = "flails at"
	response_harm = "hits"
	speak_chance = 0
	a_intent = "harm"
	stop_automated_movement_when_pulled = 0
	maxHealth = 15
	health = 15
	see_in_dark = 10
	harm_intent_damage = 6
	melee_damage_lower = 6
	melee_damage_upper = 5
	attacktext = "bites"
	pass_flags = PASSTABLE
	faction = "carp"
	attack_sound = 'sound/weapons/bite.ogg'
	environment_smash = 0
	ventcrawler = 2


	//Space bats need no air to fly in.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
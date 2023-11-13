//Standard
/mob/living/simple_animal/hostile/guardian/standard
	damage_coeff = list(BRUTE = 0.5, BURN = 0.5, TOX = 0.5, CLONE = 0.5, STAMINA = 0, OXY = 0.5)
	melee_damage_lower = 20
	melee_damage_upper = 20
	wound_bonus = -5 //you can wound!
	obj_damage = 80
	next_move_modifier = 0.8 //attacks 20% faster
	environment_smash = ENVIRONMENT_SMASH_WALLS
	playstyle_string = span_holoparasite("As a <b>standard</b> type you have no special abilities, but have a high damage resistance and a powerful attack capable of smashing through walls.")
	magic_fluff_string = span_holoparasite("..And draw the Assistant, faceless and generic, but never to be underestimated.")
	tech_fluff_string = span_holoparasite("Boot sequence complete. Standard combat modules loaded. Holoparasite swarm online.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! You caught one! It's really boring and standard. Better punch some walls to ease the tension.")
	miner_fluff_string = span_holoparasite("You encounter... Adamantine, a powerful attacker.")
	creator_name = "Standard"
	creator_desc = "Devastating close combat attacks and high damage resistance. Can smash through weak walls."
	creator_icon = "standard"
	/// The text we shout when attacking.
	var/battlecry = "AT"

/mob/living/simple_animal/hostile/guardian/standard/verb/Battlecry()
	set name = "Set Battlecry"
	set category = "Guardian"
	set desc = "Choose what you shout as you punch people."
	var/input = tgui_input_text(src, "What do you want your battlecry to be?", "Battle Cry", max_length = 6)
	if(input)
		battlecry = input

/mob/living/simple_animal/hostile/guardian/standard/AttackingTarget(atom/attacked_target)
	. = ..()
	if(!isliving(target) || attacked_target == src)
		return
	var/msg = ""
	for(var/i in 1 to 9)
		msg += battlecry
	say("[msg]!!", ignore_spam = TRUE)
	for(var/j in 1 to 4)
		addtimer(CALLBACK(src, PROC_REF(do_attack_sound), target.loc), j)

/mob/living/simple_animal/hostile/guardian/standard/proc/do_attack_sound(atom/playing_from)
	playsound(playing_from, attack_sound, 50, TRUE, TRUE)

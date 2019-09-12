//ZA WARUDO = FULP CODE
/mob/living/simple_animal/hostile/guardian/timestop
	melee_damage_lower = 20
	melee_damage_upper = 20
	damage_coeff = list(BRUTE = 1.5, BURN = 2.0, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0) // Bloodsuckers do not take toxin, oxy, and clone rarely shows up anyway.
	obj_damage = 80
	speed = -1
	next_move_modifier = 0.6 //attacks 40% faster using the power of TIME MANIPULATION
	environment_smash = ENVIRONMENT_SMASH_WALLS // The World IS a standard type like star platinum but more skilled in stopping time and in ways more powerful due to the unique biology of their host.
	playstyle_string = "<span class='holoparasite'>As a <b>time manipulation</b> type you can stop time and you have a damage multiplier instead of armor as-well as powerful melee attacks capable of smashing through walls.</span>"
	magic_fluff_string = "<span class='holoparasite'>...And draw... The World, through sheer luck or perhaps destiny, maybe even your own physiology. Manipulator of time, a guardian powerful enough to control THE WORLD!.</span>"
	tech_fluff_string = "<span class='holoparasite'>ERROR...  T$M3 M4N!PULA%I0N modules loaded. Holoparasite swarm online.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! You caught one! It's imbued with the power of Carp'Sie herself. Time to rule THE WORLD!.</span>"
	var/battlecry = "MUDA"

/mob/living/simple_animal/hostile/guardian/timestop/verb/Battlecry()
	set name = "Set Battlecry"
	set category = "Guardian"
	set desc = "Choose what you shout as you punch people."
	var/input = stripped_input(src,"What do you want your battlecry to be? Max length of 6 characters.", ,"", 7)
	if(input)
		battlecry = input





/mob/living/simple_animal/hostile/guardian/timestop/AttackingTarget()
	. = ..()
	if(isliving(target))
		say("[battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry]!!", ignore_spam = TRUE)
		playsound(loc, src.attack_sound, 50, TRUE, TRUE)
		playsound(loc, src.attack_sound, 50, TRUE, TRUE)
		playsound(loc, src.attack_sound, 50, TRUE, TRUE)
		playsound(loc, src.attack_sound, 50, TRUE, TRUE)

/mob/living/simple_animal/hostile/guardian/timestop/Initialize()
	. = ..()
	mob_spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/guardian

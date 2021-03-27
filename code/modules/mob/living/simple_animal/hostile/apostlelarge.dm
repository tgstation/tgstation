/mob/living/simple_animal/hostile/largeapostle //what they all should have
	name = "Apostle"
	desc = "if you read this i fucked up and also you're gay"
	icon = 'icons/mob/largeapostles.dmi'
	vision_range = 20
	pixel_x = -16
	weather_immunities = list("lava","ash")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	robust_searching = 1
	mob_size = MOB_SIZE_HUGE
	del_on_death = TRUE
	layer = LARGE_MOB_LAYER
	deathmessage = "fades away into nothing..."
	faction = list("neutral","silicon","turret","sabbatziege")


/mob/living/simple_animal/hostile/largeapostle/khamael
	name = "Khamael"
	desc = "One blessed by Sabbatziege's mercy. It can knock anything over with the strength of its love."
	icon_state = "khamael"
	health = 800
	maxHealth = 800
	vision_range = 5
	wander = 1
	robust_searching = 1
	health = 800
	maxHealth = 800
	armour_penetration = 30
	melee_damage_lower = 30
	melee_damage_upper = 70
	ranged = 1
	ranged_message = "charges"
	attack_verb_continuous = "devours"
	attack_verb_simple = "devour"
	var/range = 10
	var/charging = 0
	var/aggressive_message_said = FALSE

/mob/living/simple_animal/hostile/largeapostle/khamael/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(health > maxHealth*0.5)
		rapid_melee = initial(rapid_melee)
		return
	if(!aggressive_message_said && target)
		visible_message("<span class='danger'>[name] stands more upright and stares at [target]!</span>")
		aggressive_message_said = TRUE
	rapid_melee = 2

/mob/living/simple_animal/hostile/largeapostle/khamael/OpenFire(atom/A)
	if(!charging)
		visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")
		ranged_cooldown = world.time + ranged_cooldown_time
		Shoot(A)

/mob/living/simple_animal/hostile/largeapostle/khamael/Shoot(atom/targeted_atom)
	charging = 1
	throw_at(targeted_atom, range, 1, src, FALSE, TRUE, callback = CALLBACK(src, .proc/charging_end))

/mob/living/simple_animal/hostile/largeapostle/khamael/proc/charging_end()
	charging = 0

/mob/living/simple_animal/hostile/largeapostle/khamael/Life()
	. = ..()
	if(!. || target)
		return
	adjustHealth(-maxHealth*0.025)
	aggressive_message_said = FALSE

/mob/living/simple_animal/hostile/largeapostle/tzaphkiel
	name = "Tzaphkiel"
	desc = "One blessed by Sabbatziege's mercy. It removes the sin of others with its many hands."
	icon_state = "tzaphkiel"
	health = 500
	maxHealth = 500
	attack_verb_continuous = "rips apart"
	attack_verb_simple = "rips apart"
	armour_penetration = 30
	melee_damage_lower = 30
	melee_damage_upper = 50

/mob/living/simple_animal/hostile/largeapostle/raphael
	name = "Raphael"
	icon = 'icons/mob/largeapostles_raphael.dmi'
	desc = "One blessed by Sabbatziege's mercy. It feeds on your sin and redeems you, should you let it."
	icon_state = "raphael"
	health = 100
	maxHealth = 100
	armour_penetration = 0
	melee_damage_lower = 0
	melee_damage_upper = 0


/mob/living/simple_animal/hostile/largeapostle/raphael/pet
	desc = "And to think I wanted to kill you two times, in this timeloop you have become my friend.. I love you Raphael."
	ventcrawler = VENTCRAWLER_ALWAYS
	health = 50
	maxHealth = 50
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	pet_bonus = TRUE
	pet_bonus_emote = "cries!"
	speak = list("eugh!", "Esp!", "Brlb", "Plip")
	speak_emote = list("bubbles", "pops")
	emote_hear = list("sizzles.", "bubbles.")
	emote_see = list("shudders.", "shivers.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6

/mob/living/simple_animal/hostile/largeapostle/tzadkiel
	name = "Tzadkiel"
	desc = "One blessed by Sabbatziege's mercy. It holds down its subjects with the love of the Lord."
	icon_state = "tzadkiel"
	health = 1000
	maxHealth = 1000
	attack_verb_continuous = "destroys"
	attack_verb_simple = "destroys"
	armour_penetration = 30
	melee_damage_lower = 50
	melee_damage_upper = 70

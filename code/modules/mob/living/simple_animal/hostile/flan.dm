//Will probably eventually be expanded to fit multiple types of Flan because I am a nerd.

/mob/living/simple_animal/hostile/flan
	name = "Flan"
	desc = "Definitely not a dessert."
	var/casting = 0
	icon_state = "flan0"
	icon_living = "flan0"
	turns_per_move = 5
	environment_smash = 0
	speed = -2
	maxHealth = 50
	health = 50
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "headbutts"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	del_on_death = 1
	ranged = 1
	retreat_distance = 2
	minimum_distance = 4
	AIStatus = AI_IDLE
	ranged_message = "begins to cast something"
	ranged_cooldown_time = 5
	var/spellname = "a Water spell!"
	var/spellsound = 'sound/effects/spray3.ogg'
	var/spellanimation = ATTACK_EFFECT_SMASH		//More in defines/misc.dm
	var/spelldamagetype = BRUTE
	var/spelldamage = 20

/mob/living/simple_animal/hostile/flan/OpenFire(mob/living/A)		//Spellcasting!
	if(isliving(A))				//A is originally an atom, this is here to prevent that from fucking this up.
		visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")
		casting = 1
		icon_state = "[initial(icon_state)][casting]"
		if(do_after(src, 10, target = A, progress = 0))
			if(qdeleted(src))
				return
			if((A in view(src)))
				A.do_attack_animation(A, spellanimation)
				playsound(A, spellsound, 20, 1)
				A.apply_damage(damage = spelldamage,damagetype = spelldamagetype, def_zone = null, blocked = 0)
				visible_message("<span class='danger'><b>[A]</b> has been hit by [spellname]</span>")
		ranged_cooldown = world.time + ranged_cooldown_time
		casting = 0
		icon_state = "[initial(icon_state)][casting]"

/mob/living/simple_animal/hostile/flan/fire
	name = "Flame Flan"
	desc = "You'd think they'd be spicy, but nobody has ever tried."
	icon_state = "fireflan"
	icon_living = "fireflan"
	spellname = "a Fire spell!"
	spellsound = 'sound/effects/fuse.ogg'
	spelldamagetype = BURN
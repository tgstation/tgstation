//Will probably eventually be expanded to fit multiple types of Flan because I am a nerd.

/mob/living/simple_animal/hostile/flan
	name = "Flan"
	desc = "Definitely not a dessert."
	var/casting = 0
	icon_state = "flan"								//Required for the inheritance of casting animations.
	icon_living = "flan"
	icon_dead = "flan_dead"
	turns_per_move = 5
	environment_smash = 0
	speed = -2
	maxHealth = 50
	health = 50
	harm_intent_damage = 5
	damage_coeff = list(BRUTE = 0.75, BURN = 1.5, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "headbutts"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	ranged = 1
	retreat_distance = 2
	minimum_distance = 4
	AIStatus = AI_IDLE
	ranged_message = "begins to cast something"
	ranged_cooldown_time = 15
	var/spellname = "a generic spell!"
	var/spellsound = 'sound/effects/spray3.ogg'
	var/spellanimation = ATTACK_EFFECT_SMASH		//More in defines/misc.dm
	var/spelldamagetype = BRUTE
	var/spelldamage = 15
	var/spellcasttime = 15							//if you varedit this also varedit ranged_cooldown_time else the mob will attack again before the spell hits, looking weird but still working

/mob/living/simple_animal/hostile/flan/New()		//Required for the inheritance of casting animations.
	..()
	casting = 0
	icon_state = "[initial(icon_state)][casting]"

/mob/living/simple_animal/hostile/flan/proc/spellaftereffects(mob/living/A)	//Inherit and override. Allows for spells that stun and do basically anything you'd want.
	return

/mob/living/simple_animal/hostile/flan/OpenFire(mob/living/A)		//Spellcasting!
	if(isliving(A))				//A is originally an atom, this is here to prevent that from fucking this up.
		visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")
		casting = 1
		icon_state = "[initial(icon_state)][casting]"
		if(do_after_mob(src, A, spellcasttime, uninterruptible = 1, progress = 0))		//Break LOS to dodge.
			if(QDELETED(src))
				return
			if((A in view(src)))
				A.do_attack_animation(A, spellanimation)
				playsound(A, spellsound, 20, 1)
				A.apply_damage(damage = spelldamage,damagetype = spelldamagetype, def_zone = null, blocked = 0)
				visible_message("<span class='danger'><b>[A]</b> has been hit by [spellname]</span>")
				spellaftereffects(A,src)
		ranged_cooldown = world.time + ranged_cooldown_time
		casting = 0
		icon_state = "[initial(icon_state)][casting]"

/mob/living/simple_animal/hostile/flan/fire
	name = "Flame Flan"
	desc = "You'd think they'd be spicy, but nobody has ever tried."
	icon_state = "fireflan"
	icon_living = "fireflan"
	icon_dead = "fireflan_dead"
	damage_coeff = list(BRUTE = 1.5, BURN = 0.75, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	spellname = "a Fire spell!"
	spellsound = 'sound/effects/fuse.ogg'
	spelldamagetype = BURN
	spellcasttime = 20

/mob/living/simple_animal/hostile/flan/fire/spellaftereffects(mob/living/A)
	A.adjust_fire_stacks(2)
	A.IgniteMob()

/mob/living/simple_animal/hostile/flan/water
	name = "Water Flan"
	desc = "Is pretty likely to dampen your spirits."
	icon_state = "flan"
	icon_living = "flan"
	icon_dead = "flan_dead"
	spellname = "a Water spell!"
	spelldamage = 10			//Basic flan, learn the dance with em.

/mob/living/simple_animal/hostile/flan/water/spellaftereffects(mob/living/A)
	A.ExtinguishMob()
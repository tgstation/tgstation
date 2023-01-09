/mob/living/simple_animal/hostile/construct/juggernaut
	name = "Juggernaut"
	real_name = "Juggernaut"
	desc = "A massive, armored construct built to spearhead attacks and soak up enemy fire."
	icon_state = "juggernaut"
	icon_living = "juggernaut"
	maxHealth = 150
	health = 150
	response_harm_continuous = "harmlessly punches"
	response_harm_simple = "harmlessly punch"
	harm_intent_damage = 0
	obj_damage = 90
	melee_damage_lower = 25
	melee_damage_upper = 25
	attack_verb_continuous = "smashes their armored gauntlet into"
	attack_verb_simple = "smash your armored gauntlet into"
	speed = 2.5
	environment_smash = ENVIRONMENT_SMASH_WALLS
	attack_sound = 'sound/weapons/punch3.ogg'
	status_flags = 0
	mob_size = MOB_SIZE_LARGE
	force_threshold = 10
	construct_spells = list(
		/datum/action/cooldown/spell/forcewall/cult,
		/datum/action/cooldown/spell/basic_projectile/juggernaut,
		/datum/action/innate/cult/create_rune/wall,
	)
	playstyle_string = "<b>You are a Juggernaut. Though slow, your shell can withstand heavy punishment, \
						create shield walls, rip apart enemies and walls alike, and even deflect energy weapons.</b>"

/mob/living/simple_animal/hostile/construct/juggernaut/hostile //actually hostile, will move around, hit things
	AIStatus = AI_ON
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES //only token destruction, don't smash the cult wall NO STOP

/mob/living/simple_animal/hostile/construct/juggernaut/bullet_act(obj/projectile/P)
	if(istype(P, /obj/projectile/energy) || istype(P, /obj/projectile/beam))
		var/reflectchance = 40 - round(P.damage/3)
		if(prob(reflectchance))
			apply_damage(P.damage * 0.5, P.damage_type)
			visible_message(span_danger("The [P.name] is reflected by [src]'s armored shell!"), \
							span_userdanger("The [P.name] is reflected by your armored shell!"))

			// Find a turf near or on the original location to bounce to
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
				var/new_y = P.starting.y + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
				var/turf/curloc = get_turf(src)

				// redirect the projectile
				P.original = locate(new_x, new_y, P.z)
				P.starting = curloc
				P.firer = src
				P.yo = new_y - curloc.y
				P.xo = new_x - curloc.x
				var/new_angle_s = P.Angle + rand(120,240)
				while(new_angle_s > 180) // Translate to regular projectile degrees
					new_angle_s -= 360
				P.set_angle(new_angle_s)

			return BULLET_ACT_FORCE_PIERCE // complete projectile permutation

	return ..()

//////////////////////////Juggernaut-alts////////////////////////////
/mob/living/simple_animal/hostile/construct/juggernaut/angelic
	theme = THEME_HOLY
	loot = list(/obj/item/ectoplasm/angelic)

/mob/living/simple_animal/hostile/construct/juggernaut/mystic
	theme = THEME_WIZARD
	loot = list(/obj/item/ectoplasm/mystic)

/mob/living/simple_animal/hostile/construct/juggernaut/noncult

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

/mob/living/simple_animal/hostile/construct/juggernaut/bullet_act(obj/projectile/bullet)
	if(!istype(bullet, /obj/projectile/energy) && !istype(bullet, /obj/projectile/beam))
		return ..()
	if(!prob(40 - round(bullet.damage / 3))) // reflect chance
		return ..()

	apply_damage(bullet.damage * 0.5, bullet.damage_type)
	visible_message(span_danger("The [bullet.name] is reflected by [src]'s armored shell!"), \
					span_userdanger("The [bullet.name] is reflected by your armored shell!"))

	if(!bullet.starting)
		return BULLET_ACT_FORCE_PIERCE
	// Find a turf near or on the original location to bounce to
	var/new_x = bullet.starting.x + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
	var/new_y = bullet.starting.y + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
	var/turf/current_tile = get_turf(src)

	// redirect the projectile
	bullet.original = locate(new_x, new_y, bullet.z)
	bullet.starting = current_tile
	bullet.firer = src
	bullet.yo = new_y - current_tile.y
	bullet.xo = new_x - current_tile.x
	var/new_angle_s = bullet.Angle + rand(120,240)
	while(new_angle_s > 180) // Translate to regular projectile degrees
		new_angle_s -= 360
	bullet.set_angle(new_angle_s)

	return BULLET_ACT_FORCE_PIERCE // complete projectile permutation


//////////////////////////Juggernaut-alts////////////////////////////
/mob/living/simple_animal/hostile/construct/juggernaut/angelic
	theme = THEME_HOLY
	loot = list(/obj/item/ectoplasm/angelic)

/mob/living/simple_animal/hostile/construct/juggernaut/mystic
	theme = THEME_WIZARD
	loot = list(/obj/item/ectoplasm/mystic)

/mob/living/simple_animal/hostile/construct/juggernaut/noncult

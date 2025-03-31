/mob/living/basic/construct/juggernaut
	name = "Juggernaut"
	real_name = "Juggernaut"
	desc = "A massive, armored construct built to spearhead attacks and soak up enemy fire."
	icon_state = "juggernaut"
	icon_living = "juggernaut"
	maxHealth = 150
	health = 150
	response_harm_continuous = "harmlessly punches"
	response_harm_simple = "harmlessly punch"
	obj_damage = 90
	melee_damage_lower = 25
	melee_damage_upper = 25
	attack_verb_continuous = "smashes their armored gauntlet into"
	attack_verb_simple = "smash your armored gauntlet into"
	speed = 2.5
	attack_sound = 'sound/items/weapons/punch3.ogg'
	status_flags = NONE
	mob_size = MOB_SIZE_LARGE
	construct_spells = list(
		/datum/action/cooldown/spell/basic_projectile/juggernaut,
		/datum/action/cooldown/spell/forcewall/cult,
		/datum/action/innate/cult/create_rune/wall,
	)
	playstyle_string = span_bold("You are a Juggernaut. Though slow, your shell can withstand heavy punishment, create shield walls, rip apart enemies and walls alike, and even deflect energy weapons.")

	smashes_walls = TRUE

/mob/living/basic/construct/juggernaut/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/damage_threshold, 10)

/// Hostile NPC version. Pretty dumb, just attacks whoever is near.
/mob/living/basic/construct/juggernaut/hostile
	ai_controller = /datum/ai_controller/basic_controller/juggernaut
	smashes_walls = FALSE
	melee_attack_cooldown = 2 SECONDS

/mob/living/basic/construct/juggernaut/bullet_act(obj/projectile/bullet)
	if(!istype(bullet, /obj/projectile/energy) && !istype(bullet, /obj/projectile/beam))
		return ..()
	if(!prob(40 - round(bullet.damage / 3))) // reflect chance
		return ..()

	apply_damage(bullet.damage * 0.5, bullet.damage_type)
	visible_message(
		span_danger("\The [bullet] is reflected by [src]'s armored shell!"),
		span_userdanger("\The [bullet] is reflected by your armored shell!"),
	)

	bullet.reflect(src)

	return BULLET_ACT_FORCE_PIERCE // complete projectile permutation

// Alternate juggernaut themes
/mob/living/basic/construct/juggernaut/angelic
	theme = THEME_HOLY

/mob/living/basic/construct/juggernaut/angelic/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ANGELIC, INNATE_TRAIT)

/mob/living/basic/construct/juggernaut/mystic
	theme = THEME_WIZARD

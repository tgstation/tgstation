//spooky human cultist
/mob/living/simple_animal/hostile/cultist/human
	name = "Cultist"
	desc = "Praise Nar'Sie!"
	icon_state = "cult"
	icon_living = "cult"
	icon_dead = null //can someone explain to me why these mobs need a dead/gibbed icon if the body is qdel'd after corpse spawn?
	icon_gib = null
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 20
	melee_damage_upper = 25
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	a_intent = "harm"
	var/corpse = /obj/effect/landmark/mobcorpse/cultist
	var/weapon1 = /obj/item/weapon/melee/cultblade
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("hostile")
	status_flags = CANPUSH

/mob/living/simple_animal/hostile/cultist/human/space
	name = "Spacebound Cultist"
	desc = "Praise Nar'Sie!"
	icon_state = "cultspace"
	icon_living = "cultspace"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	corpse = /obj/effect/landmark/mobcorpse/cultist/space

/mob/living/simple_animal/hostile/cultist/human/death(gibbed)
	..(gibbed)
	if(corpse)
		new corpse (src.loc)
	if(weapon1)
		new weapon1 (src.loc)
	qdel(src)
	return































































































=======
//simplemob variants of the constructs. mostly meant for badmins/mappers who want spooky constructs without player mobs.

/mob/living/simple_animal/hostile/cultist/construct
	name = "Artificer"
	desc = "A bulbous construct dedicated to building and maintaining The Cult of Nar-Sie's armies."
	icon = 'icons/mob/mob.dmi'
	icon_state = "artificer"
	icon_living = "artificer"
	icon_dead = null
	icon_gib = null
	speak_chance = 0
	turns_per_move = 5
	response_help = "nudges"
	response_disarm = "shoves"
	response_harm = "hits"
	environment_smash = 1
	speed = 0
	maxHealth = 50
	health = 50
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "rams"
	attack_sound = 'sound/weapons/punch3.ogg'
	a_intent = "harm"
	var/itemdrop = /obj/item/weapon/ectoplasm
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("hostile")
	status_flags = CANPUSH

/mob/living/simple_animal/hostile/cultist/construct/death(gibbed)
	..(gibbed)
	if(itemdrop)
		new itemdrop (src.loc)
	qdel(src)
	return

/mob/living/simple_animal/hostile/cultist/construct/juggernaut
	name = "Juggernaut"
	desc = "A possessed suit of armor driven by the will of the restless dead."
	icon_state = "behemoth"
	icon_living = "behemoth"
	attacktext = "smashes their armored gauntlet into"
	maxHealth = 250
	health = 250
	melee_damage_lower = 30
	melee_damage_upper = 30
	move_to_delay = 10
	speed = 3
	environment_smash = 2
	mob_size = MOB_SIZE_LARGE

/mob/living/simple_animal/hostile/cultist/construct/juggernaut/bullet_act(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam))
		var/reflectchance = 80 - round(P.damage/3)
		if(prob(reflectchance))
			if(P.damage_type == BURN || P.damage_type == BRUTE)
				adjustBruteLoss(P.damage * 0.5)
			visible_message("<span class='danger'>The [P.name] gets reflected by [src]'s shell!</span>", \
							"<span class='userdanger'>The [P.name] gets reflected by [src]'s shell!</span>")

			// Find a turf near or on the original location to bounce to
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
				var/new_y = P.starting.y + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
				var/turf/curloc = get_turf(src)

				// redirect the projectile
				P.original = locate(new_x, new_y, P.z)
				P.starting = curloc
				P.current = curloc
				P.firer = src
				P.yo = new_y - curloc.y
				P.xo = new_x - curloc.x

			return -1 // complete projectile permutation

	return (..(P))

/mob/living/simple_animal/hostile/cultist/construct/wraith
	name = "Wraith"
	desc = "A wicked bladed shell contraption piloted by a bound spirit"
	icon_state = "floating"
	icon_living = "floating"
	maxHealth = 75
	health = 75
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "slashes"
	speed = 0
	see_in_dark = 7
	attack_sound = 'sound/weapons/bladeslice.ogg'
>>>>>>> .theirs

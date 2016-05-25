/mob/living/simple_animal/hostile/megafauna/colossus
	name = "colossus"
	desc = "get in the fucking robot."
	health = 2500
	maxHealth = 2500
	attacktext = "chomps"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	icon_state = "eva"
	icon_living = "eva"
	icon_dead = "dragon_dead"
	friendly = "stares down"
	icon = 'icons/mob/lavaland/mech.dmi'
	faction = list("mining")
	weather_immunities = list("lava","ash")
	speak_emote = list("roars")
	luminosity = 3
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 1
	move_to_delay = 10
	ranged = 1
	flying = 1
	mob_size = MOB_SIZE_LARGE
	pixel_x = -32
	aggro_vision_range = 18
	idle_vision_range = 5
	loot = list(/obj/structure/closet/crate/necropolis/dragon)
	butcher_results = list(/obj/item/weapon/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/animalhide/ashdrake = 10, /obj/item/stack/sheet/bone = 30)

	deathmessage = "crashes to the ground."
	death_sound = 'sound/magic/demon_dies.ogg'
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)


/obj/effect/at_shield
	name = "anti-toolbox field"
	desc = "A shimmering forcefield protecting the colossus."
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield2"
	layer = 6.1
	luminosity = 2
	var/target

/obj/effect/at_shield/New()
	..()
	spawn()
		for(var/i in 1 to 80-1)
			if(target)
				loc = get_turf(target)
		qdel(src)

/mob/living/simple_animal/hostile/megafauna/colossus/bullet_act(obj/item/projectile/P)
	if(!stat)
		var/obj/effect/at_shield/AT = new(src.loc)
		AT.target = src
		var/random_x = rand(-32, 32)
		AT.pixel_x += random_x

		var/random_y = rand(0, 72)
		AT.pixel_y += random_y
	..()
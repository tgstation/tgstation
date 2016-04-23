/mob/living/simple_animal/hostile/megafauna/legion
	name = "legion"
	health = 800
	maxHealth = 800
	icon_state = "legion"
	icon_living = "legion"
	desc = "One of many."
	icon = 'icons/mob/lavaland/legion.dmi'
	attacktext = "chomps"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	faction = list("mining")
	speak_emote = list("echoes")
	armour_penetration = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	speed = 2
	ranged = 1
	flying = 1
	del_on_death = 1
	retreat_distance = 5
	minimum_distance = 5
	ranged_cooldown_time = 20
	var/size = 10
	var/charging = 0
	pixel_y = -90
	pixel_x = -75
	layer = 6
	loot = list(/obj/structure/closet/crate/necropolis)

	vision_range = 13
	aggro_vision_range = 20
	idle_vision_range = 13


/mob/living/simple_animal/hostile/megafauna/legion/New()
	..()
	new/obj/item/device/gps/internal/legion(src)

/mob/living/simple_animal/hostile/megafauna/legion/OpenFire(the_target)
	if(world.time >= ranged_cooldown && !charging)
		if(prob(75))
			var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/A = new(src.loc)
			A.GiveTarget(target)
			A.friends = friends
			A.faction = faction
			ranged_cooldown = world.time + ranged_cooldown_time
		else
			visible_message("<span class='danger'>[src] charges!</span>")
			SpinAnimation(speed = 20, loops = 5)
			ranged = 0
			retreat_distance = 0
			minimum_distance = 0
			speed = 0
			charging = 1
			spawn(50)
				ranged = 1
				retreat_distance = 5
				minimum_distance = 5
				speed = 2
				charging = 0

/mob/living/simple_animal/hostile/megafauna/legion/death()
	if(size > 2)
		for(var/i in 1 to 2)
			var/mob/living/simple_animal/hostile/megafauna/legion/L = new(src.loc)
			L.health = src.maxHealth * 0.6
			L.maxHealth = L.health
			L.size = size - 2
			var/size_multiplier = L.size * 0.08
			L.resize = size_multiplier
			L.pixel_y = L.pixel_y * size_multiplier
			L.pixel_x = L.pixel_x * size_multiplier

			L.update_transform()
		visible_message("<span class='danger'>[src] splits!</span>")
		qdel(src)
	else
		..()

/obj/item/device/gps/internal/legion
	icon_state = null
	gpstag = "Echoing Signal"
	desc = "The message repeats."
	invisibility = 100
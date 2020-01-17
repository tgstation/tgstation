/obj/projectile/glockroachbullet
	damage = 10 //same damage as a hivebot
	damage_type = BRUTE

/obj/item/ammo_casing/glockroach
	name = "0.9mm bullet casing"
	desc = "A... 0.9mm bullet casing? What?"
	projectile_type = /obj/projectile/glockroachbullet

/mob/living/simple_animal/hostile/glockroach //copypasted from cockroach.dm so i could use the shooting code in hostile.dm
	name = "glockroach"
	desc = "HOLY SHIT, THAT COCKROACH HAS A GUN!"
	icon_state = "glockroach"
	icon_dead = "cockroach"
	health = 1
	maxHealth = 1
	turns_per_move = 5
	loot = list(/obj/effect/decal/cleanable/insectguts)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	speak_emote = list("chitters")
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = HOSTILE_SPAWN
	verb_say = "chitters"
	verb_ask = "chitters inquisitively"
	verb_exclaim = "chitters loudly"
	verb_yell = "chitters loudly"
	projectilesound = 'sound/weapons/gun/pistol/shot.ogg'
	projectiletype = /obj/projectile/glockroachbullet
	casingtype = /obj/item/ammo_casing/glockroach
	ranged = 1
	var/squish_chance = 50
	del_on_death = 1

/mob/living/simple_animal/hostile/glockroach/death(gibbed)
	if(SSticker.mode && SSticker.mode.station_was_nuked) //If the nuke is going off, then cockroaches are invincible. Keeps the nuke from killing them, cause cockroaches are immune to nukes.
		return
	..()

/mob/living/simple_animal/hostile/glockroach/Crossed(var/atom/movable/AM)
	if(ismob(AM))
		if(isliving(AM))
			var/mob/living/A = AM
			if(A.mob_size > MOB_SIZE_SMALL && !(A.movement_type & FLYING))
				if(prob(squish_chance))
					A.visible_message("<span class='notice'>[A] squashed [src].</span>", "<span class='notice'>You squashed [src].</span>")
					adjustBruteLoss(1) //kills a normal cockroach
				else
					visible_message("<span class='notice'>[src] avoids getting crushed.</span>")
	else
		if(isstructure(AM))
			if(prob(squish_chance))
				AM.visible_message("<span class='notice'>[src] was crushed under [AM].</span>")
				adjustBruteLoss(1)
			else
				visible_message("<span class='notice'>[src] avoids getting crushed.</span>")

/mob/living/simple_animal/hostile/glockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return

#define AS_MANY_BULLETS_A_MAG_GOT 15

#define REAL_NIGGA_HOURS 24 HOURS

/mob/living/simple_animal/hostile/glockroach/magdump
	name = "south bronx glockroach"
	desc = "HOLY SHIT, THAT COCKROACH HAS STREET KNOWLEDGE!"
	rapid = AS_MANY_BULLETS_A_MAG_GOT //one magazine, aka how many times we shoot
	rapid_fire_delay = 1
	ranged_cooldown_time = REAL_NIGGA_HOURS //we set it to fire after reload

/mob/living/simple_animal/hostile/glockroach/magdump/OpenFire(atom/A)
	if(CheckFriendlyFire(A))
		return
	visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")


	if(rapid > 1)
		var/datum/callback/cb = CALLBACK(src, .proc/Shoot, A, rapid)
		for(var/i in 1 to rapid)
			addtimer(cb, (i - 1)*rapid_fire_delay)
	else
		Shoot(A)
	ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/glockroach/magdump/Shoot(atom/targeted_atom, bullet_count)
	. = ..()
	if(bullet_count == AS_MANY_BULLETS_A_MAG_GOT)
		reloading_n_shit()

/mob/living/simple_animal/hostile/glockroach/magdump/proc/reloading_n_shit()
	to_chat(src, "<span class='warning'>YOU EMPTY SON, RELOADING</span>")
	/obj/item/ammo_box/magazine/m45/ohnine = new(get_turf(src))
	addtimer(CALLBACK(src, .proc/donereloadin), 10 SECONDS)

/mob/living/simple_animal/hostile/glockroach/magdump/proc/donereloadin()
	to_chat(src, "<span class='warning'>AIGHT YOU READY TO DROP A NIGGA WHO ACT UP</span>")
	playsound('sound/weapons/gun/pistol/rack.ogg')
	ranged_cooldown = 0

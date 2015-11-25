/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	layer = 13
	damage_type = BURN
	flag = "energy"


/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	nodamage = 1
	stun = 10
	weaken = 10
	stutter = 10
/*VG EDIT
	agony = 40
	damage_type = HALLOSS
*/
	//Damage will be handled on the MOB side, to prevent window shattering.



/obj/item/projectile/energy/declone
	name = "declone"
	icon_state = "declone"
	damage = 12
	nodamage = 0
	damage_type = CLONE
	irradiate = 40

/obj/item/projectile/energy/bolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 10
	damage_type = TOX
	nodamage = 0
	weaken = 10
	stutter = 10


/obj/item/projectile/energy/bolt/large
	name = "largebolt"
	damage = 20

/obj/item/projectile/energy/plasma
	name = "plasma"
	icon_state = "plasma"
	var/knockdown_chance = 0

/obj/item/projectile/energy/plasma/on_hit(var/atom/target, var/blocked = 0)
	if (..(target, blocked))
		var/mob/living/L = target
		L.contaminate()
		if(prob(knockdown_chance))
			if(istype(target, /mob/living/carbon/))
				shake_camera(L, 3, 2)
				L.apply_effect(2, WEAKEN)
				to_chat(L, "<span class = 'alert'> The force of the bolt knocks you off your feet!")
		return 1
	return 0

/obj/item/projectile/energy/plasma/pistol
	damage = 12
	icon_state = "plasma1"
	irradiate = 12

/obj/item/projectile/energy/plasma/light
	damage = 25
	icon_state = "plasma2"
	knockdown_chance = 30

/obj/item/projectile/energy/plasma/rifle
	damage = 40
	icon_state = "plasma3"
	irradiate = 35
	knockdown_chance = 50

/obj/item/projectile/energy/plasma/MP40k
	damage = 35
	eyeblur = 4
	irradiate = 25
	knockdown_chance = 40
	icon_state = "plasma3"

/obj/item/projectile/energy/neurotoxin
	name = "neuro"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX
	weaken = 5

/obj/item/projectile/energy/rad
	name = "rad"
	icon_state = "rad"
	damage = 30
	damage_type = TOX
	nodamage = 0
	weaken = 10
	stutter = 10

	on_hit(var/atom/hit)
		if(ishuman(hit))

			var/mob/living/carbon/human/H = hit

			H.generate_name()

			scramble(1, H, 100) // Scramble all UIs
			scramble(null, H, 5) // Scramble SEs, 5% chance for each block

			H.apply_effect((rand(50, 250)),IRRADIATE)

/obj/item/projectile/energy/buster
	name = "buster shot"
	icon_state = "buster"
	nodamage = 0
	damage = 20
	damage_type = BURN

/obj/item/projectile/energy/megabuster
	name = "buster pellet"
	icon_state = "megabuster"
	nodamage = 1

/obj/item/projectile/energy/osipr
	name = "dark energy ball"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "dark"
	kill_count = 100
	damage = 50
	stun = 10
	weaken = 10
	stutter = 10
	jittery = 30
	destroy = 0
	bounce_sound = 'sound/weapons/osipr_altbounce.ogg'
	bounce_type = PROJREACT_WALLS|PROJREACT_WINDOWS
	bounces = -1
	phase_type = PROJREACT_OBJS|PROJREACT_MOBS
	penetration = -1

/obj/item/projectile/energy/osipr/Destroy()
	var/turf/T = loc
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(4, 0, T)
	s.start()
	T.turf_animation('icons/obj/projectiles_impacts.dmi',"dark_explosion",0, 0, 13, 'sound/weapons/osipr_altexplosion.ogg')
	..()

<<<<<<< HEAD
/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	flag = "energy"


/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	color = "#FFFF00"
	nodamage = 1
	stun = 5
	weaken = 5
	stutter = 5
	jitter = 20
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 7

/obj/item/projectile/energy/electrode/on_hit(atom/target, blocked = 0)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
		sparks.set_up(1, 1, src)
		sparks.start()
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.dna && C.dna.check_mutation(HULK))
			C.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		else if(C.status_flags & CANWEAKEN)
			addtimer(C, "do_jitter_animation", 5, FALSE, jitter)

/obj/item/projectile/energy/electrode/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(1, 1, src)
	sparks.start()
	..()

/obj/item/projectile/energy/net
	name = "energy netting"
	icon_state = "e_netting"
	damage = 10
	damage_type = STAMINA
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 10

/obj/item/projectile/energy/net/New()
	..()
	SpinAnimation()

/obj/item/projectile/energy/net/on_hit(atom/target, blocked = 0)
	if(isliving(target))
		var/turf/Tloc = get_turf(target)
		if(!locate(/obj/effect/nettingportal) in Tloc)
			new/obj/effect/nettingportal(Tloc)
	..()

/obj/item/projectile/energy/net/on_range()
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(1, 1, src)
	sparks.start()
	..()

/obj/effect/nettingportal
	name = "DRAGnet teleportation field"
	desc = "A field of bluespace energy, locking on to teleport a target."
	icon = 'icons/effects/effects.dmi'
	icon_state = "dragnetfield"
	anchored = 1
	unacidable = 1

/obj/effect/nettingportal/New()
	..()
	SetLuminosity(3)
	var/obj/item/device/radio/beacon/teletarget = null
	for(var/obj/machinery/computer/teleporter/com in machines)
		if(com.target)
			if(com.power_station && com.power_station.teleporter_hub && com.power_station.engaged)
				teletarget = com.target
	if(teletarget)
		spawn(30)
			for(var/mob/living/L in get_turf(src))
				do_teleport(L, teletarget, 2)//teleport what's in the tile to the beacon
			qdel(src)
	else
		spawn(30)
			for(var/mob/living/L in get_turf(src))
				do_teleport(L, L, 15) //Otherwise it just warps you off somewhere.
			qdel(src)


/obj/item/projectile/energy/trap
	name = "energy snare"
	icon_state = "e_snare"
	nodamage = 1
	weaken = 1
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 4

/obj/item/projectile/energy/trap/on_hit(atom/target, blocked = 0)
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - drop a trap
		new/obj/item/weapon/restraints/legcuffs/beartrap/energy(get_turf(loc))
	else if(iscarbon(target))
		var/obj/item/weapon/restraints/legcuffs/beartrap/B = new /obj/item/weapon/restraints/legcuffs/beartrap/energy(get_turf(target))
		B.Crossed(target)
	..()

/obj/item/projectile/energy/trap/on_range()
	new/obj/item/weapon/restraints/legcuffs/beartrap/energy(loc)
	..()

/obj/item/projectile/energy/trap/cyborg
	name = "Energy Bola"
	icon_state = "e_snare"
	nodamage = 1
	weaken = 0
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 10

/obj/item/projectile/energy/trap/cyborg/on_hit(atom/target, blocked = 0)
	if(!ismob(target) || blocked >= 100)
		var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
		sparks.set_up(1, 1, src)
		sparks.start()
		qdel(src)
	if(iscarbon(target))
		var/obj/item/weapon/restraints/legcuffs/beartrap/B = new /obj/item/weapon/restraints/legcuffs/beartrap/energy/cyborg(get_turf(target))
		B.Crossed(target)
	spawn(10)
		qdel(src)
	..()

/obj/item/projectile/energy/trap/cyborg/on_range()
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(1, 1, src)
	sparks.start()
	qdel(src)

/obj/item/projectile/energy/declone
	name = "radiation beam"
	icon_state = "declone"
	damage = 20
	damage_type = CLONE
	irradiate = 10

/obj/item/projectile/energy/dart //ninja throwing dart
	name = "dart"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	weaken = 5
	range = 7

/obj/item/projectile/energy/bolt //ebow bolts
	name = "bolt"
	icon_state = "cbbolt"
	damage = 15
	damage_type = TOX
	nodamage = 0
	weaken = 5
	stutter = 5

/obj/item/projectile/energy/bolt/large
	damage = 20

/obj/item/ammo_casing/energy/plasma
	projectile_type = /obj/item/projectile/plasma
	select_name = "plasma burst"
	fire_sound = 'sound/weapons/pulse.ogg'

/obj/item/ammo_casing/energy/plasma/adv
	projectile_type = /obj/item/projectile/plasma/adv

/obj/item/projectile/energy/shock_revolver
	name = "shock bolt"
	icon_state = "purple_laser"
	var/chain

/obj/item/ammo_casing/energy/shock_revolver/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/item/projectile/hook/P = BB
	spawn(1)
		P.chain = P.Beam(user,icon_state="purple_lightning",icon = 'icons/effects/effects.dmi',time=1000, maxdistance = 30)

/obj/item/projectile/energy/shock_revolver/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		tesla_zap(src, 3, 10000)
	qdel(chain)
=======
/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	layer = 13
	damage_type = BURN
	flag = "energy"
	fire_sound = 'sound/weapons/Taser.ogg'
	plane = PLANE_LIGHTING


/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	nodamage = 1
	stun = 10
	weaken = 10
	stutter = 10
	hitsound = 'sound/weapons/taserhit.ogg'

/*/vg/ EDIT
	agony = 40
	damage_type = HALLOSS
*/
	//Damage will be handled on the MOB side, to prevent window shattering.



/obj/item/projectile/energy/declone
	name = "decloner bolt"
	icon_state = "declone"
	damage = 12
	nodamage = 0
	damage_type = CLONE
	irradiate = 40
	fire_sound = 'sound/weapons/pulse3.ogg'

/obj/item/projectile/energy/bolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 10
	damage_type = TOX
	nodamage = 0
	weaken = 10
	stutter = 10


/obj/item/projectile/energy/bolt/large
	name = "large bolt"
	damage = 20

/obj/item/projectile/energy/plasma
	name = "plasma bolt"
	icon_state = "plasma"
	var/knockdown_chance = 0
	fire_sound = 'sound/weapons/elecfire.ogg'

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
	damage = 25
	icon_state = "plasma1"
	irradiate = 12

/obj/item/projectile/energy/plasma/light
	damage = 35
	icon_state = "plasma2"
	irradiate = 20
	knockdown_chance = 30

/obj/item/projectile/energy/plasma/rifle
	damage = 50
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
	name = "neurotoxin bolt"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX
	weaken = 5

/obj/item/projectile/energy/rad
	name = "radiation bolt"
	icon_state = "rad"
	damage = 30
	damage_type = TOX
	nodamage = 0
	weaken = 10
	stutter = 10
	fire_sound = 'sound/weapons/radgun.ogg'

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
	fire_sound = 'sound/weapons/mmlbuster.ogg'

/obj/item/projectile/energy/megabuster
	name = "buster pellet"
	icon_state = "megabuster"
	nodamage = 1
	fire_sound = 'sound/weapons/megabuster.ogg'

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
	fire_sound = 'sound/weapons/osipr_altfire.ogg'

/obj/item/projectile/energy/osipr/Destroy()
	var/turf/T = loc
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(4, 0, T)
	s.start()
	T.turf_animation('icons/obj/projectiles_impacts.dmi',"dark_explosion",0, 0, 13, 'sound/weapons/osipr_altexplosion.ogg')
	..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

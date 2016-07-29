/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = 1
<<<<<<< HEAD
	flag = "energy"


/obj/item/projectile/ion/on_hit(atom/target, blocked = 0)
	..()
	empulse(target, 1, 1)
	return 1


/obj/item/projectile/ion/weak

/obj/item/projectile/ion/weak/on_hit(atom/target, blocked = 0)
	..()
	empulse(target, 0, 0)
	return 1

=======
	layer = 13
	flag = "energy"
	fire_sound = 'sound/weapons/ion.ogg'

/obj/item/projectile/ion/Bump(atom/A as mob|obj|turf|area)
	if(!bumped && ((A != firer) || reflected))
		empulse(get_turf(A), 1, 1)
	..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
<<<<<<< HEAD

/obj/item/projectile/bullet/gyro/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 0, 2)
	return 1

/obj/item/projectile/bullet/a40mm
	name ="40mm grenade"
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	damage = 60

/obj/item/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 0, 2, 1, 0, flame_range = 3)
	return 1

/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	var/temperature = 100


/obj/item/projectile/temp/on_hit(atom/target, blocked = 0)//These two could likely check temp protection on the mob
	..()
	if(isliving(target))
		var/mob/M = target
		M.bodytemperature = temperature
	return 1

/obj/item/projectile/temp/hot
	name = "heat beam"
	temperature = 400

/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	flag = "bullet"

/obj/item/projectile/meteor/Bump(atom/A, yes)
	if(!yes) //prevents multi bumps.
		return
	if(A == firer)
		loc = A.loc
		return
	A.ex_act(2)
	playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)
	for(var/mob/M in urange(10, src))
		if(!M.stat)
			shake_camera(M, 3, 1)
	qdel(src)
=======
	flag = "bullet"

/obj/item/projectile/bullet/gyro/Bump(var/atom/target) //The bullets lose their ability to penetrate (which was pitiful for these ones) but now explode when hitting anything instead of only some things.
	explosion(target, -1, 0, 2)
	qdel(src)

/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "temp_4"
	damage = 0
	damage_type = BURN
	nodamage = 1
	layer = 13
	flag = "energy"
	var/temperature = 300
	fire_sound = 'sound/weapons/pulse3.ogg'

/obj/item/projectile/temp/OnFired()
	..()

	var/obj/item/weapon/gun/energy/temperature/T = shot_from
	if(istype(T))
		src.temperature = T.temperature
	else
		temperature = rand(100,600) //give it a random temp value if it's not fired from a temp gun

	switch(temperature)
		if(501 to INFINITY)
			name = "searing beam"	//if emagged
			icon_state = "temp_8"
		if(400 to 500)
			name = "burning beam"	//temp at which mobs start taking HEAT_DAMAGE_LEVEL_2
			icon_state = "temp_7"
		if(360 to 400)
			name = "hot beam"		//temp at which mobs start taking HEAT_DAMAGE_LEVEL_1
			icon_state = "temp_6"
		if(335 to 360)
			name = "warm beam"		//temp at which players get notified of their high body temp
			icon_state = "temp_5"
		if(295 to 335)
			name = "ambient beam"
			icon_state = "temp_4"
		if(260 to 295)
			name = "cool beam"		//temp at which players get notified of their low body temp
			icon_state = "temp_3"
		if(200 to 260)
			name = "cold beam"		//temp at which mobs start taking COLD_DAMAGE_LEVEL_1
			icon_state = "temp_2"
		if(120 to 260)
			name = "ice beam"		//temp at which mobs start taking COLD_DAMAGE_LEVEL_2
			icon_state = "temp_1"
		if(-INFINITY to 120)
			name = "freeze beam"	//temp at which mobs start taking COLD_DAMAGE_LEVEL_3
			icon_state = "temp_0"
		else
			name = "temperature beam"//failsafe
			icon_state = "temp_4"


/obj/item/projectile/temp/on_hit(var/atom/target, var/blocked = 0)//These two could likely check temp protection on the mob
	if(istype(target, /mob/living))
		var/mob/living/M = target
		if(M.flags & INVULNERABLE)
			return 0
		if(istype(M,/mob/living/carbon/human))
			M.bodytemperature -= 2*((temperature-T0C)/(-T0C))
		else
			M.bodytemperature = temperature
		if(temperature > 500)//emagged
			M.adjust_fire_stacks(0.5)
			M.on_fire = 1
			M.update_icon = 1
			playsound(M.loc, 'sound/effects/bamf.ogg', 50, 0)
	return 1

//Simple fireball
/obj/item/projectile/simple_fireball
	name = "fireball"
	icon_state = "fireball"
	animate_movement = 2
	damage = 0
	nodamage = 1
	flag = "bullet"

/obj/item/projectile/simple_fireball/Bump(atom/A)
	explosion(get_turf(src), -1, -1, 2, 2)
	return qdel(src)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"
<<<<<<< HEAD

/obj/item/projectile/energy/floramut/on_hit(atom/target, blocked = 0)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.dna.species.id == "pod")
			randmuti(C)
			randmut(C)
			C.updateappearance()
			C.domutcheck()
=======
	var/mutstrength = 10
	fire_sound = 'sound/effects/stealthoff.ogg'

/obj/item/projectile/energy/floramut/on_hit(var/atom/target, var/blocked = 0)
	var/mob/living/M = target
//	if(ishuman(target) && M.dna && M.dna.mutantrace == "plant") //Plantmen possibly get mutated and damaged by the rays.
	if(ishuman(target))
		var/mob/living/carbon/human/H = M
		if((H.species.flags & IS_PLANT))
			if(prob(mutstrength*2))
				M.apply_effect((rand(30,80)),IRRADIATE)
				M.Weaken(5)
				for (var/mob/V in viewers(src))
					V.show_message("<span class='warning'>[M] writhes in pain as \his vacuoles boil.</span>", 1, "<span class='warning'>You hear the crunching of leaves.</span>", 2)
			if(prob(mutstrength*3))
			//	for (var/mob/V in viewers(src)) //Public messages commented out to prevent possible metaish genetics experimentation and stuff. - Cheridan
			//		V.show_message("<span class='warning'>[M] is mutated by the radiation beam.</span>", 1, "<span class='warning'>You hear the snapping of twigs.</span>", 2)
				if(prob(80))
					randmutb(M)
					domutcheck(M,null)
				else
					randmutg(M)
					domutcheck(M,null)
			else
				M.adjustFireLoss(rand(mutstrength/3, mutstrength))
				M.show_message("<span class='warning'>The radiation beam singes you!</span>")
			//	for (var/mob/V in viewers(src))
			//		V.show_message("<span class='warning'>[M] is singed by the radiation beam.</span>", 1, "<span class='warning'>You hear the crackle of burning leaves.</span>", 2)
		else
			M.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
	else if(istype(target, /mob/living/carbon/))
	//	for (var/mob/V in viewers(src))
	//		V.show_message("The radiation beam dissipates harmlessly through [M]")
		M.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
	else
		return 1

/obj/item/projectile/energy/floramut/emag
	name = "gamma somatoray"
	icon_state = "energy"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"
<<<<<<< HEAD
=======
	fire_sound = 'sound/effects/stealthoff.ogg'

/obj/item/projectile/energy/florayield/on_hit(var/atom/target, var/blocked = 0)
	var/mob/M = target
//	if(ishuman(target) && M.dna && M.dna.mutantrace == "plant") //These rays make plantmen fat.
	if(ishuman(target)) //These rays make plantmen fat.
		var/mob/living/carbon/human/H = M
		if((H.species.flags & IS_PLANT) && (M.nutrition < 500))
			M.nutrition += 30
		else
			M.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
	else if (istype(target, /mob/living/carbon/))
		M.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
	else
		return 1

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

<<<<<<< HEAD
/obj/item/projectile/beam/mindflayer/on_hit(atom/target, blocked = 0)
	. = ..()
=======
/obj/item/projectile/beam/mindflayer/on_hit(var/atom/target, var/blocked = 0)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.adjustBrainLoss(20)
		M.hallucination += 20

/obj/item/projectile/kinetic
	name = "kinetic force"
<<<<<<< HEAD
	icon_state = null
	damage = 10
	damage_type = BRUTE
	flag = "bomb"
	range = 3
	var/splash = 0

/obj/item/projectile/kinetic/super
	damage = 11
	range = 4

/obj/item/projectile/kinetic/hyper
	damage = 12
	range = 5
	splash = 1

/obj/item/projectile/kinetic/New()
=======
	icon_state = "energy"
	damage = 15
	damage_type = BRUTE
	flag = "energy"
	var/range = 2
	fire_sound = 'sound/weapons/Taser.ogg'

obj/item/projectile/kinetic/New()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure < 50)
		name = "full strength kinetic force"
<<<<<<< HEAD
		damage *= 4
	..()

/obj/item/projectile/kinetic/on_range()
	new /obj/effect/kinetic_blast(src.loc)
	..()

/obj/item/projectile/kinetic/on_hit(atom/target)
	. = ..()
	var/turf/target_turf= get_turf(target)
	if(istype(target_turf, /turf/closed/mineral))
		var/turf/closed/mineral/M = target_turf
		M.gets_drilled(firer)
	new /obj/effect/kinetic_blast(target_turf)
	if(src.splash)
		for(var/turf/T in range(splash, target_turf))
			if(istype(T, /turf/closed/mineral))
				var/turf/closed/mineral/M = T
				M.gets_drilled(firer)


/obj/effect/kinetic_blast
	name = "kinetic explosion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/kinetic_blast/New()
	spawn(4)
		qdel(src)

/obj/item/projectile/beam/wormhole
	name = "bluespace beam"
	icon_state = "spark"
	hitsound = "sparks"
	damage = 3
	var/obj/item/weapon/gun/energy/wormhole_projector/gun
	color = "#33CCFF"

/obj/item/projectile/beam/wormhole/orange
	name = "orange bluespace beam"
	color = "#FF6600"

/obj/item/projectile/beam/wormhole/New(var/obj/item/ammo_casing/energy/wormhole/casing)
	if(casing)
		gun = casing.gun

/obj/item/ammo_casing/energy/wormhole/New(var/obj/item/weapon/gun/energy/wormhole_projector/wh)
	gun = wh

/obj/item/projectile/beam/wormhole/on_hit(atom/target)
	if(ismob(target))
		var/turf/portal_destination = pick(orange(6, src))
		do_teleport(target, portal_destination)
		return ..()
	if(!gun)
		qdel(src)
	gun.create_portal(src)

/obj/item/projectile/bullet/frag12
	name ="explosive slug"
	damage = 25
	weaken = 5

/obj/item/projectile/bullet/frag12/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 0, 1)
	return 1

/obj/item/projectile/plasma
	name = "plasma blast"
	icon_state = "plasmacutter"
	damage_type = BRUTE
	damage = 5
	range = 5

/obj/item/projectile/plasma/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	if(environment)
		var/pressure = environment.return_pressure()
		if(pressure < 60)
			name = "full strength plasma blast"
			damage *= 4
	..()

/obj/item/projectile/plasma/on_hit(atom/target)
	. = ..()
	if(istype(target, /turf/closed/mineral))
		var/turf/closed/mineral/M = target
		M.gets_drilled(firer)
		Range()
		if(range > 0)
			return -1

/obj/item/projectile/plasma/adv
	damage = 7
	range = 7

/obj/item/projectile/plasma/adv/mech
	damage = 10
	range = 8


/obj/item/projectile/gravityrepulse
	name = "repulsion bolt"
	icon = 'icons/effects/effects.dmi'
	icon_state = "chronofield"
	hitsound = "sound/weapons/wave.ogg"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	color = "#33CCFF"
	var/turf/T
	var/power = 4

/obj/item/projectile/gravityrepulse/New(var/obj/item/ammo_casing/energy/gravityrepulse/C)
	..()
	if(C) //Hard-coded maximum power so servers can't be crashed by trying to throw the entire Z level's items
		power = min(C.gun.power, 15)

/obj/item/projectile/gravityrepulse/on_hit()
	. = ..()
	T = get_turf(src)
	for(var/atom/movable/A in range(T, power))
		if(A == src || (firer && A == src.firer) || A.anchored)
			continue
		var/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(A, src)))
		A.throw_at_fast(throwtarget,power+1,1)
	for(var/turf/F in range(T,power))
		var/obj/effect/overlay/gravfield = new /obj/effect/overlay{icon='icons/effects/effects.dmi'; icon_state="shieldsparkles"; mouse_opacity=0; density=0}()
		F.overlays += gravfield
		spawn(5)
		F.overlays -= gravfield

/obj/item/projectile/gravityattract
	name = "attraction bolt"
	icon = 'icons/effects/effects.dmi'
	icon_state = "chronofield"
	hitsound = "sound/weapons/wave.ogg"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	color = "#FF6600"
	var/turf/T
	var/power = 4

/obj/item/projectile/gravityattract/New(var/obj/item/ammo_casing/energy/gravityattract/C)
	..()
	if(C) //Hard-coded maximum power so servers can't be crashed by trying to throw the entire Z level's items
		power = min(C.gun.power, 15)

/obj/item/projectile/gravityattract/on_hit()
	. = ..()
	T = get_turf(src)
	for(var/atom/movable/A in range(T, power))
		if(A == src || (firer && A == src.firer) || A.anchored)
			continue
		A.throw_at_fast(T, power+1, 1)
	for(var/turf/F in range(T,power))
		var/obj/effect/overlay/gravfield = new /obj/effect/overlay{icon='icons/effects/effects.dmi'; icon_state="shieldsparkles"; mouse_opacity=0; density=0}()
		F.overlays += gravfield
		spawn(5)
		F.overlays -= gravfield

/obj/item/projectile/gravitychaos
	name = "gravitational blast"
	icon = 'icons/effects/effects.dmi'
	icon_state = "chronofield"
	hitsound = "sound/weapons/wave.ogg"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	color = "#101010"
	var/turf/T
	var/power = 4

/obj/item/projectile/gravitychaos/New(var/obj/item/ammo_casing/energy/gravitychaos/C)
	..()
	if(C) //Hard-coded maximum power so servers can't be crashed by trying to throw the entire Z level's items
		power = min(C.gun.power, 15)

/obj/item/projectile/gravitychaos/on_hit()
	. = ..()
	T = get_turf(src)
	for(var/atom/movable/A in range(T, power))
		if(A == src|| (firer && A == src.firer) || A.anchored)
			continue
		A.throw_at_fast(get_edge_target_turf(A, pick(cardinal)), power+1, 1)
	for(var/turf/Z in range(T,power))
		var/obj/effect/overlay/gravfield = new /obj/effect/overlay{icon='icons/effects/effects.dmi'; icon_state="shieldsparkles"; mouse_opacity=0; density=0}()
		Z.overlays += gravfield
		spawn(5)
		Z.overlays -= gravfield

=======
		damage = 30
	..()

/* wat - N3X
/obj/item/projectile/kinetic/Range()
	range--
	if(range <= 0)
		new /obj/item/effect/kinetic_blast(src.loc)
		qdel(src)
*/

/obj/item/projectile/kinetic/on_hit(var/atom/target, var/blocked = 0)
	if(!loc) return
	var/turf/target_turf = get_turf(target)
	//testing("Hit [target.type], on [target_turf.type].")
	if(istype(target_turf, /turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = target_turf
		M.GetDrilled()
	new /obj/item/effect/kinetic_blast(target_turf)
	..(target,blocked)

/obj/item/projectile/kinetic/Bump(atom/A as mob|obj|turf|area)
	if(!loc) return
	if(A == firer)
		loc = A.loc
		return

	if(src)//Do not add to this if() statement, otherwise the meteor won't delete them

		if(A)
			var/turf/target_turf = get_turf(A)
			//testing("Bumped [A.type], on [target_turf.type].")
			if(istype(target_turf, /turf/unsimulated/mineral))
				var/turf/unsimulated/mineral/M = target_turf
				M.GetDrilled()
			// Now we bump as a bullet, if the atom is a non-turf.
			if(!isturf(A))
				..(A)
			//qdel(src) // Comment this out if you want to shoot through the asteroid, ERASER-style.
			returnToPool(src)
			return 1
	else
		//qdel(src)
		returnToPool(src)
		return 0

/obj/item/effect/kinetic_blast
	name = "kinetic explosion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = 4.1

/obj/item/effect/kinetic_blast/New()
	..()
	spawn(4)
		returnToPool(src)

/obj/item/projectile/stickybomb
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "stickybomb"
	damage = 0
	var/obj/item/stickybomb/sticky = null


/obj/item/projectile/stickybomb/Bump(atom/A as mob|obj|turf|area)
	if(bumped)	return 0
	bumped = 1

	if(A)
		density = 0
		invisibility = 101
		kill_count = 0
		if(isliving(A))
			sticky.stick_to(A)
		else if(loc)
			var/turf/T = get_turf(src)
			sticky.stick_to(T,get_dir(src,A))
		bullet_die()

/obj/item/projectile/stickybomb/bump_original_check()//so players can aim at floors
	if(!bumped)
		if(loc == get_turf(original))
			if(!(original in permutated))
				Bump(original)

/obj/item/projectile/portalgun
	name = "portal gun shot"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "portalgun"
	damage = 0
	nodamage = 1
	kill_count = 500//enough to cross a ZLevel...twice!
	var/setting = 0

/obj/item/projectile/portalgun/bump_original_check()//so players can aim at floors
	if(!bumped)
		if(loc == get_turf(original))
			if(!(original in permutated))
				Bump(original)

/obj/item/projectile/portalgun/Bump(atom/A as mob|obj|turf|area)
	if(bumped)
		return
	bumped = 1

	if(!istype(shot_from,/obj/item/weapon/gun/portalgun))
		bullet_die()
		return

	var/obj/item/weapon/gun/portalgun/P = shot_from

	if(isliving(A))
		forceMove(get_step(loc,dir))

	if(!(locate(/obj/effect/portal) in loc))
		P.open_portal(setting,loc,A,firer)
	bullet_die()


//Fire breath
//Fairly simple projectile that doesn't use any atmos calculations. Intended to be used by simple mobs
/obj/item/projectile/fire_breath
	name = "fiery breath"
	icon_state = null
	damage = 0
	penetration = -1
	phase_type = PROJREACT_MOBS|PROJREACT_BLOB|PROJREACT_OBJS
	bounce_sound = null
	custom_impact = 1
	penetration_message = 0
	grillepasschance = 100

	var/stepped_range = 0
	var/max_range = 9

	var/fire_damage = 10
	var/pressure = ONE_ATMOSPHERE * 4.5
	var/temperature = T0C + 175

/obj/item/projectile/fire_breath/process_step()
	..()

	if(stepped_range <= max_range)
		stepped_range++
	else
		bullet_die()
		return

	var/turf/T = get_turf(src)
	if(!T) return

	new /obj/effect/fire_blast(T, fire_damage, stepped_range, 1, pressure, temperature)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = 1
	layer = 13
	flag = "energy"

/obj/item/projectile/ion/Bump(atom/A as mob|obj|turf|area)
	if(!bumped && ((A != firer) || reflected))
		empulse(get_turf(A), 1, 1)
	..()

/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
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

/obj/item/projectile/temp/OnFired()
	..()

	var/obj/item/weapon/gun/energy/temperature/T = shot_from
	if(istype(T))
		src.temperature = T.temperature

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
		M.bodytemperature = temperature
		if(temperature > 500)//emagged
			M.adjust_fire_stacks(0.5)
			M.on_fire = 1
			M.update_icon = 1
			playsound(M.loc, 'sound/effects/bamf.ogg', 50, 0)
	return 1

//This shouldn't fucking exist, just spawn a meteor damnit
/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "smallf"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	flag = "bullet"

/obj/item/projectile/meteor/Bump(atom/A as mob|obj|turf|area)
	if(A == firer)
		loc = A.loc
		return

	//Copied straight from small meteor code
	spawn(0)
		for(var/mob/M in range(8, src))
			if(!M.stat && !istype(M, /mob/living/silicon/ai)) //bad idea to shake an ai's view
				shake_camera(M, 2, 1) //Poof

		playsound(get_turf(src), 'sound/effects/meteorimpact.ogg', 10, 1)
		explosion(src.loc, -1, 1, 3, 4, 0) //Tiny meteor doesn't cause too much damage
		qdel(src)

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

/obj/item/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"
	var/mutstrength = 10

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
					V.show_message("<span class='warning'>[M] writhes in pain as \his vacuoles boil.</span>", 3, "<span class='warning'>You hear the crunching of leaves.</span>", 2)
			if(prob(mutstrength*3))
			//	for (var/mob/V in viewers(src)) //Public messages commented out to prevent possible metaish genetics experimentation and stuff. - Cheridan
			//		V.show_message("<span class='warning'>[M] is mutated by the radiation beam.</span>", 3, "<span class='warning'>You hear the snapping of twigs.</span>", 2)
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
			//		V.show_message("<span class='warning'>[M] is singed by the radiation beam.</span>", 3, "<span class='warning'>You hear the crackle of burning leaves.</span>", 2)
		else
			M.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
	else if(istype(target, /mob/living/carbon/))
	//	for (var/mob/V in viewers(src))
	//		V.show_message("The radiation beam dissipates harmlessly through [M]", 3)
		M.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
	else
		return 1

/obj/item/projectile/energy/floramut/emag
	name = "gamma somatoray"
	icon_state = "energy"

/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

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


/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

/obj/item/projectile/beam/mindflayer/on_hit(var/atom/target, var/blocked = 0)
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.adjustBrainLoss(20)
		M.hallucination += 20

/obj/item/projectile/kinetic
	name = "kinetic force"
	icon_state = "energy"
	damage = 15
	damage_type = BRUTE
	flag = "energy"
	var/range = 2

obj/item/projectile/kinetic/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure < 50)
		name = "full strength kinetic force"
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
		P.open_portal(setting,loc,A)
	bullet_die()

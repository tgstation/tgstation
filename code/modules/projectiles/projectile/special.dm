/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"


	on_hit(var/atom/target, var/blocked = 0)
		empulse(target, 1, 1)
		return 1


/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	flag = "bullet"


	on_hit(var/atom/target, var/blocked = 0)
		explosion(target, -1, 0, 2)
		return 1

/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "temp_4"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	var/temperature = 300
	var/obj/item/weapon/gun/energy/temperature/T = null

	OnFired()
		T = shot_from
		temperature = T.temperature
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


	on_hit(var/atom/target, var/blocked = 0)//These two could likely check temp protection on the mob
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

/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "smallf"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	flag = "bullet"

	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return

		sleep(-1) //Might not be important enough for a sleep(-1) but the sleep/spawn itself is necessary thanks to explosions and metoerhits

		if(src)//Do not add to this if() statement, otherwise the meteor won't delete them
			if(A)

				A.meteorhit(src)
				playsound(get_turf(src), 'sound/effects/meteorimpact.ogg', 40, 1)

				for(var/mob/M in range(10, src))
					if(!M.stat && !istype(M, /mob/living/silicon/ai))\
						shake_camera(M, 3, 1)
				del(src)
				return 1
		else
			return 0

/obj/item/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

	on_hit(var/atom/target, var/blocked = 0)
		var/mob/living/M = target
//		if(ishuman(target) && M.dna && M.dna.mutantrace == "plant") //Plantmen possibly get mutated and damaged by the rays.
		if(ishuman(target))
			var/mob/living/carbon/human/H = M
			if((H.species.flags & IS_PLANT) && (M.nutrition < 500))
				if(prob(15))
					M.apply_effect((rand(30,80)),IRRADIATE)
					M.Weaken(5)
					for (var/mob/V in viewers(src))
						V.show_message("\red [M] writhes in pain as \his vacuoles boil.", 3, "\red You hear the crunching of leaves.", 2)
				if(prob(35))
				//	for (var/mob/V in viewers(src)) //Public messages commented out to prevent possible metaish genetics experimentation and stuff. - Cheridan
				//		V.show_message("\red [M] is mutated by the radiation beam.", 3, "\red You hear the snapping of twigs.", 2)
					if(prob(80))
						randmutb(M)
						domutcheck(M,null)
					else
						randmutg(M)
						domutcheck(M,null)
				else
					M.adjustFireLoss(rand(5,15))
					M.show_message("\red The radiation beam singes you!")
				//	for (var/mob/V in viewers(src))
				//		V.show_message("\red [M] is singed by the radiation beam.", 3, "\red You hear the crackle of burning leaves.", 2)
		else if(istype(target, /mob/living/carbon/))
		//	for (var/mob/V in viewers(src))
		//		V.show_message("The radiation beam dissipates harmlessly through [M]", 3)
			M.show_message("\blue The radiation beam dissipates harmlessly through your body.")
		else
			return 1

/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

	on_hit(var/atom/target, var/blocked = 0)
		var/mob/M = target
//		if(ishuman(target) && M.dna && M.dna.mutantrace == "plant") //These rays make plantmen fat.
		if(ishuman(target)) //These rays make plantmen fat.
			var/mob/living/carbon/human/H = M
			if((H.species.flags & IS_PLANT) && (M.nutrition < 500))
				M.nutrition += 30
		else if (istype(target, /mob/living/carbon/))
			M.show_message("\blue The radiation beam dissipates harmlessly through your body.")
		else
			return 1


/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

	on_hit(var/atom/target, var/blocked = 0)
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
	spawn(4)
		del(src)
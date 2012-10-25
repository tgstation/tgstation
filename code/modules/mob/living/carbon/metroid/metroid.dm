/mob/living/carbon/metroid
	name = "baby roro"
	icon = 'icons/mob/mob.dmi'
	icon_state = "baby roro"
	pass_flags = PASSTABLE
	voice_message = "skree!"
	say_message = "hums"

	layer = 5

	maxHealth = 150
	health = 150
	gender = NEUTER

	update_icon = 0
	nutrition = 700 // 1000 = max

	see_in_dark = 8

	// canstun and canweaken don't affect metroids because they ignore stun and weakened variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANPARALYSE

	var/cores = 3 // the number of /obj/item/metroid_core's the metroid has left inside

	var/powerlevel = 0 	// 1-10 controls how much electricity they are generating
	var/amount_grown = 0 // controls how long the metroid has been overfed, if 10, grows into an adult
						 // if adult: if 10: reproduces


	var/mob/living/Victim = null // the person the metroid is currently feeding on
	var/mob/living/Target = null // AI variable - tells the Metroid to hunt this down

	var/attacked = 0 // determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/tame = 0 // if set to 1, the Metroid will not eat humans ever, or attack them
	var/rabid = 0 // if set to 1, the Metroid will attack and eat anything it comes in contact with

	var/list/Friends = list() // A list of potential friends
	var/list/FriendsWeight = list() // A list containing values respective to Friends. This determines how many times a Metroid "likes" something. If the Metroid likes it more than 2 times, it becomes a friend

	// Metroids pass on genetic data, so all their offspring have the same "Friends",

/mob/living/carbon/metroid/adult
	name = "adult roro"
	icon = 'icons/mob/mob.dmi'
	icon_state = "adult roro"

	health = 200
	gender = NEUTER

	update_icon = 0
	nutrition = 800 // 1200 = max


/mob/living/carbon/metroid/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "baby roro")
		name = text("baby roro ([rand(1, 1000)])")
	else
		name = text("adult roro ([rand(1,1000)])")
	real_name = name
	spawn (1)
		regenerate_icons()
		src << "\blue Your icons have been generated!"
	..()

/mob/living/carbon/metroid/adult/New()
	verbs.Remove(/mob/living/carbon/metroid/verb/ventcrawl)
	..()

/mob/living/carbon/metroid/movement_delay()
	var/tally = 0

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45) tally += (health_deficiency / 25)

	if (bodytemperature < 183.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75

	if(reagents)
		if(reagents.has_reagent("hyperzine")) // hyperzine slows Metroids down
			tally *= 2 // moves twice as slow

		if(reagents.has_reagent("frostoil")) // frostoil also makes them move VEEERRYYYYY slow
			tally *= 5

	if(health <= 0) // if damaged, the metroid moves twice as slow
		tally *= 2

	if (bodytemperature >= 330.23) // 135 F
		return -1	// Metroids become supercharged at high temperatures

	return tally+config.metroid_delay


/mob/living/carbon/metroid/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1

		if(isobj(AM))
			if(!client && powerlevel > 0)
				var/probab = 10
				switch(powerlevel)
					if(1 to 2) probab = 20
					if(3 to 4) probab = 30
					if(5 to 6) probab = 40
					if(7 to 8) probab = 60
					if(9) 	   probab = 70
					if(10) 	   probab = 95
				if(prob(probab))


					if(istype(AM, /obj/structure/window) || istype(AM, /obj/structure/grille))
						if(istype(src, /mob/living/carbon/metroid/adult))
							if(nutrition <= 600 && !Atkcool)
								AM.attack_metroid(src)
								spawn()
									Atkcool = 1
									sleep(15)
									Atkcool = 0
						else
							if(nutrition <= 500 && !Atkcool)
								if(prob(5))
									AM.attack_metroid(src)
									spawn()
										Atkcool = 1
										sleep(15)
										Atkcool = 0

		if(ismob(AM))
			var/mob/tmob = AM

			if(istype(src, /mob/living/carbon/metroid/adult))
				if(istype(tmob, /mob/living/carbon/human))
					if(prob(90))
						now_pushing = 0
						return
			else
				if(istype(tmob, /mob/living/carbon/human))
					now_pushing = 0
					return

		now_pushing = 0
		..()
		if (!( istype(AM, /atom/movable) ))
			return
		if (!( now_pushing ))
			now_pushing = 1
			if (!( AM.anchored ))
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/structure/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/structure/window/win in get_step(AM,t))
							now_pushing = 0
							return
				step(AM, t)
			now_pushing = null
		return
	return

/mob/living/carbon/metroid/Process_Spacemove()
	return 2


/mob/living/carbon/metroid/Stat()
	..()

	statpanel("Status")
	if(istype(src, /mob/living/carbon/metroid/adult))
		stat(null, "Health: [round((health / 200) * 100)]%")
	else
		stat(null, "Health: [round((health / 150) * 100)]%")


	if (client.statpanel == "Status")
		if(istype(src,/mob/living/carbon/metroid/adult))
			stat(null, "Nutrition: [nutrition]/1200")
			if(amount_grown >= 10)
				stat(null, "You can reproduce!")
		else
			stat(null, "Nutrition: [nutrition]/1000")
			if(amount_grown >= 10)
				stat(null, "You can evolve!")

		stat(null,"Power Level: [powerlevel]")


/mob/living/carbon/metroid/adjustFireLoss(amount)
	..(-abs(amount)) // Heals them
	return

/mob/living/carbon/metroid/bullet_act(var/obj/item/projectile/Proj)
	attacked += 10
	..(Proj)
	return 0


/mob/living/carbon/metroid/emp_act(severity)
	powerlevel = 0 // oh no, the power!
	..()

/mob/living/carbon/metroid/ex_act(severity)

	if (stat == 2 && client)
		return

	else if (stat == 2 && !client)
		del(src)
		return

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			return

		if (2.0)

			b_loss += 60
			f_loss += 60


		if(3.0)
			b_loss += 30

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()


/mob/living/carbon/metroid/blob_act()
	if (stat == 2)
		return
	var/shielded = 0

	var/damage = null
	if (stat != 2)
		damage = rand(10,30)

	if(shielded)
		damage /= 4

		//paralysis += 1

	show_message("\red The blob attacks you!")

	adjustFireLoss(damage)

	updatehealth()
	return


/mob/living/carbon/metroid/u_equip(obj/item/W as obj)
	return


/mob/living/carbon/metroid/attack_ui(slot)
	return

/mob/living/carbon/metroid/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (health > 0)
		adjustBruteLoss((istype(O, /obj/effect/meteor/small) ? 10 : 25))
		adjustFireLoss(30)

		updatehealth()
	return


/mob/living/carbon/metroid/Move(a, b, flag)

	var/t7 = 1
	if (restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (pulling && ((get_dist(src, pulling) <= 1 || pulling.loc == loc) && (client && client.moving)))))
		var/turf/T = loc
		. = ..()

		if (pulling && pulling.loc)
			if(!( isturf(pulling.loc) ))
				stop_pulling()
				return
			else
				if(Debug)
					diary <<"pulling disappeared? at __LINE__ in mob.dm - pulling = [pulling]"
					diary <<"REPORT THIS"

		/////
		if(pulling && pulling.anchored)
			stop_pulling()
			return

		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if (ismob(pulling))
					var/mob/M = pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [] has been pulled from []'s grip by []", G.affecting, G.assailant, src), 1)
								//G = null
								del(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/atom/movable/t = M.pulling
						M.stop_pulling()
						step(pulling, get_dir(pulling.loc, T))
						M.start_pulling(t)
				else
					if (pulling)
						step(pulling, get_dir(pulling.loc, T))
	else
		stop_pulling()
		. = ..()
	if ((s_active && !( s_active in contents ) ))
		s_active.close(src)
	return


/mob/living/carbon/metroid/attack_metroid(mob/living/carbon/metroid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if(Victim) return // can't attack while eating!

	if (health > -100)

		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>The [M.name] has bit []!</B>", src), 1)

		var/damage = rand(1, 3)
		attacked += 5

		if(istype(src, /mob/living/carbon/metroid/adult))
			damage = rand(1, 6)
		else
			damage = rand(1, 3)

		adjustBruteLoss(damage)


		updatehealth()

	return


/mob/living/carbon/metroid/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[M]</B> [M.attacktext] [src]!", 1)
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/carbon/metroid/attack_paw(mob/living/carbon/monkey/M as mob)
	if(!(istype(M, /mob/living/carbon/monkey)))	return//Fix for aliens receiving double messages when attacking other aliens.

	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return
	..()

	switch(M.a_intent)

		if ("help")
			help_shake_act(M)
		else
			if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
				return
			if (health > 0)
				attacked += 10
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[M.name] has bit [src]!</B>"), 1)
				adjustBruteLoss(rand(1, 3))
				updatehealth()
	return


/mob/living/carbon/metroid/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	..()

	if(Victim)
		if(Victim == M)
			if(prob(60))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("\red [M] attempts to wrestle \the [name] off!", 1)
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("\red [M] manages to wrestle \the [name] off!", 1)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

				if(prob(90) && !client)
					Discipline++

				spawn()
					SStun = 1
					sleep(rand(45,60))
					if(src)
						SStun = 0

				Victim = null
				anchored = 0
				step_away(src,M)

			return

		else
			if(prob(30))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("\red [M] attempts to wrestle \the [name] off of [Victim]!", 1)
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message("\red [M] manages to wrestle \the [name] off of [Victim]!", 1)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

				if(prob(80) && !client)
					Discipline++

					if(!istype(src, /mob/living/carbon/metroid/adult))
						if(Discipline == 1)
							attacked = 0

				spawn()
					SStun = 1
					sleep(rand(55,65))
					if(src)
						SStun = 0

				Victim = null
				anchored = 0
				step_away(src,M)

			return




	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.cell)
			if(M.a_intent == "hurt")//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.charge -= 2500
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>", 1, "\red You hear someone fall.", 2)
					return
				else
					M << "\red Not enough charge! "
					return

	switch(M.a_intent)

		if ("help")
			help_shake_act(M)

		if ("grab")
			if (M == src)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M, M, src )

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()

			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)

		else
			if(ELECTRICHANDS in M.augmentations)
				var/gendertxt = "their"
				if(M.gender == MALE)
					gendertxt = "his"
				if(M.gender == FEMALE)
					gendertxt = "her"

				visible_message("\red <B>[M] has shocked [src] with [gendertxt] bare hands!</B>")
				return

			var/damage = rand(1, 9)

			attacked += 10
			if (prob(90))
				if ((HULK in M.mutations) || (SUPRSTR in M.augmentations))
					damage += 5
					if(Victim)
						Victim = null
						anchored = 0
						if(prob(80) && !client)
							Discipline++
					spawn(0)

						step_away(src,M,15)
						sleep(3)
						step_away(src,M,15)


				playsound(loc, "punch", 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has punched []!</B>", M, src), 1)

				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has attempted to punch []!</B>", M, src), 1)
	return



/mob/living/carbon/metroid/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	switch(M.a_intent)
		if ("help")
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\blue [M] caresses [src] with its scythe like arm."), 1)

		if ("hurt")

			if ((prob(95) && health > 0))
				attacked += 10
				playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
				var/damage = rand(15, 30)
				if (damage >= 25)
					damage = rand(20, 40)
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has slashed [name]!</B>", M), 1)
				else
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has wounded [name]!</B>", M), 1)
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has attempted to lunge at [name]!</B>", M), 1)

		if ("grab")
			if (M == src)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M, M, src )

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()

			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [] has grabbed [name] passively!", M), 1)

		if ("disarm")
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			var/damage = 5
			attacked += 10

			if(prob(95))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has tackled [name]!</B>", M), 1)

				if(Victim)
					Victim = null
					anchored = 0
					if(prob(80) && !client)
						Discipline++
						if(!istype(src, /mob/living/carbon/metroid))
							if(Discipline == 1)
								attacked = 0

				spawn()
					SStun = 1
					sleep(rand(5,20))
					SStun = 0

				spawn(0)

					step_away(src,M,15)
					sleep(3)
					step_away(src,M,15)

			else
				drop_item()
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has disarmed [name]!</B>", M), 1)
			adjustBruteLoss(damage)
			updatehealth()
	return


/mob/living/carbon/metroid/restrained()
	return 0


mob/living/carbon/metroid/var/co2overloadtime = null
mob/living/carbon/metroid/var/temperature_resistance = T0C+75


/mob/living/carbon/metroid/show_inv(mob/user as mob)

	user.machine = src
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR><BR>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[name];size=340x480"))
	onclose(user, "mob[name]")
	return

/mob/living/carbon/metroid/updatehealth()
	if (nodamage == 0)
		// metroids can't suffocate unless they suicide. They are also not harmed by fire
		if(istype(src, /mob/living/carbon/metroid/adult))
			health = 200 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())
		else
			health = 150 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())
	else
		if(istype(src, /mob/living/carbon/metroid/adult))
			health = 200
		else
			health = 150
		stat = 0


/mob/living/carbon/metroid/proc/get_obstacle_ok(atom/A)
	var/direct = get_dir(src, A)
	var/obj/item/weapon/dummy/D = new /obj/item/weapon/dummy( src.loc )
	var/ok = 0
	if ( (direct - 1) & direct)
		var/turf/Step_1
		var/turf/Step_2
		switch(direct)
			if(5.0)
				Step_1 = get_step(src, NORTH)
				Step_2 = get_step(src, EAST)

			if(6.0)
				Step_1 = get_step(src, SOUTH)
				Step_2 = get_step(src, EAST)

			if(9.0)
				Step_1 = get_step(src, NORTH)
				Step_2 = get_step(src, WEST)

			if(10.0)
				Step_1 = get_step(src, SOUTH)
				Step_2 = get_step(src, WEST)

			else
		if(Step_1 && Step_2)
			var/check_1 = 0
			var/check_2 = 0
			if(step_to(D, Step_1))
				check_1 = 1
				for(var/obj/border_obstacle in Step_1)
					if(border_obstacle.flags & ON_BORDER)
						if(!border_obstacle.CheckExit(D, A))
							check_1 = 0
				for(var/obj/border_obstacle in get_turf(A))
					if((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
						if(!border_obstacle.CanPass(D, D.loc, 1, 0))
							check_1 = 0

			D.loc = src.loc
			if(step_to(D, Step_2))
				check_2 = 1

				for(var/obj/border_obstacle in Step_2)
					if(border_obstacle.flags & ON_BORDER)
						if(!border_obstacle.CheckExit(D, A))
							check_2 = 0
				for(var/obj/border_obstacle in get_turf(A))
					if((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
						if(!border_obstacle.CanPass(D, D.loc, 1, 0))
							check_2 = 0
			if(check_1 || check_2)
				ok = 1
	else
		if(loc == src.loc)
			ok = 1
		else
			ok = 1

			//Now, check objects to block exit that are on the border
			for(var/obj/border_obstacle in src.loc)
				if(border_obstacle.flags & ON_BORDER)
					if(!border_obstacle.CheckExit(D, A))
						ok = 0

			//Next, check objects to block entry that are on the border
			for(var/obj/border_obstacle in get_turf(A))
				if((border_obstacle.flags & ON_BORDER) && (A != border_obstacle))
					if(!border_obstacle.CanPass(D, D.loc, 1, 0))
						ok = 0

	//del(D)
	//Garbage Collect Dummy
	D.loc = null
	D = null
	if (!( ok ))

		return 0

	return 1


// Basically this Metroid Core catalyzes reactions that normally wouldn't happen anywhere
/obj/item/metroid_core
	name = "roro core"
	desc = "A very slimy and tender part of a Rorobeast. Legends claim these to have \"magical powers\"."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "roro core"
	flags = TABLEPASS
	force = 1.0
	w_class = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 6
	origin_tech = "biotech=4"
	var/POWERFLAG = 0 // sshhhhhhh
	var/Flush = 30
	var/Uses = 5 // uses before it goes inert

/obj/item/metroid_core/New()
		..()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		POWERFLAG = rand(1,10)
		Uses = rand(7, 25)
		//flags |= NOREACT
/*
		spawn()
			Life()

	proc/Life()
		while(src)
			sleep(25)
			Flush--
			if(Flush <= 0)
				reagents.clear_reagents()
				Flush = 30
*/

/obj/item/weapon/reagent_containers/food/snacks/egg/roro
	name = "roro egg"
	desc = "A small, gelatinous egg."
	icon = 'icons/mob/mob.dmi'
	icon_state = "roro egg-growing"
	bitesize = 12
	origin_tech = "biotech=4"
	var/grown = 0

/obj/item/weapon/reagent_containers/food/snacks/egg/roro/New()
	..()
	reagents.add_reagent("nutriment", 5)
	spawn(rand(1200,1500))//the egg takes a while to "ripen"
		Grow()

/obj/item/weapon/reagent_containers/food/snacks/egg/roro/proc/Grow()
	grown = 1
	icon_state = "roro egg-grown"
	processing_objects.Add(src)
	return

/obj/item/weapon/reagent_containers/food/snacks/egg/roro/proc/Hatch()
	processing_objects.Remove(src)
	var/turf/T = get_turf(src)
	src.visible_message("\blue The [name] pulsates and quivers!")
	spawn(rand(50,100))
		src.visible_message("\blue The [name] bursts open!")
		new/mob/living/carbon/metroid(T)
		del(src)


/obj/item/weapon/reagent_containers/food/snacks/egg/roro/process()
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	if (environment.toxins > MOLES_PLASMA_VISIBLE)//plasma exposure causes the egg to hatch
		src.Hatch()

/obj/item/weapon/reagent_containers/food/snacks/egg/roro/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype( W, /obj/item/toy/crayon ))
		return
	else
		..()
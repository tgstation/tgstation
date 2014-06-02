
// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	return

// No comment
/atom/proc/attackby(obj/item/W, mob/user)
	return
/atom/movable/attackby(obj/item/W, mob/user)
	if(W && !(W.flags&NOBLUDGEON))
		visible_message("<span class='danger'>[src] has been hit by [user] with [W].</span>")

/mob/living/attackby(obj/item/I, mob/user)
	user.changeNext_move(10)
	if(istype(I) && ismob(user))
		I.attack(src, user)


// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	return

// Overrides the weapon attack so it can attack any atoms like when we want to have an effect on an object independent of attackby
// It is a powerfull proc but it should be used wisely, if there is other alternatives instead use those
// If it returns 1 it exits click code. Always . = 1 at start of the function if you delete src.
/obj/item/proc/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	return

obj/item/proc/get_clamped_volume()
	if(src.force && src.w_class)
		return Clamp((src.force + src.w_class) * 4, 30, 100)// Add the item's force to its weight class and multiply by 4, then clamp the value between 30 and 100
	else if(!src.force && src.w_class)
		return Clamp(src.w_class * 6, 10, 100) // Multiply the item's weight class by 6, then clamp the value between 10 and 100

/obj/item/proc/attack(mob/living/M as mob, mob/living/user as mob, def_zone)

	if (!istype(M)) // not sure if this is the right thing...
		return
	//var/messagesource = M
	if (can_operate(M))        //Checks if mob is lying down on table for surgery
		if (do_surgery(M,user,src))
			return
	//if (istype(M,/mob/living/carbon/brain))
	//	messagesource = M:container
	if (hitsound)
		playsound(loc, hitsound, 50, 1, -1)
	/////////////////////////
	user.lastattacked = M
	M.lastattacker = user

	add_logs(user, M, "attacked", object=src.name, addition="(INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])")

	//spawn(1800)            // this wont work right
	//	M.lastattacker = null
	/////////////////////////

	var/power = force
	if(M_HULK in user.mutations)
		power *= 2

	if(!istype(M, /mob/living/carbon/human))
		if(istype(M, /mob/living/carbon/slime))
			var/mob/living/carbon/slime/slime = M
			if(prob(25))
				user << "\red [src] passes right through [M]!"
				return

			if(power > 0)
				slime.attacked += 10

			if(slime.Discipline && prob(50))	// wow, buddy, why am I getting attacked??
				slime.Discipline = 0

			if(power >= 3)
				if(istype(slime, /mob/living/carbon/slime/adult))
					if(prob(5 + round(power/2)))

						if(slime.Victim)
							if(prob(80) && !slime.client)
								slime.Discipline++
						slime.Victim = null
						slime.anchored = 0

						spawn()
							if(slime)
								slime.SStun = 1
								sleep(rand(5,20))
								if(slime)
									slime.SStun = 0

						spawn(0)
							if(slime)
								slime.canmove = 0
								step_away(slime, user)
								if(prob(25 + power))
									sleep(2)
									if(slime && user)
										step_away(slime, user)
								slime.canmove = 1

				else
					if(prob(10 + power*2))
						if(slime)
							if(slime.Victim)
								if(prob(80) && !slime.client)
									slime.Discipline++

									if(slime.Discipline == 1)
										slime.attacked = 0

								spawn()
									if(slime)
										slime.SStun = 1
										sleep(rand(5,20))
										if(slime)
											slime.SStun = 0

							slime.Victim = null
							slime.anchored = 0


						spawn(0)
							if(slime && user)
								step_away(slime, user)
								slime.canmove = 0
								if(prob(25 + power*4))
									sleep(2)
									if(slime && user)
										step_away(slime, user)
								slime.canmove = 1


		var/showname = "."
		if(user)
			showname = " by [user]!"
		if(!(user in viewers(M, null)))
			showname = "."

		if(attack_verb && attack_verb.len)
			M.visible_message("<span class='danger'>[M] has been [pick(attack_verb)] with [src][showname]</span>",
			"<span class='userdanger'>[M] has been [pick(attack_verb)] with [src][showname]!</span>")
		else if(force == 0)
			M.visible_message("<span class='danger'>[M] has been [pick("tapped","patted")] with [src][showname]</span>",
			"<span class='userdanger'>[M] has been [pick("tapped","patted")] with [src][showname]</span>")
		else
			M.visible_message("<span class='danger'>[M] has been attacked with [src][showname]</span>",
			"<span class='userdanger'>[M] has been attacked with [src][showname]</span>")

		if(!showname && user)
			if(user.client)
				user << "\red <B>You attack [M] with [src]. </B>"



	if(istype(M, /mob/living/carbon/human))
		M:attacked_by(src, user, def_zone)
	else
		switch(damtype)
			if("brute")
				if(istype(src, /mob/living/carbon/slime))
					M.adjustBrainLoss(power)

				else

					M.take_organ_damage(power)
					if (prob(33) && src.force) // Added blood for whacking non-humans too
						var/turf/location = M.loc
						if (istype(location, /turf/simulated))
							location:add_blood_floor(M)
			if("fire")
				if (!(M_RESIST_COLD in M.mutations))
					M.take_organ_damage(0, power)
					M << "Aargh it burns!"
		M.updatehealth()
	add_fingerprint(user)
	return 1
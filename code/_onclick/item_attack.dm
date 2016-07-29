<<<<<<< HEAD

// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	return

// No comment
/atom/proc/attackby(obj/item/W, mob/user, params)
	return

/obj/attackby(obj/item/I, mob/living/user, params)
	return I.attack_obj(src, user)

/mob/living/attackby(obj/item/I, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(user.a_intent == "harm" && stat == DEAD && butcher_results) //can we butcher it?
		var/sharpness = I.is_sharp()
		if(sharpness)
			user << "<span class='notice'>You begin to butcher [src]...</span>"
			playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
			if(do_mob(user, src, 80/sharpness))
				harvest(user)
			return 1
	return I.attack(src, user)


/obj/item/proc/attack(mob/living/M, mob/living/user)
	if(flags & NOBLUDGEON)
		return
	if(!force)
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), 1, -1)
	else if(hitsound)
		playsound(loc, hitsound, get_clamped_volume(), 1, -1)

	user.lastattacked = M
	M.lastattacker = user

	M.attacked_by(src, user)

	add_logs(user, M, "attacked", src.name, "(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
	add_fingerprint(user)


//the equivalent of the standard version of attack() but for object targets.
/obj/item/proc/attack_obj(obj/O, mob/living/user)
	if(flags & NOBLUDGEON)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(O)
	O.attacked_by(src, user)



/atom/movable/proc/attacked_by()
	return

/obj/attacked_by(obj/item/I, mob/living/user)
	if(I.force)
		user.visible_message("<span class='danger'>[user] has hit [src] with [I]!</span>", "<span class='danger'>You hit [src] with [I]!</span>")

/mob/living/attacked_by(obj/item/I, mob/living/user)
	if(user != src)
		user.do_attack_animation(src)
	if(send_item_attack_message(I, user))
		if(apply_damage(I.force, I.damtype))
			if(I.damtype == BRUTE)
				if(prob(33))
					I.add_mob_blood(src)
					var/turf/location = get_turf(src)
					add_splatter_floor(location)
					if(get_dist(user, src) <= 1)	//people with TK won't get smeared with blood
						user.add_mob_blood(src)
	return TRUE


// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	return


/obj/item/proc/get_clamped_volume()
	if(w_class)
		if(force)
			return Clamp((force + w_class) * 4, 30, 100)// Add the item's force to its weight class and multiply by 4, then clamp the value between 30 and 100
		else
			return Clamp(w_class * 6, 10, 100) // Multiply the item's weight class by 6, then clamp the value between 10 and 100

/mob/living/proc/send_item_attack_message(obj/item/I, mob/living/user, hit_area)
	var/message_verb = "attacked"
	if(I.attack_verb && I.attack_verb.len)
		message_verb = "[pick(I.attack_verb)]"
	else if(!I.force)
		return 0
	var/message_hit_area = ""
	if(hit_area)
		message_hit_area = " in the [hit_area]"

	var/attack_message = "[src] has been [message_verb][message_hit_area] with [I]."
	if(user in viewers(src, null))
		attack_message = "[user] has [message_verb] [src][message_hit_area] with [I]!"
	visible_message("<span class='danger'>[attack_message]</span>",
		"<span class='userdanger'>[attack_message]</span>")
	return 1

/mob/living/simple_animal/send_item_attack_message(obj/item/I, mob/living/user, hit_area)
	if(!I.force)
		user.visible_message("<span class='warning'>[user] gently taps [src] with [I].</span>",\
						"<span class='warning'>This weapon is ineffective, it does no damage!</span>")
	else if(I.force < force_threshold || I.damtype == STAMINA)
		visible_message("<span class='warning'>[I] bounces harmlessly off of [src].</span>",\
					"<span class='warning'>[I] bounces harmlessly off of [src]!</span>")
	else
		return ..()
=======

// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	if(flags & TWOHANDABLE)
		if(!(flags & MUSTTWOHAND))
			if(wielded)
				. = src.unwield(user)
			else
				. = src.wield(user)

// No comment
/atom/proc/attackby(obj/item/W, mob/user)
	return

/atom/movable/attackby(obj/item/W, mob/user)
	if(W && !(W.flags&NOBLUDGEON))
		visible_message("<span class='danger'>[src] has been hit by [user] with [W].</span>")

/mob/living/attackby(obj/item/I, mob/user, var/no_delay = 0, var/originator = null)
	if(!no_delay)
		user.delayNextAttack(10)
	if(istype(I) && ismob(user))
		if(originator)
			I.attack(src, user, null, originator)
		else
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

/obj/item/proc/attack(mob/living/M as mob, mob/living/user as mob, def_zone, var/originator = null)
	if(originator)
		return handle_attack(src, M, user, def_zone, originator)
	else
		return handle_attack(src, M, user, def_zone)

// Making this into a helper proc because of inheritance wonkyness making children of reagent_containers being nigh impossible to attack with.
/obj/item/proc/handle_attack(obj/item/I, mob/living/M as mob, mob/living/user as mob, def_zone, var/mob/originator = null)
	. = 1
	if (!istype(M)) // not sure if this is the right thing...
		return 0
	//var/messagesource = M
	if (can_operate(M))        //Checks if mob is lying down on table for surgery
		if (do_surgery(M,user,I))
			return 1
	//if (istype(M,/mob/living/carbon/brain))
	//	messagesource = M:container
	if (hitsound)
		playsound(get_turf(M.loc), I.hitsound, 50, 1, -1)
	/////////////////////////
	if(originator)
		if(ismob(originator))
			originator.lastattacked = M
			M.lastattacker = originator
			add_logs(originator, M, "attacked", object=I.name, addition="(INTENT: [uppertext(originator.a_intent)]) (DAMTYE: [uppertext(I.damtype)])")
	else
		user.lastattacked = M
		M.lastattacker = user
		add_logs(user, M, "attacked", object=I.name, addition="(INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(I.damtype)])")

	//spawn(1800)            // this wont work right
	//	M.lastattacker = null
	/////////////////////////

	var/power = I.force
	if(M_HULK in user.mutations)
		power *= 2

	if(!istype(M, /mob/living/carbon/human))
		if(istype(M, /mob/living/carbon/slime))
			var/mob/living/carbon/slime/slime = M
			if(prob(25))
				to_chat(user, "<span class='warning'>[I] passes right through [M]!</span>")
				return 0

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
			showname = "[user]"
		if(!(user in viewers(M, null)))
			showname = "."

		if(originator)
			if(istype(originator, /mob/living/simple_animal/borer))
				var/mob/living/simple_animal/borer/B = originator
				if(B.host == user)
					if(B.hostlimb == LIMB_RIGHT_ARM)
						showname = "[user]'s right arm"
					else if(B.hostlimb == LIMB_LEFT_ARM)
						showname = "[user]'s left arm"

		//make not the same mistake as me, these messages are only for slimes
		if(istype(I.attack_verb,/list) && I.attack_verb.len)
			M.visible_message("<span class='danger'>[showname] [pick(I.attack_verb)] [M] with [I].</span>", \
				"<span class='userdanger'>[showname] [pick(I.attack_verb)] you with [I].</span>")
		else if(I.force == 0)
			M.visible_message("<span class='danger'>[showname] [pick("taps","pats")] [M] with [I].</span>", \
				"<span class='userdanger'>[showname] [pick("taps","pats")] you with [I].</span>")
		else
			M.visible_message("<span class='danger'>[showname] attacks [M] with [I].</span>", \
				"<span class='userdanger'>[showname] attacks you with [I].</span>")

		if(!showname && user)
			if(user.client)
				if(originator)
					if(istype(originator, /mob/living/simple_animal/borer))
						var/mob/living/simple_animal/borer/BO = originator
						if(BO.host == user)
							if(BO.hostlimb == LIMB_RIGHT_ARM)
								to_chat(user, "<span class='warning'>Your right arm attacks [M] with [I]!</span>")
							else if(BO.hostlimb == LIMB_LEFT_ARM)
								to_chat(user, "<span class='warning'>Your left arm attacks [M] with [I]!</span>")
					else
						to_chat(user, "<span class='warning'>You attack [M] with [I]!</span>")
				else
					to_chat(user, "<span class='warning'>You attack [M] with [I]!</span>")


	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(originator)
			. = H.attacked_by(I, user, def_zone, originator)
		else
			. = H.attacked_by(I, user, def_zone)
	else
		switch(I.damtype)
			if("brute")
				if(istype(src, /mob/living/carbon/slime))
					M.adjustBrainLoss(power)

				else
					if(istype(M, /mob/living/carbon/monkey))
						var/mob/living/carbon/monkey/K = M
						power = K.defense(power,def_zone)
					M.take_organ_damage(power)
					if (prob(33) && I.force) // Added blood for whacking non-humans too
						var/turf/location = M.loc
						if (istype(location, /turf/simulated))
							location:add_blood_floor(M)
			if("fire")
				if (!(M_RESIST_COLD in M.mutations))
					if(istype(M, /mob/living/carbon/monkey))
						var/mob/living/carbon/monkey/K = M
						power = K.defense(power,def_zone)
					M.take_organ_damage(0, power)
					to_chat(M, "Aargh it burns!")
		M.updatehealth()
	I.add_fingerprint(user)
	return .
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

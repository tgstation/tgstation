/*
Contains most of the procs that are called when a mob is attacked by something

bullet_act
ex_act
meteor_act
emp_act

*/

/mob/living/carbon/human/bullet_act(var/obj/item/projectile/P, var/def_zone)

	if(wear_suit && istype(wear_suit, /obj/item/clothing/suit/armor/laserproof))
		if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam))
			var/reflectchance = 40 - round(P.damage/3)
			if(!(def_zone in list("chest", "groin")))
				reflectchance /= 2
			if(prob(reflectchance))
				visible_message("\red <B>The [P.name] gets reflected by [src]'s [wear_suit.name]!</B>")

				// Find a turf near or on the original location to bounce to
				if(P.starting)
					var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
					var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
					var/turf/curloc = get_turf(src)

					// redirect the projectile
					P.original = locate(new_x, new_y, P.z)
					P.starting = curloc
					P.current = curloc
					P.firer = src
					P.yo = new_y - curloc.y
					P.xo = new_x - curloc.x

				return -1 // complete projectile permutation

	if(check_shields(P.damage, "the [P.name]"))
		P.on_hit(src, 2)
		return 2
	return (..(P , def_zone))


/mob/living/carbon/human/getarmor(var/def_zone, var/type)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		if(isorgan(def_zone))
			return checkarmor(def_zone, type)
		var/datum/organ/external/affecting = get_organ(ran_zone(def_zone))
		return checkarmor(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/datum/organ/external/organ in organs)
		armorval += checkarmor(organ, type)
		organnum++
	return (armorval/max(organnum, 1))


/mob/living/carbon/human/proc/checkarmor(var/datum/organ/external/def_zone, var/type)
	if(!type)	return 0
	var/protection = 0
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform)
	for(var/bp in body_parts)
		if(!bp)	continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				protection += C.armor[type]
	return protection

/mob/living/carbon/human/proc/check_head_coverage(var/hidemask=0)
	for(var/obj/item/clothing/C in get_all_slots())
		if(!C) continue
		if(C.body_parts_covered & HEAD && (hidemask==0 || C.flags_inv & hidemask))
			return 1


/mob/living/carbon/human/proc/check_body_part_coverage(var/body_part_flags=0)
	if(!body_part_flags)
		return 0
	for(var/obj/item/clothing/C in get_all_slots())
		if(!C) continue
		if(C.body_parts_covered & body_part_flags)
			return 1
	return 0

/mob/living/carbon/human/proc/check_shields(var/damage = 0, var/attack_text = "the attack")
	if(l_hand && istype(l_hand, /obj/item/weapon))//Current base is the prob(50-d/3)
		var/obj/item/weapon/I = l_hand
		if(I.IsShield() && (prob(50 - round(damage / 3))))
			visible_message("\red <B>[src] blocks [attack_text] with the [l_hand.name]!</B>")
			return 1
	if(r_hand && istype(r_hand, /obj/item/weapon))
		var/obj/item/weapon/I = r_hand
		if(I.IsShield() && (prob(50 - round(damage / 3))))
			visible_message("\red <B>[src] blocks [attack_text] with the [r_hand.name]!</B>")
			return 1
	if(wear_suit && istype(wear_suit, /obj/item/))
		var/obj/item/I = wear_suit
		if(I.IsShield() && (prob(35)))
			visible_message("\red <B>The reactive teleport system flings [src] clear of [attack_text]!</B>")
			var/list/turfs = new/list()
			for(var/turf/T in orange(6))
				if(istype(T,/turf/space)) continue
				if(T.density) continue
				if(T.x>world.maxx-6 || T.x<6)	continue
				if(T.y>world.maxy-6 || T.y<6)	continue
				turfs += T
			if(!turfs.len) turfs += pick(/turf in orange(6))
			var/turf/picked = pick(turfs)
			if(!isturf(picked)) return
			src.loc = picked
			return 1
	return 0

/mob/living/carbon/human/emp_act(severity)
	for(var/obj/O in src)
		if(!O)	continue
		O.emp_act(severity)
	if(istype(src.w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/u = src.w_uniform
		var/obj/item/clothing/tie/holster/h = u.hastie
		if(h && istype(h))
			if(h.holstered)
				h.holstered.emp_act(severity)
	for(var/datum/organ/external/O  in organs)
		if(O.status & ORGAN_DESTROYED)	continue
		O.emp_act(severity)
		for(var/datum/organ/internal/I  in O.internal_organs)
			if(I.robotic == 0)	continue
			I.emp_act(severity)
	..()


/mob/living/carbon/human/proc/attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone)
	if(!I || !user)	return 0

	var/target_zone = get_zone_with_miss_chance(user.zone_sel.selecting, src)
	if(user == src) // Attacking yourself can't miss
		target_zone = user.zone_sel.selecting
	if(!target_zone && !src.stat)
		visible_message("\red <B>[user] misses [src] with \the [I]!")
		return
	if(istype(I, /obj/item/weapon/butch/meatcleaver) && src.stat == DEAD && user.a_intent == "hurt")
		var/obj/item/weapon/reagent_containers/food/snacks/meat/human/newmeat = new /obj/item/weapon/reagent_containers/food/snacks/meat/human(get_turf(src.loc))
		newmeat.name = src.real_name + newmeat.name
		newmeat.subjectname = src.real_name
		newmeat.subjectjob = src.job
		newmeat.reagents.add_reagent ("nutriment", (src.nutrition / 15) / 3)
		src.reagents.trans_to (newmeat, round ((src.reagents.total_volume) / 3, 1))
		src.loc.add_blood(src)
		--src.meatleft
		user << "\red You hack off a chunk of meat from [src.name]"
		if(!src.meatleft)
			src.attack_log += "\[[time_stamp()]\] Was chopped up into meat by <b>[user]/[user.ckey]</b>"
			user.attack_log += "\[[time_stamp()]\] Chopped up <b>[src]/[src.ckey]</b> into meat</b>"
			msg_admin_attack("[user.name] ([user.ckey]) chopped up [src] ([src.ckey]) into meat (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			if(!iscarbon(user))
				LAssailant = null
			else
				LAssailant = user
			del(src)
	var/datum/organ/external/affecting = get_organ(target_zone)
	if (!affecting)
		return
	if(affecting.status & ORGAN_DESTROYED)
		user << "What [affecting.display_name]?"
		return
	var/hit_area = affecting.display_name

	if((user != src) && check_shields(I.force, "the [I.name]"))
		return 0

	if(istype(I,/obj/item/weapon/card/emag))
		if(!(affecting.status & ORGAN_ROBOT))
			user << "\red That limb isn't robotic."
			return
		if(affecting.sabotaged)
			user << "\red [src]'s [affecting.display_name] is already sabotaged!"
		else
			user << "\red You sneakily slide [I] into the dataport on [src]'s [affecting.display_name] and short out the safeties."
			affecting.sabotaged = 1
		return

	if(I.attack_verb.len)
		visible_message("\red <B>[src] has been [pick(I.attack_verb)] in the [hit_area] with [I.name] by [user]!</B>")
	else
		visible_message("\red <B>[src] has been attacked in the [hit_area] with [I.name] by [user]!</B>")

	var/armor = run_armor_check(affecting, "melee", "Your armor has protected your [hit_area].", "Your armor has softened hit to your [hit_area].")
	if(armor >= 2)	return 0
	if(!I.force)	return 0

	apply_damage(I.force, I.damtype, affecting, armor , is_sharp(I), I)

	var/bloody = 0
	if(((I.damtype == BRUTE) || (I.damtype == HALLOSS)) && prob(25 + (I.force * 2)))
		I.add_blood(src)	//Make the weapon bloody, not the person.
//		if(user.hand)	user.update_inv_l_hand()	//updates the attacker's overlay for the (now bloodied) weapon
//		else			user.update_inv_r_hand()	//removed because weapons don't have on-mob blood overlays
		if(prob(33))
			bloody = 1
			var/turf/location = loc
			if(istype(location, /turf/simulated))
				location.add_blood(src)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(get_dist(H, src) <= 1) //people with TK won't get smeared with blood
					H.bloody_body(src)
					H.bloody_hands(src)

		switch(hit_area)
			if("head")//Harder to score a stun but if you do it lasts a bit longer
				if(prob(I.force))
					apply_effect(20, PARALYZE, armor)
					visible_message("\red <B>[src] has been knocked unconscious!</B>")
					if(src != user && I.damtype == BRUTE)
						ticker.mode.remove_revolutionary(mind)

				if(bloody)//Apply blood
					if(wear_mask)
						wear_mask.add_blood(src)
						update_inv_wear_mask(0)
					if(head)
						head.add_blood(src)
						update_inv_head(0)
					if(glasses && prob(33))
						glasses.add_blood(src)
						update_inv_glasses(0)

			if("chest")//Easier to score a stun but lasts less time
				if(prob((I.force + 10)))
					apply_effect(5, WEAKEN, armor)
					visible_message("\red <B>[src] has been knocked down!</B>")

				if(bloody)
					bloody_body(src)

/mob/living/carbon/human/proc/bloody_hands(var/mob/living/source, var/amount = 2)
	if (gloves)
		gloves.add_blood(source)
		gloves:transfer_blood = amount
		gloves:bloody_hands_mob = source
	else
		add_blood(source)
		bloody_hands = amount
		bloody_hands_mob = source
	update_inv_gloves()		//updates on-mob overlays for bloody hands and/or bloody gloves

/mob/living/carbon/human/proc/bloody_body(var/mob/living/source)
	if(wear_suit)
		wear_suit.add_blood(source)
		update_inv_wear_suit(0)
	if(w_uniform)
		w_uniform.add_blood(source)
		update_inv_w_uniform(0)

/mob/living/carbon/human/ex_act(severity)
	if(!blinded)
		flick("flash", flash)

	var/shielded = 0
	var/b_loss = null
	var/f_loss = null

	switch (severity)
		if (1.0)
			b_loss += 500
			if (!prob(getarmor(null, "bomb")))
				gib()
				return
			else
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)
			//return
//				var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
				//user.throw_at(target, 200, 4)

		if (2.0)
			if (stat == 2 && client)
				gib()
				return

			else if (stat == 2 && !client)
				gibs(loc, viruses)
				del(src)
				return

			if (!shielded)
				b_loss += 60

			f_loss += 60

			if (prob(getarmor(null, "bomb")))
				b_loss = b_loss/1.5
				f_loss = f_loss/1.5

			if (!is_on_ears(/obj/item/clothing/ears/earmuffs))
				ear_damage += 30
				ear_deaf += 120
			if (prob(70) && !shielded)
				Paralyse(10)

		if(3.0)
			b_loss += 30
			if (prob(getarmor(null, "bomb")))
				b_loss = b_loss/2
			if (!is_on_ears(/obj/item/clothing/ears/earmuffs))
				ear_damage += 15
				ear_deaf += 60
			if (prob(50) && !shielded)
				Paralyse(10)

	var/update = 0

	// focus most of the blast on one organ
	var/datum/organ/external/take_blast = pick(organs)
	update |= take_blast.take_damage(b_loss * 0.9, f_loss * 0.9, used_weapon = "Explosive blast")

	// distribute the remaining 10% on all limbs equally
	b_loss *= 0.1
	f_loss *= 0.1

	var/weapon_message = "Explosive Blast"

	for(var/datum/organ/external/temp in organs)
		switch(temp.name)
			if("head")
				update |= temp.take_damage(b_loss * 0.2, f_loss * 0.2, used_weapon = weapon_message)
			if("chest")
				update |= temp.take_damage(b_loss * 0.4, f_loss * 0.4, used_weapon = weapon_message)
			if("l_arm")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if("r_arm")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if("l_leg")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if("r_leg")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if("r_foot")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if("l_foot")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if("r_arm")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if("l_arm")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
	if(update)	UpdateDamageIcon()


/mob/living/carbon/human/blob_act()
	if(stat == 2)	return
	show_message("\red The blob attacks you!")
	var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
	var/datum/organ/external/affecting = get_organ(ran_zone(dam_zone))
	apply_damage(rand(30,40), BRUTE, affecting, run_armor_check(affecting, "melee"))
	return

/mob/living/carbon/human/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message("\red [src] has been hit by [O]", 1)
	if (health > 0)
		var/datum/organ/external/affecting = get_organ(pick("chest", "chest", "chest", "head"))
		if(!affecting)	return
		if (istype(O, /obj/effect/immovablerod))
			if(affecting.take_damage(101, 0))
				UpdateDamageIcon()
		else
			if(affecting.take_damage((istype(O, /obj/effect/meteor/small) ? 10 : 25), 30))
				UpdateDamageIcon()
		updatehealth()
	return
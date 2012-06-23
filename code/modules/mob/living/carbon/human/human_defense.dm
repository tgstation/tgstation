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
	for(var/name in organs)
		var/datum/organ/external/organ = organs[name]
		armorval += checkarmor(organ, type)
		organnum++
	return (armorval/max(organnum, 1))


/mob/living/carbon/human/proc/checkarmor(var/datum/organ/external/def_zone, var/type)
	if(!type)	return 0
	var/protection = 0
	var/adjuster = 0
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform)
	for(var/bp in body_parts)
		if(!bp)	continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				protection += C.armor[type]
				adjuster++
	protection = (adjuster ? protection/(sqrt(adjuster)) : 0)
	return protection


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
			for(var/turf/T in orange(6,src))
				if(istype(T,/turf/space)) continue
				if(T.density) continue
				turfs += T
			if(!turfs.len)
				turfs += pick(/turf in orange(6,src))
				visible_message("\red <B>The reactive teleport system malfunctions!</B>")
			var/turf/picked = pick(turfs)
			if(!isturf(picked)) return
			src.loc = picked
			return 1
	return 0

/mob/living/carbon/human/emp_act(severity)
	for(var/obj/O in src)
		if(!O)	continue
		O.emp_act(severity)
	for(var/named in organs)
		var/datum/organ/external/O = organs[named]
		if(O.destroyed)	continue
		O.emp_act(severity)
	..()


/mob/living/carbon/human/proc/attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone)
	if(!I || !user)	return 0

	var/datum/organ/external/affecting = get_organ(ran_zone(user.zone_sel.selecting))

	var/hit_area = affecting.display_name

	if((user != src) && check_shields(I.force, "the [I.name]"))
		return 0

	if(!affecting.destroyed)
		visible_message("\red <B>[src] has been attacked in the [hit_area] with [I.name] by [user]!</B>")
	else
		user << "What [affecting]?"
		return

	var/armor = run_armor_check(affecting, "melee", "Your armor has protected you from a hit to the [hit_area].", "Your armor has softened hit to your [hit_area].")
	if(armor >= 2)	return 0
	if(!I.force)	return 0

	// make heavy weapons do more damage
	var/power = I.force
	if(I.w_class >= 4)
		power *= 2
	apply_damage(power, I.damtype, affecting, armor, is_cut(I), I.name)

	var/bloody = 0
	if(((I.damtype == BRUTE) || (I.damtype == HALLOSS)) && prob(25 + is_sharp(I) * 50 + (I.force * 2)))
		I.add_blood(src)	//Make the weapon bloody, not the person.
		bloody = 1
		var/turf/location = loc
		if(istype(location, /turf/simulated))
			location.add_blood(src)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.wear_suit)			H.wear_suit.add_blood(src)
			else if(H.w_uniform)	H.w_uniform.add_blood(src)
			if(H.shoes)				H.shoes.add_blood(src)
			if (H.gloves && istype(H.gloves,/obj/item/clothing/gloves))
				var/obj/item/clothing/gloves/G = H.gloves
				G.add_blood(H)
				G.transfer_blood = 2
				G.bloody_hands_mob = H
			else
				H.add_blood(H)
				H.bloody_hands = 2
				H.bloody_hands_mob = H

	switch(hit_area)
		if("head")//Harder to score a stun but if you do it lasts a bit longer
			var/knockout_chance = 0
			if(power >= 4)
				knockout_chance += 5
			if(power >= 10)
				knockout_chance += 20
				knockout_chance += power
				if(health <= 40) knockout_chance += 40
			if(prob(knockout_chance))
				apply_effect(20, PARALYZE, armor)
				visible_message("\red <B>[src] has been knocked unconscious!</B>")
				if(src != user)
					ticker.mode.remove_revolutionary(mind)

			if(bloody)//Apply blood
				if(wear_mask)				wear_mask.add_blood(src)
				if(head)					head.add_blood(src)
				if(glasses && prob(33))		glasses.add_blood(src)

		if("chest")//Easier to score a stun but lasts less time
			var/knockdown_chance = 0
			if(power >= 10)
				knockdown_chance += 10
			if(I.w_class >= 4)
				knockdown_chance *= 4
			knockdown_chance = min(knockdown_chance, 50)
			if(prob(knockdown_chance))
				apply_effect(5, WEAKEN, armor)
				visible_message("\red <B>[src] has been knocked down!</B>")

			if(bloody)
				if(src.wear_suit)	src.wear_suit.add_blood(src)
				if(src.w_uniform)	src.w_uniform.add_blood(src)

	UpdateDamageIcon()

/*
Contains most of the procs that are called when a mob is attacked by something

bullet_act
ex_act
meteor_act
emp_act

*/

/mob/living/carbon/human/bullet_act(A as obj, var/datum/organ/external/def_zone)
	//Preparing the var for grabbing the armor information, can't grab the values yet because we don't know what kind of bullet was used. --NEO

	var/obj/item/projectile/P = A//I really don't like how metroids are scattered throughout the code
	if(prob(80))
		for(var/mob/living/carbon/metroid/M in view(1,src))
			if(M.Victim == src)
				M.bullet_act(A) // the bullet hits them, not src!
				return

	var/list/hand_held_shields = list("/obj/item/weapon/shield/riot","/obj/item/weapon/melee/energy/sword")
	if(l_hand)
		if(is_type_in_list(l_hand, hand_held_shields))//Current base is the prob(50-d/3) Should likely give the things their own block prob
			if(prob(50 - round(P.damage / 3)))
				show_message("\red You block the [P.name] with your [l_hand.name]!", 4)
	if(r_hand)
		if(is_type_in_list(r_hand, hand_held_shields))
			if(prob(50 - round(P.damage / 3)))
				show_message("\red You block the [P.name] with your [l_hand.name]!", 4)

	var/obj/item/weapon/cloaking_device/C = locate((/obj/item/weapon/cloaking_device) in src)
	if(C)
		if(C.active)
			C.attack_self(src)//Should shut it off
			src << "\blue Your [C.name] was disrupted!"
			stunned = max(stunned, rand(2,4))//Why in the hell did this use to be 120 para

	var/datum/organ/external/affecting
	if(!def_zone)
		var/organ = organs[ran_zone("chest")]
		if (istype(organ, /datum/organ/external))
			affecting = organ
	else
		affecting = organs["[def_zone]"]

	if(!affecting)
		return
	if(locate(/obj/item/weapon/grab, src))
		var/mob/safe = null
		if (istype(l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = l_hand
			if ((G.state == 3 && get_dir(src, A) == dir))
				safe = G.affecting
		if (istype(r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon.grab/G = r_hand
			if ((G.state == 3 && get_dir(src, A) == dir))
				safe = G.affecting
		if (safe && A)
			return safe.bullet_act(A)

	var/absorb = 0
	var/soften = 0

	for(var/i = 1, i<= P.mobdamage.len, i++)

		switch(i)
			if(1)
				var/d = P.mobdamage[BRUTE]
				if(d)
					var/list/armor = getarmor(affecting, P.flag)
					if (prob(armor["armor"]))
						absorb = 1
					else
						if(prob(armor["armor"])/2)
							soften = 1
							d = d / 2


						if(!P.nodamage) affecting.take_damage(d, 0)
						UpdateDamageIcon()
						updatehealth()
			if(2)
				var/d = P.mobdamage[BURN]
				if(d)
					var/list/armor = getarmor(affecting, P.flag)
					if (prob(armor["armor"]))
						absorb = 1
					else
						if(prob(armor["armor"])/2)
							soften = 1
							d = d / 2


						if(!P.nodamage) affecting.take_damage(0, d)
						UpdateDamageIcon()
						updatehealth()
			if(3)
				var/d = P.mobdamage[TOX]
				if(d)
					var/list/armor = getarmor(affecting, P.flag)
					if (prob(armor["armor"]))
						absorb = 1
					else
						if(prob(armor["armor"])/2)
							soften = 1
							d = d / 2


						if(!P.nodamage) toxloss += d
						UpdateDamageIcon()
						updatehealth()
			if(4)
				var/d = P.mobdamage[OXY]
				if(d)
					var/list/armor = getarmor(affecting, P.flag)
					if (prob(armor["armor"]))
						absorb = 1
					else
						if(prob(armor["armor"])/2)
							soften = 1
							d = d / 2


						if(!P.nodamage) oxyloss += d
						UpdateDamageIcon()
						updatehealth()
			if(5)
				var/d = P.mobdamage[CLONE]
				if(d)
					var/list/armor = getarmor(affecting, P.flag)
					if (prob(armor["armor"]))
						absorb = 1
					else
						if(prob(armor["armor"])/2)
							soften = 1
							d = d / 2


						if(!nodamage) cloneloss += d
						UpdateDamageIcon()
						updatehealth()




	///////////////////  All the unique projectile stuff goes here ///////////////////

	if(absorb)
		show_message("\red Your armor absorbs the blow!", 4)
		return // a projectile can be deflected/absorbed given the right amount of protection
	if(soften)
		show_message("\red Your armor only softens the blow!", 4)

	var/nostutter = 0

	if(P.effects["stun"] && prob(P.effectprob["stun"]))
		var/list/armor = getarmor(affecting, "taser")
		if (!prob(armor["armor"]))
			if(P.effectmod["stun"] == SET)
				stunned = P.effects["stun"]
			else
				stunned += P.effects["stun"]
		else
			nostutter = 1


	if(P.effects["weak"] && prob(P.effectprob["weak"]))
		if(P.effectmod["weak"] == SET)
			weakened = P.effects["weak"]
		else
			weakened += P.effects["weak"]

	if(P.effects["paralysis"] && prob(P.effectprob["paralysis"]))
		if(P.effectmod["paralysis"] == SET)
			paralysis = P.effects["paralysis"]
		else
			paralysis += P.effects["paralysis"]

	if(P.effects["stutter"] && prob(P.effectprob["stutter"]) && !nostutter)
		if(P.effectmod["stutter"] == SET)
			stuttering = P.effects["stutter"]
		else
			stuttering += P.effects["stutter"]

	if(P.effects["drowsyness"] && prob(P.effectprob["drowsyness"]))
		if(P.effectmod["drowsyness"] == SET)
			drowsyness = P.effects["drowsyness"]
		else
			drowsyness += P.effects["drowsyness"]

	if(P.effects["radiation"] && prob(P.effectprob["radiation"]))
		var/list/armor = getarmor(affecting, "rad")
		if (!prob(armor["armor"]))
			if(P.effectmod["radiation"] == SET)
				radiation = P.effects["radiation"]
			else
				radiation += P.effects["radiation"]

	if(P.effects["eyeblur"] && prob(P.effectprob["eyeblur"]))
		if(P.effectmod["eyeblur"] == SET)
			eye_blurry = P.effects["eyeblur"]
		else
			eye_blurry += P.effects["eyeblur"]

	if(P.effects["emp"])
		var/emppulse = P.effects["emp"]
		if(prob(P.effectprob["emp"]))
			empulse(src, emppulse, emppulse)
		else
			empulse(src, 0, emppulse)

	return




/mob/living/carbon/human/proc/getarmor(var/datum/organ/external/def_zone, var/type)
	var/armorval = 0
	var/organnum = 0


	if(istype(def_zone))
		return checkarmor(def_zone, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value. --NEO

	else
		//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
		for(var/organ_name in organs)
			var/datum/organ/external/organ = organs[organ_name]
			if (istype(organ))
				var/list/organarmor = checkarmor(organ, type)
				armorval += organarmor["armor"]
				organnum++
				//world << "Debug text: full body armor check in progress, [organ.name] is best protected against [type] damage by [organarmor["clothes"]], with a value of [organarmor["armor"]]"
		//world << "Debug text: full body armor check complete, average of [armorval/organnum] protection against [type] damage."
		return armorval/organnum

	return 0

/mob/living/carbon/human/proc/checkarmor(var/datum/organ/external/def_zone, var/type)
	if (!type)
		return
	var/obj/item/clothing/best
	var/armorval = 0

	//I don't really like the way this is coded, but I can't think of a better way to check what they're actually wearing as opposed to something they're holding. --NEO

	if(head && istype(head,/obj/item/clothing))
		if(def_zone.body_part & head.body_parts_covered)
			if(head.armor[type] > armorval)
				armorval = head.armor[type]
				best = head

	if(wear_mask && istype(wear_mask,/obj/item/clothing))
		if(def_zone.body_part & wear_mask.body_parts_covered)
			if(wear_mask.armor[type] > armorval)
				armorval = wear_mask.armor[type]
				best = wear_mask

	if(wear_suit && istype(wear_suit,/obj/item/clothing))
		if(def_zone.body_part & wear_suit.body_parts_covered)
			if(wear_suit.armor[type] > armorval)
				armorval = wear_suit.armor[type]
				best = wear_suit

	if(w_uniform && istype(w_uniform,/obj/item/clothing))
		if(def_zone.body_part & w_uniform.body_parts_covered)
			if(w_uniform.armor[type] > armorval)
				armorval = w_uniform.armor[type]
				best = w_uniform

	if(shoes && istype(shoes,/obj/item/clothing))
		if(def_zone.body_part & shoes.body_parts_covered)
			if(shoes.armor[type] > armorval)
				armorval = shoes.armor[type]
				best = shoes

	if(gloves && istype(gloves,/obj/item/clothing))
		if(def_zone.body_part & gloves.body_parts_covered)
			if(gloves.armor[type] > armorval)
				armorval = gloves.armor[type]
				best = gloves

	var/list/result = list(clothes = best, armor = armorval)
	return result




/mob/living/carbon/human/emp_act(severity)
	/*if(wear_suit) wear_suit.emp_act(severity)
	if(w_uniform) w_uniform.emp_act(severity)
	if(shoes) shoes.emp_act(severity)
	if(belt) belt.emp_act(severity)
	if(gloves) gloves.emp_act(severity)
	if(glasses) glasses.emp_act(severity)
	if(head) head.emp_act(severity)
	if(ears) ears.emp_act(severity)
	if(wear_id) wear_id.emp_act(severity)
	if(r_store) r_store.emp_act(severity)
	if(l_store) l_store.emp_act(severity)
	if(s_store) s_store.emp_act(severity)
	if(h_store) h_store.emp_act(severity)
	..()*/
	for(var/obj/O in src)
		if(!O)	continue
		O.emp_act(severity)
	..()

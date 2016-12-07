
/mob/living/carbon/monkey/get_eye_protection()
	var/number = ..()
	if(istype(src.wear_mask, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/MFP = src.wear_mask
		number += MFP.flash_protect
	return number

/mob/living/carbon/monkey/help_shake_act(mob/living/carbon/M)
	if(health < 0 && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.do_cpr(src)
	else
		..()

/mob/living/carbon/monkey/attack_paw(mob/living/M)
	if(..()) //successful monkey bite.
		var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart("chest")
		if(M.limb_destroyer)
			dismembering_strike(M, affecting.body_zone)
		if(stat != DEAD)
			var/dmg = rand(1, 5)
			apply_damage(dmg, BRUTE, affecting)
			damage_clothes(dmg, BRUTE, "melee", affecting.body_zone)



/mob/living/carbon/monkey/attack_larva(mob/living/carbon/alien/larva/L)
	if(..()) //successful larva bite.
		var/damage = rand(1, 3)
		if(stat != DEAD)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(L.zone_selected))
			if(!affecting)
				affecting = get_bodypart("chest")
			apply_damage(damage, BRUTE, affecting)
			damage_clothes(damage, BRUTE, "melee", affecting.body_zone)

/mob/living/carbon/monkey/attack_hand(mob/living/carbon/human/M)
	if(..())	//To allow surgery to return properly.
		return

	switch(M.a_intent)
		if("help")
			help_shake_act(M)
		if("grab")
			grabbedby(M)
		if("harm")
			M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			if (prob(75))
				visible_message("<span class='danger'>[M] has punched [name]!</span>", \
						"<span class='userdanger'>[M] has punched [name]!</span>", null, COMBAT_MESSAGE_RANGE)

				playsound(loc, "punch", 25, 1, -1)
				var/damage = rand(5, 10)
				if (prob(40))
					damage = rand(10, 15)
					if ( (paralysis < 5)  && (health > 0) )
						Paralyse(rand(10, 15))
						visible_message("<span class='danger'>[M] has knocked out [name]!</span>", \
									"<span class='userdanger'>[M] has knocked out [name]!</span>", null, 5)
				var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
				if(!affecting)
					affecting = get_bodypart("chest")
				apply_damage(damage, BRUTE, affecting)
				damage_clothes(damage, BRUTE, "melee", affecting.body_zone)
				add_logs(M, src, "attacked")

			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to punch [name]!</span>", \
					"<span class='userdanger'>[M] has attempted to punch [name]!</span>", null, COMBAT_MESSAGE_RANGE)
		if("disarm")
			if (!paralysis)
				M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
				if (prob(25))
					Paralyse(2)
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					add_logs(M, src, "pushed")
					visible_message("<span class='danger'>[M] has pushed down [src]!</span>", \
						"<span class='userdanger'>[M] has pushed down [src]!</span>", null, COMBAT_MESSAGE_RANGE)
				else
					if(drop_item())
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						visible_message("<span class='danger'>[M] has disarmed [src]!</span>", \
							"<span class='userdanger'>[M] has disarmed [src]!</span>", null, COMBAT_MESSAGE_RANGE)

/mob/living/carbon/monkey/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent.
		if (M.a_intent == INTENT_HARM)
			if ((prob(95) && health > 0))
				playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
				var/damage = rand(15, 30)
				if (damage >= 25)
					damage = rand(20, 40)
					if (paralysis < 15)
						Paralyse(rand(10, 15))
					visible_message("<span class='danger'>[M] has wounded [name]!</span>", \
							"<span class='userdanger'>[M] has wounded [name]!</span>", null, COMBAT_MESSAGE_RANGE)
				else
					visible_message("<span class='danger'>[M] has slashed [name]!</span>", \
							"<span class='userdanger'>[M] has slashed [name]!</span>", null, COMBAT_MESSAGE_RANGE)

				var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
				add_logs(M, src, "attacked")
				if(!affecting)
					affecting = get_bodypart("chest")
				if(!dismembering_strike(M, affecting.body_zone)) //Dismemberment successful
					return 1
				apply_damage(damage, BRUTE, affecting)
				damage_clothes(damage, BRUTE, "melee", affecting.body_zone)

			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to lunge at [name]!</span>", \
						"<span class='userdanger'>[M] has attempted to lunge at [name]!</span>", null, COMBAT_MESSAGE_RANGE)
		if (M.a_intent == INTENT_DISARM)
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			if(prob(95))
				Weaken(10)
				visible_message("<span class='danger'>[M] has tackled down [name]!</span>", \
						"<span class='userdanger'>[M] has tackled down [name]!</span>", null, COMBAT_MESSAGE_RANGE)
			else
				if(drop_item())
					visible_message("<span class='danger'>[M] has disarmed [name]!</span>", \
							"<span class='userdanger'>[M] has disarmed [name]!</span>", null, COMBAT_MESSAGE_RANGE)
			add_logs(M, src, "disarmed")
			updatehealth()


/mob/living/carbon/monkey/attack_animal(mob/living/simple_animal/M)
	if(..())
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		var/dam_zone = dismembering_strike(M, pick("chest", "l_hand", "r_hand", "l_leg", "r_leg"))
		if(!dam_zone) //Dismemberment successful
			return 1
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart("chest")
		apply_damage(damage, M.melee_damage_type, affecting)
		damage_clothes(damage, M.melee_damage_type, "melee", affecting.body_zone)



/mob/living/carbon/monkey/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = rand(5, 35)
		if(M.is_adult)
			damage = rand(20, 40)
		var/dam_zone = dismembering_strike(M, pick("head", "chest", "l_arm", "r_arm", "l_leg", "r_leg"))
		if(!dam_zone) //Dismemberment successful
			return 1
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart("chest")
		apply_damage(damage, BRUTE, affecting)
		damage_clothes(damage, BRUTE, "melee", affecting.body_zone)


/mob/living/carbon/monkey/acid_act(acidpwr, acid_volume, bodyzone_hit)
	. = 1
	if(!bodyzone_hit || bodyzone_hit == "head")
		if(wear_mask)
			if(!(wear_mask.resistance_flags & UNACIDABLE))
				wear_mask.acid_act(acidpwr)
			else
				src << "<span class='warning'>Your mask protects you from the acid.</span>"
			return
		if(head)
			if(!(head.resistance_flags & UNACIDABLE))
				head.acid_act(acidpwr)
			else
				src << "<span class='warning'>Your hat protects you from the acid.</span>"
			return
	take_bodypart_damage(acidpwr * min(0.6, acid_volume*0.1))


/mob/living/carbon/monkey/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()

	switch (severity)
		if (1)
			gib()
			return

		if (2)
			take_overall_damage(60, 60)
			damage_clothes(200, BRUTE, "bomb")
			adjustEarDamage(30, 120)
			if(prob(70))
				Paralyse(10)

		if(3)
			take_overall_damage(30, 0)
			damage_clothes(50, BRUTE, "bomb")
			adjustEarDamage(15,60)
			if (prob(50))
				Paralyse(8)


	//attempt to dismember bodyparts
	if(severity <= 2)
		var/max_limb_loss = round(4/severity) //so you don't lose four limbs at severity 3.
		for(var/X in bodyparts)
			var/obj/item/bodypart/BP = X
			if(prob(50/severity) && BP.body_zone != "chest")
				BP.brute_dam = BP.max_damage
				BP.dismember()
				max_limb_loss--
				if(!max_limb_loss)
					break

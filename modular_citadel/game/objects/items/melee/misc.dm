/obj/item/melee/classic_baton
	var/last_hit = 0
	var/stun_stam_cost_coeff = 1.25
	var/hardstun_ds = 1
	var/softstun_ds = 0
	var/stam_dmg = 30
	cooldown = 20
	total_mass = 3.75

/obj/item/melee/classic_baton/attack(mob/living/target, mob/living/user)
	if(!on)
		return ..()

	if(user.getStaminaLoss() >= STAMINA_SOFTCRIT)//CIT CHANGE - makes batons unusuable in stamina softcrit
		to_chat(user, "<span class='warning'>You're too exhausted for that.</span>")//CIT CHANGE - ditto
		return //CIT CHANGE - ditto

	add_fingerprint(user)
	if((user.has_trait(TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class ='danger'>You club yourself over the head.</span>")
		user.Knockdown(60 * force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		..()
		return
	if(!isliving(target))
		return
	if (user.a_intent == INTENT_HARM)
		if(!..())
			return
		if(!iscyborg(target))
			return
	else
		if(last_hit + cooldown < world.time)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				if (H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
					return
				if(check_martial_counter(H, user))
					return
			playsound(get_turf(src), 'sound/effects/woodhit.ogg', 75, 1, -1)
			target.Knockdown(softstun_ds, TRUE, FALSE, hardstun_ds, stam_dmg)
			add_logs(user, target, "stunned", src)
			src.add_fingerprint(user)
			target.visible_message("<span class ='danger'>[user] has knocked down [target] with [src]!</span>", \
				"<span class ='userdanger'>[user] has knocked down [target] with [src]!</span>")
			if(!iscarbon(user))
				target.LAssailant = null
			else
				target.LAssailant = user
			last_hit = world.time
			user.adjustStaminaLossBuffered(getweight())//CIT CHANGE - makes swinging batons cost stamina



/mob/living/carbon/alien/humanoid/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.a_intent == INTENT_HARM)
		..(user, 1)
		adjustBruteLoss(15)
		var/hitverb = "punches"
		if(mob_size < MOB_SIZE_LARGE)
			step_away(src,user,15)
			sleep(1)
			step_away(src,user,15)
			hitverb = "slams"
		playsound(loc, "punch", 25, 1, -1)
		visible_message("<span class='danger'>[user] [hitverb] [src]!</span>", \
		"<span class='userdanger'>[user] [hitverb] you!</span>", null, COMBAT_MESSAGE_RANGE)
		return 1

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M)
	if(..())
		switch(M.a_intent)
			if ("harm")
				var/damage = rand(1, 9)
				if (prob(90))
					playsound(loc, "punch", 25, 1, -1)
					visible_message("<span class='danger'>[M] punches [src]!</span>", \
							"<span class='userdanger'>[M] punches you!</span>", null, COMBAT_MESSAGE_RANGE)
					if ((stat != DEAD) && (damage > 9 || prob(5)))//Regular humans have a very small chance of knocking an alien down.
						Unconscious(40)
						visible_message("<span class='danger'>[M] knocks [src] down!</span>", \
								"<span class='userdanger'>[M] knocks you down!</span>")
					var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
					apply_damage(damage, BRUTE, affecting)
					log_combat(M, src, "attacked")
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
					visible_message("<span class='danger'>[M]'s punch misses [src]!</span>", \
						"<span class='userdanger'>[M]'s punch misses you!</span>", null, COMBAT_MESSAGE_RANGE)

			if ("disarm")
				if (!(mobility_flags & MOBILITY_STAND))
					if (prob(5))
						Unconscious(40)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						log_combat(M, src, "pushed")
						visible_message("<span class='danger'>[M] pushed [src] down!</span>", \
							"<span class='userdanger'>[M] pushed you down!</span>")
					else
						if (prob(50))
							dropItemToGround(get_active_held_item())
							playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
							visible_message("<span class='danger'>[M] disarms [src]!</span>", \
							"<span class='userdanger'>[M] disarms you!</span>", null, COMBAT_MESSAGE_RANGE)
						else
							playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
							visible_message("<span class='danger'>[M] fails to disarm [src]!</span>",\
								"<span class='userdanger'>[M] fails to disarm you!</span>", null, COMBAT_MESSAGE_RANGE)



/mob/living/carbon/alien/humanoid/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()


/mob/living/carbon/alien/humanoid/grabbedby(mob/living/carbon/user, supress_message = 0)
	if(user == src && pulling && grab_state >= GRAB_AGGRESSIVE && !pulling.anchored && iscarbon(pulling))
		devour_mob(pulling, devour_time = 60)
	else
		..()

/mob/living/carbon/alien/humanoid/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.a_intent == INTENT_HARM)
		..(user, 1)
		adjustBruteLoss(15)
		var/hitverb = "punched"
		if(mob_size < MOB_SIZE_LARGE)
			step_away(src,user,15)
			sleep(1)
			step_away(src,user,15)
			hitverb = "slammed"
		playsound(loc, "punch", 25, 1, -1)
		visible_message("<span class='danger'>[IDENTITY_SUBJECT(1)] has [hitverb] [IDENTITY_SUBJECT(2)]!</span>", \
		"<span class='userdanger'>[IDENTITY_SUBJECT(1)] has [hitverb] [IDENTITY_SUBJECT(2)]!</span>", null, COMBAT_MESSAGE_RANGE, subjects=list(user, src))
		return 1

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M)
	if(..())
		switch(M.a_intent)
			if ("harm")
				var/damage = rand(1, 9)
				if (prob(90))
					playsound(loc, "punch", 25, 1, -1)
					visible_message("<span class='danger'>[IDENTITY_SUBJECT(1)] has punched [IDENTITY_SUBJECT(2)]!</span>", \
							"<span class='userdanger'>[IDENTITY_SUBJECT(1)] has punched [IDENTITY_SUBJECT(2)]!</span>", null, COMBAT_MESSAGE_RANGE, subjects=list(M, src))
					if ((stat != DEAD) && (damage > 9 || prob(5)))//Regular humans have a very small chance of weakening an alien.
						Paralyse(2)
						visible_message("<span class='danger'>[IDENTITY_SUBJECT(1)] has weakened [IDENTITY_SUBJECT(2)]!</span>", \
								"<span class='userdanger'>[IDENTITY_SUBJECT(1)] has weakened [IDENTITY_SUBJECT(2)]!</span>", subjects=list(M, src))
					var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
					apply_damage(damage, BRUTE, affecting)
					add_logs(M, src, "attacked")
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
					visible_message("<span class='userdanger'>[IDENTITY_SUBJECT(1)] has attempted to punch [IDENTITY_SUBJECT(2)]!</span>", \
						"<span class='userdanger'>[IDENTITY_SUBJECT(1)] has attempted to punch [IDENTITY_SUBJECT(2)]!</span>", null, COMBAT_MESSAGE_RANGE, subjects=list(M, src))

			if ("disarm")
				if (!lying)
					if (prob(5))
						Paralyse(2)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						add_logs(M, src, "pushed")
						visible_message("<span class='danger'>[IDENTITY_SUBJECT(1)] has pushed down [IDENTITY_SUBJECT(2)]!</span>", \
							"<span class='userdanger'>[IDENTITY_SUBJECT(1)] has pushed down [IDENTITY_SUBJECT(2)]!</span>", subjects=list(M, src))
					else
						if (prob(50))
							drop_item()
							playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
							visible_message("<span class='danger'>[IDENTITY_SUBJECT(1)] has disarmed [IDENTITY_SUBJECT(2)]!</span>", \
							"<span class='userdanger'>[IDENTITY_SUBJECT(1)] has disarmed [IDENTITY_SUBJECT(2)]!</span>", null, COMBAT_MESSAGE_RANGE, subjects=list(M, src))
						else
							playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
							visible_message("<span class='userdanger'>[IDENTITY_SUBJECT(1)] has attempted to disarm [IDENTITY_SUBJECT(2)]!</span>",\
								"<span class='userdanger'>[IDENTITY_SUBJECT(1)] has attempted to disarm [IDENTITY_SUBJECT(2)]!</span>", null, COMBAT_MESSAGE_RANGE, subjects=list(M, src))



/mob/living/carbon/alien/humanoid/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect, end_pixel_y)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()

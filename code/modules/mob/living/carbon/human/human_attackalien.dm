/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(check_shields(0, M.name))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>")
		return 0

	if(..())
		if(M.a_intent == "harm")
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = prob(90) ? 20 : 0
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M] has lunged at [src]!</span>", \
					"<span class='userdanger'>[M] has lunged at [src]!</span>")
				return 0
			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
			var/armor_block = run_armor_check(affecting, "melee","","",10)

			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
				"<span class='userdanger'>[M] has slashed at [src]!</span>")
			if(!dismembering_strike(M, M.zone_selected)) //Dismemberment successful
				return 1
			apply_damage(damage, BRUTE, affecting, armor_block)
			add_logs(M, src, "attacked")
			updatehealth()

		if(M.a_intent == "disarm") //Always drop item in hand, if no item, get stunned instead.
			if(get_active_held_item() && drop_item())
				playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] disarmed [src]!</span>", \
						"<span class='userdanger'>[M] disarmed [src]!</span>")
			else
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				Weaken(5)
				add_logs(M, src, "tackled")
				visible_message("<span class='danger'>[M] has tackled down [src]!</span>", \
					"<span class='userdanger'>[M] has tackled down [src]!</span>")
	return

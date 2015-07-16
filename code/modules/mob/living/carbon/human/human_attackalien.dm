/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(check_shields(0, M.name))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>")
		return 0

	if(..())
		if(M.a_intent == "harm")
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = rand(15, 30)
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M] has lunged at [src]!</span>", \
					"<span class='userdanger'>[M] has lunged at [src]!</span>")
				return 0
			var/obj/item/organ/limb/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee","","",10)

			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
				"<span class='userdanger'>[M] has slashed at [src]!</span>")

			apply_damage(damage, BRUTE, affecting, armor_block)
			if (damage >= 25)
				visible_message("<span class='danger'>[M] has wounded [src]!</span>", \
					"<span class='userdanger'>[M] has wounded [src]!</span>")
				apply_effect(4, WEAKEN, armor_block)
				add_logs(M, src, "attacked", admin=0)
			updatehealth()

		if(M.a_intent == "disarm")
			var/randn = rand(1, 100)
			if (randn <= 80)
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				Weaken(5)
				add_logs(M, src, "tackled", admin=0)
				visible_message("<span class='danger'>[M] has tackled down [src]!</span>", \
					"<span class='userdanger'>[M] has tackled down [src]!</span>")
			else
				if (randn <= 99)
					playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
					drop_item()
					visible_message("<span class='danger'>[M] disarmed [src]!</span>", \
						"<span class='userdanger'>[M] disarmed [src]!</span>")
				else
					playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[M] has tried to disarm [src]!</span>", \
						"<span class='userdanger'>[M] has tried to disarm [src]!</span>")
	return

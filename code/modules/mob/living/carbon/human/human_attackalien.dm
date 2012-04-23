/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(check_shields(0, M.name))
		visible_message("\red <B>[M] attempted to touch [src]!</B>")
		return 0

	switch(M.a_intent)
		if ("help")
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\blue [M] caresses [src] with its scythe like arm."), 1)
		if ("grab")
			if(M == src)	return
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			grabbed_by += G
			G.synch()
			LAssailant = M

			playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)

		if("hurt")
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = rand(15, 30)
			if(!damage)
				playsound(loc, 'slashmiss.ogg', 50, 1, -1)
				visible_message("\red <B>[M] has lunged at [src]!</B>")
				return 0
			var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			playsound(loc, 'slice.ogg', 25, 1, -1)
			visible_message("\red <B>[M] has slashed at [src]!</B>")

			apply_damage(damage, BRUTE, affecting, armor_block)
			if (damage >= 25)
				visible_message("\red <B>[M] has wounded [src]!</B>")
				apply_effect(4, WEAKEN, armor_block)
			UpdateDamageIcon()
			updatehealth()

		if("disarm")
			var/randn = rand(1, 100)
			if (randn <= 90)
				playsound(loc, 'pierce.ogg', 25, 1, -1)
				Weaken(rand(10,15))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has tackled down []!</B>", M, src), 1)
			else
				if (randn <= 99)
					playsound(loc, 'slash.ogg', 25, 1, -1)
					drop_item()
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] disarmed []!</B>", M, src), 1)
				else
					playsound(loc, 'slashmiss.ogg', 50, 1, -1)
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has tried to disarm []!</B>", M, src), 1)
	update_clothing()
	return
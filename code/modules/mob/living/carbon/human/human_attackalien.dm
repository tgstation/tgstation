<<<<<<< HEAD
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
			if (prob(30))
				visible_message("<span class='danger'>[M] has wounded [src]!</span>", \
					"<span class='userdanger'>[M] has wounded [src]!</span>")
				apply_effect(4, WEAKEN, armor_block)
				add_logs(M, src, "attacked")
			updatehealth()

		if(M.a_intent == "disarm")
			var/randn = rand(1, 100)
			if (randn <= 80)
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				Weaken(5)
				add_logs(M, src, "tackled")
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
=======
/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	//M.delayNextAttack(10)
	if(check_shields(0, M.name))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>")
		return 0

	switch(M.a_intent)
		if (I_HELP)
			visible_message(text("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>"))
		if (I_GRAB)
			if(M == src || anchored)
				return
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/obj/item/weapon/grab/G = getFromPool(/obj/item/weapon/grab,M,src)

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()
			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message(text("<span class='warning'>[] has grabbed [] passively!</span>", M, src))

		if(I_HURT)
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = rand(15, 30)
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M] has lunged at [src]!</span>")
				return 0
			var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>")

			apply_damage(damage, BRUTE, affecting, armor_block)
			if (damage >= 25)
				visible_message("<span class='danger'>[M] has wounded [src]!</span>")
				apply_effect(rand(0.5,3), WEAKEN, armor_block)
			updatehealth()

		if(I_DISARM)
			if (prob(80))
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				Weaken(rand(3,4))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("<span class='danger'>[] has tackled down []!</span>", M, src), 1)
				if (prob(25))
					M.Weaken(rand(4,5))
			else
				if (prob(80))
					playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
					drop_item()
					visible_message(text("<span class='danger'>[] disarmed []!</span>", M, src))
				else
					playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
					visible_message(text("<span class='danger'>[] has tried to disarm []!</span>", M, src))
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

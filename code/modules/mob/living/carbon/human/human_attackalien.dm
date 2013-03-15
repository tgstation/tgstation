/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(check_shields(0, M.name))
		visible_message("\red <B>[M] attempted to touch [src]!</B>")
		return 0

	switch(M.a_intent)
		if ("help")
			visible_message(text("\blue [M] caresses [src] with its scythe like arm."))
		if ("grab")
			if(M == src)	return
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src)

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()
			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message(text("\red [] has grabbed [] passively!", M, src))

		if("harm")
			var/modifier = 1 // Aliens are sneaky creatures, they can do certain things
			if (w_uniform && M.m_intent != "walk") // Sneaky stabbings only leave holes
				w_uniform.add_fingerprint(M)
			if(M.m_intent == "walk")
				switch(M.caste) // If we're in sneaky mode, do an damage based on caste.
					if("d")
						modifier = 1.1
					if("h")
						modifier = 1.7
					if("s")
						modifier = 1.5
					if("q")
						modifier = 2
				M.m_intent = "run"
				M.update_icons()
			//borrowed from life.dm
			var/light_amount = 0
			if(isturf(get_turf(M)))
				var/turf/T = get_turf(M)
				var/area/A = T.loc
				if(A)
					if(A.lighting_use_dynamic)	light_amount = T.lighting_lumcount
					else						light_amount =  10
			//end the borrowing
			if(light_amount < 3)
				modifier += 2 // Adding two to get 3.5 or 3, aliens attacking from the dark are deadly.
			var/damage = rand(10*modifier, 20*modifier)
			switch(M.caste) // Add or remove damage based on caste
				if("d")
					damage -= 2
				if("h")
					damage += 2
				if("s")
					damage += 3
				if("q")
					damage -= 5 // Queenie is slow and her attacks tend to just whap people's faces.
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
				visible_message("\red <B>[M] has lunged at [src]!</B>")
				return 0
			var/datum/limb/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")
			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message("\red <B>[M] has slashed at [src]!</B>")
			apply_damage(damage, BRUTE, affecting, armor_block)
			if (damage >= 25)
				visible_message("\red <B>[M] has mauled [src]!</B>")
				apply_effect(4, WEAKEN, armor_block)
			updatehealth()

		if("disarm")
			var/randn = rand(1, 100)
			if (randn <= 80)
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				Weaken(10)
				visible_message(text("\red <B>[] has tackled down []!</B>", M, src))
			else
				if (randn <= 99)
					playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
					drop_item()
					visible_message(text("\red <B>[] disarmed []!</B>", M, src))
				else
					playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
					visible_message(text("\red <B>[] has tried to disarm []!</B>", M, src))
	return
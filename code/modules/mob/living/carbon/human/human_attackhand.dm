/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M as mob)
	//M.delayNextAttack(10)
	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	var/datum/organ/external/temp = M:organs_by_name["r_hand"]
	if (M.hand)
		temp = M:organs_by_name["l_hand"]
	if(temp && !temp.is_usable())
		to_chat(M, "<span class='warning'>You can't use your [temp.display_name].</span>")
		return

	..()

	if((M != src) && check_shields(0, M.name))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>")
		return 0


	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.cell)
			if(M.a_intent == I_HURT)//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.use(2500)
					visible_message("<span class='danger'>[src] has been touched with the stun gloves by [M]!</span>")
					M.attack_log += text("\[[time_stamp()]\] <font color='red'>Stungloved [src.name] ([src.ckey])</font>")
					src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stungloved by [M.name] ([M.ckey])</font>")
					if(!iscarbon(M))
						LAssailant = null
					else
						LAssailant = M

					log_attack("<font color='red'>[M.name] ([M.ckey]) stungloved [src.name] ([src.ckey])</font>")

					var/armorblock = run_armor_check(M.zone_sel.selecting, "energy")
					apply_effects(5,5,0,0,5,0,0,armorblock)
					return 1
				else
					to_chat(M, "<span class='warning'>Not enough charge! </span>")
					visible_message("<span class='danger'>[src] has been touched with the stun gloves by [M]!</span>")
				return

		if(istype(M.gloves , /obj/item/clothing/gloves/boxing/hologlove))

			var/damage = rand(0, 9)
			if(!damage)
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to punch [src]!</span>")
				return 0
			var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			if(M_HULK in M.mutations)			damage += 5

			playsound(loc, "punch", 25, 1, -1)

			visible_message("<span class='danger'>[M] has punched [src]!</span>")

			apply_damage(damage, HALLOSS, affecting, armor_block)
			if(damage >= 9)
				visible_message("<span class='danger'>[M] has weakened [src]!</span>")
				apply_effect(4, WEAKEN, armor_block)

			return
	else
		if(istype(M,/mob/living/carbon))
//			log_debug("No gloves, [M] is truing to infect [src]")
			M.spread_disease_to(src, "Contact")


	switch(M.a_intent)
		if(I_HELP)
			if(health >= config.health_threshold_crit)
				help_shake_act(M)
				return 1
//			if(M.health < -75)	return 0

			if(M.check_body_part_coverage(MOUTH))
				to_chat(M, "<span class='notice'><B>Remove your [M.get_body_part_coverage(MOUTH)]!</B></span>")
				return 0
			if(src.check_body_part_coverage(MOUTH))
				to_chat(M, "<span class='notice'><B>Remove his [src.get_body_part_coverage(MOUTH)]!</B></span>")
				return 0

			var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human()
			O.source = M
			O.target = src
			O.s_loc = M.loc
			O.t_loc = loc
			O.place = "CPR"
			requests += O
			spawn(0)
				O.process()
			return 1

		if(I_GRAB)
			if(M == src || anchored)
				return 0
			if(w_uniform)
				w_uniform.add_fingerprint(M)

			var/obj/item/weapon/grab/G = getFromPool(/obj/item/weapon/grab,M,src)
			if(locked_to)
				to_chat(M, "<span class='notice'>You cannot grab [src], \he is buckled in!</span>")
			if(!G)	//the grab will delete itself in New if affecting is anchored
				return
			M.put_in_active_hand(G)
			grabbed_by += G
			G.synch()
			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='warning'>[M] has grabbed [src] passively!</span>")
			return 1

		if(I_HURT)
			//Vampire code
			if(M.zone_sel && M.zone_sel.selecting == "head" && src != M)
				if(M.mind && M.mind.vampire && (M.mind in ticker.mode.vampires) && !M.mind.vampire.draining)
					if(src.check_body_part_coverage(MOUTH))
						to_chat(M, "<span class='warning'>Remove their mask!</span>")
						return 0
					if(M.check_body_part_coverage(MOUTH))
						if(M.species.breath_type == "oxygen")
							to_chat(M, "<span class='warning'>Remove your mask!</span>")
							return 0
						else
							to_chat(M, "<span class='notice'>With practiced ease, you shift aside your mask for each gulp of blood.</span>")
					if(mind && mind.vampire && (mind in ticker.mode.vampires))
						to_chat(M, "<span class='warning'>Your fangs fail to pierce [src.name]'s cold flesh.</span>")
						return 0
					//we're good to suck the blood, blaah
					M.handle_bloodsucking(src)
					return
			//end vampire codes

			// BITING
			var/can_bite = 0
			for(var/datum/disease/D in M.viruses)
				if(D.spread == "Bite")
					can_bite = 1
					break
			if(can_bite)
				if ((prob(75) && health > 0))
					playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
					src.visible_message("<span class='danger'>[M.name] has bit [name]!</span>")

					var/damage = rand(1, 5)
					adjustBruteLoss(damage)
					health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
					for(var/datum/disease/D in M.viruses)
						if(D.spread == "Bite")
							contract_disease(D,1,0)
					M.attack_log += text("\[[time_stamp()]\] <font color='red'>bitten by [src.name] ([src.ckey])</font>")
					src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been bitten by [M.name] ([M.ckey])</font>")
					if(!iscarbon(M))
						LAssailant = null
					else
						LAssailant = M
					log_attack("[M.name] ([M.ckey]) bitten by [src.name] ([src.ckey])")
					return
			//end biting

			M.attack_log += text("\[[time_stamp()]\] <font color='red'>[M.species.attack_verb]ed [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [M.species.attack_verb]ed by [M.name] ([M.ckey])</font>")
			if(!iscarbon(M))
				LAssailant = null
			else
				LAssailant = M

			log_attack("[M.name] ([M.ckey]) [M.species.attack_verb]ed [src.name] ([src.ckey])")


			var/damage = rand(0, M.species.max_hurt_damage)//BS12 EDIT // edited again by Iamgoofball to fix species attacks
			if(!damage)
				if(M.species.attack_verb == "punch")
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				else
					playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)

				visible_message("<span class='danger'>[M] has attempted to [M.species.attack_verb] [src]!</span>")
				return 0


			var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			if(M_HULK in M.mutations)							damage += 5
			if((M_CLAWS in M.mutations) && !istype(M.gloves))	damage += 3 //Claws mutation + no gloves


			if(M.species.attack_verb == "punch")
				playsound(loc, "punch", 25, 1, -1)
			else
				playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)

			visible_message("<span class='danger'>[M] has [M.species.attack_verb]ed [src]!</span>")
			//Rearranged, so claws don't increase weaken chance.
			if(damage >= M.species.max_hurt_damage && prob(50))
				visible_message("<span class='danger'>[M] has weakened [src]!</span>")
				apply_effect(2, WEAKEN, armor_block)

			if(M.species.punch_damage)
				damage += M.species.punch_damage
			apply_damage(damage, BRUTE, affecting, armor_block)

			// Horror form can punch people so hard they learn how to fly.
			if(M.species.punch_throw_range && prob(25))
				visible_message("<span class='danger'>[src] is thrown by the force of the assault!</span>")
				var/turf/T = get_turf(src)
				var/turf/target
				if(istype(T, /turf/space)) // if ended in space, then range is unlimited
					target = get_edge_target_turf(T, M.dir)
				else						// otherwise limit to 10 tiles
					target = get_ranged_target_turf(T, M.dir, M.species.punch_throw_range)
				src.throw_at(target,100,M.species.punch_throw_speed)

			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.zone_sel && H.zone_sel.selecting == "mouth")
					var/chance = 0.5 * damage
					if(M_HULK in H.mutations) chance += 50
					if(prob(chance))
						knock_out_teeth(H)


		if(I_DISARM)
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>Disarmed [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [M.name] ([M.ckey])</font>")

			log_attack("[M.name] ([M.ckey]) disarmed [src.name] ([src.ckey])")

			if(w_uniform)
				w_uniform.add_fingerprint(M)
			var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))

			if (istype(r_hand,/obj/item/weapon/gun) || istype(l_hand,/obj/item/weapon/gun))
				var/obj/item/weapon/gun/W = null
				var/chance = 0

				if (istype(l_hand,/obj/item/weapon/gun))
					W = l_hand
					chance = hand ? 40 : 20

				if (istype(r_hand,/obj/item/weapon/gun))
					W = r_hand
					chance = !hand ? 40 : 20

				if (prob(chance))
					visible_message("<spawn class=danger>[W], held by [src], goes off during struggle!")
					var/list/turfs = list()
					for(var/turf/T in view())
						turfs += T
					var/turf/target = pick(turfs)
					return W.afterattack(target,src, "struggle" = 1)

			var/randn = rand(1, 100)
			if (randn <= 25)
				apply_effect(4, WEAKEN, run_armor_check(affecting, "melee"))
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M] has pushed [src]!</span>")
				M.attack_log += text("\[[time_stamp()]\] <font color='red'>Pushed [src.name] ([src.ckey])</font>")
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been pushed by [M.name] ([M.ckey])</font>")
				if(!iscarbon(M))
					LAssailant = null
				else
					LAssailant = M

				log_attack("[M.name] ([M.ckey]) pushed [src.name] ([src.ckey])")
				return

			var/talked = 0	// BubbleWrap

			if(randn <= 60)
				//BubbleWrap: Disarming breaks a pull
				if(pulling)
					visible_message("<span class='danger'>[M] has broken [src]'s grip on [pulling]!</span>")
					talked = 1
					stop_pulling()

				//BubbleWrap: Disarming also breaks a grab - this will also stop someone being choked, won't it?
				if(istype(l_hand, /obj/item/weapon/grab))
					var/obj/item/weapon/grab/lgrab = l_hand
					if(lgrab.affecting)
						visible_message("<span class='danger'>[M] has broken [src]'s grip on [lgrab.affecting]!</span>")
						talked = 1
					spawn(1)
						del(lgrab)
				if(istype(r_hand, /obj/item/weapon/grab))
					var/obj/item/weapon/grab/rgrab = r_hand
					if(rgrab.affecting)
						visible_message("<span class='danger'>[M] has broken [src]'s grip on [rgrab.affecting]!</span>")
						talked = 1
					spawn(1)
						del(rgrab)
				//End BubbleWrap

				if(!talked)	//BubbleWrap
					drop_item()
					visible_message("<span class='danger'>[M] has disarmed [src]!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				return


			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] attempted to disarm [src]!</span>")
	return

/mob/living/carbon/human/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return
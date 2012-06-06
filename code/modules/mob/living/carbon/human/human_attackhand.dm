/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M as mob)
	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	..()

	if((M != src) && check_shields(0, M.name))
		visible_message("\red <B>[M] attempted to touch [src]!</B>")
		return 0


	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.cell)
			if(M.a_intent == "hurt")//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.charge -= 2500
					visible_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>")
					M.attack_log += text("\[[time_stamp()]\] <font color='red'>Stungloved [src.name] ([src.ckey])</font>")
					src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stungloved by [M.name] ([M.ckey])</font>")


					log_admin("ATTACK: [src] ([src.ckey]) stungloved [M] ([M.ckey]).")
					message_admins("ATTACK: [src] ([src.ckey]) stungloved [M] ([M.ckey]).")
					log_attack("<font color='red'>[M.name] ([M.ckey]) stungloved [src.name] ([src.ckey])</font>")


					var/armorblock = run_armor_check(M.zone_sel.selecting, "energy")
					apply_effects(5,5,0,0,5,0,0,armorblock)
					return 1
				else
					M << "\red Not enough charge! "
					visible_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>")
				return

		if(istype(M.gloves , /obj/item/clothing/gloves/boxing/hologlove))

			var/damage = rand(0, 9)
			if(!damage)
				playsound(loc, 'punchmiss.ogg', 25, 1, -1)
				visible_message("\red <B>[M] has attempted to punch [src]!</B>")
				return 0
			var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			if(HULK in M.mutations)			damage += 5
			if(SUPRSTR in M.augmentations)	damage += 5

			playsound(loc, "punch", 25, 1, -1)

			visible_message("\red <B>[M] has punched [src]!</B>")

			apply_damage(damage, HALLOSS, affecting, armor_block)
			if(damage >= 9)
				visible_message("\red <B>[M] has weakened [src]!</B>")
				apply_effect(4, WEAKEN, armor_block)
			UpdateDamageIcon()

			return


	switch(M.a_intent)
		if("help")
			if(health > 0)
				help_shake_act(M)
				return 1
			if(M.health < -75)	return 0

			if((M.head && (M.head.flags & HEADCOVERSMOUTH)) || (M.wear_mask && (M.wear_mask.flags & MASKCOVERSMOUTH)))
				M << "\blue <B>Remove your mask!</B>"
				return 0
			if((head && (head.flags & HEADCOVERSMOUTH)) || (wear_mask && (wear_mask.flags & MASKCOVERSMOUTH)))
				M << "\blue <B>Remove his mask!</B>"
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

		if("grab")
			if(M == src)	return 0
			if(w_uniform)	w_uniform.add_fingerprint(M)
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M)
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
			visible_message("\red [M] has grabbed [src] passively!")
			return 1

		if("hurt")

			if(ELECTRICHANDS in M.augmentations)
				var/gendertxt = "their"
				if(M.gender == "male")
					gendertxt = "his"
				if(M.gender == "female")
					gendertxt = "her"

				visible_message("\red <B>[M] has shocked [src] with [gendertxt] bare hands!</B>")
				M.attack_log += text("\[[time_stamp()]\] <font color='red'>Used Electric Hands nanoaug power on [src.name] ([src.ckey])</font>")
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been shocked by [M.name] with the Electric Hands nanoaug ([M.ckey])</font>")

				log_admin("ATTACK: [M.name] ([M.ckey]) used Electric Hands nanoaug on [src.name] ([src.ckey]), shocking them .")
				message_admins("ATTACK: [M.name] ([M.ckey]) used Electric Hands nanoaug on [src.name] ([src.ckey]), shocking them .")
				log_attack("<font color='red'>[M.name] ([M.ckey]) used Electric Hands nanoaug on [src.name] ([src.ckey]), shocking them </font>")


				var/armorblock = run_armor_check(M.zone_sel.selecting, "energy")
				apply_effects(5,5,0,0,5,0,0,armorblock)

				return

			if(M.type != /mob/living/carbon/human/tajaran)
				M.attack_log += text("\[[time_stamp()]\] <font color='red'>Punched [src.name] ([src.ckey])</font>")
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been punched by [M.name] ([M.ckey])</font>")
				log_admin("ATTACK: [M] ([M.ckey]) punched [src] ([src.ckey]).")
				message_admins("ATTACK: [M] ([M.ckey]) punched [src] ([src.ckey]).")
				log_attack("<font color='red'>[M.name] ([M.ckey]) punched [src.name] ([src.ckey])</font>")
			else if(M.type == /mob/living/carbon/human/tajaran)
				M.attack_log += text("\[[time_stamp()]\] <font color='red'>Slashed [src.name] ([src.ckey])</font>")
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been slashed by [M.name] ([M.ckey])</font>")
				log_admin("ATTACK: [M] ([M.ckey]) slashed [src] ([src.ckey]).")
				message_admins("ATTACK: [M] ([M.ckey]) slashed [src] ([src.ckey]).")
				log_attack("<font color='red'>[M.name] ([M.ckey]) slashed [src.name] ([src.ckey])</font>")

			var/attack_verb
			switch(M.mutantrace)
				if("lizard")
					attack_verb = "scratch"
				if("plant")
					attack_verb = "whip"
				else
					attack_verb = "punch"

			if(istajaran(M))
				attack_verb = "slash"

			var/damage = rand(0, 5)
			if(!damage)
				if(attack_verb == "scratch" || attack_verb == "slash")
					playsound(loc, 'slashmiss.ogg', 25, 1, -1)
				else
					playsound(loc, 'punchmiss.ogg', 25, 1, -1)

				visible_message("\red <B>[M] has attempted to [attack_verb] [src]!</B>")
				return 0


			var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			if(HULK in M.mutations)			damage += 5
			if(SUPRSTR in M.augmentations) 	damage += 5
			if(attack_verb == "scratch" || attack_verb == "slash")
				damage += 7
				playsound(loc, 'slice.ogg', 25, 1, -1)
			else
				playsound(loc, "punch", 25, 1, -1)

			visible_message("\red <B>[M] has [attack_verb]ed [src]!</B>")

			apply_damage(damage, BRUTE, affecting, armor_block)
			if(damage >= 5 && prob(50))
				visible_message("\red <B>[M] has weakened [src]!</B>")
				apply_effect(2, WEAKEN, armor_block)
			UpdateDamageIcon()

		if("disarm")
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>Disarmed [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [M.name] ([M.ckey])</font>")

			log_admin("ATTACK: [src] ([src.ckey]) disarmed [M] ([M.ckey]).")
			log_attack("<font color='red'>[M.name] ([M.ckey]) disarmed [src.name] ([src.ckey])</font>")


			if(w_uniform)
				w_uniform.add_fingerprint(M)
			var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/randn = rand(1, 100)
			if (randn <= 25)
				apply_effect(5, WEAKEN, run_armor_check(affecting, "melee"))
				playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
				visible_message("\red <B>[M] has pushed [src]!</B>")
				return

			var/talked = 0	// BubbleWrap

			if(randn <= 60)
				//BubbleWrap: Disarming breaks a pull
				if(pulling)
					visible_message("\red <b>[M] has broken [src]'s grip on [pulling]!</B>")
					talked = 1
					pulling = null

				//BubbleWrap: Disarming also breaks a grab - this will also stop someone being choked, won't it?
				if(istype(l_hand, /obj/item/weapon/grab))
					var/obj/item/weapon/grab/lgrab = l_hand
					if(lgrab.affecting)
						visible_message("\red <b>[M] has broken [src]'s grip on [lgrab.affecting]!</B>")
						talked = 1
					spawn(1)
						del(lgrab)
				if(istype(r_hand, /obj/item/weapon/grab))
					var/obj/item/weapon/grab/rgrab = r_hand
					if(rgrab.affecting)
						visible_message("\red <b>[M] has broken [src]'s grip on [rgrab.affecting]!</B>")
						talked = 1
					spawn(1)
						del(rgrab)
				//End BubbleWrap

				if(!talked)	//BubbleWrap
					drop_item()
					visible_message("\red <B>[M] has disarmed [src]!</B>")
				playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
				return


			playsound(loc, 'punchmiss.ogg', 25, 1, -1)
			visible_message("\red <B>[M] attempted to disarm [src]!</B>")
	return

/mob/living/carbon/human/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return
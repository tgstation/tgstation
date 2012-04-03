/obj/item/weapon/grab
	name = "grab"
	icon = 'screen1.dmi'
	icon_state = "grabbed"
	var/obj/screen/grab/hud1 = null
	var/mob/affecting = null
	var/mob/assailant = null
	var/state = 1.0
	var/killing = 0.0
	var/allow_upgrade = 1.0
	var/last_suffocate = 1.0
	layer = 21
	abstract = 1.0
	item_state = "nothing"
	w_class = 5.0


/obj/item/weapon/grab/proc/throw()
	if(affecting)
		var/grabee = affecting
		spawn(0)
			del(src)
		return grabee
	return null


/obj/item/weapon/grab/proc/synch()
	if(affecting.anchored)//This will prevent from grabbing people that are anchored.
		del(src)
	if (assailant.r_hand == src)
		hud1.screen_loc = ui_rhand
	else
		hud1.screen_loc = ui_lhand
	return


/obj/item/weapon/grab/process()
	if(!assailant || !affecting)
		del(src)
		return
	if ((!( isturf(assailant.loc) ) || (!( isturf(affecting.loc) ) || (assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1))))
		//SN src = null
		del(src)
		return
	if (assailant.client)
		assailant.client.screen -= hud1
		assailant.client.screen += hud1
	if (assailant.pulling == affecting)
		assailant.pulling = null
	if (state <= 2)
		allow_upgrade = 1
		if ((assailant.l_hand && assailant.l_hand != src && istype(assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.l_hand
			if (G.affecting != affecting)
				allow_upgrade = 0
		if ((assailant.r_hand && assailant.r_hand != src && istype(assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.r_hand
			if (G.affecting != affecting)
				allow_upgrade = 0
		if (state == 2)
			var/h = affecting.hand
			affecting.hand = 0
			affecting.drop_item()
			affecting.hand = 1
			affecting.drop_item()
			affecting.hand = h
			for(var/obj/item/weapon/grab/G in affecting.grabbed_by)
				if (G.state == 2)
					allow_upgrade = 0
				//Foreach goto(341)
		if (allow_upgrade)
			hud1.icon_state = "reinforce"
		else
			hud1.icon_state = "!reinforce"
	else
		if (!( affecting.buckled ))
			affecting.loc = assailant.loc
	if ((killing && state == 3))
		affecting.Stun(5)
		affecting.Paralyse(3)
		affecting.losebreath = min(affecting.losebreath + 2, 3)
	return


/obj/item/weapon/grab/proc/s_click(obj/screen/S as obj)
	if (!affecting)
		return
	if (assailant.next_move > world.time)
		return
	if ((!( assailant.canmove ) || assailant.lying))
		//SN src = null
		del(src)
		return
	switch(S.id)
		if(1.0)
			if (state >= 3)
				if (!( killing ))
					for(var/mob/O in viewers(assailant, null))
						O.show_message(text("\red [] has temporarily tightened his grip on []!", assailant, affecting), 1)
						//Foreach goto(97)
					assailant.next_move = world.time + 10
					//affecting.stunned = max(2, affecting.stunned)
					//affecting.paralysis = max(1, affecting.paralysis)
					affecting.losebreath = min(affecting.losebreath + 1, 3)
					last_suffocate = world.time
					flick("disarm/killf", S)
		else
	return


/obj/item/weapon/grab/proc/s_dbclick(obj/screen/S as obj)
	//if ((assailant.next_move > world.time && !( last_suffocate < world.time + 2 )))
	//	return
	if ((!( assailant.canmove ) || assailant.lying))
		del(src)
		return
	switch(S.id)
		if(1.0)
			if (state < 2)
				if (!( allow_upgrade ))
					return
				if (prob(75))
					for(var/mob/O in viewers(assailant, null))
						O.show_message(text("\red [] has grabbed [] aggressively (now hands)!", assailant, affecting), 1)
					state = 2
					icon_state = "grabbed1"
				else
					for(var/mob/O in viewers(assailant, null))
						O.show_message(text("\red [] has failed to grab [] aggressively!", assailant, affecting), 1)
					del(src)
					return
			else
				if (state < 3)
					if(istype(affecting, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = affecting
						if(H.mutations & FAT)
							assailant << "\blue You can't strangle [affecting] through all that fat!"
							return

						/*Hrm might want to add this back in
						//we should be able to strangle the Captain if he is wearing a hat
						for(var/obj/item/clothing/C in list(H.head, H.wear_suit, H.wear_mask, H.w_uniform))
							if(C.body_parts_covered & HEAD)
								assailant << "\blue You have to take off [affecting]'s [C.name] first!"
								return

						if(istype(H.wear_suit, /obj/item/clothing/suit/space) || istype(H.wear_suit, /obj/item/clothing/suit/armor) || istype(H.wear_suit, /obj/item/clothing/suit/bio_suit) || istype(H.wear_suit, /obj/item/clothing/suit/swat_suit))
							assailant << "\blue You can't strangle [affecting] through their suit collar!"
							return
						*/

					if(istype(affecting, /mob/living/carbon/metroid))
						assailant << "\blue You squeeze [affecting], but nothing interesting happens."
						return

					for(var/mob/O in viewers(assailant, null))
						O.show_message(text("\red [] has reinforced his grip on [] (now neck)!", assailant, affecting), 1)

					state = 3
					icon_state = "grabbed+1"
					if (!( affecting.buckled ))
						affecting.loc = assailant.loc
					affecting.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their neck grabbed by [assailant.name] ([assailant.ckey])</font>")
					assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>Grabbed the neck of [affecting.name] ([affecting.ckey])</font>")
					log_attack("<font color='red'>[assailant.name] ([assailant.ckey]) grabbed the neck of [affecting.name] ([affecting.ckey])</font>")
					hud1.icon_state = "disarm/kill"
					hud1.name = "disarm/kill"
				else
					if (state >= 3)
						killing = !( killing )
						if (killing)
							for(var/mob/O in viewers(assailant, null))
								O.show_message(text("\red [] has tightened his grip on []'s neck!", assailant, affecting), 1)
							affecting.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been strangled (kill intent) by [assailant.name] ([assailant.ckey])</font>")
							assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>Strangled (kill intent) [affecting.name] ([affecting.ckey])</font>")
							log_attack("<font color='red'>[assailant.name] ([assailant.ckey]) Strangled (kill intent) [affecting.name] ([affecting.ckey])</font>")

							assailant.next_move = world.time + 10
							affecting.losebreath += 1
							hud1.icon_state = "disarm/kill1"
						else
							hud1.icon_state = "disarm/kill"
							for(var/mob/O in viewers(assailant, null))
								O.show_message(text("\red [] has loosened the grip on []'s neck!", assailant, affecting), 1)
		else
	return


/obj/item/weapon/grab/New()
	..()
	hud1 = new /obj/screen/grab( src )
	hud1.icon_state = "reinforce"
	hud1.name = "Reinforce Grab"
	hud1.id = 1
	hud1.master = src
	return


/obj/item/weapon/grab/attack(mob/M as mob, mob/user as mob)
	if (M == affecting)
		if (state < 3)
			s_dbclick(hud1)
		else
			s_click(hud1)
		return
	if(M == assailant && state >= 2)
		if( ( ishuman(user) && (user.mutations & FAT) && ismonkey(affecting) ) || ( isalien(user) && iscarbon(affecting) ) )
			var/mob/living/carbon/attacker = user
			for(var/mob/N in viewers(user, null))
				if(N.client)
					N.show_message(text("\red <B>[user] is attempting to devour [affecting]!</B>"), 1)
			if(istype(user, /mob/living/carbon/alien/humanoid/hunter))
				if(!do_mob(user, affecting)||!do_after(user, 30)) return
			else
				if(!do_mob(user, affecting)||!do_after(user, 100)) return
			for(var/mob/N in viewers(user, null))
				if(N.client)
					N.show_message(text("\red <B>[user] devours [affecting]!</B>"), 1)
			affecting.loc = user
			attacker.stomach_contents.Add(affecting)
			del(src)


/obj/item/weapon/grab/dropped()
	del(src)
	return


/obj/item/weapon/grab/Del()
	del(hud1)
	..()
	return
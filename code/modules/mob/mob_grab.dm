#define UPGRADE_COOLDOWN	40
#define UPGRADE_KILL_TIMER	100

/obj/item/weapon/grab
	name = "grab"
	flags = NOBLUDGEON | ABSTRACT
	var/obj/screen/grab/hud = null
	var/mob/affecting = null
	var/mob/assailant = null
	var/state = GRAB_PASSIVE

	var/allow_upgrade = 1
	var/last_upgrade = 0

	layer = 21
	item_state = "nothing"
	w_class = 5.0


/obj/item/weapon/grab/New(mob/user, mob/victim)
	..()
	loc = user
	assailant = user
	affecting = victim

	if(affecting.anchored || !user.Adjacent(victim))
		qdel(src)
		return

	hud = new /obj/screen/grab(src)
	hud.icon_state = "reinforce"
	hud.name = "reinforce grab"
	hud.master = src

	affecting.grabbed_by += src


/obj/item/weapon/grab/Destroy()
	if(affecting)
		affecting.grabbed_by -= src
		affecting = null
	if(assailant)
		if(assailant.client)
			assailant.client.screen -= hud
		assailant = null
	qdel(hud)
	..()

//Used by throw code to hand over the mob, instead of throwing the grab. The grab is then deleted by the throw code.
/obj/item/weapon/grab/proc/throw()
	if(affecting)
		if(affecting.buckled)
			return null
		if(state >= GRAB_AGGRESSIVE)
			return affecting
	return null


//This makes sure that the grab screen object is displayed in the correct hand.
/obj/item/weapon/grab/proc/synch()
	if(affecting)
		if(assailant.r_hand == src)
			hud.screen_loc = ui_rhand
		else
			hud.screen_loc = ui_lhand


/obj/item/weapon/grab/process()
	if(!confirm())
		return 0

	if(assailant.client)
		assailant.client.screen -= hud
		assailant.client.screen += hud

	if(assailant.pulling == affecting)
		assailant.stop_pulling()

	if(state <= GRAB_AGGRESSIVE)
		allow_upgrade = 1
		if((assailant.l_hand && assailant.l_hand != src && istype(assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.l_hand
			if(G.affecting != affecting)
				allow_upgrade = 0
		if((assailant.r_hand && assailant.r_hand != src && istype(assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.r_hand
			if(G.affecting != affecting)
				allow_upgrade = 0
		if(state == GRAB_AGGRESSIVE)
			var/h = affecting.hand
			affecting.hand = 0
			affecting.drop_item()
			affecting.hand = 1
			affecting.drop_item()
			affecting.hand = h
			for(var/obj/item/weapon/grab/G in affecting.grabbed_by)
				if(G == src) continue
				if(G.state == GRAB_AGGRESSIVE)
					allow_upgrade = 0
		if(allow_upgrade)
			hud.icon_state = "reinforce"
		else
			hud.icon_state = "!reinforce"
	else
		if(!affecting.buckled)
			affecting.loc = assailant.loc

	if(state >= GRAB_NECK)
		affecting.Stun(5)	//It will hamper your voice, being choked and all.
		if(isliving(affecting))
			var/mob/living/L = affecting
			L.adjustOxyLoss(1)

	if(state >= GRAB_KILL)
		affecting.Weaken(5)	//Should keep you down unless you get help.
		affecting.losebreath = min(affecting.losebreath + 2, 3)

/obj/item/weapon/grab/attack_self(mob/user)
	s_click(hud)

/obj/item/weapon/grab/proc/s_click(obj/screen/S)
	if(!affecting)
		return
	if(state == GRAB_UPGRADING)
		return
	if(assailant.next_move > world.time)
		return
	if(world.time < (last_upgrade + UPGRADE_COOLDOWN))
		return
	if(!assailant.canmove || assailant.lying)
		qdel(src)
		return

	last_upgrade = world.time

	if(state < GRAB_AGGRESSIVE)
		if(!allow_upgrade)
			return
		assailant.visible_message("<span class='warning'>[assailant] has grabbed [affecting] aggressively (now hands)!</span>")
		state = GRAB_AGGRESSIVE
		icon_state = "grabbed1"
	else
		if(state < GRAB_NECK)
			if(isslime(affecting))
				assailant << "<span class='notice'>You squeeze [affecting], but nothing interesting happens.</span>"
				return

			assailant.visible_message("<span class='warning'>[assailant] has reinforced \his grip on [affecting] (now neck)!</span>")
			state = GRAB_NECK
			icon_state = "grabbed+1"
			if(!affecting.buckled)
				affecting.loc = assailant.loc
			add_logs(assailant, affecting, "neck-grabbed")
			hud.icon_state = "disarm/kill"
			hud.name = "disarm/kill"
		else
			if(state < GRAB_UPGRADING)
				assailant.visible_message("<span class='danger'>[assailant] starts to tighten \his grip on [affecting]'s neck!</span>")
				hud.icon_state = "disarm/kill1"
				state = GRAB_UPGRADING
				if(do_after(assailant, UPGRADE_KILL_TIMER))
					if(state == GRAB_KILL)
						return
					if(!affecting)
						qdel(src)
						return
					if(!assailant.canmove || assailant.lying)
						qdel(src)
						return
					state = GRAB_KILL
					assailant.visible_message("<span class='danger'>[assailant] has tightened \his grip on [affecting]'s neck!</span>")
					add_logs(assailant, affecting, "strangled")

					assailant.changeNext_move(CLICK_CD_TKSTRANGLE)
					affecting.losebreath += 1
				else
					if(assailant)
						assailant.visible_message("<span class='warning'>[assailant] was unable to tighten \his grip on [affecting]'s neck!</span>")
						hud.icon_state = "disarm/kill"
						state = GRAB_NECK


//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/grab/proc/confirm()
	if(!assailant || !affecting)
		qdel(src)
		return 0

	if(affecting)
		if(!isturf(assailant.loc) || ( !isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return 0

	return 1


/obj/item/weapon/grab/attack(mob/M, mob/user)
	if(!affecting)
		return

	if(M == affecting)
		s_click(hud)
		return

	if(M == assailant && state >= GRAB_AGGRESSIVE)
		if( (ishuman(user) && (user.disabilities & FAT) && ismonkey(affecting) ) || ( isalien(user) && iscarbon(affecting) ) )
			var/mob/living/carbon/choker = user
			user.visible_message("<span class='danger'>[user] is attempting to devour [affecting]!</span>")
			if(istype(user, /mob/living/carbon/alien/humanoid/hunter))
				if(!do_mob(user, affecting)||!do_after(user, 30)) return
			else
				if(!do_mob(user, affecting)||!do_after(user, 100)) return
			user.visible_message("<span class='danger'>[user] devours [affecting]!</span>")
			affecting.loc = user
			choker.stomach_contents.Add(affecting)
			qdel(src)

////////////////////LING CODE HERE/////////////////////////////////////////////////
		if( (ishuman(user) && (user.mind.changeling) && ishuman(affecting) ) )
			var/mob/living/carbon/human/attacker = user
			var/mob/living/carbon/human/victim = affecting
			var/lingbite_armor_check = victim.run_armor_check(user.zone_sel.selecting, "melee")
			var/obj/item/organ/limb/L = victim.get_organ(check_zone(user.zone_sel.selecting))
			if(victim.health > 0)
				user.visible_message("<span class='danger'>[user] takes a large bite out of [affecting]'s [L.getDisplayName()]!</span>")
				victim.apply_damage(15, BRUTE, user.zone_sel.selecting, lingbite_armor_check)
				attacker.mind.changeling.chem_charges += 0.5
				playsound(attacker, 'sound/weapons/bite.ogg', 50,)
			else
				var/datum/changeling/changeling = attacker.mind.changeling
				user.visible_message("<span class='danger'>[user] messily rips into [affecting], and begins feeding!</span>")
				victim.apply_damage(35, BRUTE, user.zone_sel.selecting, lingbite_armor_check)
				if(victim.disabilities & LING_VICTIM)
					user <<"<span class='notice'>This form has been ravaged. It is worthless to us.</span>"
				else
					if(!do_mob(attacker, victim)||do_after(attacker, 30))
						if(!changeling.has_dna(victim.dna))
							changeling.absorb_dna(victim, user)
							if(attacker.wear_suit)
								attacker.wear_suit.add_blood(victim)
								attacker.update_inv_wear_suit(0)
							else if(attacker.w_uniform)
								attacker.w_uniform.add_blood(victim)
								attacker.update_inv_w_uniform(0)
							if (attacker.gloves)
								attacker.gloves.add_blood(victim)
							else
								attacker.add_blood(victim)
								attacker.update_inv_gloves()
							if(attacker.wear_mask)
								attacker.wear_mask.add_blood(victim)
								attacker.update_inv_wear_mask(0)
							if(attacker.head)
								attacker.head.add_blood(victim)
								attacker.update_inv_head(0)
							if(attacker.glasses)
								attacker.glasses.add_blood(victim)
								attacker.update_inv_glasses(0)
							if(attacker.shoes)
								attacker.shoes.add_blood(victim)
								attacker.update_inv_shoes(0)


							var/obj/item/organ/appendix/A = locate() in victim.internal_organs
							if(A)
								qdel(A)
								user.visible_message("<span class='danger'>[user] tears [affecting]'s appendix out with their teeth and swallows it whole!</span>")
								changeling.geneticpoints += 2
								victim.apply_damage(65, BRUTE, "chest", lingbite_armor_check)
								victim.disabilities |= LING_VICTIM
								victim.status_flags |= DISFIGURED
								victim.update_base_icon_state(0)
							else
								user.visible_message("<span class='danger'>[user] tears a large chunk from [affecting] and swallows it whole!</span>")
								changeling.geneticpoints += 1
								victim.apply_damage(65, BRUTE, "chest", lingbite_armor_check)
								victim.disabilities |= LING_VICTIM
								victim.status_flags |= DISFIGURED
								victim.update_base_icon_state(0)


							if(user.nutrition < NUTRITION_LEVEL_WELL_FED)
								user.nutrition = NUTRITION_LEVEL_WELL_FED
							if(victim.mind)//if the victim has got a mind
								victim.mind.show_memory(victim, 0) //I can read your mind, kekeke. Output all their notes.

								if(victim.mind.changeling)//If the victim was a changeling, suck out their extra juice and objective points!
									changeling.chem_charges += min(victim.mind.changeling.chem_charges, changeling.chem_storage)
									changeling.absorbedcount += (victim.mind.changeling.absorbedcount)
									changeling.geneticpoints += (victim.mind.changeling.geneticpoints)

									victim.mind.changeling.absorbed_dna.len = 1
									victim.mind.changeling.absorbedcount = 0
									victim.mind.changeling.geneticpoints = 0


						else
							user <<"<span class='notice'>We have already feasted upon these genomes!</span>"

					else
						user <<"<span class='notice'>We have fumbled [affecting]. We must focus only on consuming!</span>"


/obj/item/weapon/grab/dropped()
	qdel(src)

#undef UPGRADE_COOLDOWN
#undef UPGRADE_KILL_TIMER

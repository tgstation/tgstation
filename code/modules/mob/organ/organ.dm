/datum/organ
	var
		name = "organ"
		mob/living/carbon/human/owner = null

		list/datum/autopsy_data/autopsy_data = list()
		list/trace_chemicals = list() // traces of chemicals in the organ,
								      // links chemical IDs to number of ticks for which they'll stay in the blood


	proc/process()
		return 0

	proc/receive_chem(chemical as obj)
		return 0

/datum/autopsy_data
	var
		weapon = null
		pretend_weapon = null
		damage = 0
		hits = 0
		time_inflicted = 0

	proc/copy()
		var/datum/autopsy_data/W = new()
		W.weapon = src.weapon
		W.pretend_weapon = src.pretend_weapon
		W.damage = src.damage
		W.hits = src.hits
		W.time_inflicted = src.time_inflicted
		return W

/****************************************************
				EXTERNAL ORGANS
****************************************************/
/datum/organ/external
	name = "external"
	var
		icon_name = null
		body_part = null

		damage_state = "00"
		brute_dam = 0
		burn_dam = 0
		bandaged = 0
		max_damage = 0
		max_size = 0
		obj/item/weapon/implant/implant = null

		display_name
		list/wounds = list()
		bleeding = 0
		perma_injury = 0
		perma_dmg = 0
		broken = 0
		destroyed = 0
		destspawn = 0 //Has it spawned the broken limb?
		gauzed = 0 //Has the missing limb been patched?
		min_broken_damage = 30
		datum/organ/external/parent
		damage_msg = "\red You feel a intense pain"

		var/open = 0
		var/stage = 0
		var/wound = 0

	New(mob/living/carbon/human/H)
		..(H)
		if(!display_name)
			display_name = name
		if(istype(H))
			owner = H
			H.organs[name] = src

	proc/take_damage(brute, burn, sharp, used_weapon = null)
		if((brute <= 0) && (burn <= 0))
			return 0
		if(destroyed)
			return 0

		if(owner) owner.pain(display_name, (brute+burn)*3, 1)
		if(sharp)
			var/nux = brute * rand(10,15)
			if(brute_dam >= max_damage)
				if(prob(5 * brute))
//					for(var/mob/M in viewers(owner))
//						M.show_message("\red [owner.name]'s [display_name] flies off.")
					destroyed = 1
					droplimb()
					return
			else if(prob(nux))
				createwound(max(1,min(6,round(brute/10) + rand(-1,1))),0,brute)
				owner << "You feel something wet on your [display_name]"

		if((brute_dam + burn_dam + brute + burn) < max_damage)
			if(brute)
				brute_dam += brute
				if(prob(brute) && brute > 20 && !sharp)
					createwound(rand(4,6),0,brute)
				else if(!sharp)
					createwound(max(1,min(6,round(brute/10) + rand(-1,1))),1,brute)
			if(burn)
				burn_dam += burn
				createwound(max(1,min(6,round(burn/10) + rand(-1,1))),2,burn)
		else
			var/can_inflict = src.max_damage - (src.brute_dam + src.burn_dam)
			if(can_inflict)
				if (brute > 0 && burn > 0)
					brute = can_inflict/2
					burn = can_inflict/2
					var/ratio = brute / (brute + burn)
					src.brute_dam += ratio * can_inflict
					src.burn_dam += (1 - ratio) * can_inflict
				else
					if (brute > 0)
						brute = can_inflict
						src.brute_dam += brute
						if(!sharp) createwound(max(1,min(6,round(brute/10) + rand(-1,1))),1,brute)
					else
						burn = can_inflict
						src.burn_dam += burn
						createwound(max(1,min(6,round(burn/10) + rand(-1,1))),2,burn)
			else
				return 0

			if(broken)
				owner.emote("scream")

		if(used_weapon) add_wound(used_weapon, brute + burn)

		var/result = src.update_icon()
		return result


	proc/heal_damage(brute, burn, internal = 0)
		var/brute_to_heal = 0
		var/brute_wounds = list()
		var/burn_to_heal = 0
		var/burn_wounds = list()
		for(var/datum/organ/wound/W in wounds)
			if(W.wound_type > 1 && W.damage)
				burn_to_heal += W.damage
				burn_wounds += W
			else if(W.damage)
				brute_to_heal += W.damage
				brute_wounds += W
		if(brute && brute >= brute_to_heal)
			for(var/datum/organ/wound/W in brute_wounds)
				if(brute >= W.damage)
					brute_dam -= W.damage
					brute -= W.damage
					W.damage = 0
					W.initial_dmg = 0
					W.stopbleeding()
				else
					W.damage -= brute
					W.initial_dmg -= brute
		else if(brute)
			for(var/datum/organ/wound/W in brute_wounds)
				W.damage = 0
				W.initial_dmg = 0
				W.stopbleeding()
			brute_dam = 0
		if(burn && burn >= burn_to_heal)
			for(var/datum/organ/wound/W in burn_wounds)
				if(burn >= W.damage)
					burn_dam -= W.damage
					burn -= W.damage
					W.damage = 0
					W.initial_dmg = 0
					W.stopbleeding()
				else
					W.damage -= burn
					W.initial_dmg -= burn
		else if(burn)
			for(var/datum/organ/wound/W in burn_wounds)
				W.damage = 0
				W.initial_dmg = 0
				W.stopbleeding()
			burn_dam = 0
		if(internal)
			broken = 0
			perma_injury = 0
		// if all damage is healed, replace the wounds with scars
		if(brute_dam + burn_dam == 0)
			for(var/V in autopsy_data)
				var/datum/autopsy_data/W = autopsy_data[V]
				del W
			autopsy_data = list()
		return update_icon()

	proc/add_wound(var/used_weapon, var/damage)
		var/datum/autopsy_data/W = autopsy_data[used_weapon]
		if(!W)
			W = new()
			W.weapon = used_weapon
			autopsy_data[used_weapon] = W

		W.hits += 1
		W.damage += damage
		W.time_inflicted = world.time



	proc/get_damage()	//returns total damage
		return max(brute_dam + burn_dam - perma_injury,perma_injury)	//could use health?

	proc/get_damage_brute()
		return max(brute_dam+perma_injury,perma_injury)

	proc/get_damage_fire()
		return burn_dam

	process()
		if(destroyed)
			if(!destspawn)
				droplimb()
			return
		if(broken == 0)
			perma_dmg = 0
		if(parent)
			if(parent.destroyed)
				destroyed = 1
				owner:update_body()
				return
		if(brute_dam > min_broken_damage)
			if(broken == 0)
				var/dmgmsg = "[damage_msg] in your [display_name]"
				owner << dmgmsg
				//owner.unlock_medal("Broke Yarrr Bones!", 0, "Break a bone.", "easy")
				owner.visible_message("\red You hear a loud cracking sound coming from [owner.name].","\red <b>Something feels like it shattered in your [display_name]!</b>","You hear a sickening crack.")
				owner.emote("scream")
				broken = 1
				wound = "broken" //Randomise in future
				perma_injury = brute_dam
			return
		return

// new damage icon system
// returns just the brute/burn damage code
	proc/damage_state_text()
		var/tburn = 0
		var/tbrute = 0

		if(burn_dam ==0)
			tburn =0
		else if (src.burn_dam < (src.max_damage * 0.25 / 2))
			tburn = 1
		else if (src.burn_dam < (src.max_damage * 0.75 / 2))
			tburn = 2
		else
			tburn = 3

		if (src.brute_dam == 0)
			tbrute = 0
		else if (src.brute_dam < (src.max_damage * 0.25 / 2))
			tbrute = 1
		else if (src.brute_dam < (src.max_damage * 0.75 / 2))
			tbrute = 2
		else
			tbrute = 3
		return "[tbrute][tburn]"


// new damage icon system
// adjusted to set damage_state to brute/burn code only (without r_name0 as before)
	proc/update_icon()
		var/n_is = src.damage_state_text()
		if (n_is != src.damage_state)
			src.damage_state = n_is
			return 1
		return 0

	proc/droplimb()
		if(destroyed)
			//owner.unlock_medal("Lost something?", 0, "Lose a limb.", "easy")
			switch(body_part)
				if(UPPER_TORSO)
					owner.gib()
				if(LOWER_TORSO)
					owner << "\red You are now sterile."
				if(HEAD)
					var/obj/item/weapon/organ/head/H = new(owner.loc, owner)
					if(owner.gender == FEMALE)
						H.icon_state = "head_f_l"
					H.overlays += owner.face_lying
					H.transfer_identity(owner)
					H.pixel_x = -10
					H.pixel_y = 6

					var/lol = pick(cardinal)
					step(H,lol)
					owner.update_face()
					owner.update_body()
					owner.death()
				if(ARM_RIGHT)
					var/obj/item/weapon/organ/r_arm/H = new(owner.loc, owner)
					if(owner:organs["r_hand"])
						var/datum/organ/external/S = owner:organs["r_hand"]
						if(!S.destroyed)
							S.droplimb()
					var/lol = pick(cardinal)
					step(H,lol)
					destroyed = 1
				if(ARM_LEFT)
					var/obj/item/weapon/organ/l_arm/H = new(owner.loc, owner)
					if(owner:organs["l_hand"])
						var/datum/organ/external/S = owner:organs["l_hand"]
						if(!S.destroyed)
							S.droplimb()
					var/lol = pick(cardinal)
					step(H,lol)
					destroyed = 1
				if(LEG_RIGHT)
					var/obj/item/weapon/organ/r_leg/H = new(owner.loc, owner)
					if(owner:organs["r_foot"])
						var/datum/organ/external/S = owner:organs["r_foot"]
						if(!S.destroyed)
							S.droplimb()
					var/lol = pick(cardinal)
					step(H,lol)
					destroyed = 1
				if(LEG_LEFT)
					var/obj/item/weapon/organ/l_leg/H = new(owner.loc, owner)
					if(owner:organs["l_foot"])
						var/datum/organ/external/S = owner:organs["l_foot"]
						if(!S.destroyed)
							S.droplimb()
					var/lol = pick(cardinal)
					step(H,lol)
					destroyed = 1
				if(HAND_RIGHT)
					var/obj/item/weapon/organ/r_hand/X = new(owner.loc, owner)
					for(var/mob/M in viewers(owner))
						M.show_message("\red [owner.name]'s [X.name] flies off in an arc.")
					var/lol2 = pick(cardinal)
					step(X,lol2)
					destroyed = 1
				if(HAND_LEFT)
					var/obj/item/weapon/organ/l_hand/X = new(owner.loc, owner)
					for(var/mob/M in viewers(owner))
						M.show_message("\red [owner.name]'s [X.name] flies off in an arc.")
					var/lol2 = pick(cardinal)
					step(X,lol2)
					destroyed = 1
				if(FOOT_RIGHT)
					var/obj/item/weapon/organ/r_foot/X = new(owner.loc, owner)
					for(var/mob/M in viewers(owner))
						M.show_message("\red [owner.name]'s [X.name] flies off in an arc.")
					var/lol2 = pick(cardinal)
					step(X,lol2)
					destroyed = 1
				if(FOOT_LEFT)
					var/obj/item/weapon/organ/l_foot/X = new(owner.loc, owner)
					for(var/mob/M in viewers(owner))
						M.show_message("\red [owner.name]'s [X.name] flies off in an arc.")
					var/lol2 = pick(cardinal)
					step(X,lol2)
					destroyed = 1
			destspawn = 1
			for(var/datum/organ/wound/W in wounds)
				W.update_health()
				del(W)
			del(wounds)
			src.owner.update_clothing()

	proc/createwound(var/size = 1, var/type = 0, var/damage)
		if(ishuman(owner))
			var/datum/organ/wound/W = new(src)
			bleeding = !type //Sharp objects cause bleeding.
			W.bleeding = !type
//			owner:bloodloss += 10 * size
			W.damage = damage
			W.initial_dmg = damage
			W.wound_type = type
			W.wound_size = size
			W.owner = owner
			W.parent = src
			spawn W.start_close() //Let small cuts close themselves.
			wounds += W

/datum/organ/wound
	name = "wound"
	var/wound_type = 0 //0 = cut, 1 = bruise, 2 = burn
	var/damage = 0 //How much damage it caused.
	var/initial_dmg = 0
	var/wound_size = 1
	var/datum/organ/external/parent
	var/bleeding = 0 //You got wounded, of course it's bleeding. --  Scratch that.  Rewrote it.
	var/healing_state = 0

	proc/start_close()
		sleep(rand(1800,3000)) //3-5 minutes
		if(prob(50) && wound_size == 1)
			parent.wounds.Remove(src)
			update_health(1)
			del(src)
		else if(prob(33) && wound_size < 3)
			stopbleeding()
			return
		sleep(rand(1800,3000))
		if(wound_size == 1) //Small cuts heal in 3-10 minutes.
			parent.wounds.Remove(src)
			update_health(1)
			del(src)
		else if(prob(50) && wound_size < 5 && bleeding)
			stopbleeding()
			return
		if(wound_size < 5 && bleeding) //Give it a chance to stop bleeding on it's own.
			spawn(1)
				sleep(1200)
				if(prob(50))
					stopbleeding()
					return
		return

	proc/stopbleeding()
		if(healing_state)
			return 0
//		owner:bloodloss -= 10 * src.wound_size
		parent.bleeding = 0
		for(var/datum/organ/wound/W in parent)
			if(W.bleeding && W != src)
				parent.bleeding = 1
		bleeding = 0
		spawn become_scar() //spawn off the process of becoming a scar.
		return 1

	proc/become_scar()
		healing_state = 1 //Patched
		update_health(0.5) //Heals some.

		sleep(rand(1800,3000)) //3-5 minutes

		if(parent.owner.stat == 2)
			return
		if(prob(80) && wound_size < 2) //Small cuts heal.
			update_health(1)
			parent.wounds.Remove(src)
			del(src)

		healing_state = 2 //Noticibly healing.
		update_health(1) //Heals the rest of the way.

		sleep(rand(1800,3000)) //3-5 minutes
		if(parent.owner.stat == 2)
			return
		if(prob(60) && wound_size < 3) //Cuts heal up
			parent.wounds.Remove(src)
			del(src)
		healing_state = 3 //Angry red scar
		sleep(rand(6000,9000)) //10-15 minutes
		if(parent.owner.stat == 2)
			return
		if(prob(80) && wound_size < 4) //Minor wounds heal up fully.
			parent.wounds.Remove(src)
			del(src)
		healing_state = 4 //Scar
		sleep(rand(6000,9000)) //10-15 minutes
		if(parent.owner.stat == 2)
			return
		if(prob(30) || wound_size < 4 || wound_type == 1) //Small chance for the scar to disappear, any small remaining wounds deleted.
			parent.wounds.Remove(src)
			del(src)
		healing_state = 5 //Faded scar
		return

	proc/update_health(var/percent = 1)
		damage -= damage/percent //Remove that amount of the damage
		if(wound_type > 1)
			parent.burn_dam -= initial_dmg - damage
		else
			parent.brute_dam -= initial_dmg - damage
		initial_dmg = damage //reset it for further updates.
		parent.owner.updatehealth()


/****************************************************
				INTERNAL ORGANS
****************************************************/
/datum/organ/internal
	name = "internal"
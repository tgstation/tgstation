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

	New(mob/living/carbon/H)
		..(H)
		if(!display_name)
			display_name = name
		if(istype(H))
			owner = H
			H.organs[name] = src

	Del()
		for(var/datum/organ/wound/W in wounds)
			del(W)
		..()

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
				createwound(max(1,min(6,round(brute/10) + rand(0,2))),0,brute)
				owner << "You feel something wet on your [display_name]"

		if((brute_dam + burn_dam + brute + burn) < max_damage)
			if(brute)
				brute_dam += brute
				if(prob(brute) && brute > 20 && !sharp)
					createwound(rand(4,6),0,brute)
				else if(!sharp)
					createwound(max(1,min(6,round(brute/10) + rand(1,3))),1,brute)
			if(burn)
				burn_dam += burn
				createwound(max(1,min(6,round(burn/10) + rand(0,2))),2,burn)
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
					W.stopbleeding(1)
				else
					W.damage -= brute
					W.initial_dmg -= brute
					W.stopbleeding()
		else if(brute)
			for(var/datum/organ/wound/W in brute_wounds)
				W.damage = 0
				W.initial_dmg = 0
				W.stopbleeding(1)
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
					W.stopbleeding()
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
				//owner.unlock_medal("Broke Yarrr Bones!", 0, "Break a bone.", "easy")
				owner.visible_message("\red You hear a loud cracking sound coming from [owner.name].","\red <b>Something feels like it shattered in your [display_name]!</b>","You hear a sickening crack.")
				owner.emote("scream")
				broken = 1
				wound = pick("broken","fracture","hairline fracture") //Randomise in future.  Edit: Randomized. --SkyMarshal
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

	proc/droplimb(var/override = 0)
		if(override)
			destroyed = 1
		if(destroyed)
			//owner.unlock_medal("Lost something?", 0, "Lose a limb.", "easy")

			var/obj/item/weapon/organ/H
			switch(body_part)
				if(UPPER_TORSO)
					owner.gib()
				if(LOWER_TORSO)
					owner << "\red You are now sterile."
				if(HEAD)
					H = new /obj/item/weapon/organ/head(owner.loc, owner)
					if(ishuman(owner))
						if(owner.gender == FEMALE)
							H.icon_state = "head_f_l"
						H.overlays += owner.face_lying
					if(ismonkey(owner))
						H.icon_state = "head_l"
						//H.overlays += owner.face_lying
					H:transfer_identity(owner)
					H.pixel_x = -10
					H.pixel_y = 6
					H.name = "[owner.name]'s head"

					owner.update_face()
					owner.update_body()
					owner.death()
				if(ARM_RIGHT)
					H = new /obj/item/weapon/organ/r_arm(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "r_arm_l"
					if(owner:organs["r_hand"])
						var/datum/organ/external/S = owner:organs["r_hand"]
						if(!S.destroyed)
							S.droplimb(1)
				if(ARM_LEFT)
					H = new /obj/item/weapon/organ/l_arm(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "l_arm_l"
					if(owner:organs["l_hand"])
						var/datum/organ/external/S = owner:organs["l_hand"]
						if(!S.destroyed)
							S.droplimb(1)
				if(LEG_RIGHT)
					H = new /obj/item/weapon/organ/r_leg(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "r_leg_l"
					if(owner:organs["r_foot"])
						var/datum/organ/external/S = owner:organs["r_foot"]
						if(!S.destroyed)
							S.droplimb(1)
				if(LEG_LEFT)
					H = new /obj/item/weapon/organ/l_leg(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "l_leg_l"
					if(owner:organs["l_foot"])
						var/datum/organ/external/S = owner:organs["l_foot"]
						if(!S.destroyed)
							S.droplimb(1)
				if(HAND_RIGHT)
					H = new /obj/item/weapon/organ/r_hand(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "r_hand_l"
				if(HAND_LEFT)
					H = new /obj/item/weapon/organ/l_hand(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "l_hand_l"
				if(FOOT_RIGHT)
					H = new /obj/item/weapon/organ/r_foot/(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "r_foot_l"
				if(FOOT_LEFT)
					H = new /obj/item/weapon/organ/l_foot(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "l_foot_l"
			if(ismonkey(owner))
				H.icon = 'monkey.dmi'
			if(istajaran(owner))
				H.icon = 'tajaran.dmi'
			var/lol = pick(cardinal)
			step(H,lol)
			destspawn = 1
			owner.visible_message("\red [owner.name]'s [display_name] flies off in an arc.","\red <b>Your [display_name] goes flying off!</b>","You hear a terrible sound of ripping tendons and flesh.")
			for(var/datum/organ/wound/W in wounds)
				W.update_health()
				del(W)
			del(wounds)
			owner.update_body()
			owner.update_clothing()

	proc/createwound(var/size = 1, var/type = 0, var/damage)
		var/list/datum/organ/wound/possible_wounds = list()
		for(var/datum/organ/wound/W in wounds)
			if(W.type == type && W.wound_size < 3 && size < 3 && !W.is_healing)
				possible_wounds += W
		if(ishuman(owner))
			if(!possible_wounds.len || prob(25))
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
				if(type == 1)
					spawn W.become_scar()
				else
					spawn W.start_close() //Let small cuts close themselves.
				wounds += W
			else
				var/datum/organ/wound/W = pick(possible_wounds)
				bleeding = !type //Sharp objects cause bleeding.
				W.bleeding = !type
	//			owner:bloodloss += 10 * size
				W.damage += damage
				W.initial_dmg += damage
				W.wound_size = round(sqrt(size^2 + W.wound_size^2))
				if(type == 1)
					spawn W.become_scar()
				else
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
	var/is_healing = 0
	var/slowheal = 3

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
		if(wound_size == 1) //Small cuts heal in 6-10 minutes.
			parent.wounds.Remove(src)
			update_health(1)
			del(src)
		else if(prob(50) && wound_size < 5 && bleeding)
			stopbleeding()
			return
		if(wound_size < 5 && bleeding) //Give it a chance to stop bleeding on it's own.
			spawn while(1)
				sleep(1200)
				if(prob(50))
					stopbleeding()
					return
		return

	proc/stopbleeding(var/bleed = 0)
		if(is_healing)
			return 0
//		owner:bloodloss -= 10 * src.wound_size
		parent.bleeding = min(bleed,bleeding)
		for(var/datum/organ/wound/W in parent)
			if(W.bleeding && W != src)
				parent.bleeding = 1
				break
		bleeding = min(bleed,bleeding)
		is_healing = 1
		slowheal = 1
		spawn become_scar() //spawn off the process of becoming a scar.
		return 1

	proc/become_scar()
		healing_state = 1 //Patched
		spawn(200*slowheal) //20 seconds
			update_health(5) //Heals some.

		sleep(rand(1800,3000)*slowheal) //3-5 minutes

		if(parent.owner.stat == 2)
			return
		if(prob(80) && wound_size < 2) //Small cuts heal.
			update_health(1)
			parent.wounds.Remove(src)
			del(src)

		healing_state = 2 //Noticibly healing.
		update_health(2) //Heals more.

		sleep(rand(1800,3000)*slowheal) //3-5 minutes
		if(parent.owner.stat == 2)
			return
		if(prob(60) && wound_size < 3) //Cuts heal up
			parent.wounds.Remove(src)
			del(src)
		healing_state = 3 //Angry red scar
		update_health(1) //Heals the rest of the way.


		sleep(rand(6000,9000)*slowheal) //10-15 minutes
		if(parent.owner.stat == 2)
			return
		if(prob(80) && wound_size < 4) //Minor wounds heal up fully.
			parent.wounds.Remove(src)
			del(src)
		healing_state = 4 //Scar
		sleep(rand(6000,9000)*slowheal) //10-15 minutes
		if(parent.owner.stat == 2)
			return
		if(prob(30) || wound_size < 4 || wound_type == 1) //Small chance for the scar to disappear, any small remaining wounds deleted.
			parent.wounds.Remove(src)
			del(src)
		healing_state = 5 //Faded scar
		return

	proc/update_health(var/percent = 1)
		damage = max(damage - damage/percent,0) //Remove that amount of the damage
		if(wound_type > 1)
			parent.burn_dam = max(parent.burn_dam - (initial_dmg - damage),0)
		else
			parent.brute_dam = max(parent.brute_dam - (initial_dmg - damage),0)
		initial_dmg = damage //reset it for further updates.
		parent.owner.updatehealth()


/****************************************************
				INTERNAL ORGANS
****************************************************/
/datum/organ/internal
	name = "internal"
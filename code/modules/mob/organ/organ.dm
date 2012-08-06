///////////////////////////////
//CONTAINS: ORGANS AND WOUNDS//
///////////////////////////////

/datum/organ
	var/name = "organ"
	var/mob/living/carbon/human/owner = null

	var/list/datum/autopsy_data/autopsy_data = list()
	var/list/trace_chemicals = list() // traces of chemicals in the organ,
								      // links chemical IDs to number of ticks for which they'll stay in the blood


	proc/process()
		return 0

	proc/receive_chem(chemical as obj)
		return 0

/datum/autopsy_data
	var/weapon = null
	var/pretend_weapon = null
	var/damage = 0
	var/hits = 0
	var/time_inflicted = 0

	proc/copy()
		var/datum/autopsy_data/W = new()
		W.weapon = weapon
		W.pretend_weapon = pretend_weapon
		W.damage = damage
		W.hits = hits
		W.time_inflicted = time_inflicted
		return W

/****************************************************
					WOUNDS
****************************************************/
/datum/wound
	// stages such as "cut", "deep cut", etc.
	var/list/stages
	// number representing the current stage
	var/current_stage = 0

	// description of the wound
	var/desc = ""

	// amount of damage this wound causes
	var/damage = 0

	// amount of damage the current wound type requires(less means we need to apply the next healing stage)
	var/min_damage = 0

	// one of CUTE, BRUISE, BURN
	var/damage_type = BRUTE

	// whether this wound needs a bandage/salve to heal at all
	var/needs_treatment = 0

	// is the wound bandaged?
	var/tmp/bandaged = 0
	// is the wound salved?
	var/tmp/salved = 0
	// is the wound disinfected?
	var/tmp/disinfected = 0

	// helper lists
	var/tmp/list/desc_list = list()
	var/tmp/list/damage_list = list()
	New(var/damage)

		// reading from a list("stage" = damage) is pretty difficult, so build two separate
		// lists from them instead
		for(var/V in stages)
			desc_list += V
			damage_list += stages[V]

		src.damage = damage

		// initialize with the first stage
		next_stage()

		// this will ensure the size of the wound matches the damage
		src.heal_damage(0)

	// returns 1 if there's a next stage, 0 otherwise
	proc/next_stage()
		if(current_stage + 1 > src.desc_list.len)
			return 0

		current_stage++

		src.min_damage = damage_list[current_stage]
		src.desc = desc_list[current_stage]
		return 1

	// returns 1 if the wound has started healing
	proc/started_healing()
		return (current_stage > 1)

	// checks whether the wound has been appropriately treated
	// always returns 1 for wounds that don't need to be treated
	proc/is_treated()
		if(!needs_treatment) return 1

		if(damage_type == BRUISE || damage_type == CUT)
			return bandaged
		else if(damage_type == BURN)
			return salved

	// heal the given amount of damage, and if the given amount of damage was more
	// than what needed to be healed, return how much heal was left
	proc/heal_damage(amount)
		var/healed_damage = min(src.damage, amount)
		amount -= healed_damage
		src.damage -= healed_damage

		while(src.damage < damage_list[current_stage] && current_stage < src.desc_list.len)
			current_stage++
		desc = desc_list[current_stage]

		// return amount of healing still leftover, can be used for other wounds
		return amount

	// opens the wound again
	proc/open_wound()
		if(current_stage > 1)
			// e.g. current_stage is 2, then reset it to 0 and do next_stage(), bringing it to 1
			src.current_stage -= 2
			next_stage()
			src.damage = src.min_damage + 5

/** CUTS **/
/datum/wound/cut
	// link wound descriptions to amounts of damage
	stages = list("cut" = 5, "healing cut" = 2, "small scab" = 0)

/datum/wound/deep_cut
	stages = list("deep cut" = 15, "clotted cut" = 8, "scab" = 2, "fresh skin" = 0)

/datum/wound/flesh_wound
	stages = list("flesh wound" = 25, "blood soaked clot" = 15, "large scab" = 5, "fresh skin" = 0)

/datum/wound/gaping_wound
	stages = list("gaping wound" = 50, "large blood soaked clot" = 25, "large clot" = 15, "small angry scar" = 5, \
	               "small straight scar" = 0)

/datum/wound/big_gaping_wound
	stages = list("big gaping wound" = 60, "gauze wrapped wound" = 50, "blood soaked bandage" = 25,\
				  "large angry scar" = 10, "large straight scar" = 0)

	needs_treatment = 1 // this only heals when bandaged

/datum/wound/massive_wound
	stages = list("massive wound" = 70, "massive blood soaked bandage" = 40, "huge bloody mess" = 20,\
				  "massive angry scar" = 10,  "massive jagged scar" = 0)

	needs_treatment = 1 // this only heals when bandaged

/** BRUISES **/
/datum/wound/bruise
	stages = list("monumental bruise" = 80, "huge bruise" = 50, "large bruise" = 30,\
				  "moderate bruise" = 20, "small bruise" = 10, "tiny bruise" = 5)

	needs_treatment = 1 // this only heals when bandaged
	damage_type = BRUISE

/datum/wound/bruise/monumental_bruise

// implement sub-paths by starting at a later stage
/datum/wound/bruise/huge_bruise
	current_stage = 1

/datum/wound/bruise/large_bruise
	current_stage = 2

/datum/wound/bruise/moderate_bruise
	current_stage = 3
	needs_treatment = 0

/datum/wound/bruise/small_bruise
	current_stage = 4
	needs_treatment = 0

/datum/wound/bruise/tiny_bruise
	current_stage = 5
	needs_treatment = 0

/** BURNS **/
/datum/wound/moderate_burn
	stages = list("moderate burn" = 5, "moderate salved burn" = 2, "fresh skin" = 0)

	needs_treatment = 1 // this only heals when bandaged

	damage_type = BURN

/datum/wound/large_burn
	stages = list("large burn" = 15, "large salved burn" = 5, "fresh skin" = 0)

	needs_treatment = 1 // this only heals when bandaged

	damage_type = BURN

/datum/wound/severe_burn
	stages = list("severe burn" = 30, "severe salved burn" = 10, "burn scar" = 0)

	needs_treatment = 1 // this only heals when bandaged

	damage_type = BURN

/datum/wound/deep_burn
	stages = list("deep burn" = 40, "deep salved burn" = 15,  "large burn scar" = 0)

	needs_treatment = 1 // this only heals when bandaged

	damage_type = BURN

/datum/wound/carbonised_area
	stages = list("carbonised area" = 50, "treated carbonised area" = 20, "massive burn scar" = 0)

	needs_treatment = 1 // this only heals when bandaged

	damage_type = BURN


/****************************************************
				EXTERNAL ORGANS
****************************************************/
/datum/organ/external
	name = "external"
	var/icon_name = null
	var/body_part = null

	var/damage_state = "00"
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/max_size = 0
	var/tmp/list/obj/item/weapon/implant/implant

	var/display_name
	var/list/wounds = list()

	var/tmp/perma_injury = 0
	var/tmp/perma_dmg = 0
	var/tmp/destspawn = 0 //Has it spawned the broken limb?
	var/tmp/amputated = 0 // Whether this has been cleanly amputated, thus causing no pain
	var/min_broken_damage = 30

	var/datum/organ/external/parent
	var/list/datum/organ/external/children

	var/damage_msg = "\red You feel an intense pain"

	var/status = 0
	var/broken_description
	var/open = 0
	var/stage = 0

	New(mob/living/carbon/H)
		..(H)
		if(!display_name)
			display_name = name
		if(istype(H))
			owner = H
			H.organs[name] = src

	proc/take_damage(brute, burn, sharp, used_weapon = null, list/forbidden_limbs = list())
		// TODO: this proc needs to be rewritten to not update damages directly
		if((brute <= 0) && (burn <= 0))
			return 0
		if(status & ORGAN_DESTROYED)
			return 0
		if(status & ORGAN_ROBOT)
			brute *= 0.66 //~2/3 damage for ROBOLIMBS
			burn *= 0.66 //~2/3 damage for ROBOLIMBS

		if(owner && !(status & ORGAN_ROBOT))
			owner.pain(display_name, (brute+burn)*3, 1, burn > brute)

		if(sharp)
			var/nux = brute * rand(10,15)
			if(brute_dam >= max_damage)
				if(prob(5 * brute))
					status |= ORGAN_DESTROYED
					droplimb()
					return

			else if(prob(nux))
				createwound( CUT, brute )
				if(!(status & ORGAN_ROBOT))
					owner << "You feel something wet on your [display_name]"

		if((brute_dam + burn_dam + brute + burn) < max_damage)
			if(brute)
				brute_dam += brute
				if( (prob(brute*2) && !sharp) || sharp )
					createwound( CUT, brute )
				else if(!sharp)
					createwound( BRUISE, brute )
			if(burn)
				burn_dam += burn
				createwound( BURN, burn )
		else
			var/can_inflict = max_damage - (brute_dam + burn_dam) //How much damage can we actually cause?
			if(can_inflict)
				if (brute > 0 && burn > 0)
					brute = can_inflict/2
					burn = can_inflict/2
					var/ratio = brute / (brute + burn)
					brute_dam += ratio * can_inflict
					burn_dam += (1 - ratio) * can_inflict
				else
					if (brute > 0)
						brute = can_inflict
						brute_dam += brute
						if(!sharp && !prob(brute*3)) createwound(max(1,min(6,round(brute/10) + rand(0,1))),1,brute)
						else createwound(max(1,min(6,round(brute/10) + rand(1,2))),1,brute)
					else
						burn = can_inflict
						burn_dam += burn
						createwound(max(1,min(6,round(burn/10) + rand(0,1))),2,burn)
			else if(!(status & ORGAN_ROBOT))
				var/passed_dam = (brute + burn) - can_inflict //Getting how much overdamage we have.
				var/list/datum/organ/external/possible_points = list()
				if(parent)
					possible_points += parent
				if(children)
					possible_points += children
				if(forbidden_limbs.len)
					possible_points -= forbidden_limbs
				if(!possible_points.len)
					message_admins("Oh god WHAT!  [owner]'s [src] was unable to find an organ to pass overdamage too!")
				else
					var/datum/organ/external/target = pick(possible_points)
					if(brute)
						target.take_damage(passed_dam, 0, sharp, used_weapon, forbidden_limbs + src)
					else
						target.take_damage(0, passed_dam, sharp, used_weapon, forbidden_limbs + src)
			else
				droplimb(1) //Robot limbs just kinda fail at full damage.


			if(status & ORGAN_BROKEN)
				owner.emote("scream")

		if(used_weapon) add_wound(used_weapon, brute + burn)

		owner.updatehealth()

		var/result = update_icon()
		return result



	proc/heal_damage(brute, burn, internal = 0, robo_repair = 0)
		if(status & ORGAN_ROBOT && !robo_repair)
			return

		// heal damage on the individual wounds
		for(var/datum/wound/W in wounds)
			if(brute == 0 && burn == 0)
				break

			// heal brute damage
			if(W.damage_type == CUT || W.damage_type == BRUISE)
				brute = W.heal_damage(brute)
			else if(W.damage_type == BURN)
				burn = W.heal_damage(burn)

		// sync organ damage with wound damages
		update_damages()

		if(internal)
			status &= ~ORGAN_BROKEN
			perma_injury = 0

		// if all damage is healed, replace the wounds with scars
		if(brute_dam + burn_dam == 0)
			for(var/V in autopsy_data)
				var/datum/autopsy_data/W = autopsy_data[V]
				del W
			autopsy_data = list()

		owner.updatehealth()
		var/result = update_icon()
		return result

	proc/update_damages()
		brute_dam = 0
		burn_dam = 0
		status &= ~ORGAN_BLEEDING
		for(var/datum/wound/W in wounds)
			if(W.damage_type == CUT || W.damage_type == BRUISE)
				brute_dam += W.damage
			else if(W.damage_type == BURN)
				burn_dam += W.damage

			if(!W.bandaged && W.damage > 4)
				status |= ORGAN_BLEEDING

	proc/update_wounds()
		for(var/datum/wound/W in wounds)
			if(W.is_treated())
				// slow healing
				var/amount = 0.2
				if(W.bandaged) amount++
				if(W.salved) amount++
				if(W.disinfected) amount++
				// amount of healing is spread over all the wounds
				W.heal_damage(amount / (20*owner.number_wounds+1))

	proc/add_wound(var/used_weapon, var/damage)
		var/datum/autopsy_data/W = autopsy_data[used_weapon]
		if(!W)
			W = new()
			W.weapon = used_weapon
			autopsy_data[used_weapon] = W

		W.hits += 1
		W.damage += damage
		W.time_inflicted = world.time

		owner.update_body_appearance()


	proc/get_damage()	//returns total damage
		return max(brute_dam + burn_dam - perma_injury, perma_injury)	//could use health?

	proc/get_damage_brute()
		return max(brute_dam+perma_injury, perma_injury)

	proc/get_damage_fire()
		return burn_dam

	process()
		// process wounds, doing healing etc.
		update_wounds()
		// update damages from wounds
		update_damages()
		if(status & ORGAN_DESTROYED)
			if(!destspawn)
				droplimb()
			return
		if(!(status & ORGAN_BROKEN))
			perma_dmg = 0
		if(parent)
			if(parent.status & ORGAN_DESTROYED)
				status |= ORGAN_DESTROYED
				owner:update_body()
				return
		if(brute_dam > min_broken_damage && !(status & ORGAN_ROBOT))
			if(!(status & ORGAN_BROKEN))
				owner.visible_message("\red You hear a loud cracking sound coming from \the [owner].","\red <b>Something feels like it shattered in your [display_name]!</b>","You hear a sickening crack.")
				owner.emote("scream")
				status |= ORGAN_BROKEN
				broken_description = pick("broken","fracture","hairline fracture")
				perma_injury = brute_dam
		return

// new damage icon system
// returns just the brute/burn damage code
	proc/damage_state_text()
		var/tburn = 0
		var/tbrute = 0

		if(burn_dam ==0)
			tburn =0
		else if (burn_dam < (max_damage * 0.25 / 2))
			tburn = 1
		else if (burn_dam < (max_damage * 0.75 / 2))
			tburn = 2
		else
			tburn = 3

		if (brute_dam == 0)
			tbrute = 0
		else if (brute_dam < (max_damage * 0.25 / 2))
			tbrute = 1
		else if (brute_dam < (max_damage * 0.75 / 2))
			tbrute = 2
		else
			tbrute = 3
		return "[tbrute][tburn]"


// new damage icon system
// adjusted to set damage_state to brute/burn code only (without r_name0 as before)
	proc/update_icon()
		var/n_is = damage_state_text()
		if (n_is != damage_state)
			damage_state = n_is
			owner.update_body_appearance() // I'm not sure about this, Sky probably knows better where to put it
			return 1
		return 0

	proc/droplimb(var/override = 0,var/no_explode = 0)
		if(override)
			status |= ORGAN_DESTROYED
		if(status & ORGAN_DESTROYED)
			if(status & ORGAN_SPLINTED)
				status &= ~ORGAN_SPLINTED
			if(implant)
				for(var/implants in implant)
					del(implants)
			//owner.unlock_medal("Lost something?", 0, "Lose a limb.", "easy")

			for(var/datum/organ/external/I in children)
				if(I && !(I.status & ORGAN_DESTROYED))
					I.droplimb(1,1)
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
					if(!owner.original_name)
						owner.original_name = owner.real_name
					H.name = "[owner.original_name]'s head"

					owner.update_face()
					owner.update_body()
					owner.death()
				if(ARM_RIGHT)
					H = new /obj/item/weapon/organ/r_arm(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "r_arm_l"
				if(ARM_LEFT)
					H = new /obj/item/weapon/organ/l_arm(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "l_arm_l"
				if(LEG_RIGHT)
					H = new /obj/item/weapon/organ/r_leg(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "r_leg_l"
				if(LEG_LEFT)
					H = new /obj/item/weapon/organ/l_leg(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "l_leg_l"
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
			if(status & ORGAN_ROBOT)
				owner.visible_message("\red \The [owner]'s [display_name] explodes violently!",\
				"\red <b>Your [display_name] explodes!</b>",\
				"You hear an explosion followed by a scream!")
				if(!no_explode)
					explosion(get_turf(owner),-1,-1,2,3)
					var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
					spark_system.set_up(5, 0, src)
					spark_system.attach(src)
					spark_system.start()
					spawn(10)
						del(spark_system)
			else
				owner.visible_message("\red [owner.name]'s [display_name] flies off in an arc.",\
				"<span class='moderate'><b>Your [display_name] goes flying off!</b></span>",\
				"You hear a terrible sound of ripping tendons and flesh.")
			owner.update_body_appearance()
			owner.update_clothing()

	proc/createwound(var/type = CUT, var/damage)
		if(hasorgans(owner))
			var/wound_type
			var/size = min( max( 1, damage/10 ) , 6)

			// first check whether we can widen an existing wound
			if(wounds.len > 0 && prob(25))
				if((type == CUT || type == BRUISE) && damage >= 5)
					var/datum/wound/W = pick(wounds)
					if(W.started_healing())
						W.open_wound()
						owner.visible_message("\red The wound on [owner.name]'s [display_name] widens with a nasty ripping voice.",\
						"\red The wound on your [display_name] widens with a nasty ripping voice.",\
						"You hear a nasty ripping noise, as if flesh is being torn apart.")

						return

			if(damage == 0) return

			switch(type)
				if(CUT)
					src.status |= ORGAN_BLEEDING
					var/list/size_names = list(/datum/wound/cut, /datum/wound/deep_cut, /datum/wound/flesh_wound, /datum/wound/gaping_wound, /datum/wound/big_gaping_wound, /datum/wound/massive_wound)
					wound_type = size_names[size]

					var/datum/wound/W = new wound_type(damage)
					wounds += W
				if(BRUISE)
					var/list/size_names = list(/datum/wound/bruise/tiny_bruise, /datum/wound/bruise/small_bruise, /datum/wound/bruise/moderate_bruise, /datum/wound/bruise/large_bruise, /datum/wound/bruise/huge_bruise, /datum/wound/bruise/monumental_bruise)
					wound_type = size_names[size]

					var/datum/wound/W = new wound_type(damage)
					W.damage = damage
					wounds += W
				if(BURN)
					var/list/size_names = list(/datum/wound/moderate_burn, /datum/wound/large_burn, /datum/wound/severe_burn, /datum/wound/deep_burn, /datum/wound/carbonised_area)
					wound_type = size_names[size]

					var/datum/wound/W = new wound_type(damage)
					W.damage = damage
					wounds += W

	proc/emp_act(severity)
		if(!(status & ORGAN_ROBOT))
			return
		if(prob(30*severity))
			take_damage(4(4-severity), 0, 1, used_weapon = "EMP")
		else
			droplimb(1)

	proc/getDisplayName()
		switch(name)
			if("l_leg")
				return "left leg"
			if("r_leg")
				return "right leg"
			if("l_arm")
				return "left arm"
			if("r_arm")
				return "right arm"
			if("l_foot")
				return "left foot"
			if("r_foot")
				return "right foot"
			if("l_hand")
				return "left hand"
			if("r_hand")
				return "right hand"
			else
				return name



/****************************************************
				INTERNAL ORGANS
****************************************************/
/datum/organ/internal
	name = "internal"
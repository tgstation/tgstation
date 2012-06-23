///////////////////////////////
//CONTAINS: ORGANS AND WOUNDS//
///////////////////////////////

var/list/wound_progressions = list(
//cut healing path"
"cut" = "healing cut", "healing cut" = "small scab",\

//deep cut healing path
"deep cut" = "clotted cut", "clotted cut" = "scab", "scab" = "fresh skin",\

//flesh wound healing path
"flesh wound" = "blood soaked clot", "blood soaked clot" = "large scab", "large scab" = "fresh skin",\

//gaping wound healing path
"gaping wound" = "large blood soaked clot", "large blood soaked clot" = "large clot", "large clot" = "small angry scar",\
"small angry scar" = "small straight scar",\

//big gaping wound healing path
"big gaping wound" = "gauze wrapped wound", "gauze wrapped wound" = "blood soaked bandage", "blood soaked bandage" = "large angry scar",\
"large angry scar" = "large straight scar",\

//massive wound healing path
"massive wound" = "massive blood soaked bandage", "massive blood soaked bandage" = "huge bloody mess", "huge bloody mess" = "massive angry scar",\
"massive angry scar" = "massive jagged scar",\

//bruise healing path
"monumental bruise" = "large bruise", "huge bruise" = "large bruise", "large bruise" = "moderate bruise",\
"moderate bruise" = "small bruise", "small bruise" = "tiny bruise",\

//moderate burn healing path
"moderate burn" = "moderate salved burn", "moderate salved burn" = "fresh skin",\

"large burn" = "large salved burn", "large salved burn" = "moderate salved burn",\

"severe burn" = "severe salved burn", "severe salved burn" = "burn scar",\

"deep burn" = "deep salved burn", "deep salved burn" = "large burn scar",\

"carbonised area" = "treated carbonised area", "treated carbonised area" = "massive burn scar")

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

#define CUT 0
#define BRUISE 1
#define BURN 2

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

	var/tmp/list/wound_descs = list()
	var/tmp/next_wound_update = 0

	var/tmp/perma_injury = 0
	var/tmp/perma_dmg = 0
	var/tmp/destspawn = 0 //Has it spawned the broken limb?
	var/min_broken_damage = 30

	var/datum/organ/external/parent
	var/list/datum/organ/external/children

	var/damage_msg = "\red You feel a intense pain"

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
		if((brute <= 0) && (burn <= 0))
			return 0
		if(status & DESTROYED)
			return 0
		if(status & ROBOT)
			brute *= 0.66 //~2/3 damage for ROBOLIMBS
			burn *= 0.66 //~2/3 damage for ROBOLIMBS

		if(owner && !(status & ROBOT))
			owner.pain(display_name, (brute+burn)*3, 1, burn > brute)

		if(sharp)
			var/nux = brute * rand(10,15)
			if(brute_dam >= max_damage)
				if(prob(5 * brute))
					status |= DESTROYED
					droplimb()
					return

			else if(prob(nux))
				createwound( CUT, brute )
				if(!(status & ROBOT))
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
			else if(!(status & ROBOT))
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


			if(status & BROKEN)
				owner.emote("scream")

		if(used_weapon) add_wound(used_weapon, brute + burn)

		owner.updatehealth()

		var/result = update_icon()
		return result


	proc/heal_damage(brute, burn, internal = 0, robo_repair = 0)
		if(status & ROBOT && !robo_repair)
			return
	//	var/brute_to_heal = 0
	//	var/brute_wounds = list()
	//	var/burn_to_heal = 0
	//	var/burn_wounds = list()
	//	for(var/datum/organ/wound/W in brute_wounds)

		brute_dam = max(0, brute_dam-brute)
		burn_dam = max(0, burn_dam-burn)

		if(internal)
			status &= ~BROKEN
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
		if(next_wound_update && world.time > next_wound_update)
			update_wounds()
		if(status & DESTROYED)
			if(!destspawn)
				droplimb()
			return
		if(!(status & BROKEN))
			perma_dmg = 0
		if(parent)
			if(parent.status & DESTROYED)
				status |= DESTROYED
				owner:update_body()
				return
		if(brute_dam > min_broken_damage && !(status & ROBOT))
			if(!(status & BROKEN))
				//owner.unlock_medal("Broke Yarrr Bones!", 0, "Break a bone.", "easy")
				owner.visible_message("\red You hear a loud cracking sound coming from \the [owner].","\red <b>Something feels like it shattered in your [display_name]!</b>","You hear a sickening crack.")
				owner.emote("scream")
				status |= BROKEN
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
			status |= DESTROYED
		if(status & DESTROYED)
			if(implant)
				for(var/implants in implant)
					del(implants)
			//owner.unlock_medal("Lost something?", 0, "Lose a limb.", "easy")

			for(var/datum/organ/external/I in children)
				if(I && !(I.status & DESTROYED))
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
			if(status & ROBOT)
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
			var/wound_name
			var/update_time = world.time + damage*100
			var/size = min( max( 1, damage/10 ) , 6)
			switch(type)
				if(CUT)
					var/list/size_names = list("cut", "deep cut", "flesh wound", "gaping wound", "big gaping wound", "massive wound")
					wound_name = size_names[size]
					if(wound_descs["[update_time]"])
						var/list/update_next = wound_descs["[update_time]"]
						update_next += wound_name
					else
						if (next_wound_update > update_time)
							next_wound_update = update_time
						wound_descs["[update_time]"] = list(wound_name)
				if(BRUISE)
					var/list/size_names = list("tiny bruise", "small bruise", "moderate bruise", "large bruise", "huge bruise", "monumental bruise")
					wound_name = size_names[size]
					if(wound_descs["[update_time]"])
						var/list/update_next = wound_descs["[update_time]"]
						update_next += wound_name
					else
						if (next_wound_update > update_time)
							next_wound_update = update_time
						wound_descs["[update_time]"] = list(wound_name)
				if(BURN)
					var/list/size_names = list("small burn", "moderate burn", "large burn", "severe burn", "deep burn", "carbonised area")
					wound_name = size_names[size]
					update_time += damage*300
					if(wound_descs["[update_time]"])
						var/list/update_next = wound_descs["[update_time]"]
						update_next += wound_name
					else
						if (next_wound_update > update_time)
							next_wound_update = update_time
						wound_descs["[update_time]"] = list(wound_name)

	proc/update_wounds()
		var/list/wounds_to_update = wound_descs["[next_wound_update]"]
		for(var/wound in wounds_to_update)
			if(wound_progressions[wound])
				var/wound_name = wound_progressions[wound]
				var/next_update = world.time + 600*rand(5,13)
				if(wound_descs["[next_update]"])
					var/list/update_next = wound_descs["[next_update]"]
					update_next += wound_name
				else
					wound_descs["[next_update]"] = list(wound_name)
		wound_descs.Remove("[next_wound_update]")
		if(wound_descs.len)
			var/next_update = text2num(wound_descs[1])
			for(var/wound in wound_descs)
				next_update = min(next_update, text2num(wound))
			next_wound_update = next_update
		else
			next_wound_update = 0

	proc/emp_act(severity)
		if(!(status & ROBOT))
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

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
	var/number_wounds = 0 // cache the number of wounds, which is NOT wounds.len!

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

	// how often wounds should be updated, a higher number means less often
	var/wound_update_accuracy = 20 // update every 20 ticks(roughly every minute)

	proc/take_damage(brute, burn, sharp, used_weapon = null, list/forbidden_limbs = list())
		// TODO: this proc needs to be rewritten to not update damages directly
		if((brute <= 0) && (burn <= 0))
			return 0
		if(status & ORGAN_DESTROYED)
			return 0
		if(status & ORGAN_ROBOT)
			brute *= 0.66 //~2/3 damage for ROBOLIMBS
			burn *= 0.66 //~2/3 damage for ROBOLIMBS

		//if(owner && !(status & ORGAN_ROBOT))
		//	owner.pain(display_name, (brute+burn)*3, 1, burn > brute)

		if(sharp)
			var/nux = brute * rand(10,15)
			if(config.limbs_can_break && brute_dam >= max_damage * config.organ_health_multiplier)
				if(prob(5 * brute))
					status |= ORGAN_DESTROYED
					droplimb()
					return

			else if(prob(nux))
				createwound( CUT, brute )
				if(!(status & ORGAN_ROBOT))
					owner << "You feel something wet on your [display_name]"

		else if(brute > 20)
			if(config.limbs_can_break && brute_dam >= max_damage * config.organ_health_multiplier)
				if(prob(5 * brute))
					status |= ORGAN_DESTROYED
					droplimb()
					return

		// If the limbs can break, make sure we don't exceed the maximum damage a limb can take before breaking
		if((brute_dam + burn_dam + brute + burn) < max_damage || !config.limbs_can_break)
			if(brute)
				if( (prob(brute*2) && !sharp) || sharp )
					createwound( CUT, brute )
				else if(!sharp)
					createwound( BRUISE, brute )
			if(burn)
				createwound( BURN, burn )
		else
			// If we can't inflict the full amount of damage, spread the damage in other ways
			var/can_inflict = max_damage * config.organ_health_multiplier - (brute_dam + burn_dam) //How much damage can we actually cause?
			if(can_inflict)
				if (brute > 0)
					brute = can_inflict
					createwound(BRUISE, brute)
				if (burn > 0)
					burn = can_inflict
					createwound(BURN, burn)
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

		owner.updatehealth()

		// sync the organ's damage with its wounds
		src.update_damages()

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

		// sync the organ's damage with its wounds
		src.update_damages()

		owner.updatehealth()
		var/result = update_icon()
		return result

	proc/update_damages()
		number_wounds = 0
		brute_dam = 0
		burn_dam = 0
		status &= ~ORGAN_BLEEDING
		for(var/datum/wound/W in wounds)
			if(W.damage_type == CUT || W.damage_type == BRUISE)
				brute_dam += W.damage
			else if(W.damage_type == BURN)
				burn_dam += W.damage

			if(W.bleeding())
				status |= ORGAN_BLEEDING

			number_wounds += W.amount

	proc/update_wounds()
		for(var/datum/wound/W in wounds)
			// wounds can disappear after 10 minutes at the earliest
			if(W.damage == 0 && W.created + 10 * 10 * 60 <= world.time)
				wounds -= W
				// let the GC handle the deletion of the wound
			if(W.is_treated())
				// slow healing
				var/amount = 0.2
				if(W.bandaged) amount++
				if(W.salved) amount++
				if(W.disinfected) amount++
				// amount of healing is spread over all the wounds
				W.heal_damage((wound_update_accuracy * amount * W.amount * config.organ_regeneration_multiplier) / (20*owner.number_wounds+1))

		// sync the organ's damage with its wounds
		src.update_damages()

	proc/bandage()
		var/rval = 0
		status |= ORGAN_BANDAGED
		for(var/datum/wound/W in wounds)
			rval |= !W.bandaged
			W.bandaged = 1
		return rval

	proc/salve()
		var/rval = 0
		for(var/datum/wound/W in wounds)
			rval |= !W.salved
			W.salved = 1
		return rval

	proc/get_damage()	//returns total damage
		return max(brute_dam + burn_dam - perma_injury, perma_injury)	//could use health?

	proc/get_damage_brute()
		return max(brute_dam+perma_injury, perma_injury)

	proc/get_damage_fire()
		return burn_dam

	process()
		// process wounds, doing healing etc., only do this every 4 ticks to save processing power
		if(owner.life_tick % wound_update_accuracy == 0)
			update_wounds()
		if(status & ORGAN_DESTROYED)
			if(!destspawn && config.limbs_can_break)
				droplimb()
			return
		if(!(status & ORGAN_BROKEN))
			perma_dmg = 0
		if(parent)
			if(parent.status & ORGAN_DESTROYED)
				status |= ORGAN_DESTROYED
				owner.update_body(1)
				return
		if(config.bones_can_break && brute_dam > min_broken_damage * config.organ_health_multiplier && !(status & ORGAN_ROBOT))
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
		if(status & ORGAN_DESTROYED)
			return "--"

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
			owner.update_body(1)
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

			// If any organs are attached to this, destroy them
			for(var/datum/organ/external/O in owner.organs)
				if(O.parent == src)
					O.droplimb(1)

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
						H.overlays += owner.generate_head_icon()
					H:transfer_identity(owner)
					H.pixel_x = -10
					H.pixel_y = 6
					H.name = "[owner.real_name]'s head"

					owner.u_equip(owner.glasses)
					owner.u_equip(owner.head)
					owner.u_equip(owner.ears)
					owner.u_equip(owner.wear_mask)

					owner.regenerate_icons()

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
					owner.u_equip(owner.gloves)
				if(HAND_LEFT)
					H = new /obj/item/weapon/organ/l_hand(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "l_hand_l"
					owner.u_equip(owner.gloves)
				if(FOOT_RIGHT)
					H = new /obj/item/weapon/organ/r_foot/(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "r_foot_l"
					owner.u_equip(owner.shoes)
				if(FOOT_LEFT)
					H = new /obj/item/weapon/organ/l_foot(owner.loc, owner)
					if(ismonkey(owner))
						H.icon_state = "l_foot_l"
					owner.u_equip(owner.shoes)
			if(ismonkey(owner))
				H.icon = 'monkey.dmi'
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

			// force the icon to rebuild
			owner.regenerate_icons()

	proc/createwound(var/type = CUT, var/damage)
		if(hasorgans(owner))
			var/wound_type
			var/size = min( max( 1, damage/10 ) , 6)

			// first check whether we can widen an existing wound
			if(wounds.len > 0 && prob(max(50+owner.number_wounds*10,100)))
				if((type == CUT || type == BRUISE) && damage >= 5)
					var/datum/wound/W = pick(wounds)
					if(W.amount == 1 && W.started_healing())
						W.open_wound(damage)
						if(prob(25))
							owner.visible_message("\red The wound on [owner.name]'s [display_name] widens with a nasty ripping voice.",\
							"\red The wound on your [display_name] widens with a nasty ripping voice.",\
							"You hear a nasty ripping noise, as if flesh is being torn apart.")

						return

			if(damage == 0) return

			// the wound we will create
			var/datum/wound/W

			switch(type)
				if(CUT)
					src.status |= ORGAN_BLEEDING
					var/list/size_names = list(/datum/wound/cut, /datum/wound/deep_cut, /datum/wound/flesh_wound, /datum/wound/gaping_wound, /datum/wound/big_gaping_wound, /datum/wound/massive_wound)
					wound_type = size_names[size]

					W = new wound_type(damage)

				if(BRUISE)
					var/list/size_names = list(/datum/wound/bruise/tiny_bruise, /datum/wound/bruise/small_bruise, /datum/wound/bruise/moderate_bruise, /datum/wound/bruise/large_bruise, /datum/wound/bruise/huge_bruise, /datum/wound/bruise/monumental_bruise)
					wound_type = size_names[size]

					W = new wound_type(damage)
				if(BURN)
					var/list/size_names = list(/datum/wound/moderate_burn, /datum/wound/large_burn, /datum/wound/severe_burn, /datum/wound/deep_burn, /datum/wound/carbonised_area)
					wound_type = size_names[size]

					W = new wound_type(damage)



			// check whether we can add the wound to an existing wound
			for(var/datum/wound/other in wounds)
				if(other.desc == W.desc)
					// okay, add it!
					other.damage += W.damage
					other.amount += 1
					W = null // to signify that the wound was added
					break

			// if we couldn't add the wound to another wound, ignore
			if(W)
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

/datum/organ/external/chest
	name = "chest"
	icon_name = "chest"
	display_name = "chest"
	max_damage = 150
	min_broken_damage = 75
	body_part = UPPER_TORSO

/datum/organ/external/groin
	name = "groin"
	icon_name = "diaper"
	display_name = "groin"
	max_damage = 115
	min_broken_damage = 70
	body_part = LOWER_TORSO

/datum/organ/external/head
	name = "head"
	icon_name = "head"
	display_name = "head"
	max_damage = 75
	min_broken_damage = 40
	body_part = HEAD
	var/disfigured = 0

/datum/organ/external/l_arm
	name = "l_arm"
	display_name = "left arm"
	icon_name = "l_arm"
	max_damage = 75
	min_broken_damage = 30
	body_part = ARM_LEFT

/datum/organ/external/l_leg
	name = "l_leg"
	display_name = "left leg"
	icon_name = "l_leg"
	max_damage = 75
	min_broken_damage = 30
	body_part = LEG_LEFT

/datum/organ/external/r_arm
	name = "r_arm"
	display_name = "right arm"
	icon_name = "r_arm"
	max_damage = 75
	min_broken_damage = 30
	body_part = ARM_RIGHT

/datum/organ/external/r_leg
	name = "r_leg"
	display_name = "right leg"
	icon_name = "r_leg"
	max_damage = 75
	min_broken_damage = 30
	body_part = LEG_RIGHT

/datum/organ/external/l_foot
	name = "l_foot"
	display_name = "left foot"
	icon_name = "l_foot"
	max_damage = 40
	min_broken_damage = 15
	body_part = FOOT_LEFT

/datum/organ/external/r_foot
	name = "r_foot"
	display_name = "right foot"
	icon_name = "r_foot"
	max_damage = 40
	min_broken_damage = 15
	body_part = FOOT_RIGHT

/datum/organ/external/r_hand
	name = "r_hand"
	display_name = "right hand"
	icon_name = "r_hand"
	max_damage = 40
	min_broken_damage = 15
	body_part = HAND_RIGHT

/datum/organ/external/l_hand
	name = "l_hand"
	display_name = "left hand"
	icon_name = "l_hand"
	max_damage = 40
	min_broken_damage = 15
	body_part = HAND_LEFT

/****************************************************
			   EXTERNAL ORGAN ITEMS
****************************************************/

obj/item/weapon/organ
	icon = 'human.dmi'

obj/item/weapon/organ/New(loc, mob/living/carbon/human/H)
	..(loc)
	if(!istype(H))
		return
	if(H.dna)
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA[H.dna.unique_enzymes] = H.dna.b_type

	var/icon/I = new /icon(icon, icon_state)

	if (H.s_tone >= 0)
		I.Blend(rgb(H.s_tone, H.s_tone, H.s_tone), ICON_ADD)
	else
		I.Blend(rgb(-H.s_tone,  -H.s_tone,  -H.s_tone), ICON_SUBTRACT)
	icon = I

obj/item/weapon/organ/head
	name = "head"
	icon_state = "head_m_l"
	var/mob/living/carbon/brain/brainmob
	var/brain_op_stage = 0

obj/item/weapon/organ/head/New()
	..()
	spawn(5)
	if(brainmob && brainmob.client)
		brainmob.client.screen.len = null //clear the hud

obj/item/weapon/organ/head/proc/transfer_identity(var/mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->head
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna
	if(H.mind)
		H.mind.transfer_to(brainmob)
	brainmob.container = src

obj/item/weapon/organ/head/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/scalpel))
		switch(brain_op_stage)
			if(0)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] is beginning to have \his head cut open with [src] by [user].", 1)
				brainmob << "\red [user] begins to cut open your head with [src]!"
				user << "\red You cut [brainmob]'s head open with [src]!"

				brain_op_stage = 1

			if(2)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] is having \his connections to the brain delicately severed with [src] by [user].", 1)
				brainmob << "\red [user] begins to cut open your head with [src]!"
				user << "\red You cut [brainmob]'s head open with [src]!"

				brain_op_stage = 3.0
			else
				..()
	else if(istype(W,/obj/item/weapon/circular_saw))
		switch(brain_op_stage)
			if(1)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] has \his skull sawed open with [src] by [user].", 1)
				brainmob << "\red [user] begins to saw open your head with [src]!"
				user << "\red You saw [brainmob]'s head open with [src]!"

				brain_op_stage = 2
			if(3)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] has \his spine's connection to the brain severed with [src] by [user].", 1)
				brainmob << "\red [user] severs your brain's connection to the spine with [src]!"
				user << "\red You sever [brainmob]'s brain's connection to the spine with [src]!"

				user.attack_log += "\[[time_stamp()]\]<font color='red'> Debrained [brainmob.name] ([brainmob.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
				brainmob.attack_log += "\[[time_stamp()]\]<font color='orange'> Debrained by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
				log_admin("ATTACK: [brainmob] ([brainmob.ckey]) debrained [user] ([user.ckey]).")
				message_admins("ATTACK: [brainmob] ([brainmob.ckey]) debrained [user] ([user.ckey]).")

				var/obj/item/brain/B = new(loc)
				B.transfer_identity(brainmob)

				brain_op_stage = 4.0
			else
				..()
	else
		..()

obj/item/weapon/organ/l_arm
	name = "left arm"
	icon_state = "l_arm_l"
obj/item/weapon/organ/l_foot
	name = "left foot"
	icon_state = "l_foot_l"
obj/item/weapon/organ/l_hand
	name = "left hand"
	icon_state = "l_hand_l"
obj/item/weapon/organ/l_leg
	name = "left leg"
	icon_state = "l_leg_l"
obj/item/weapon/organ/r_arm
	name = "right arm"
	icon_state = "r_arm_l"
obj/item/weapon/organ/r_foot
	name = "right foot"
	icon_state = "r_foot_l"
obj/item/weapon/organ/r_hand
	name = "right hand"
	icon_state = "r_hand_l"
obj/item/weapon/organ/r_leg
	name = "right leg"
	icon_state = "r_leg_l"
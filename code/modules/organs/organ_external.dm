/****************************************************
				EXTERNAL ORGANS
****************************************************/
/datum/organ/external
	name = "external"
	var/icon_name = null
	var/body_part = null
	var/icon_position = 0

	var/damage_state = "00"
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/max_size = 0
	var/last_dam = -1

	var/display_name
	var/list/wounds = list()
	var/number_wounds = 0 // cache the number of wounds, which is NOT wounds.len!

	var/tmp/perma_injury = 0
	var/tmp/destspawn = 0 //Has it spawned the broken limb?
	var/tmp/amputated = 0 //Whether this has been cleanly amputated, thus causing no pain
	var/min_broken_damage = 30

	var/datum/organ/external/parent
	var/list/datum/organ/external/children

	// Internal organs of this body part
	var/list/datum/organ/internal/internal_organs

	var/damage_msg = "\red You feel an intense pain"
	var/broken_description

	var/open = 0
	var/stage = 0
	var/cavity = 0
	var/sabotaged = 0 //If a prosthetic limb is emagged, it will detonate when it fails.
	var/encased       // Needs to be opened with a saw to access the organs.

	var/obj/item/hidden = null
	var/list/implants = list()

	// how often wounds should be updated, a higher number means less often
	var/wound_update_accuracy = 1

	var/has_fat=0 // Has a _fat variant

/datum/organ/external/New(var/datum/organ/external/P)
	if(P)
		parent = P
		if(!parent.children)
			parent.children = list()
		parent.children.Add(src)
	return ..()

/****************************************************
			   DAMAGE PROCS
****************************************************/

/datum/organ/external/proc/emp_act(severity)
	if(!(status & ORGAN_ROBOT))	//meatbags do not care about EMP
		return
	var/probability = 30
	var/damage = 15
	if(severity == 2)
		probability = 1
		damage = 3
	if(prob(probability))
		droplimb(1)
	else
		take_damage(damage, 0, 1, used_weapon = "EMP")

/datum/organ/external/proc/take_damage(brute, burn, sharp, edge, used_weapon = null, list/forbidden_limbs = list())
	if((brute <= 0) && (burn <= 0))
		return 0

	if(status & ORGAN_DESTROYED)
		return 0
	if(status & (ORGAN_ROBOT|ORGAN_PEG))
		brute *= 0.66 //~2/3 damage for ROBOLIMBS
		burn *= 0.66 //~2/3 damage for ROBOLIMBS

	//If limb took enough damage, try to cut or tear it off
	if(body_part != UPPER_TORSO && body_part != LOWER_TORSO) //as hilarious as it is, getting hit on the chest too much shouldn't effectively gib you.
		if(config.limbs_can_break && brute_dam >= max_damage * config.organ_health_multiplier)
			if( (sharp && prob(5 * brute)) || (brute > 20 && prob(2 * brute)) )
				droplimb(1)
				return

	// High brute damage or sharp objects may damage internal organs
	if(internal_organs != null) if( (sharp && brute >= 5) || brute >= 10) if(prob(5))
		// Damage an internal organ
		var/datum/organ/internal/I = pick(internal_organs)
		I.take_damage(brute / 2)
		brute -= brute / 2

	if(status & ORGAN_BROKEN && prob(40) && brute)
		owner.agony = 1
		owner.emote("scream")	//getting hit on broken hand hurts
		owner.agony = 0
	if(used_weapon)
		add_autopsy_data("[used_weapon]", brute + burn)

	var/can_cut = (prob(brute*2) || sharp) && !(status & (ORGAN_ROBOT|ORGAN_PEG))
	// If the limbs can break, make sure we don't exceed the maximum damage a limb can take before breaking
	if((brute_dam + burn_dam + brute + burn) < max_damage || !config.limbs_can_break)
		if(brute)
			if(can_cut)
				createwound( CUT, brute )
			else
				createwound( BRUISE, brute )
		if(burn)
			createwound( BURN, burn )
	else
		//If we can't inflict the full amount of damage, spread the damage in other ways
		//How much damage can we actually cause?
		var/can_inflict = max_damage * config.organ_health_multiplier - (brute_dam + burn_dam)
		if(can_inflict)
			if (brute > 0)
				//Inflict all burte damage we can
				if(can_cut)
					createwound( CUT, min(brute,can_inflict) )
				else
					createwound( BRUISE, min(brute,can_inflict) )
				var/temp = can_inflict
				//How much mroe damage can we inflict
				can_inflict = max(0, can_inflict - brute)
				//How much brute damage is left to inflict
				brute = max(0, brute - temp)

			if (burn > 0 && can_inflict)
				//Inflict all burn damage we can
				createwound(BURN, min(burn,can_inflict))
				//How much burn damage is left to inflict
				burn = max(0, burn - can_inflict)
		//If there are still hurties to dispense
		if (burn || brute)
			if (status & (ORGAN_ROBOT|ORGAN_PEG))
				droplimb(1) //Robot limbs just kinda fail at full damage.
			else
				//List organs we can pass it to
				var/list/datum/organ/external/possible_points = list()
				if(parent)
					possible_points += parent
				if(children)
					possible_points += children
				if(forbidden_limbs.len)
					possible_points -= forbidden_limbs
				if(possible_points.len)
					//And pass the pain around
					var/datum/organ/external/target = pick(possible_points)
					target.take_damage(brute, burn, sharp, edge, used_weapon, forbidden_limbs + src)

	// sync the organ's damage with its wounds
	src.update_damages()
	owner.updatehealth()

	var/result = update_icon()
	return result

/datum/organ/external/proc/heal_damage(brute, burn, internal = 0, robo_repair = 0)
	if(status & ORGAN_ROBOT && !robo_repair)
		return

	// Can't fix peglegs.
	if(status & ORGAN_PEG)
		return

	//Heal damage on the individual wounds
	for(var/datum/wound/W in wounds)
		if(brute == 0 && burn == 0)
			break

		// heal brute damage
		if(W.damage_type == CUT || W.damage_type == BRUISE)
			brute = W.heal_damage(brute)
		else if(W.damage_type == BURN)
			burn = W.heal_damage(burn)

	if(internal)
		status &= ~ORGAN_BROKEN
		perma_injury = 0

	//Sync the organ's damage with its wounds
	src.update_damages()
	owner.updatehealth()

	var/result = update_icon()
	return result

/*
This function completely restores a damaged organ to perfect condition.
*/
/datum/organ/external/proc/rejuvenate()
	damage_state = "00"
	// Robotic organs stay robotic.  Fix because right click rejuvinate makes IPC's organs organic.
	// N3X: Use bitmask to exclude shit we don't want.
	status=status & (ORGAN_ROBOT|ORGAN_PEG)
	perma_injury = 0
	brute_dam = 0
	burn_dam = 0

	// handle internal organs
	for(var/datum/organ/internal/current_organ in internal_organs)
		current_organ.rejuvenate()

	// remove embedded objects and drop them on the floor
	for(var/obj/implanted_object in implants)
		if(!istype(implanted_object,/obj/item/weapon/implant))	// We don't want to remove REAL implants. Just shrapnel etc.
			implanted_object.loc = owner.loc
			implants -= implanted_object

	owner.updatehealth()


/datum/organ/external/proc/createwound(var/type = CUT, var/damage)
	if(damage == 0) return

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

	//Creating wound
	var/datum/wound/W
	var/size = min( max( 1, damage/10 ) , 6)
	//Possible types of wound
	var/list/size_names = list()
	switch(type)
		if(CUT)
			size_names = typesof(/datum/wound/cut/) - /datum/wound/cut/
		if(BRUISE)
			size_names = typesof(/datum/wound/bruise/) - /datum/wound/bruise/
		if(BURN)
			size_names = typesof(/datum/wound/burn/) - /datum/wound/burn/

	size = min(size,size_names.len)
	var/wound_type = size_names[size]
	W = new wound_type(damage)

	//Possibly trigger an internal wound, too.
	var/local_damage = brute_dam + burn_dam + damage
	if(damage > 10 && type != BURN && local_damage > 20 && prob(damage) && !(status & (ORGAN_ROBOT|ORGAN_PEG))&& !(owner.species && owner.species.flags & NO_BLOOD))
		var/datum/wound/internal_bleeding/I = new (15)
		wounds += I
		owner.custom_pain("You feel something rip in your [display_name]!", 1)

	//Check whether we can add the wound to an existing wound
	for(var/datum/wound/other in wounds)
		if(other.desc == W.desc)
			// okay, add it!
			other.damage += W.damage
			other.amount += 1
			W = null // to signify that the wound was added
			break
	if(W)
		wounds += W

/****************************************************
			   PROCESSING & UPDATING
****************************************************/

//Determines if we even need to process this organ.

/datum/organ/external/proc/need_process()
	if(status && status & (ORGAN_ROBOT|ORGAN_PEG)) // If it's robotic OR PEG, that's fine it will have a status.
		return 1
	if(brute_dam || burn_dam)
		return 1
	if(last_dam != brute_dam + burn_dam) // Process when we are fully healed up.
		last_dam = brute_dam + burn_dam
		return 1
	last_dam = brute_dam + burn_dam
	return 0

/datum/organ/external/process()
	// Process wounds, doing healing etc. Only do this every few ticks to save processing power
	if(owner.life_tick % wound_update_accuracy == 0)
		update_wounds()

	//Chem traces slowly vanish
	if(owner.life_tick % 10 == 0)
		for(var/chemID in trace_chemicals)
			trace_chemicals[chemID] = trace_chemicals[chemID] - 1
			if(trace_chemicals[chemID] <= 0)
				trace_chemicals.Remove(chemID)

	//Dismemberment
	if(status & ORGAN_DESTROYED)
		if(!destspawn && config.limbs_can_break)
			droplimb()
		return
	if(parent)
		if(parent.status & ORGAN_DESTROYED)
			status |= ORGAN_DESTROYED
			owner.update_body(1)
			return

	//Bone fracurtes
	if(config.bones_can_break && brute_dam > min_broken_damage * config.organ_health_multiplier && !(status & (ORGAN_ROBOT|ORGAN_PEG)))
		src.fracture()
	if(!(status & ORGAN_BROKEN))
		perma_injury = 0

	update_germs()
	return

//Updating germ levels. Handles organ germ levels and necrosis.
/*
The INFECTION_LEVEL values defined in setup.dm control the time it takes to reach the different
infection levels. Since infection growth is exponential, you can adjust the time it takes to get
from one germ_level to another using the rough formula:

desired_germ_level = initial_germ_level*e^(desired_time_in_seconds/1000)

So if I wanted it to take an average of 15 minutes to get from level one (100) to level two
I would set INFECTION_LEVEL_TWO to 100*e^(15*60/1000) = 245. Note that this is the average time,
the actual time is dependent on RNG.

INFECTION_LEVEL_ONE		below this germ level nothing happens, and the infection doesn't grow
INFECTION_LEVEL_TWO		above this germ level the infection will start to spread to internal and adjacent organs
INFECTION_LEVEL_THREE	above this germ level the player will take additional toxin damage per second, and will die in minutes without
						antitox. also, above this germ level you will need to overdose on spaceacillin to reduce the germ_level.

Note that amputating the affected organ does in fact remove the infection from the player's body.
*/
/datum/organ/external/proc/update_germs()
	if(status & (ORGAN_ROBOT|ORGAN_PEG|ORGAN_DESTROYED)) //how does robot limb have da germs?
		germ_level = 0
		return

	if(owner.bodytemperature >= 170)	//cryo stops germs from moving and doing their bad stuffs
		//** Syncing germ levels with external wounds
		handle_germ_sync()

		//** Handle antibiotics and curing infections
		handle_antibiotics()

		//** Handle the effects of infections
		handle_germ_effects()

/datum/organ/external/proc/handle_germ_sync()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")
	for(var/datum/wound/W in wounds)
		//Open wounds can become infected
		if (owner.germ_level > W.germ_level && W.infection_check())
			W.germ_level++

	if (antibiotics < 5)
		for(var/datum/wound/W in wounds)
			//Infected wounds raise the organ's germ level
			if (W.germ_level > germ_level)
				germ_level++
				break	//limit increase to a maximum of one per second

/datum/organ/external/proc/handle_germ_effects()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (germ_level > 0 && germ_level < INFECTION_LEVEL_ONE && prob(60))	//this could be an else clause, but it looks cleaner this way
		germ_level--	//since germ_level increases at a rate of 1 per second with dirty wounds, prob(60) should give us about 5 minutes before level one.

	if(germ_level >= INFECTION_LEVEL_ONE)
		//having an infection raises your body temperature
		var/fever_temperature = (owner.species.heat_level_1 - owner.species.body_temperature - 5)* min(germ_level/INFECTION_LEVEL_TWO, 1) + owner.species.body_temperature
		//need to make sure we raise temperature fast enough to get around environmental cooling preventing us from reaching fever_temperature
		owner.bodytemperature += between(0, (fever_temperature - T20C)/BODYTEMP_COLD_DIVISOR + 1, fever_temperature - owner.bodytemperature)

		if(prob(round(germ_level/10)))
			if (antibiotics < 5)
				germ_level++

			if (prob(10))	//adjust this to tweak how fast people take toxin damage from infections
				owner.adjustToxLoss(1)

	if(germ_level >= INFECTION_LEVEL_TWO && antibiotics < 5)
		//spread the infection to internal organs
		var/datum/organ/internal/target_organ = null	//make internal organs become infected one at a time instead of all at once
		for (var/datum/organ/internal/I in internal_organs)
			if (I.germ_level > 0 && I.germ_level < min(germ_level, INFECTION_LEVEL_TWO))	//once the organ reaches whatever we can give it, or level two, switch to a different one
				if (!target_organ || I.germ_level > target_organ.germ_level)	//choose the organ with the highest germ_level
					target_organ = I

		if (!target_organ)
			//figure out which organs we can spread germs to and pick one at random
			var/list/candidate_organs = list()
			for (var/datum/organ/internal/I in internal_organs)
				if (I.germ_level < germ_level)
					candidate_organs += I
			if (candidate_organs.len)
				target_organ = pick(candidate_organs)

		if (target_organ)
			target_organ.germ_level++

		//spread the infection to child and parent organs
		if (children)
			for (var/datum/organ/external/child in children)
				if (child.germ_level < germ_level && !(child.status & ORGAN_ROBOT))
					if (child.germ_level < INFECTION_LEVEL_ONE*2 || prob(30))
						child.germ_level++

		if (parent)
			if (parent.germ_level < germ_level && !(parent.status & ORGAN_ROBOT))
				if (parent.germ_level < INFECTION_LEVEL_ONE*2 || prob(30))
					parent.germ_level++

	if(germ_level >= INFECTION_LEVEL_THREE && antibiotics < 30)	//overdosing is necessary to stop severe infections
		if (!(status & ORGAN_DEAD))
			status |= ORGAN_DEAD
			owner << "<span class='notice'>You can't feel your [display_name] anymore...</span>"
			owner.update_body(1)

		germ_level++
		owner.adjustToxLoss(1)

//Updating wounds. Handles wound natural healing, internal bleedings and infections
/datum/organ/external/proc/update_wounds()

	if((status & (ORGAN_ROBOT|ORGAN_PEG))) //Robotic limbs don't heal or get worse.
		return

	for(var/datum/wound/W in wounds)
		// wounds can disappear after 10 minutes at the earliest
		if(W.damage <= 0 && W.created + 10 * 10 * 60 <= world.time)
			wounds -= W
			continue
			// let the GC handle the deletion of the wound

		// Internal wounds get worse over time. Low temperatures (cryo) stop them.
		if(W.internal && !W.is_treated() && owner.bodytemperature >= 170)
			if(!owner.reagents.has_reagent("bicaridine"))	//bicard stops internal wounds from growing bigger with time, and also stop bleeding
				W.open_wound(0.1 * wound_update_accuracy)
				owner.vessel.remove_reagent("blood",0.05 * W.damage * wound_update_accuracy)
			if(!owner.reagents.has_reagent("inaprovaline")) //This little copypaste will allow inaprovaline to work too, giving it a much needed buff to help medical.
				W.open_wound(0.1 * wound_update_accuracy)
				owner.vessel.remove_reagent("blood",0.05 * W.damage * wound_update_accuracy)

			owner.vessel.remove_reagent("blood",0.02 * W.damage * wound_update_accuracy)//Bicaridine slows Internal Bleeding
			if(prob(1 * wound_update_accuracy))
				owner.custom_pain("You feel a stabbing pain in your [display_name]!",1)

			//overdose of bicaridine begins healing IB
			if(owner.reagents.get_reagent_amount("bicaridine") >= 30)
				W.damage = max(0, W.damage - 0.2)

		// slow healing
		var/heal_amt = 0

		if (W.damage < 15) //this thing's edges are not in day's travel of each other, what healing?
			heal_amt += 0.2

		if(W.is_treated() && W.damage < 50) //whoa, not even magical band aid can hold it together
			heal_amt += 0.3

		//we only update wounds once in [wound_update_accuracy] ticks so have to emulate realtime
		heal_amt = heal_amt * wound_update_accuracy
		//configurable regen speed woo, no-regen hardcore or instaheal hugbox, choose your destiny
		heal_amt = heal_amt * config.organ_regeneration_multiplier
		// amount of healing is spread over all the wounds
		heal_amt = heal_amt / (wounds.len + 1)
		// making it look prettier on scanners
		heal_amt = round(heal_amt,0.1)
		W.heal_damage(heal_amt)

		// Salving also helps against infection
		if(W.germ_level > 0 && W.salved && prob(2))
			W.germ_level = 0
			W.disinfected = 1

	// sync the organ's damage with its wounds
	src.update_damages()
	if (update_icon())
		owner.UpdateDamageIcon(1)

//Updates brute_damn and burn_damn from wound damages. Updates BLEEDING status.
/datum/organ/external/proc/update_damages()
	number_wounds = 0
	brute_dam = 0
	burn_dam = 0
	status &= ~ORGAN_BLEEDING
	var/clamped = 0
	for(var/datum/wound/W in wounds)
		if(W.damage_type == CUT || W.damage_type == BRUISE)
			brute_dam += W.damage
		else if(W.damage_type == BURN)
			burn_dam += W.damage

		if(!(status & (ORGAN_ROBOT|ORGAN_PEG)) && W.bleeding())
			W.bleed_timer--
			status |= ORGAN_BLEEDING

		clamped |= W.clamped

		number_wounds += W.amount

	if (open && !clamped && !(status & (ORGAN_ROBOT|ORGAN_PEG)))	//things tend to bleed if they are CUT OPEN
		status |= ORGAN_BLEEDING


// new damage icon system
// adjusted to set damage_state to brute/burn code only (without r_name0 as before)
/datum/organ/external/proc/update_icon()
	var/n_is = damage_state_text()
	if (n_is != damage_state)
		damage_state = n_is
		owner.update_body(1)
		return 1
	return 0

// new damage icon system
// returns just the brute/burn damage code
/datum/organ/external/proc/damage_state_text()
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

/****************************************************
			   DISMEMBERMENT
****************************************************/

//Recursive setting of all child organs to amputated
/datum/organ/external/proc/setAmputatedTree()
	for(var/datum/organ/external/O in children)
		O.amputated=amputated
		O.setAmputatedTree()

//Handles dismemberment
/datum/organ/external/proc/droplimb(var/override = 0,var/no_explode = 0, var/spawn_limb=1)
	if(destspawn) return
	if(override)
		status |= ORGAN_DESTROYED
	if(status & ORGAN_DESTROYED)
		if(body_part == UPPER_TORSO)
			return

		src.status &= ~ORGAN_BROKEN
		src.status &= ~ORGAN_BLEEDING
		src.status &= ~ORGAN_SPLINTED
		src.status &= ~ORGAN_DEAD
		for(var/implant in implants)
			del(implant)

		// If any organs are attached to this, destroy them
		for(var/datum/organ/external/O in children)
			O.droplimb(1)

		var/obj/organ	//Dropped limb object
		switch(body_part)
			if(LOWER_TORSO)
				owner << "\red You are now sterile."
			if(HEAD)
				if(owner.species.flags & IS_SYNTHETIC)
					organ= new /obj/item/weapon/organ/head/posi(owner.loc, owner)
				else
					organ= new /obj/item/weapon/organ/head(owner.loc, owner)
				owner.u_equip(owner.glasses)
				owner.u_equip(owner.head)
				owner.u_equip(owner.l_ear)
				owner.u_equip(owner.r_ear)
				owner.u_equip(owner.wear_mask)
			if(ARM_RIGHT)
				if(spawn_limb)
					if(status & ORGAN_ROBOT)
						organ = new /obj/item/robot_parts/r_arm(owner.loc)
					else
						organ= new /obj/item/weapon/organ/r_arm(owner.loc, owner)
			if(ARM_LEFT)
				if(spawn_limb)
					if(status & ORGAN_ROBOT)
						organ= new /obj/item/robot_parts/l_arm(owner.loc)
					else
						organ= new /obj/item/weapon/organ/l_arm(owner.loc, owner)
			if(LEG_RIGHT)
				if(spawn_limb)
					if(status & ORGAN_ROBOT)
						organ = new /obj/item/robot_parts/r_leg(owner.loc)
					else
						organ= new /obj/item/weapon/organ/r_leg(owner.loc, owner)
			if(LEG_LEFT)
				if(spawn_limb)
					if(status & ORGAN_ROBOT)
						organ = new /obj/item/robot_parts/l_leg(owner.loc)
					else
						organ= new /obj/item/weapon/organ/l_leg(owner.loc, owner)
			if(HAND_RIGHT)
				if(spawn_limb)
					if(!(status & (ORGAN_ROBOT)))
						organ= new /obj/item/weapon/organ/r_hand(owner.loc, owner)
				owner.u_equip(owner.gloves)
			if(HAND_LEFT)
				if(spawn_limb)
					if(!(status & (ORGAN_ROBOT)))
						organ= new /obj/item/weapon/organ/l_hand(owner.loc, owner)
				owner.u_equip(owner.gloves)
			if(FOOT_RIGHT)
				if(spawn_limb)
					if(!(status & ORGAN_ROBOT))
						organ= new /obj/item/weapon/organ/r_foot/(owner.loc, owner)
				owner.u_equip(owner.shoes)
			if(FOOT_LEFT)
				if(spawn_limb)
					if(!(status & ORGAN_ROBOT))
						organ = new /obj/item/weapon/organ/l_foot(owner.loc, owner)
				owner.u_equip(owner.shoes)

		destspawn = 1
		//Robotic limbs explode if sabotaged.
		if(status & ORGAN_ROBOT && !no_explode && sabotaged)
			owner.visible_message("\red \The [owner]'s [display_name] explodes violently!",\
			"\red <b>Your [display_name] explodes!</b>",\
			"You hear an explosion followed by a scream!")
			explosion(get_turf(owner),-1,-1,2,3)
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, owner)
			spark_system.attach(owner)
			spark_system.start()
			spawn(10)
				del(spark_system)

		if(organ)
			owner.visible_message("\red [owner.name]'s [display_name] flies off in an arc.",\
			"<span class='moderate'><b>Your [display_name] goes flying off!</b></span>",\
			"You hear a terrible sound of ripping tendons and flesh.")

			//Throw organs around
			var/lol = pick(cardinal)
			step(organ,lol)
		owner.update_body(1)

		// OK so maybe your limb just flew off, but if it was attached to a pair of cuffs then hooray! Freedom!
		release_restraints()

		if(vital)
			owner.death()

/****************************************************
			   HELPERS
****************************************************/

/datum/organ/external/proc/release_restraints()
	if (owner.handcuffed && body_part in list(ARM_LEFT, ARM_RIGHT, HAND_LEFT, HAND_RIGHT))
		owner.visible_message(\
			"\The [owner.handcuffed.name] falls off of [owner.name].",\
			"\The [owner.handcuffed.name] falls off you.")

		owner.drop_from_inventory(owner.handcuffed)

	if (owner.legcuffed && body_part in list(FOOT_LEFT, FOOT_RIGHT, LEG_LEFT, LEG_RIGHT))
		owner.visible_message(\
			"\The [owner.legcuffed.name] falls off of [owner.name].",\
			"\The [owner.legcuffed.name] falls off you.")

		owner.drop_from_inventory(owner.legcuffed)

/datum/organ/external/proc/bandage()
	var/rval = 0
	src.status &= ~ORGAN_BLEEDING
	for(var/datum/wound/W in wounds)
		if(W.internal) continue
		rval |= !W.bandaged
		W.bandaged = 1
	return rval

/datum/organ/external/proc/disinfect()
	var/rval = 0
	for(var/datum/wound/W in wounds)
		if(W.internal) continue
		rval |= !W.disinfected
		W.disinfected = 1
		W.germ_level = 0
	return rval

/datum/organ/external/proc/clamp()
	var/rval = 0
	src.status &= ~ORGAN_BLEEDING
	for(var/datum/wound/W in wounds)
		if(W.internal) continue
		rval |= !W.clamped
		W.clamped = 1
	return rval

/datum/organ/external/proc/salve()
	var/rval = 0
	for(var/datum/wound/W in wounds)
		rval |= !W.salved
		W.salved = 1
	return rval

/datum/organ/external/proc/fracture()
	if(status & ORGAN_BROKEN)
		return
	owner.visible_message("\red You hear a loud cracking sound coming from \the [owner].","\red <b>Something feels like it shattered in your [display_name]!</b>","You hear a sickening crack.")

	if(owner.species && !(owner.species.flags & NO_PAIN))
		owner.agony = 1
		owner.emote("scream")
		owner.agony = 0

	status |= ORGAN_BROKEN
	broken_description = pick("broken","fracture","hairline fracture")
	perma_injury = brute_dam

	// Fractures have a chance of getting you out of restraints
	if (prob(25))
		release_restraints()

	// This is mostly for the ninja suit to stop ninja being so crippled by breaks.
	// TODO: consider moving this to a suit proc or process() or something during
	// hardsuit rewrite.
	/*
	if(!(status & ORGAN_SPLINTED) && istype(owner,/mob/living/carbon/human))

		var/mob/living/carbon/human/H = owner

		if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space))
			return

			//var/obj/item/clothing/suit/space/suit = H.wear_suit

			if(!suit.supporting_limbs)
				return

			owner << "You feel \the [suit] constrict about your [display_name], supporting it."
			status |= ORGAN_SPLINTED
			suit.supporting_limbs |= src
	remove ninja code */
	return

/datum/organ/external/proc/robotize()
	src.status &= ~ORGAN_BROKEN
	src.status &= ~ORGAN_BLEEDING
	src.status &= ~ORGAN_SPLINTED
	src.status &= ~ORGAN_CUT_AWAY
	src.status &= ~ORGAN_ATTACHABLE
	src.status &= ~ORGAN_DESTROYED
	src.status &= ~ORGAN_PEG
	src.status |= ORGAN_ROBOT
	src.destspawn = 0
	for (var/datum/organ/external/T in children)
		if(T)
			T.robotize()

/datum/organ/external/proc/peggify()
	src.status &= ~ORGAN_BROKEN
	src.status &= ~ORGAN_BLEEDING
	src.status &= ~ORGAN_SPLINTED
	src.status &= ~ORGAN_ATTACHABLE
	src.status &= ~ORGAN_DESTROYED
	src.status &= ~ORGAN_ROBOT
	src.status |= ORGAN_PEG
	for (var/datum/organ/external/T in children)
		if(T)
			if(body_part == ARM_LEFT || body_part == ARM_RIGHT)
				T.peggify()
			else
				T.droplimb(1,1)

/datum/organ/external/proc/mutate()
	src.status |= ORGAN_MUTATED
	owner.update_body()

/datum/organ/external/proc/unmutate()
	src.status &= ~ORGAN_MUTATED
	owner.update_body()

/datum/organ/external/proc/get_damage()	//returns total damage
	return max(brute_dam + burn_dam - perma_injury, perma_injury)	//could use health?

/datum/organ/external/proc/has_infected_wound()
	for(var/datum/wound/W in wounds)
		if(W.germ_level > INFECTION_LEVEL_ONE)
			return 1
	return 0

/datum/organ/external/get_icon(gender="",isFat=0)
	//stand_icon = new /icon(icobase, "torso_[g][fat?"_fat":""]")
	if(gender)
		gender="_[gender]"
	var/fat=""
	if(isFat && has_fat)
		fat="_fat"
	var/icon_state="[icon_name][gender][fat]"
	var/baseicon=owner.race_icon
	if (status & ORGAN_MUTATED)
		baseicon=owner.deform_icon
	else if (status & ORGAN_PEG)
		baseicon='icons/mob/human_races/o_peg.dmi'
	else if (status & ORGAN_ROBOT)
		baseicon='icons/mob/human_races/o_robot.dmi'
	return new /icon(baseicon, icon_state)


/datum/organ/external/proc/is_usable()
	return !(status & (ORGAN_DESTROYED|ORGAN_MUTATED|ORGAN_DEAD))

/datum/organ/external/proc/is_broken()
	return ((status & ORGAN_BROKEN) && !(status & ORGAN_SPLINTED))

/datum/organ/external/proc/is_malfunctioning()
	return ((status & ORGAN_ROBOT) && prob(brute_dam + burn_dam))

/datum/organ/external/proc/can_use_advanced_tools() // Hook-hands can't pull triggers.
	return !(status & (ORGAN_DESTROYED|ORGAN_MUTATED|ORGAN_DEAD|ORGAN_PEG))

/datum/organ/external/proc/process_grasp(var/obj/item/c_hand, var/hand_name)
	if (!c_hand)
		return

	if(is_broken())
		owner.u_equip(c_hand)
		var/emote_scream = pick("screams in pain and", "lets out a sharp cry and", "cries out and")
		owner.emote("me", 1, "[(owner.species && owner.species.flags & NO_PAIN) ? "" : emote_scream ] drops what they were holding in their [hand_name]!")
	if(is_malfunctioning())
		owner.u_equip(c_hand)
		owner.emote("me", 1, "drops what they were holding, their [hand_name] malfunctioning!")
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, owner)
		spark_system.attach(owner)
		spark_system.start()
		spawn(10)
			del(spark_system)

/datum/organ/external/proc/embed(var/obj/item/weapon/W, var/silent = 0)
	if(!silent)
		owner.visible_message("<span class='danger'>\The [W] sticks in the wound!</span>")
	implants += W
	owner.embedded_flag = 1
	owner.verbs += /mob/proc/yank_out_object
	W.add_blood(owner)
	if(ismob(W.loc))
		var/mob/living/H = W.loc
		H.drop_item()
	W.loc = owner

/****************************************************
			   ORGAN DEFINES
****************************************************/

/datum/organ/external/chest
	name = "chest"
	icon_name = "torso"
	display_name = "chest"
	max_damage = 150
	min_broken_damage = 75
	body_part = UPPER_TORSO
	has_fat = 1
	vital = 1
	encased = "ribcage"

/datum/organ/external/groin
	name = "groin"
	icon_name = "groin"
	display_name = "groin"
	max_damage = 115
	min_broken_damage = 70
	body_part = LOWER_TORSO
	vital = 1

/datum/organ/external/l_arm
	name = "l_arm"
	display_name = "left arm"
	icon_name = "l_arm"
	max_damage = 75
	min_broken_damage = 30
	body_part = ARM_LEFT

	process()
		..()
		process_grasp(owner.l_hand, "left hand")

/datum/organ/external/l_leg
	name = "l_leg"
	display_name = "left leg"
	icon_name = "l_leg"
	max_damage = 75
	min_broken_damage = 30
	body_part = LEG_LEFT
	icon_position = LEFT

/datum/organ/external/r_arm
	name = "r_arm"
	display_name = "right arm"
	icon_name = "r_arm"
	max_damage = 75
	min_broken_damage = 30
	body_part = ARM_RIGHT

	process()
		..()
		process_grasp(owner.r_hand, "right hand")

/datum/organ/external/r_leg
	name = "r_leg"
	display_name = "right leg"
	icon_name = "r_leg"
	max_damage = 75
	min_broken_damage = 30
	body_part = LEG_RIGHT
	icon_position = RIGHT

/datum/organ/external/l_foot
	name = "l_foot"
	display_name = "left foot"
	icon_name = "l_foot"
	max_damage = 40
	min_broken_damage = 15
	body_part = FOOT_LEFT
	icon_position = LEFT

/datum/organ/external/r_foot
	name = "r_foot"
	display_name = "right foot"
	icon_name = "r_foot"
	max_damage = 40
	min_broken_damage = 15
	body_part = FOOT_RIGHT
	icon_position = RIGHT

/datum/organ/external/r_hand
	name = "r_hand"
	display_name = "right hand"
	icon_name = "r_hand"
	max_damage = 40
	min_broken_damage = 15
	body_part = HAND_RIGHT

	process()
		..()
		process_grasp(owner.r_hand, "right hand")

/datum/organ/external/l_hand
	name = "l_hand"
	display_name = "left hand"
	icon_name = "l_hand"
	max_damage = 40
	min_broken_damage = 15
	body_part = HAND_LEFT

	process()
		..()
		process_grasp(owner.l_hand, "left hand")

/datum/organ/external/head
	name = "head"
	icon_name = "head"
	display_name = "head"
	max_damage = 130
	min_broken_damage = 40
	body_part = HEAD
	var/disfigured = 0
	vital = 1
	encased = "skull"

/datum/organ/external/head/get_icon()
	if (!owner)
		return ..()
	var/g = "m"
	if(owner.gender == FEMALE)	g = "f"
	var/baseicon=owner.race_icon
	if (status & ORGAN_MUTATED)
		baseicon=owner.deform_icon
	if (status & ORGAN_PEG)
		baseicon='icons/mob/human_races/o_peg.dmi'
	if (status & ORGAN_ROBOT)
		baseicon='icons/mob/human_races/o_robot.dmi'
	return new /icon(baseicon, "[icon_name]_[g]")

/datum/organ/external/head/take_damage(brute, burn, sharp, edge, used_weapon = null, list/forbidden_limbs = list())
	..(brute, burn, sharp, edge, used_weapon, forbidden_limbs)
	if (!disfigured)
		if (brute_dam > 40)
			if (prob(50))
				disfigure("brute")
		if (burn_dam > 40)
			disfigure("burn")

/datum/organ/external/head/proc/disfigure(var/type = "brute")
	if (disfigured)
		return
	if(type == "brute")
		owner.visible_message("\red You hear a sickening cracking sound coming from \the [owner]'s face.",	\
		"\red <b>Your face becomes unrecognizible mangled mess!</b>",	\
		"\red You hear a sickening crack.")
	else
		owner.visible_message("\red [owner]'s face melts away, turning into mangled mess!",	\
		"\red <b>Your face melts off!</b>",	\
		"\red You hear a sickening sizzle.")
	disfigured = 1

/****************************************************
			   EXTERNAL ORGAN ITEMS
****************************************************/

obj/item/weapon/organ
	icon = 'icons/mob/human_races/r_human.dmi'

obj/item/weapon/organ/New(loc, mob/living/carbon/human/H)
	..(loc)
	if(!istype(H))
		return
	if(H.dna)
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA[H.dna.unique_enzymes] = H.dna.b_type

	//Forming icon for the limb

	//Setting base icon for this mob's race
	var/icon/base
	if(H.species && H.species.icobase)
		base = icon(H.species.icobase)
	else
		base = icon('icons/mob/human_races/r_human.dmi')

	if(base)
		//Changing limb's skin tone to match owner
		if(!H.species || H.species.flags & HAS_SKIN_TONE)
			if (H.s_tone >= 0)
				base.Blend(rgb(H.s_tone, H.s_tone, H.s_tone), ICON_ADD)
			else
				base.Blend(rgb(-H.s_tone,  -H.s_tone,  -H.s_tone), ICON_SUBTRACT)

/*	if(base)
		//Changing limb's skin color to match owner
		if(!H.species || H.species.flags & HAS_SKIN_COLOR)
			base.Blend(rgb(H.r_skin, H.g_skin, H.b_skin), ICON_ADD)*/

	icon = base
	dir = SOUTH
	src.transform = turn(src.transform, rand(70,130))


/****************************************************
			   EXTERNAL ORGAN ITEMS DEFINES
****************************************************/

obj/item/weapon/organ/l_arm
	name = "left arm"
	icon_state = "l_arm"
obj/item/weapon/organ/l_foot
	name = "left foot"
	icon_state = "l_foot"
obj/item/weapon/organ/l_hand
	name = "left hand"
	icon_state = "l_hand"
obj/item/weapon/organ/l_leg
	name = "left leg"
	icon_state = "l_leg"
obj/item/weapon/organ/r_arm
	name = "right arm"
	icon_state = "r_arm"
obj/item/weapon/organ/r_foot
	name = "right foot"
	icon_state = "r_foot"
obj/item/weapon/organ/r_hand
	name = "right hand"
	icon_state = "r_hand"
obj/item/weapon/organ/r_leg
	name = "right leg"
	icon_state = "r_leg"

obj/item/weapon/organ/head
	name = "head"
	icon_state = "head_m"
	var/mob/living/carbon/brain/brainmob
	var/brain_op_stage = 0

/obj/item/weapon/organ/head/posi
	name = "robotic head"

obj/item/weapon/organ/head/New(loc, mob/living/carbon/human/H)
	if(istype(H))
		src.icon_state = H.gender == MALE? "head_m" : "head_f"
	..()
	//Add (facial) hair.
	if(H.f_style)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[H.f_style]
		if(facial_hair_style)
			var/icon/facial = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				facial.Blend(rgb(H.r_facial, H.g_facial, H.b_facial), ICON_ADD)

			overlays.Add(facial) // icon.Blend(facial, ICON_OVERLAY)

	if(H.h_style && !(H.head && (H.head.flags & BLOCKHEADHAIR)))
		var/datum/sprite_accessory/hair_style = hair_styles_list[H.h_style]
		if(hair_style)
			var/icon/hair = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration)
				hair.Blend(rgb(H.r_hair, H.g_hair, H.b_hair), ICON_ADD)

			overlays.Add(hair) //icon.Blend(hair, ICON_OVERLAY)
	spawn(5)
	if(brainmob && brainmob.client)
		brainmob.client.screen.len = null //clear the hud

	//if(ishuman(H))
	//	if(H.gender == FEMALE)
	//		H.icon_state = "head_f"
	//	H.overlays += H.generate_head_icon()
	transfer_identity(H)

	name = "[H.real_name]'s head"

	H.regenerate_icons()

	brainmob.stat = 2
	brainmob.death()

obj/item/weapon/organ/head/proc/transfer_identity(var/mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->head
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna.Clone()
	if(H.mind)
		H.mind.transfer_to(brainmob)
	brainmob.container = src

obj/item/weapon/organ/head/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/scalpel))
		switch(brain_op_stage)
			if(0)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] is beginning to have \his head cut open with [W] by [user].", 1)
				brainmob << "\red [user] begins to cut open your head with [W]!"
				user << "\red You cut [brainmob]'s head open with [W]!"

				brain_op_stage = 1

			if(2)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] is having \his connections to the brain delicately severed with [W] by [user].", 1)
				brainmob << "\red [user] begins to cut open your head with [W]!"
				user << "\red You cut [brainmob]'s head open with [W]!"

				brain_op_stage = 3.0
			else
				..()
	else if(istype(W,/obj/item/weapon/circular_saw))
		switch(brain_op_stage)
			if(1)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] has \his head sawed open with [W] by [user].", 1)
				brainmob << "\red [user] begins to saw open your head with [W]!"
				user << "\red You saw [brainmob]'s head open with [W]!"

				brain_op_stage = 2
			if(3)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] has \his spine's connection to the brain severed with [W] by [user].", 1)
				brainmob << "\red [user] severs your brain's connection to the spine with [W]!"
				user << "\red You sever [brainmob]'s brain's connection to the spine with [W]!"

				user.attack_log += "\[[time_stamp()]\]<font color='red'> Debrained [brainmob.name] ([brainmob.ckey]) with [W.name] (INTENT: [uppertext(user.a_intent)])</font>"
				brainmob.attack_log += "\[[time_stamp()]\]<font color='orange'> Debrained by [user.name] ([user.ckey]) with [W.name] (INTENT: [uppertext(user.a_intent)])</font>"
				msg_admin_attack("[user] ([user.ckey]) debrained [brainmob] ([brainmob.ckey]) (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

				//TODO: ORGAN REMOVAL UPDATE.
				if(istype(src,/obj/item/weapon/organ/head/posi))
					var/obj/item/device/mmi/posibrain/B = new(loc)
					B.transfer_identity(brainmob)
				else
					var/obj/item/organ/brain/B = new(loc)
					B.transfer_identity(brainmob)

				brain_op_stage = 4.0
			else
				..()
	else
		..()

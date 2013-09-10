
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
	// ticks of bleeding left.
	var/bleed_timer = 0
	// amount of damage the current wound type requires(less means we need to apply the next healing stage)
	var/min_damage = 0

	// one of CUT, BRUISE, BURN
	var/damage_type = CUT

	// whether this wound needs a bandage/salve to heal at all
	var/needs_treatment = 0

	// is the wound bandaged?
	var/tmp/bandaged = 0
	// Similar to bandaged, but works differently
	var/tmp/clamped = 0
	// is the wound salved?
	var/tmp/salved = 0
	// is the wound disinfected?
	var/tmp/disinfected = 0
	var/tmp/created = 0

	// number of wounds of this type
	var/tmp/amount = 1

	// maximum stage at which bleeding should still happen, counted from the right rather than the left of the list
	// 1 means all stages except the last should bleed
	var/max_bleeding_stage = 1

	// internal wounds can only be fixed through surgery
	var/internal = 0

	// amount of germs in the wound
	var/germ_level = 0

	// helper lists
	var/tmp/list/desc_list = list()
	var/tmp/list/damage_list = list()
	New(var/damage)

		created = world.time

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

		// make the max_bleeding_stage count from the end of the list rather than the start
		// this is more robust to changes to the list
		max_bleeding_stage = src.desc_list.len - max_bleeding_stage

		bleed_timer += damage

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

	// checks if wound is considered open for external infections
	// untreated cuts (and bleeding bruises) and burns are possibly infectable, chance higher if wound is bigger
	proc/can_infect()
		if (is_treated() && damage < 10)
			return 0
		if (disinfected)
			return 0
		var/dam_coef = round(damage/10)
		switch (damage_type)
			if (BRUISE)
				return prob(dam_coef*5) && bleeding() //bruises only infectable if bleeding
			if (BURN)
				return prob(dam_coef*10)
			if (CUT)
				return prob(dam_coef*20)

		return 0
	// heal the given amount of damage, and if the given amount of damage was more
	// than what needed to be healed, return how much heal was left
	// set @heals_internal to also heal internal organ damage
	proc/heal_damage(amount, heals_internal = 0)
		if(src.internal && !heals_internal)
			// heal nothing
			return amount

		var/healed_damage = min(src.damage, amount)
		amount -= healed_damage
		src.damage -= healed_damage

		while(src.damage / src.amount < damage_list[current_stage] && current_stage < src.desc_list.len)
			current_stage++
		desc = desc_list[current_stage]
		src.min_damage = damage_list[current_stage]

		// return amount of healing still leftover, can be used for other wounds
		return amount

	// opens the wound again
	proc/open_wound(damage)
		src.damage += damage
		bleed_timer += damage

		while(src.current_stage > 1 && src.damage_list[current_stage-1] <= src.damage)
			src.current_stage--

		src.desc = desc_list[current_stage]
		src.min_damage = damage_list[current_stage]

	proc/bleeding()
		// internal wounds don't bleed in the sense of this function
		return ((damage > 30 || bleed_timer > 0) && !(bandaged||clamped) && (damage_type == BRUISE && damage >= 20 || damage_type == CUT && damage >= 5) && current_stage <= max_bleeding_stage && !src.internal)

/** CUTS **/
/datum/wound/cut/small
	// link wound descriptions to amounts of damage
	max_bleeding_stage = 2
	stages = list("ugly ripped cut" = 20, "ripped cut" = 10, "cut" = 5, "healing cut" = 2, "small scab" = 0)

/datum/wound/cut/deep
	max_bleeding_stage = 3
	stages = list("ugly deep ripped cut" = 25, "deep ripped cut" = 20, "deep cut" = 15, "clotted cut" = 8, "scab" = 2, "fresh skin" = 0)

/datum/wound/cut/flesh
	max_bleeding_stage = 3
	stages = list("ugly ripped flesh wound" = 35, "ugly flesh wound" = 30, "flesh wound" = 25, "blood soaked clot" = 15, "large scab" = 5, "fresh skin" = 0)

/datum/wound/cut/gaping
	max_bleeding_stage = 2
	stages = list("gaping wound" = 50, "large blood soaked clot" = 25, "large clot" = 15, "small angry scar" = 5, \
				   "small straight scar" = 0)

/datum/wound/cut/gaping_big
	max_bleeding_stage = 2
	stages = list("big gaping wound" = 60, "healing gaping wound" = 40, "large angry scar" = 10, "large straight scar" = 0)

	needs_treatment = 1 // this only heals when bandaged

datum/wound/cut/massive
	max_bleeding_stage = 2
	stages = list("massive wound" = 70, "massive healing wound" = 50, "massive angry scar" = 10,  "massive jagged scar" = 0)

	needs_treatment = 1 // this only heals when bandaged

/** BRUISES **/
/datum/wound/bruise
	stages = list("monumental bruise" = 80, "huge bruise" = 50, "large bruise" = 30,\
				  "moderate bruise" = 20, "small bruise" = 10, "tiny bruise" = 5)

	needs_treatment = 1 // this only heals when bandaged
	damage_type = BRUISE

/datum/wound/bruise/monumental

// implement sub-paths by starting at a later stage

/datum/wound/bruise/tiny
	current_stage = 5
	needs_treatment = 0

/datum/wound/bruise/small
	current_stage = 4
	needs_treatment = 0

/datum/wound/bruise/moderate
	current_stage = 3
	needs_treatment = 0

/datum/wound/bruise/large
	current_stage = 2

/datum/wound/bruise/huge
	current_stage = 1

/** BURNS **/
/datum/wound/burn/moderate
	stages = list("ripped burn" = 10, "moderate burn" = 5, "moderate salved burn" = 2, "fresh skin" = 0)

	needs_treatment = 1 // this only heals when bandaged

	damage_type = BURN

/datum/wound/burn/large
	stages = list("ripped large burn" = 20, "large burn" = 15, "large salved burn" = 5, "fresh skin" = 0)

	needs_treatment = 1 // this only heals when bandaged

	damage_type = BURN

/datum/wound/burn/severe
	stages = list("ripped severe burn" = 35, "severe burn" = 30, "severe salved burn" = 10, "burn scar" = 0)

	needs_treatment = 1 // this only heals when bandaged

	damage_type = BURN

/datum/wound/burn/deep
	stages = list("ripped deep burn" = 45, "deep burn" = 40, "deep salved burn" = 15,  "large burn scar" = 0)

	needs_treatment = 1 // this only heals when bandaged

	damage_type = BURN


/datum/wound/burn/carbonised
	stages = list("carbonised area" = 50, "treated carbonised area" = 20, "massive burn scar" = 0)

	needs_treatment = 1 // this only heals when bandaged

	damage_type = BURN

/datum/wound/internal_bleeding
	internal = 1

	stages = list("severed vein" = 30, "cut vein" = 20, "damaged vein" = 10, "bruised vein" = 5)
	max_bleeding_stage = 0

	needs_treatment = 1

/datum/disease
	//Flags
	var/visibility_flags = NONE
	var/disease_flags = CURABLE|CAN_CARRY|CAN_RESIST
	var/spread_flags = DISEASE_SPREAD_AIRBORNE | DISEASE_SPREAD_CONTACT_FLUIDS | DISEASE_SPREAD_CONTACT_SKIN

	//Fluff
	var/form = "Virus"
	var/name = "No disease"
	var/desc = ""
	var/agent = "some microbes"
	var/spread_text = ""
	var/cure_text = ""

	//Stages
	var/stage = 1
	var/max_stages = 0
	/// The probability of this infection advancing a stage every second the cure is not present.
	var/stage_prob = 2
	/// How long this infection incubates (non-visible) before revealing itself
	var/incubation_time
	/// Has the virus hit its limit?
	var/stage_peaked = FALSE
	/// How many cycles has the virus been at its peak?
	var/peaked_cycles = 0
	/// How many cycles do we need to have been active after hitting our max stage to start rolling back?
	var/cycles_to_beat = 0
	/// Number of cycles we've prevented symptoms from appearing
	var/symptom_offsets = 0
	/// Number of cycles we've benefited from chemical or other non-resting symptom protection
	var/chemical_offsets = 0

	//Other
	var/list/viable_mobtypes = list() //typepaths of viable mobs
	var/mob/living/carbon/affected_mob = null
	var/list/cures = list() //list of cures if the disease has the CURABLE flag, these are reagent ids
	/// The probability of spreading through the air every second
	var/infectivity = 41
	/// The probability of this infection being cured every second the cure is present
	var/cure_chance = 4
	var/carrier = FALSE //If our host is only a carrier
	var/bypasses_immunity = FALSE //Does it skip species virus immunity check? Some things may diseases and not viruses
	var/spreading_modifier = 1
	var/severity = DISEASE_SEVERITY_NONTHREAT
	/// If the disease requires an organ for the effects to function, robotic organs are immune to disease unless inorganic biology symptom is present
	var/required_organ
	var/needs_all_cures = TRUE
	var/list/strain_data = list() //dna_spread special bullshit
	var/infectable_biotypes = MOB_ORGANIC //if the disease can spread on organics, synthetics, or undead
	var/process_dead = FALSE //if this ticks while the host is dead
	var/copy_type = null //if this is null, copies will use the type of the instance being copied

/datum/disease/Destroy()
	. = ..()
	if(affected_mob)
		remove_disease()
	SSdisease.active_diseases.Remove(src)

//add this disease if the host does not already have too many
/datum/disease/proc/try_infect(mob/living/infectee, make_copy = TRUE)
	infect(infectee, make_copy)
	return TRUE

//add the disease with no checks
/datum/disease/proc/infect(mob/living/infectee, make_copy = TRUE)
	var/datum/disease/D = make_copy ? Copy() : src
	LAZYADD(infectee.diseases, D)
	D.affected_mob = infectee
	SSdisease.active_diseases += D //Add it to the active diseases list, now that it's actually in a mob and being processed.

	D.after_add()
	infectee.med_hud_set_status()
	register_disease_signals()

	var/turf/source_turf = get_turf(infectee)
	log_virus("[key_name(infectee)] was infected by virus: [src.admin_details()] at [loc_name(source_turf)]")

/// Updates the spread flags set, ensuring signals are updated as necessary
/datum/disease/proc/update_spread_flags(new_flags)
	if(spread_flags == new_flags)
		return

	spread_flags = new_flags
	unregister_disease_signals()
	register_disease_signals()

/// Register any relevant signals for the disease
/datum/disease/proc/register_disease_signals()
	if(isnull(affected_mob))
		return
	if(spread_flags & DISEASE_SPREAD_AIRBORNE)
		RegisterSignal(affected_mob, COMSIG_CARBON_PRE_BREATHE, PROC_REF(on_breath))

/// Unregister any relevant signals for the disease
/datum/disease/proc/unregister_disease_signals()
	if(isnull(affected_mob))
		return
	UnregisterSignal(affected_mob, COMSIG_CARBON_PRE_BREATHE)

///Proc to process the disease and decide on whether to advance, cure or make the symptoms appear. Returns a boolean on whether to continue acting on the symptoms or not.
/datum/disease/proc/stage_act(seconds_per_tick, times_fired)
	var/slowdown = HAS_TRAIT(affected_mob, TRAIT_VIRUS_RESISTANCE) ? 0.5 : 1 // spaceacillin slows stage speed by 50%
	var/recovery_prob = 0
	var/cure_mod

	if(required_organ)
		if(!has_required_infectious_organ(affected_mob, required_organ))
			cure(add_resistance = FALSE)
			return FALSE

	if(has_cure())
		cure_mod = cure_chance
		if(istype(src, /datum/disease/advance))
			cure_mod = max(cure_chance, DISEASE_MINIMUM_CHEMICAL_CURE_CHANCE)
		if(disease_flags & CHRONIC && SPT_PROB(cure_mod, seconds_per_tick))
			update_stage(1)
			to_chat(affected_mob, span_notice("Your chronic illness is alleviated a little, though it can't be cured!"))
			return
		if(SPT_PROB(cure_mod, seconds_per_tick))
			update_stage(max(stage - 1, 1))
		if(disease_flags & CURABLE && SPT_PROB(cure_mod, seconds_per_tick))
			cure()
			return FALSE

	if(stage == max_stages && stage_peaked != TRUE) //mostly a sanity check in case we manually set a virus to max stages
		stage_peaked = TRUE

	if(SPT_PROB(stage_prob*slowdown, seconds_per_tick))
		update_stage(min(stage + 1, max_stages))

	if(!(disease_flags & CHRONIC) && disease_flags & CURABLE && bypasses_immunity != TRUE)
		switch(severity)
			if(DISEASE_SEVERITY_POSITIVE) //good viruses don't go anywhere after hitting max stage - you can try to get rid of them by sleeping earlier
				cycles_to_beat = max(DISEASE_RECOVERY_SCALING, DISEASE_CYCLES_POSITIVE) //because of the way we later check for recovery_prob, we need to floor this at least equal to the scaling to avoid infinitely getting less likely to cure
				if(((HAS_TRAIT(affected_mob, TRAIT_NOHUNGER)) || ((affected_mob.nutrition > NUTRITION_LEVEL_STARVING) && (affected_mob.satiety >= 0))) && slowdown == 1) //any sort of malnourishment/immunosuppressant opens you to losing a good virus
					return TRUE
			if(DISEASE_SEVERITY_NONTHREAT)
				cycles_to_beat = max(DISEASE_RECOVERY_SCALING, DISEASE_CYCLES_NONTHREAT)
			if(DISEASE_SEVERITY_MINOR)
				cycles_to_beat = max(DISEASE_RECOVERY_SCALING, DISEASE_CYCLES_MINOR)
			if(DISEASE_SEVERITY_MEDIUM)
				cycles_to_beat = max(DISEASE_RECOVERY_SCALING, DISEASE_CYCLES_MEDIUM)
			if(DISEASE_SEVERITY_DANGEROUS)
				cycles_to_beat = max(DISEASE_RECOVERY_SCALING, DISEASE_CYCLES_DANGEROUS)
			if(DISEASE_SEVERITY_HARMFUL)
				cycles_to_beat = max(DISEASE_RECOVERY_SCALING, DISEASE_CYCLES_HARMFUL)
			if(DISEASE_SEVERITY_BIOHAZARD)
				cycles_to_beat = max(DISEASE_RECOVERY_SCALING, DISEASE_CYCLES_BIOHAZARD)
		peaked_cycles += stage/max_stages //every cycle we spend sick counts towards eventually curing the virus, faster at higher stages
		recovery_prob += DISEASE_RECOVERY_CONSTANT + (peaked_cycles / (cycles_to_beat / DISEASE_RECOVERY_SCALING)) //more severe viruses are beaten back more aggressively after the peak
		if(stage_peaked)
			recovery_prob *= DISEASE_PEAKED_RECOVERY_MULTIPLIER
		if(slowdown != 1) //using spaceacillin can help get them over the finish line to kill a virus with decreasing effect over time
			recovery_prob += clamp((((1 - slowdown)*(DISEASE_SLOWDOWN_RECOVERY_BONUS * 2)) * ((DISEASE_SLOWDOWN_RECOVERY_BONUS_DURATION - chemical_offsets) / DISEASE_SLOWDOWN_RECOVERY_BONUS_DURATION)), 0, DISEASE_SLOWDOWN_RECOVERY_BONUS)
			chemical_offsets = min(chemical_offsets + 1, DISEASE_SLOWDOWN_RECOVERY_BONUS_DURATION)
		if(!HAS_TRAIT(affected_mob, TRAIT_NOHUNGER))
			if(affected_mob.satiety < 0 || affected_mob.nutrition < NUTRITION_LEVEL_STARVING) //being malnourished makes it a lot harder to defeat your illness
				recovery_prob -= DISEASE_MALNUTRITION_RECOVERY_PENALTY
			else
				if(affected_mob.satiety >= 0)
					recovery_prob += round((DISEASE_SATIETY_RECOVERY_MULTIPLIER * (affected_mob.satiety/MAX_SATIETY)), 0.1)

		if(affected_mob.mob_mood) // this and most other modifiers below a shameless rip from sleeping healing buffs, but feeling good helps make it go away quicker
			switch(affected_mob.mob_mood.sanity_level)
				if(SANITY_LEVEL_GREAT)
					recovery_prob += 0.4
				if(SANITY_LEVEL_NEUTRAL)
					recovery_prob += 0.2
				if(SANITY_LEVEL_DISTURBED)
					recovery_prob += 0
				if(SANITY_LEVEL_UNSTABLE)
					recovery_prob += 0
				if(SANITY_LEVEL_CRAZY)
					recovery_prob += -0.2
				if(SANITY_LEVEL_INSANE)
					recovery_prob += -0.4

		if((HAS_TRAIT(affected_mob, TRAIT_NOHUNGER) || !(affected_mob.satiety < 0 || affected_mob.nutrition < NUTRITION_LEVEL_STARVING)) && HAS_TRAIT(affected_mob, TRAIT_KNOCKEDOUT)) //resting starved won't help, but resting helps
			var/turf/rest_turf = get_turf(affected_mob)
			var/is_sleeping_in_darkness = rest_turf.get_lumcount() <= LIGHTING_TILE_IS_DARK

			if(affected_mob.is_blind_from(EYES_COVERED) || is_sleeping_in_darkness)
				recovery_prob += DISEASE_GOOD_SLEEPING_RECOVERY_BONUS

			// sleeping in silence is always better
			if(HAS_TRAIT(affected_mob, TRAIT_DEAF))
				recovery_prob += DISEASE_GOOD_SLEEPING_RECOVERY_BONUS

			// check for beds
			if((locate(/obj/structure/bed) in affected_mob.loc))
				recovery_prob += DISEASE_GOOD_SLEEPING_RECOVERY_BONUS
			else if((locate(/obj/structure/table) in affected_mob.loc))
				recovery_prob += (DISEASE_GOOD_SLEEPING_RECOVERY_BONUS / 2)

			// don't forget the bedsheet
			if(locate(/obj/item/bedsheet) in affected_mob.loc)
				recovery_prob += DISEASE_GOOD_SLEEPING_RECOVERY_BONUS

			// you forgot the pillow
			if(locate(/obj/item/pillow) in affected_mob.loc)
				recovery_prob += DISEASE_GOOD_SLEEPING_RECOVERY_BONUS

			recovery_prob *= DISEASE_SLEEPING_RECOVERY_MULTIPLIER //any form of sleeping magnifies all effects a little bit

		recovery_prob = clamp(recovery_prob, 0, 100)

		if(recovery_prob)
			if(SPT_PROB(recovery_prob, seconds_per_tick))
				if(stage == 1 && prob(cure_chance * DISEASE_FINAL_CURE_CHANCE_MULTIPLIER)) //if we reduce FROM stage == 1, cure the virus - after defeating its cure_chance in a final battle
					if(!HAS_TRAIT(affected_mob, TRAIT_NOHUNGER) && (affected_mob.satiety < 0 || affected_mob.nutrition < NUTRITION_LEVEL_STARVING))
						if(stage_peaked == FALSE) //if you didn't ride out the virus from its peak, if you're malnourished when it cures, you don't get resistance
							cure(add_resistance = FALSE)
							return FALSE
						else if(prob(50)) //if you rode it out from the peak, challenge cure_chance on if you get resistance or not
							cure(add_resistance = TRUE)
							return FALSE
					else
						cure(add_resistance = TRUE) //stay fed and cure it at any point, you're immune
						return FALSE
				update_stage(max(stage - 1, 1))

		if(HAS_TRAIT(affected_mob, TRAIT_KNOCKEDOUT) || slowdown != 1) //sleeping and using spaceacillin lets us nosell applicable virus symptoms firing with decreasing effectiveness over time
			if(prob(100 - min((100 * (symptom_offsets / DISEASE_SYMPTOM_OFFSET_DURATION)), 100 - cure_chance * DISEASE_FINAL_CURE_CHANCE_MULTIPLIER))) //viruses with higher cure_chance will ultimately be more possible to offset symptoms on
				symptom_offsets = min(symptom_offsets + 1, DISEASE_SYMPTOM_OFFSET_DURATION)
				return FALSE

	return !carrier

/datum/disease/proc/update_stage(new_stage)
	stage = new_stage
	if(new_stage == max_stages && !(stage_peaked)) //once a virus has hit its peak, set it to have done so
		stage_peaked = TRUE

/datum/disease/proc/has_cure()
	if(!(disease_flags & (CURABLE | CHRONIC)))
		return FALSE

	. = cures.len
	for(var/C_id in cures)
		if(!affected_mob.reagents.has_reagent(C_id))
			.--
	if(!. || (needs_all_cures && . < cures.len))
		return FALSE

/**
 * Handles performing a spread-via-air
 *
 * Checks for stuff like "is our mouth covered" for you
 *
 * * spread_range - How far the disease can spread
 * * force_spread - If TRUE, the disease will spread regardless of the spread_flags
 * * require_facing - If TRUE, the disease will only spread if the source mob is facing the target mob
 */
/datum/disease/proc/airborne_spread(spread_range = 2, force_spread = TRUE, require_facing = FALSE)
	if(isnull(affected_mob))
		return FALSE
	if(!(spread_flags & DISEASE_SPREAD_AIRBORNE) && !force_spread)
		return FALSE
	if(affected_mob.can_spread_airborne_diseases())
		return FALSE
	if(!has_required_infectious_organ(affected_mob, ORGAN_SLOT_LUNGS)) //also if you lack lungs
		return FALSE
	if(HAS_TRAIT(affected_mob, TRAIT_VIRUS_RESISTANCE) || (affected_mob.satiety > 0 && prob(affected_mob.satiety / 2))) //being full or on spaceacillin makes you less likely to spread a virus
		return FALSE
	var/turf/mob_loc = affected_mob.loc
	if(!istype(mob_loc))
		return FALSE
	for(var/mob/living/carbon/to_infect in oview(spread_range, affected_mob))
		var/turf/infect_loc = to_infect.loc
		if(!istype(infect_loc))
			continue
		if(require_facing && !is_source_facing_target(affected_mob, to_infect))
			continue
		if(!disease_air_spread_walk(mob_loc, infect_loc))
			continue
		to_infect.contract_airborne_disease(src)
	return TRUE

/// Helper for checking if there is an air path between two turfs
/proc/disease_air_spread_walk(turf/start, turf/end)
	if(!start || !end)
		return FALSE
	while(TRUE)
		if(end == start)
			return TRUE
		var/turf/Temp = get_step_towards(end, start)
		if(!TURFS_CAN_SHARE(end, Temp)) //Don't go through a wall
			return FALSE
		end = Temp

/datum/disease/proc/cure(add_resistance = TRUE)
	if(severity == DISEASE_SEVERITY_UNCURABLE) //aw man :(
		return
	if(affected_mob)
		if(add_resistance && (disease_flags & CAN_RESIST))
			LAZYOR(affected_mob.disease_resistances, GetDiseaseID())
		if(affected_mob.ckey)
			var/cure_turf = get_turf(affected_mob)
			log_virus("[key_name(affected_mob)] was cured of virus: [src.admin_details()] at [loc_name(cure_turf)]")
	qdel(src)

/datum/disease/proc/IsSame(datum/disease/D)
	if(istype(D, type))
		return TRUE
	return FALSE


/datum/disease/proc/Copy()
	//note that stage is not copied over - the copy starts over at stage 1
	var/static/list/copy_vars = list("name", "visibility_flags", "disease_flags", "spread_flags", "form", "desc", "agent", "spread_text",
									"cure_text", "max_stages", "stage_prob", "incubation_time", "viable_mobtypes", "cures", "infectivity", "cure_chance",
									"required_organ", "bypasses_immunity", "spreading_modifier", "severity", "needs_all_cures", "strain_data",
									"infectable_biotypes", "process_dead")

	var/datum/disease/D = copy_type ? new copy_type() : new type()
	for(var/V in copy_vars)
		var/val = vars[V]
		if(islist(val))
			var/list/L = val
			val = L.Copy()
		D.vars[V] = val
	return D

/datum/disease/proc/after_add()
	return


/datum/disease/proc/GetDiseaseID()
	return "[type]"

/datum/disease/proc/remove_disease()
	unregister_disease_signals()
	LAZYREMOVE(affected_mob.diseases, src) //remove the datum from the list
	affected_mob.med_hud_set_status()
	affected_mob = null

/**
 * Checks the given typepath against the list of viable mobtypes.
 *
 * Returns TRUE if the mob_type path is derived from of any entry in the viable_mobtypes list.
 * Returns FALSE otherwise.
 *
 * Arguments:
 * * mob_type - Type path to check against the viable_mobtypes list.
 */
/datum/disease/proc/is_viable_mobtype(mob_type)
	for(var/viable_type in viable_mobtypes)
		if(ispath(mob_type, viable_type))
			return TRUE

	// Let's only do this check if it fails. Did some genius coder pass in a non-type argument?
	if(!ispath(mob_type))
		stack_trace("Non-path argument passed to mob_type variable: [mob_type]")

	return FALSE

/// Checks if the mob has the required organ and it's not robotic or affected by inorganic biology
/datum/disease/proc/has_required_infectious_organ(mob/living/carbon/target, required_organ_slot)
	if(!iscarbon(target))
		return FALSE

	var/obj/item/organ/target_organ = target.get_organ_slot(required_organ_slot)
	if(!istype(target_organ))
		return FALSE

	// robotic organs are immune to disease unless 'inorganic biology' symptom is present
	if(IS_ROBOTIC_ORGAN(target_organ) && !(infectable_biotypes & MOB_ROBOTIC))
		return FALSE

	return TRUE

/// Handles spreading via air when our mob breathes
/datum/disease/proc/on_breath(datum/source, seconds_per_tick, ...)
	SIGNAL_HANDLER

	if(SPT_PROB(infectivity * 4, seconds_per_tick))
		airborne_spread()

//Use this to compare severities
/proc/get_disease_severity_value(severity)
	switch(severity)
		if(DISEASE_SEVERITY_UNCURABLE)
			return 0
		if(DISEASE_SEVERITY_POSITIVE)
			return 1
		if(DISEASE_SEVERITY_NONTHREAT)
			return 2
		if(DISEASE_SEVERITY_MINOR)
			return 3
		if(DISEASE_SEVERITY_MEDIUM)
			return 4
		if(DISEASE_SEVERITY_HARMFUL)
			return 5
		if(DISEASE_SEVERITY_DANGEROUS)
			return 6
		if(DISEASE_SEVERITY_BIOHAZARD)
			return 7

///A list of the possible mutations for a vine
GLOBAL_LIST_INIT(vine_mutations_list, init_vine_mutation_list())

/proc/init_vine_mutation_list()
	var/list/mutation_list = list()
	init_subtypes(/datum/spacevine_mutation/, mutation_list)
	for(var/datum/spacevine_mutation/mutation as anything in mutation_list)
		mutation_list[mutation] = IDEAL_MAX_SEVERITY - mutation.severity // the ideal maximum potency is used for weighting
	return mutation_list

/datum/spacevine_controller
	///Canonical list of all the vines we "own"
	var/list/obj/structure/spacevine/vines
	///Queue of vines to process
	var/list/growth_queue
	//List of currently processed vines, on this level to prevent runtime tomfoolery
	var/list/obj/structure/spacevine/queue_end
	///Spread multiplier, depends on productivity, affects how often kudzu spreads
	var/spread_multiplier = 5 // corresponds to artificial kudzu with production speed of 1, approaches 10% of total vines will spread per second
	///Maximum spreading limit (ie. how many kudzu can there be) for this controller
	var/spread_cap = 30 // corresponds to artificial kudzu with production speed of 3.5
	///The chance that we will develop a new mutation
	var/mutativeness = 1
	///Maximum sum of mutation severities
	var/max_mutation_severity = 20
	///Minimum spread rate per second
	var/minimum_spread_rate = 1

/datum/spacevine_controller/New(turf/location, list/muts, potency, production, datum/round_event/event = null)
	vines = list()
	growth_queue = list()
	queue_end = list()
	var/obj/structure/spacevine/vine = spawn_spacevine_piece(location, null, muts)
	if(event)
		event.announce_to_ghosts(vine)
	START_PROCESSING(SSobj, src)
	if(potency != null)
		mutativeness = potency * MUTATIVENESS_SCALE_FACTOR // If potency is 100, 20 mutativeness; if 1: 0.2 mutativeness
		max_mutation_severity = round(potency * MAX_SEVERITY_LINEAR_COEFF + MAX_SEVERITY_CONSTANT_TERM) // If potency is 100, 25 max mutation severity; if 1, 10 max mutation severity
	if(production != null && production <= MAX_POSSIBLE_PRODUCTIVITY_VALUE) //Prevents runtime in case production is set to 11.
		spread_cap = SPREAD_CAP_LINEAR_COEFF * (MAX_POSSIBLE_PRODUCTIVITY_VALUE + 1 - production) + SPREAD_CAP_CONSTANT_TERM //Best production speed of 1 increases spread_cap to 60, worst production speed of 10 lowers it to 24, even distribution
		spread_multiplier = SPREAD_MULTIPLIER_MAX / (MAX_POSSIBLE_PRODUCTIVITY_VALUE + 1 - production) // Best production speed of 1: 10% of total vines will spread per second, worst production speed of 10: 1% of total vines (with minimum of 1) will spread per second
	if(event != null) // spawned by space vine event
		max_mutation_severity += MAX_SEVERITY_EVENT_BONUS
		minimum_spread_rate = 3

/datum/spacevine_controller/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_SPACEVINE_PURGE, "Delete Vines")

/datum/spacevine_controller/vv_do_topic(href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_SPACEVINE_PURGE])
		if(!check_rights(NONE))
			return
		if(tgui_alert(usr, "Are you sure you want to delete this spacevine cluster?", "Delete Vines", list("Yes", "No")) == "Yes")
			DeleteVines()

/datum/spacevine_controller/proc/DeleteVines() //this is kill
	QDEL_LIST(vines) //this will also qdel us

/datum/spacevine_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	vines.Cut()
	growth_queue.Cut()
	queue_end.Cut()
	return ..()

/datum/spacevine_controller/proc/spawn_spacevine_piece(turf/location, obj/structure/spacevine/parent, list/muts)
	var/obj/structure/spacevine/vine = new(location)
	growth_queue += vine
	vines += vine
	vine.master = src
	for(var/mutation_type in muts)
		for(var/datum/spacevine_mutation/mutation in GLOB.vine_mutations_list)
			if(istype(mutation, mutation_type))
				mutation.add_mutation_to_vinepiece(vine)
				break
	if(parent)
		vine.mutations |= parent.mutations
		vine.trait_flags |= parent.trait_flags
		var/parentcolor = parent.atom_colours[FIXED_COLOUR_PRIORITY]
		vine.add_atom_colour(parentcolor, FIXED_COLOUR_PRIORITY)
		if(prob(mutativeness))
			var/datum/spacevine_mutation/random_mutate = pick_weight(GLOB.vine_mutations_list - vine.mutations)
			if(!isnull(random_mutate)) //If this vine has every single mutation don't attempt to add a null mutation.
				var/total_severity = random_mutate.severity
				for(var/datum/spacevine_mutation/mutation as anything in vine.mutations)
					total_severity += mutation.severity
				if(total_severity <= max_mutation_severity)
					random_mutate.add_mutation_to_vinepiece(vine)

	for(var/datum/spacevine_mutation/mutation in vine.mutations)
		mutation.on_birth(vine)
	location.Entered(vine, null)
	return vine

/datum/spacevine_controller/proc/VineDestroyed(obj/structure/spacevine/vine)
	vine.master = null
	vines -= vine
	growth_queue -= vine
	queue_end -= vine
	if(length(vines))
		return
	var/obj/item/seeds/kudzu/seed = new(vine.loc)
	seed.mutations |= vine.mutations
	seed.set_potency(mutativeness / MUTATIVENESS_SCALE_FACTOR)
	// Mathematical notes:
	// The formula for spread_multiplier is SPREAD_MULTIPLIER_MAX / (MAX_POSSIBLE_PRODUCTIVITY_VALUE + 1 - production)
	// So (MAX_POSSIBLE_PRODUCTIVITY_VALUE + 1 - production) = SPREAD_MULTIPLIER_MAX / spread_multiplier
	// ie. production = MAX_POSSIBLE_PRODUCTIVITY_VALUE + 1 - SPREAD_MULTIPLIER_MAX / spread_multiplier
	seed.set_production(MAX_POSSIBLE_PRODUCTIVITY_VALUE + 1 - (SPREAD_MULTIPLIER_MAX / spread_multiplier)) //Reverts spread_multiplier formula so resulting seed gets original production stat or equivalent back.
	qdel(src)

/// Life cycle of a space vine
/datum/spacevine_controller/process(seconds_per_tick)
	var/vine_count = length(vines)
	if(!vine_count)
		qdel(src) //space vines exterminated. Remove the controller
		return

	/// Bonus spread for kudzu that has just started out (ie. with low vine count)
	var/start_spread_bonus = max(5 - spread_multiplier * (vine_count ** 2) / 400, 0)
	/// Base spread rate, depends solely on spread multiplier and vine count
	var/spread_base = 0.5 * vine_count / spread_multiplier
	/// Actual maximum spread rate for this process tick
	var/spread_max = round(clamp(seconds_per_tick * (spread_base + start_spread_bonus), max(seconds_per_tick * minimum_spread_rate, 1), spread_cap))
	var/amount_processed = 0
	for(var/obj/structure/spacevine/vine in growth_queue)
		if(!vine.can_spread)
			continue
		growth_queue -= vine
		queue_end += vine
		for(var/datum/spacevine_mutation/mutation in vine.mutations)
			mutation.process_mutation(vine)

		if(vine.growth_stage >= 2) //If tile is fully grown
			vine.entangle_mob()
		else if(SPT_PROB(10, seconds_per_tick)) //If tile isn't fully grown
			vine.grow()

		vine.spread()

		amount_processed++
		if(amount_processed >= spread_max)
			break

	//We can only do so much work per process, but we still want to process everything at some point
	//So we shift the queue a bit
	growth_queue += queue_end
	queue_end = list()

/**
 * Used to determine whether the mob is immune to actions by the vine.
 * Use cases: Stops vine from attacking itself, other plants.
 */
/proc/isvineimmune(atom/target)
	if(isliving(target))
		var/mob/living/victim = target
		if((FACTION_VINES in victim.faction) || (FACTION_PLANTS in victim.faction))
			return TRUE
	return FALSE

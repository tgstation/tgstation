/datum/component/mutation
	///list of all mutations possible
	var/list/possible_mutations = list()
	///does it produce eggs?
	var/produces_eggs = FALSE
	///time it stays inside the body if its not an egg production
	var/gestate_timer = 60 SECONDS
	///are we gestating right now
	var/gestating = FALSE
	var/gestate_cooldown_time = 3 MINUTES
	COOLDOWN_DECLARE(gestate_cooldown)


/datum/component/mutation/Initialize(list/possible_mutations, produces_eggs, gestate_timer)
	. = ..()
	src.possible_mutations = possible_mutations
	src.produces_eggs = produces_eggs
	src.gestate_timer = gestate_timer

	RegisterSignal(parent, COMSIG_MUTATION_TRIGGER, PROC_REF(trigger_mutation))

/datum/component/mutation/proc/trigger_mutation(atom/source, turf/source_turf, passes_minimum_checks, instability = 10)
	SIGNAL_HANDLER

	var/mob/living/basic/parent_animal = parent
	if(produces_eggs)
		var/obj/item/food/egg/layed_egg
		if(!passes_minimum_checks)
			layed_egg = new parent_animal.egg_type(source_turf)
			parent_animal.pass_stats(layed_egg)
			return
		if(prob(instability))
			var/list/real_mutations = list()
			for(var/datum/mutation/ranching/mutation as anything in parent_animal.created_mutations)
				var/value = 100
				if(!mutation.cycle_requirements(parent_animal))
					continue
				real_mutations |= mutation
				real_mutations[mutation] = value

			if(length(real_mutations))
				var/datum/mutation/ranching/chicken/picked_mutation = pick_weight(real_mutations)
				layed_egg = new picked_mutation.egg_type(source_turf)
				layed_egg.possible_mutations |= picked_mutation
				if(layed_egg.type != parent_animal.egg_type)
					layed_egg.fresh_mutation = TRUE
			else
				layed_egg = new parent_animal.egg_type(source_turf)
		else
			layed_egg = new parent_animal.egg_type(source_turf)

		parent_animal.pass_stats(layed_egg, TRUE)

	else
		if(!COOLDOWN_FINISHED(src, gestate_cooldown))
			return
		gestating = TRUE
		addtimer(CALLBACK(src, PROC_REF(finished_gestate), passes_minimum_checks, instability), gestate_timer)


/datum/component/mutation/proc/finished_gestate(passes_minimum_checks, instability = 10)
	gestating = FALSE
	COOLDOWN_START(src, gestate_cooldown, gestate_cooldown_time)
	var/turf/open/source_turf = get_turf(parent)
	var/mob/living/basic/parent_animal = parent
	var/mob/living/basic/child
	if(!passes_minimum_checks)
		child = new parent_animal.child_type(source_turf)

	else
		if(prob(instability))
			var/list/real_mutations = list()
			for(var/datum/mutation/ranching/mutation as anything in parent_animal.created_mutations)
				var/value = 100
				if(!mutation.cycle_requirements(parent_animal))
					continue
				real_mutations |= mutation
				real_mutations[mutation] = value
			if(length(real_mutations))
				var/datum/mutation/ranching/picked_mutation = pick_weight(real_mutations)
				child = new picked_mutation.baby(source_turf)
			else
				child = new parent_animal.child_type(source_turf)

	parent_animal.pass_stats(child)

/datum/component/mutation
	///list of all mutations possible
	var/list/possible_mutations = list()
	///does it produce eggs?
	var/produces_eggs = FALSE
	///time it stays inside the body if its not an egg production
	var/gestate_timer = 60 SECONDS


/datum/component/mutation/Initialize(list/possible_mutations, produces_eggs, gestate_timer)
	. = ..()
	src.possible_mutations = possible_mutations
	src.produces_eggs = produces_eggs
	src.gestate_timer = gestate_timer

	RegisterSignal(parent, COMSIG_MUTATION_TRIGGER, PROC_REF(trigger_mutation))

/datum/component/mutation/proc/trigger_mutation(atom/source, turf/source_turf, passes_minimum_checks)
	SIGNAL_HANDLER

	var/mob/living/basic/parent_animal = parent
	if(produces_eggs)
		var/obj/item/food/egg/layed_egg
		if(!passes_minimum_checks)
			layed_egg = new parent_animal.egg_type(source_turf)
			parent_animal.pass_stats(layed_egg)
			return

		var/list/real_mutation = list()
		for(var/raw_list_item in parent_animal.mutation_list)
			var/datum/mutation/ranching/chicken/mutation = new raw_list_item
			var/value = 100
			if(!mutation.cycle_requirements(parent_animal))
				real_mutation |= mutation
				real_mutation[mutation] = value * 0.5
				continue
			real_mutation |= mutation
			real_mutation[mutation] = value

		if(real_mutation.len)
			var/datum/mutation/ranching/chicken/picked_mutation = pick_weight(real_mutation)
			layed_egg = new picked_mutation.egg_type(source_turf)
			layed_egg.possible_mutations |= picked_mutation
			if(layed_egg.type != parent_animal.egg_type)
				layed_egg.fresh_mutation = TRUE
		else
			layed_egg = new parent_animal.egg_type(source_turf)
		parent_animal.pass_stats(layed_egg)

	else
		addtimer(CALLBACK(src, PROC_REF(finished_gestate), passes_minimum_checks), gestate_timer)


/datum/component/mutation/proc/finished_gestate(passes_minimum_checks)
	var/turf/open/source_turf = get_turf(parent)
	var/mob/living/basic/parent_animal = parent
	if(!passes_minimum_checks)
		var/mob/living/basic/child = new parent_animal.child_type(source_turf)

		parent_animal.pass_stats(child)

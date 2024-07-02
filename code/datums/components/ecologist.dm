/datum/component/ecologist
	var/last_damage
	var/cooldown

/datum/component/ecologist/Initialize(...)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/living_parent = parent
	ADD_TRAIT(living_parent, TRAIT_PLANT_SAFE, "ecologist perk")
	living_parent.faction |= list(FACTION_PLANTS, FACTION_VINES)
	living_parent.grant_language(/datum/language/sylvan, source = "ecologist perk")
	last_damage = living_parent.health

/datum/component/ecologist/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(nature_call))

/datum/component/ecologist/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE)

/datum/component/ecologist/process(seconds_per_tick)
	. = ..()
	if(!isliving(parent))
		return
	var/mob/living/living_parent = parent
	last_damage = living_parent.health

/datum/component/ecologist/proc/nature_call(mob/living/man_of_nature)
	SIGNAL_HANDLER

	var/calculate_damage = round((last_damage - man_of_nature.health)/5)
	if(isnull(calculate_damage))
		return
	if(cooldown)
		return
	make_vines(man_of_nature, calculate_damage)
	last_damage = man_of_nature.health

/datum/component/ecologist/proc/make_vines(mob/living/vine_maker, power_of_nature)
	var/list/datum/spacevine_mutation/mutations = GLOB.vine_mutations_list
	mutations -= /datum/spacevine_mutation/explosive
	mutations = shuffle(mutations)
	switch(power_of_nature)
		if(2 to 4)
			var/making_and_making
			for(var/turf/around_ecologist in range(1, vine_maker))
				if(locate(/obj/structure/spacevine) in around_ecologist)
					continue
				if(making_and_making > 0)
					if(prob(10*making_and_making))
						continue
				for(var/add_mutation in mutations)
					if(prob(5*mutations.len))
						mutations -= add_mutation
				new /datum/spacevine_controller(around_ecologist, mutations, 20, 20)
				making_and_making++
		if(5 to INFINITY)
			var/making_and_making
			for(var/turf/around_ecologist in range(2, vine_maker))
				if(locate(/obj/structure/spacevine) in around_ecologist)
					continue
				if(making_and_making > 9)
					if(prob(5*making_and_making))
						continue
				for(var/add_mutation in mutations)
					if(prob(5*mutations.len))
						mutations -= add_mutation
				new /datum/spacevine_controller(around_ecologist, mutations, 20, 20)
				making_and_making++
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 5 SECONDS)

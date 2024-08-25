/datum/artifact_effect/injector
	weight = ARTIFACT_UNCOMMON
	type_name = "Injector Effect"
	activation_message = "opens up to reveal a large needle!"
	deactivation_message = "pulls its needle inside, closing itself up."
	var/max_reagents // the total amount to dose the victim with
	var/reagent_amount
	var/list/reagent_datums = list()
	var/cooldown_time = 10 SECONDS
	COOLDOWN_DECLARE(activation_cooldown)

	research_value = 250

	examine_discovered = span_warning("It appears to be some sort of chemical injector")

/datum/artifact_effect/injector/setup()
	our_artifact.holder.create_reagents(200, NO_REACT | SEALED_CONTAINER)
	reagent_amount = rand(10,25)
	max_reagents = rand(1,2)
	var/static/list/poisons_and_medicines = list()
	if(!poisons_and_medicines.len) //mostly copied from reagents.dm but oh well
		for(var/datum/reagent/reagent as anything in (subtypesof(/datum/reagent/toxin) + subtypesof(/datum/reagent/medicine)))
			if(initial(reagent.chemical_flags) & REAGENT_CAN_BE_SYNTHESIZED)
				poisons_and_medicines += reagent
	switch(our_artifact.artifact_origin.type_name)
		if(ORIGIN_NARSIE)
			for(var/i in 1 to max_reagents)
				reagent_datums += pick(poisons_and_medicines) //cult likes killing people ok
		if(ORIGIN_WIZARD, ORIGIN_MARTIAN, ORIGIN_PRECURSOR)
			max_reagents = rand(1,3)
			reagent_amount = rand(1,50)
			potency += 5
			for(var/i in 1 to max_reagents)
				reagent_datums += get_random_reagent_id() // funny
		if(ORIGIN_SILICON)
			var/list/silicon_reagents = list(/datum/reagent/uranium, /datum/reagent/silicon, /datum/reagent/fuel, /datum/reagent/cyborg_mutation_nanomachines, /datum/reagent/fuel/oil, /datum/reagent/toxin/leadacetate)
			for(var/i in 1 to max_reagents)
				reagent_datums += pick(silicon_reagents)
	potency += reagent_amount + max_reagents

/datum/artifact_effect/injector/effect_touched(mob/living/user)
	if(!ishuman(user) || !COOLDOWN_FINISHED(src,activation_cooldown))
		our_artifact.holder.visible_message(span_smallnoticeital("[our_artifact.holder] does not react to [user]."))
		return
	for(var/reagent in reagent_datums)
		our_artifact.holder.reagents.add_reagent(reagent, reagent_amount / reagent_datums.len)
	our_artifact.holder.visible_message(span_danger("[our_artifact.holder] pricks [user] with its needle!"), span_userdanger("OW! You are pricked by [our_artifact.holder]!"))
	our_artifact.holder.reagents.trans_to(user, our_artifact.holder.reagents.total_volume, transfered_by = our_artifact.holder, methods = INJECT)
	COOLDOWN_START(src,activation_cooldown,cooldown_time)

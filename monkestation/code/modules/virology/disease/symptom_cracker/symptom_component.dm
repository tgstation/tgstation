/datum/component/symptom_genes
	///a typepath list of symptoms we can get from this mob
	var/list/symptom_types = list()
	///name to type list
	var/list/symptom_type_name = list()
	///our current puzzle
	var/datum/cracker_puzzle/puzzle

	var/static/list/species_given = list()

	var/static/list/species_specifc_symptoms = list(
	)

	var/static/list/built_symptoms = list()

	var/datum/symptom/current_choice

	var/mob/current_user

	var/obj/item/extrapolator/current_extrapolator

/datum/component/symptom_genes/Initialize(datum/species/host_species, symptom_count = 3)
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	add_symptoms(host_species, symptom_count)


/datum/component/symptom_genes/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_EXTRAPOLATOR_ACT, PROC_REF(on_extrapolate))


/datum/component/symptom_genes/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_EXTRAPOLATOR_ACT)

/datum/component/symptom_genes/Destroy(force, silent)
	. = ..()
	current_user = null
	current_extrapolator = null
	if(puzzle)
		SStgui.close_uis(puzzle)
		UnregisterSignal(puzzle, list(COMSIG_CRACKER_PUZZLE_FAILURE, COMSIG_CRACKER_PUZZLE_SUCCESS))
		qdel(puzzle)

/datum/component/symptom_genes/proc/add_symptoms(datum/species/host_species, symptom_count)

	if(!(host_species.type in species_given))
		if(add_species_symptom(host_species))
			symptom_count--

	while(symptom_count > 0)
		if(add_new_symptom(host_species))
			symptom_count--

/datum/component/symptom_genes/proc/add_species_symptom(datum/species/host_species)
	species_given |= host_species.type

	if(!(host_species.type in species_specifc_symptoms))
		return FALSE

	var/datum/symptom/new_symptom = pick(species_specifc_symptoms[host_species.type])
	symptom_types |= new_symptom
	symptom_type_name[initial(new_symptom.name)] = new_symptom
	return TRUE

/datum/component/symptom_genes/proc/add_new_symptom(datum/species/host_species)
	if(!length(built_symptoms))
		for(var/datum/symptom/symptom as anything in subtypesof(/datum/symptom))
			if(symptom.restricted)
				continue
			built_symptoms |= symptom

	var/datum/symptom/new_symptom = pick(built_symptoms)
	if(prob(5))
		new_symptom = pick(species_specifc_symptoms[host_species.type])
	if(new_symptom in symptom_types)
		return FALSE

	symptom_types |= new_symptom
	symptom_type_name[initial(new_symptom.name)] = new_symptom
	return TRUE

/datum/component/symptom_genes/proc/on_extrapolate(datum/source, mob/user, obj/item/extrapolator/extrapolator)
	SIGNAL_HANDLER

	if(!user)
		return FALSE

	if(!user.can_interact_with(parent))
		return FALSE

	INVOKE_ASYNC(src, PROC_REF(try_extrapolate), user, extrapolator)
	return TRUE

/datum/component/symptom_genes/proc/try_extrapolate(mob/user, obj/item/extrapolator/extrapolator)
	var/symptom_choice = tgui_input_list(user, "Choose a Symptom", "Genetic Symptoms", symptom_type_name)
	if(!symptom_choice)
		return
	current_choice = symptom_type_name[symptom_choice]
	current_user = user

	current_extrapolator = extrapolator

	puzzle = new(difficulty = text2num(initial(current_choice.badness)) + 1, parent = src)

	RegisterSignal(src, COMSIG_CRACKER_PUZZLE_SUCCESS, PROC_REF(on_puzzle_success))
	RegisterSignal(src, COMSIG_CRACKER_PUZZLE_FAILURE, PROC_REF(on_puzzle_fail))
	puzzle.ui_interact(user)


/datum/component/symptom_genes/proc/on_puzzle_fail()
	playsound(current_user, 'sound/machines/defib_failed.ogg', 50, FALSE)
	current_choice = null
	current_user = null
	current_extrapolator = null
	SStgui.close_uis(puzzle)
	UnregisterSignal(src, list(COMSIG_CRACKER_PUZZLE_FAILURE, COMSIG_CRACKER_PUZZLE_SUCCESS))
	qdel(puzzle)

/datum/component/symptom_genes/proc/on_puzzle_success()
	playsound(current_user, 'sound/machines/defib_success.ogg', 50, FALSE)
	var/mob/living/carbon/human/human = parent
	var/uncapped = FALSE
	if(human.mind)
		uncapped = TRUE

	var/datum/symptom/created_symptom = new current_choice

	if(uncapped)
		created_symptom.chance = rand(created_symptom.chance, created_symptom.max_chance * 4)
		created_symptom.chance = min(created_symptom.chance, 100)

		created_symptom.max_chance = max(created_symptom.chance, created_symptom.max_chance)

	else
		created_symptom.chance = rand(created_symptom.chance, created_symptom.max_chance)
		created_symptom.chance = min(created_symptom.chance, 100)

	created_symptom.multiplier = rand(created_symptom.multiplier, created_symptom.max_multiplier)


	var/obj/item/disk/disease/d = new /obj/item/disk/disease(get_turf(current_user))
	current_user.put_in_hands(d)

	d.effect = created_symptom
	d.update_desc()
	d.name = "[created_symptom.name] GNA disk."

	current_user = null
	symptom_types -= current_choice
	symptom_type_name -= initial(current_choice.name)
	current_choice = null
	if(prob(text2num(created_symptom.badness) * (15 * current_extrapolator.scanner.rating)))
		current_extrapolator.generate_varient()
	current_extrapolator = null

	UnregisterSignal(src, list(COMSIG_CRACKER_PUZZLE_FAILURE, COMSIG_CRACKER_PUZZLE_SUCCESS))
	SStgui.close_uis(puzzle)
	qdel(puzzle)

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/symptom_genes, dna.species, 3)

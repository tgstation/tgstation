/datum/traitor_objective_category/kill_pet
	name = "Kill Pet"
	objectives = list(
		/datum/traitor_objective/kill_pet/high_risk = 1,
		list(
			/datum/traitor_objective/kill_pet = 2,
			/datum/traitor_objective/kill_pet/medium_risk = 1,
		) = 4,
	)

/datum/traitor_objective/kill_pet
	name = "Kill the %DEPARTMENT HEAD%'s beloved %PET%"
	description = "The %DEPARTMENT HEAD% has particularly annoyed us by sending us spam emails and we want their %PET% dead to show them what happens when they cross us. "

	progression_minimum = 0 MINUTES
	telecrystal_reward = list(1, 2)
	progression_reward = list(3 MINUTES, 6 MINUTES)

	/// Possible heads mapped to their pet type. Can be a list of possible pets
	var/list/possible_heads = list(
		JOB_HEAD_OF_PERSONNEL = list(
			/mob/living/basic/pet/dog/corgi/ian,
			/mob/living/basic/pet/dog/corgi/puppy/ian
		),
		JOB_CAPTAIN = /mob/living/simple_animal/pet/fox/renault,
		JOB_CHIEF_MEDICAL_OFFICER = /mob/living/simple_animal/pet/cat/runtime,
		JOB_CHIEF_ENGINEER = /mob/living/simple_animal/parrot/poly,
		JOB_QUARTERMASTER = list(
			/mob/living/simple_animal/sloth/citrus,
			/mob/living/simple_animal/sloth/paperwork,
			/mob/living/simple_animal/hostile/gorilla/cargo_domestic,
		)
	)
	/// The head that we are targetting
	var/datum/job/target
	/// Whether or not we only take from the traitor's own department head or not.
	var/limited_to_department_head = TRUE
	/// The actual pet that needs to be killed
	var/mob/living/target_pet

	duplicate_type = /datum/traitor_objective/kill_pet

/datum/traitor_objective/kill_pet/medium_risk
	progression_minimum = 10 MINUTES
	progression_reward = list(5 MINUTES, 8 MINUTES)
	limited_to_department_head = FALSE

/datum/traitor_objective/kill_pet/high_risk
	progression_minimum = 25 MINUTES
	progression_reward = list(14 MINUTES, 18 MINUTES)
	telecrystal_reward = list(2, 3)

	limited_to_department_head = FALSE
	possible_heads = list(
		JOB_HEAD_OF_SECURITY = list(
			/mob/living/basic/carp/pet/lia,
			/mob/living/basic/giant_spider/sgt_araneus,
		),
		JOB_WARDEN = list(
			/mob/living/basic/pet/dog/pug/mcgriff
		)
	)

/datum/traitor_objective/kill_pet/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/datum/job/role = generating_for.assigned_role
	for(var/datum/traitor_objective/kill_pet/objective as anything in possible_duplicates)
		possible_heads -= objective.target.title
	if(limited_to_department_head)
		possible_heads = possible_heads & role.department_head
	possible_heads -= role.title

	if(!length(possible_heads))
		return FALSE
	target = SSjob.name_occupations[pick(possible_heads)]
	var/pet_type = possible_heads[target.title]
	if(islist(pet_type))
		for(var/type in pet_type)
			target_pet = locate(type) in GLOB.mob_living_list
			if(target_pet)
				break
	else
		target_pet = locate(pet_type) in GLOB.mob_living_list
	if(!target_pet)
		return FALSE
	if(target_pet.stat == DEAD)
		return FALSE
	AddComponent(/datum/component/traitor_objective_register, target_pet, \
		succeed_signals = list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
	replace_in_name("%DEPARTMENT HEAD%", target.title)
	replace_in_name("%PET%", target_pet.name)
	return TRUE

/datum/traitor_objective/kill_pet/ungenerate_objective()
	if(target_pet)
		UnregisterSignal(target_pet, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
	target_pet = null

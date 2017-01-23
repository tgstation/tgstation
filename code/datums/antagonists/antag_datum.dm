/datum/antagonist
	var/name = "Antagonist"

	var/datum/mind/owner						//Mind that owns this datum

	var/text_on_gain = ""						//Text that will be shown to the mob when he gains the datum
	var/text_on_lose = "" 						//Text that will be shown to the mob when he loses the datum
	var/silent = FALSE							//Silent will prevent the gain/lose texts to show

	var/give_special_equipment = TRUE			//If the mob will receive some sort of gear when he is given the datum
	var/remove_clown_mut = TRUE					//If it will remove the clown mutation on datum gain
	var/has_objectives = TRUE 					//Whether or not the objectives will be generated when this datum is created
	var/number_of_possible_objectives			//Number of objectives this datum will have
	var/list/current_objectives = list()		//List of objectives this datum will have
	var/list/possible_objectives = list()		//List of possible objectives

	var/can_coexist_with_others = TRUE			//Whether or not the person will be able to have more than one datum
	var/list/typecache_datum_blacklist = list()	//List of datums this type can't coexist with

	var/list/restricted_jobs = list()			//Restricted jobs if you have this antag datum
	var/ignore_job_selection = FALSE			//It won't assign the owner to any job if set to true(only valid to roundstart selection)
	var/landmark_spawn = ""						//It will attempt to spawn in a landmark with the same name as set in the variable

/datum/antagonist/New(datum/mind/new_owner)
	. = ..()
	typecache_datum_blacklist = typecacheof(typecache_datum_blacklist)
	if(new_owner)
		owner = new_owner
	if(ticker && ticker.threat)
		if(!islist(ticker.threat.antagonists[name]))
			ticker.threat.antagonists[name] = list()
		ticker.threat.antagonists[name] += owner

//This handles the application of antag huds/special abilities
/datum/antagonist/proc/apply_innate_effects()
	return

/datum/antagonist/proc/remove_innate_effects()	//This handles the removal of antag huds/special abilities
	return

//Proc called when the datum is given to a mind.
/datum/antagonist/proc/on_gain()
	if(owner && owner.current)
		if(!silent)
			greet()
		if(give_special_equipment)
			give_equipment()
		if(remove_clown_mut && owner.assigned_role == "Clown")
			var/mob/living/carbon/human/H = owner.current
			H << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			H.dna.remove_mutation(CLOWNMUT)
		apply_innate_effects()

/datum/antagonist/proc/on_removal()
	remove_innate_effects()
	if(owner)
		owner.antag_datums -= src
		if(!silent && owner.current)
			farewell()
	qdel(src)

/datum/antagonist/proc/greet()
	if(text_on_gain)
		owner.current << text_on_gain
	if(has_objectives)
		var/obj_count = 1
		for(var/i in current_objectives)
			var/datum/objective/current = i
			owner.current << "<b>Objective #[obj_count]</b>: [current.explanation_text]"
			obj_count++

/datum/antagonist/proc/farewell()
	owner.current << text_on_lose

/datum/antagonist/proc/give_equipment()
	return

/datum/antagonist/proc/remove_equipment()
	return

/datum/antagonist/proc/generate_objectives()
	return

/datum/antagonist/proc/wipe_objectives()
	for(var/o in current_objectives)
		current_objectives -= o
		qdel(o)
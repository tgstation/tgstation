/datum/action/cooldown/borer/evolution_tree
	name = "Open Evolution Tree"
	button_icon_state = "newability"
	ability_explanation = "\
	Allows you to evolve essential to survive abilities.\n\
	Beware, as evolving a tier 3 path will lock you out of all other tier 3 paths.\n\
	- The Diveworm path focuses on killing hosts, and making eggs in their corpses.\n\
	- The Hivelord path focuses on making lots of eggs.\n\
	- The Symbiote path focuses on helping their host, for mutual benefit.\n\
	"

/datum/action/cooldown/borer/evolution_tree/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	ui_interact(owner)

/datum/action/cooldown/borer/evolution_tree/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorerEvolution", name)
		ui.open()

/datum/action/cooldown/borer/evolution_tree/ui_data(mob/user)
	var/list/data = list()

	var/static/list/path_to_color = list(
		BORER_EVOLUTION_DIVEWORM = "red",
		BORER_EVOLUTION_HIVELORD = "purple",
		BORER_EVOLUTION_SYMBIOTE = "green",
		BORER_EVOLUTION_GENERAL = "label",
	)

	var/mob/living/basic/cortical_borer/cortical_owner = owner

	data["evolution_points"] = cortical_owner.stat_evolution

	for(var/datum/borer_evolution/evolution as anything in cortical_owner.get_possible_evolutions())
		if(evolution in cortical_owner.past_evolutions)
			continue

		var/list/evo_data = list()

		evo_data["path"] = evolution
		evo_data["name"] = initial(evolution.name)
		evo_data["desc"] = initial(evolution.desc)
		evo_data["gainFlavor"] = initial(evolution.gain_text)
		evo_data["cost"] = initial(evolution.evo_cost)
		evo_data["disabled"] = ((initial(evolution.evo_cost) > cortical_owner.stat_evolution) || (initial(evolution.mutually_exclusive) && cortical_owner.genome_locked))
		evo_data["evoPath"] = initial(evolution.evo_type)
		evo_data["color"] = path_to_color[initial(evolution.evo_type)] || "grey"
		evo_data["tier"] = initial(evolution.tier)
		evo_data["exclusive"] = initial(evolution.mutually_exclusive)

		data["learnableEvolution"] += list(evo_data)

	for(var/path in cortical_owner.past_evolutions)
		var/list/evo_data = list()
		var/datum/borer_evolution/found_evolution = cortical_owner.past_evolutions[path]
		if(cortical_owner.neutered && found_evolution.skip_for_neutered)
			continue

		evo_data["name"] = found_evolution.name
		evo_data["desc"] = found_evolution.desc
		evo_data["gainFlavor"] = found_evolution.gain_text
		evo_data["cost"] = found_evolution.evo_cost
		evo_data["evoPath"] = found_evolution.evo_type
		evo_data["color"] = path_to_color[found_evolution.evo_type] || "grey"
		evo_data["tier"] = found_evolution.tier

		data["learnedEvolution"] += list(evo_data)
	return data

/datum/action/cooldown/borer/evolution_tree/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	switch(action)
		if("evolve")
			var/datum/borer_evolution/to_evolve_path = text2path(params["path"])
			if(!ispath(to_evolve_path))
				CRASH("Cortical borer attempted to evolve with a non-evolution path! (Got: [to_evolve_path])")

			if(initial(to_evolve_path.evo_cost) > cortical_owner.stat_evolution)
				return
			if(initial(to_evolve_path.mutually_exclusive) && cortical_owner.genome_locked)
				return
			if(!cortical_owner.do_evolution(to_evolve_path))
				return

			cortical_owner.stat_evolution -= initial(to_evolve_path.evo_cost)
			return TRUE

/datum/action/cooldown/borer/evolution_tree/ui_state(mob/user)
	return GLOB.always_state

/datum/borer_evolution
	/// Name of the evolution
	var/name = ""
	/// Description of the evolution
	var/desc = ""
	/// Cost to get the evolution
	var/evo_cost = 2 // T5 cost 3 points instead of 2
	/// Text to show the borer when they evolve
	var/gain_text = ""
	/// What evolution genome this is
	var/evo_type = BORER_EVOLUTION_GENERAL
	/// If TRUE, this is an evolution that locks out other evolutions of the same tier & above but in different genomes
	var/mutually_exclusive = FALSE
	/// What numerical tier is this? (Doesn't affect anything mechanically)
	var/tier = 0

	/// What evolutions this one unlocks
	var/list/unlocked_evolutions = list()
	/// What action does this evolution unlock
	var/added_action = FALSE
	/// If TRUE neutered borers wont be able to get an action button from this, but will still be able to progress through the evolution tree
	var/restricted_for_neutered = FALSE

/// What happens when a borer gets this evolution
/datum/borer_evolution/proc/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	SHOULD_CALL_PARENT(TRUE)
	if(mutually_exclusive)
		cortical_owner.genome_locked = TRUE
	if(gain_text)
		to_chat(cortical_owner, span_notice("<span class='italics'>[gain_text]</span>"))

	if(restricted_for_neutered)
		if(istype(cortical_owner, /mob/living/basic/cortical_borer/neutered))
			to_chat(cortical_owner, span_danger("<span class='italics'>You didnt manage to properly evolve, you feel a strange sensation.</span>"))
			return
	if(added_action)
		var/datum/action/cooldown/borer/new_action = new added_action(cortical_owner)
		new_action.Grant(cortical_owner)

/datum/borer_evolution/base
	name = "The Beginning"
	desc = "The start of a great age."
	gain_text = "The worms, which we came to call \"Cortical Borers\", are fascinating creatures."
	evo_cost = 0
	evo_type = BORER_EVOLUTION_START
	tier = 0
	unlocked_evolutions = list(
		/datum/borer_evolution/upgrade_injection,
		/datum/borer_evolution/symbiote/willing_host,
		/datum/borer_evolution/hivelord/produce_offspring,
		/datum/borer_evolution/diveworm/health_per_level,
	)

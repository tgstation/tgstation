/** 
 * A ordnance experiment datum. What gives the science in the first place.
 * One is instantiated by the techweb, another one is also kept on SSresearch for the briefing.
 * A disk should contain several of these in a list. Only one should get picked for the final paper.
 */
/datum/experiment/ordnance
	name = "Toxin Research"
	description = "An experiment conducted in the ordnance subdepartment."
	exp_tag = "ordnance"
	performance_hint = "Perform research experiments in the ordnance lab and publish them with NT Frontier."
	/// Lookup experiments are initialized using subtypes, 
	/// this lets us ignore the ones made for subtyping.
	var/experiment_proper = FALSE
	/// Projected gain from an experiment. In list form, indexed = tier.
	var/list/gain
	/// The variable that influences the point equation; Determines when you get the most bang for your buck
	/// More rigorously, this is the middle of the derivative bell curve.
	/// In list form, indexed = tier.
	var/list/target_amount

/datum/experiment/ordnance/is_complete()
	return completed 
		
/datum/experiment/ordnance/check_progress()
	var/status_message = "You must publish a paper on [name] using the NT Frontier app"
	. += EXPERIMENT_PROG_BOOL(status_message, is_complete())

/datum/experiment/ordnance/actionable(datum/component/experiment_handler/experiment_handler)
	return !is_complete()

/datum/experiment/ordnance/explosive
	/// Typepath to gas reactions that we want. Empty if we do not require any at all or don't want any.
	var/list/required_reactions
	/// Whether we only accept explosions with reactions that we set in src.required_reactions or do we allow other reactions in.
	var/sanitized_reactions = FALSE
	/// Whether we want everything in required_reactions to be fulfilled, or only one is needed.
	var/require_all = TRUE
	/// Whether we want a clear misc or not.
	var/sanitized_misc = TRUE
	/** 
	 * Whether we allow bombs without properly filled reaction_results or not. 
	 * Setting this to true means the experiment will always pass the cause and effect check.
	 */
	var/allow_any_source = FALSE

/datum/experiment/ordnance/gaseous
	/// Typepath to the gas we require for the experiment. 
	var/required_gas

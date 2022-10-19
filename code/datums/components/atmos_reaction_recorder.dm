
/**
 * Component for atmos-related atoms to be able to record and transmit their reaction_results data
 * Use this ONLY for atoms, gasmixtures will be accessed by calling return air on the object.
 * Add this component after gasmixes has been initialized.
 */
/datum/component/atmos_reaction_recorder
	/// The list we write append each reaction tick to. 
	/// This is often a list initialized by something else (passed as a reference under Initialize).
	var/list/copied_reaction_results
	/// Signals we have been listening to.
	var/list/registered_signals

/** 
 * Verify that parent is indeed an atom, and then register signals.
 * Args:
 * - target_list (list): The list we are writing the captured reaction_results to.
 * - reset_criteria (list): Assoc signal-source list containing signals to be registered to. We will reset if any of them are sent.
 */
/datum/component/atmos_reaction_recorder/Initialize(list/target_list=list(), list/reset_criteria = list())
	. = ..()

	var/atom/parent_atom = parent
	var/datum/gas_mixture/parent_air = parent_atom?.return_air()
	if((!istype(parent_atom) || !istype(parent_air)))
		return COMPONENT_INCOMPATIBLE

	if(islist(target_list))
		copied_reaction_results = target_list
	else
		// Still can record reactions without a list, but it most likely wont be accesible outside of the component.
		stack_trace("Atmos reaction recorder component initialized without a list.")
		copied_reaction_results = list()

	registered_signals = list()
	RegisterSignal(parent_air, COMSIG_GASMIX_REACTED, .proc/update_data)
	registered_signals += list(COMSIG_GASMIX_REACTED = parent_air)

	for(var/signal in reset_criteria)
		// We currently dont implement the same signal registered twice even from different sources. This allows this component to be simpler.
		if(signal in registered_signals)
			return COMPONENT_INCOMPATIBLE
		RegisterSignal(reset_criteria[signal], signal, .proc/reset_data)
		registered_signals[signal] = reset_criteria[signal]

/// Fetches reaction_results and updates the list.
/datum/component/atmos_reaction_recorder/proc/update_data(datum/gas_mixture/recorded_gasmix)
	SIGNAL_HANDLER
	for (var/reaction in recorded_gasmix.reaction_results)
		copied_reaction_results[reaction] += recorded_gasmix.reaction_results[reaction]

/datum/component/atmos_reaction_recorder/proc/reset_data()
	SIGNAL_HANDLER
	copied_reaction_results.Cut()

/datum/component/atmos_reaction_recorder/UnregisterFromParent()
	. = ..()
	for(var/signal in registered_signals)
		UnregisterSignal(registered_signals[signal], signal)

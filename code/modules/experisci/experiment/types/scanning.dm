/**
 * # Scanning Experiment
 *
 * This is the base implementation of scanning experiments.
 *
 * This class should be subclassed for producing actual experiments. The
 * procs should be extended where necessary.
 */
/datum/experiment/scanning
	name = "Scanning Experiment"
	description = "Base experiment for scanning atoms"
	exp_tag = "Scan"
	allowed_experimentors = list(/obj/item/experi_scanner, /obj/machinery/destructive_scanner)
	performance_hint = "Perform scanning experiments using a handheld experi-scanner, or the stationary experimental destructive scanner. \
						Destructive scans can only be performed with the experimental destructive scanner."
	/// The typepaths and number of atoms that must be scanned
	var/list/required_atoms = list()
	/// The list of atoms with sub-lists of atom references for scanned atoms contributing to the experiment (Or a count of atoms destoryed for destructive expiriments)
	var/list/scanned = list()
	/// If set, it'll be used in place of the generic "Scan samples of \a [initial(target.name)]" in serialize_progress_stage()
	var/scan_message

/**
 * Initializes the scanned atoms lists
 *
 * Initializes the internal scanned atoms list to keep track of which atoms have already been scanned
 */
/datum/experiment/scanning/New(datum/techweb/techweb)
	. = ..()
	for (var/req_atom in required_atoms)
		scanned[req_atom] = (traits & EXPERIMENT_TRAIT_DESTRUCTIVE && !(traits & EXPERIMENT_TRAIT_TYPECACHE)) ? 0 : list()

/**
 * Checks if the scanning experiment is complete
 *
 * Returns TRUE/FALSE as to if the necessary number of atoms have been scanned.
 */
/datum/experiment/scanning/is_complete()
	. = TRUE
	var/destructive = traits & EXPERIMENT_TRAIT_DESTRUCTIVE
	var/typecache = traits & EXPERIMENT_TRAIT_TYPECACHE
	for (var/req_atom in required_atoms)
		var/list/seen = scanned[req_atom]
		///typecache experiments work all the same whether it's destructive or not
		if(typecache && length(seen) == required_atoms[req_atom])
			continue
		if (destructive && (!(req_atom in scanned) || scanned[req_atom] != required_atoms[req_atom]))
			return FALSE
		if (!destructive && (!seen || seen.len != required_atoms[req_atom]))
			return FALSE

/**
 * Gets the number of atoms that have been scanned and the goal
 *
 * This proc returns a string describing the number of atoms that
 * have been scanned as well as the target number of atoms.
 */
/datum/experiment/scanning/check_progress()
	. = list()
	for (var/atom_type in required_atoms)
		var/atom/required_atom = atom_type
		var/list/seen_instances = scanned[required_atom]
		. += serialize_progress_stage(required_atom, seen_instances)

/**
 * Serializes a progress stage into a list to be sent to the UI
 *
 * Arguments:
 * * target - The targeted atom for this progress stage
 * * seen_instances - The number of instances seen of this atom
 */
/datum/experiment/scanning/proc/serialize_progress_stage(atom/target, list/seen_instances)
	var/scanned_total = (traits & EXPERIMENT_TRAIT_DESTRUCTIVE && !(traits & EXPERIMENT_TRAIT_TYPECACHE)) ? scanned[target] : seen_instances.len
	var/message = scan_message || "Scan samples of \a [initial(target.name)]"
	return EXPERIMENT_PROG_INT(message, scanned_total, required_atoms[target])

/**
 * Attempts to scan an atom towards the experiment's goal
 *
 * This proc attempts to scan an atom towards the experiment's goal,
 * and returns TRUE/FALSE based on success.
 * Arguments:
 * * target - The atom to attempt to scan
 */
/datum/experiment/scanning/perform_experiment_actions(datum/component/experiment_handler/experiment_handler, atom/target)
	var/contributing_index_value = experiment_requirements(experiment_handler, target)
	if (!isnull(contributing_index_value))
		if(traits & EXPERIMENT_TRAIT_TYPECACHE)
			scanned[contributing_index_value][target.type] = TRUE
		else
			scanned[contributing_index_value] += traits & EXPERIMENT_TRAIT_DESTRUCTIVE ? 1 : WEAKREF(target)
		if(traits & EXPERIMENT_TRAIT_DESTRUCTIVE && !isliving(target))//only qdel things when destructive scanning and they're not living (living things get gibbed)
			qdel(target)
		do_after_experiment(target, contributing_index_value)
		return TRUE

/datum/experiment/scanning/actionable(datum/component/experiment_handler/experiment_handler, atom/target)
	return ..() && !isnull(experiment_requirements(experiment_handler, target))

/**
 * Attempts to get the typepath for an atom that would contribute to the experiment
 *
 * This proc checks the required atoms for a typepath that this target atom can contribute to
 * and if found returns that typepath, otherwise returns null
 * Arguments:
 * * target - The atom to attempt to scan
 */
/datum/experiment/scanning/proc/experiment_requirements(datum/component/experiment_handler/experiment_handler, atom/target)
	var/destructive = (traits & EXPERIMENT_TRAIT_DESTRUCTIVE)
	for (var/req_atom in required_atoms)
		if (!istype(target, req_atom))
			continue
		// Try to select a required atom that this scanned atom would contribute towards
		var/selected
		var/list/seen = scanned[req_atom]
		if (destructive && (req_atom in scanned) && scanned[req_atom] < required_atoms[req_atom])
			selected = req_atom
		else if (!destructive && seen.len < required_atoms[req_atom] && !(WEAKREF(target) in seen))
			selected = req_atom
		// Run any additonal checks if necessary
		if (selected && final_contributing_index_checks(experiment_handler, target, selected))
			return selected

/**
 * Performs any additional checks against the atom being considered for selection as a contributing index
 *
 * This proc is intended to be used to add additional functionality to contributing index checks
 * without having to duplicate the iteration structure of experiment_requirements()
 * Arguments:
 * * target - The atom being scanned
 * * typepath - The typepath (selected index) of the target atom
 */
/datum/experiment/scanning/proc/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, atom/target, typepath)
	return TRUE

/**
 * Performs actions following a successful experiment action
 *
 * This proc is intended to be used to add additional functionality to follow experiment
 * actions without having to change the perform_experiment_actions proc to get access to the
 * selected typepath index
 * Arguments:
 * * target - The atom being scanned
 * * typepath - The typepath (selected index) of the target atom
 */
/datum/experiment/scanning/proc/do_after_experiment(atom/target, typepath)
	return TRUE

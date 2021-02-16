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
	/// The list of atoms with sub-lists of atom references for scanned atoms contributing to the experiment
	var/list/scanned = list()

/**
 * Initializes the scanned atoms lists
 *
 * Initializes the internal scanned atoms list to keep track of which atoms have already been scanned
 */
/datum/experiment/scanning/New()
	. = ..()
	for (var/a in required_atoms)
		scanned[a] = traits & EXP_TRAIT_DESTRUCTIVE ? 0 : list()

/**
 * Checks if the scanning experiment is complete
 *
 * Returns TRUE/FALSE as to if the necessary number of atoms have been
 * scanned.
 */
/datum/experiment/scanning/is_complete()
	. = TRUE
	var/destructive = traits & EXP_TRAIT_DESTRUCTIVE
	for (var/a in required_atoms)
		var/list/seen = scanned[a]
		if (destructive && (!(a in scanned) || scanned[a] != required_atoms[a]))
			return FALSE
		if (!destructive && (!seen || seen.len != required_atoms[a]))
			return FALSE

/**
 * Gets the number of atoms that have been scanned and the goal
 *
 * This proc returns a string describing the number of atoms that
 * have been scanned as well as the target number of atoms.
 */
/datum/experiment/scanning/check_progress()
	. = list()
	for (var/a_type in required_atoms)
		var/atom/a = a_type
		var/list/seen = scanned[a]
		. += serialize_progress_stage(a, seen)

/**
 * Serializes a progress stage into a list to be sent to the UI
 *
 * Arguments:
 * * target - The targeted atom for this progress stage
 * * seen_instances - The number of instances seen of this atom
 */
/datum/experiment/scanning/proc/serialize_progress_stage(atom/target, list/seen_instances)
	var/scanned_total = traits & EXP_TRAIT_DESTRUCTIVE ? scanned[target] : seen_instances.len
	return EXP_PROG_INT("Scan samples of \a [initial(target.name)]", scanned_total, required_atoms[target])

/**
 * Attempts to scan an atom towards the experiment's goal
 *
 * This proc attempts to scan an atom towards the experiment's goal,
 * and returns TRUE/FALSE based on success.
 * Arguments:
 * * target - The atom to attempt to scan
 */
/datum/experiment/scanning/perform_experiment_actions(datum/component/experiment_handler/experiment_handler, atom/target)
	var/idx = get_contributing_index(target)
	if (idx)
		scanned[idx] += traits & EXP_TRAIT_DESTRUCTIVE ? 1 : target
		if(traits & EXP_TRAIT_DESTRUCTIVE && !isliving(target))//only qdel things when destructive scanning and they're not living (living things get gibbed)
			qdel(target)
		do_after_experiment(target, idx)
		return TRUE

/datum/experiment/scanning/actionable(datum/component/experiment_handler/experiment_handler, atom/target)
	. = ..()
	if (.)
		return get_contributing_index(target)

/**
 * Attempts to get the typepath for an atom that would contribute to the experiment
 *
 * This proc checks the required atoms for a typepath that this target atom can contribute to
 * and if found returns that typepath, otherwise returns null
 * Arguments:
 * * target - The atom to attempt to scan
 */
/datum/experiment/scanning/proc/get_contributing_index(atom/target)
	var/destructive = traits & EXP_TRAIT_DESTRUCTIVE
	for (var/a in required_atoms)
		if (!istype(target, a))
			continue

		// Try to select a required atom that this scanned atom would contribute towards
		var/selected
		var/list/seen = scanned[a]
		if (destructive && (a in scanned) && scanned[a] < required_atoms[a])
			selected = a
		else if (!destructive && seen.len < required_atoms[a] && !(target in seen))
			selected = a

		// Run any additonal checks if necessary
		if (selected && final_contributing_index_checks(target, selected))
			return selected

/**
 * Performs any additional checks against the atom being considered for selection as a contributing index
 *
 * This proc is intended to be used to add additional functionality to contributing index checks
 * without having to duplicate the iteration structure of get_contributing_index()
 * Arguments:
 * * target - The atom being scanned
 * * typepath - The typepath (selected index) of the target atom
 */
/datum/experiment/scanning/proc/final_contributing_index_checks(atom/target, typepath)
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

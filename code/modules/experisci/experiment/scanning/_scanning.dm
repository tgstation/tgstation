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
	for (var/a in required_atoms)
		scanned[a] = list()

/**
  * Checks if the scanning experiment is complete
  *
  * Returns TRUE/FALSE as to if the necessary number of atoms have been
  * scanned.
  */
/datum/experiment/scanning/is_complete()
	. = TRUE
	for (var/a in required_atoms)
		var/list/seen = scanned[a]
		if (!seen || seen.len != required_atoms[a])
			return FALSE

/**
  * Gets the number of atoms that have been scanned and the goal
  *
  * This proc returns a string describing the number of atoms that
  * have been scanned as well as the target number of atoms.
  */
/datum/experiment/scanning/check_progress()
	var/total_scanned = 0
	var/required = 0
	for (var/a in required_atoms)
		var/list/seen = scanned[a]
		required += required_atoms[a]
		total_scanned += seen ? seen.len : 0
	return "Scanned [total_scanned] of [required] objects towards the goal."

/**
  * Attempts to scan an atom towards the experiment's goal
  *
  * This proc attempts to scan an atom towards the experiment's goal,
  * and returns TRUE/FALSE based on success.
  * Arguments:
  * * target - The atom to attempt to scan
  */
/datum/experiment/scanning/proc/scan_item(atom/target)
	. = FALSE
	var/idx = get_contributing_index(target)
	if (idx)
		scanned[idx] += target
		return TRUE

/**
  * Attempts to get the typepath for an atom that would contribute to the experiment
  *
  * This proc checks the required atoms for a typepath that this target atom can contribute to
  * and if found returns that typepath, otherwise returns null
  * Arguments:
  * * target - The atom to attempt to scan
  */
/datum/experiment/scanning/proc/get_contributing_index(atom/target)
	. = null
	for (var/a in required_atoms)
		var/list/seen = scanned[a]
		if (istype(target, a) && seen && seen.len < required_atoms[a] && !(target in seen))
			return a

/datum/experiment/scanning/can_sabotage()
	. = ..()

/**
  * Attempts to sabotage the experiment
  *
  * This proc attempts to decrease the scanned atom count by one, and
  * returns TRUE/FALSE based on the success of this operation.
  */
/datum/experiment/scanning/sabotage()
	. = FALSE
	var/list/valid_targets = list()
	for (var/a in scanned)
		var/list/seen = scanned[a]
		if (seen.len > 0)
			valid_targets += a

	if (valid_targets.len > 0)
		var/list/target = scanned[pick(valid_targets)]
		pick_n_take(target)
		return TRUE

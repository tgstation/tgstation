/// Anything with this component will show surgeries performed on them
/// on the operating computer, and optionally provide upgraded surgeries.
/datum/component/links_to_operating_computers
	/// Should this object allow the upgraded surgeries?
	var/provide_upgraded_surgeries = FALSE

	VAR_PRIVATE
		/// Current known patients, in order of least to most recently added
		list/patients = list()

/datum/component/links_to_operating_computers/Initialize(provide_upgraded_surgeries)
	. = ..()

	if (!ismovable(parent))
		stack_trace("Parent must be a movable")
		return COMPONENT_INCOMPATIBLE

	if (!isnull(provide_upgraded_surgeries))
		src.provide_upgraded_surgeries = provide_upgraded_surgeries

/datum/component/links_to_operating_computers/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_movable_moved))
	register_to_loc()

/datum/component/links_to_operating_computers/UnregisterFromParent()
	var/atom/atom_parent = parent

	UnregisterSignal(atom_parent, COMSIG_MOVABLE_MOVED)
	unregister_loc(atom_parent.loc)

	for (var/patient in patients)
		SEND_SIGNAL(src, COMSIG_LINKS_TO_OPERATING_COMPUTERS_PATIENT_REMOVED, patient)

	patients.Cut()

/datum/component/links_to_operating_computers/proc/on_atom_entered(datum/source, mob/living/carbon/enterer)
	SIGNAL_HANDLER

	if (enterer in patients)
		return

	try_add_patient(enterer)

/datum/component/links_to_operating_computers/proc/try_add_patient(atom/potential_patient)
	if (!iscarbon(potential_patient))
		return

	RegisterSignal(potential_patient, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(on_enterer_body_position_changed))
	check_patient(potential_patient)

/datum/component/links_to_operating_computers/proc/on_atom_exited(datum/source, atom/exiter)
	SIGNAL_HANDLER

	if (!iscarbon(exiter))
		return

	UnregisterSignal(exiter, COMSIG_LIVING_SET_BODY_POSITION)
	remove_patient(exiter)

/datum/component/links_to_operating_computers/proc/on_enterer_body_position_changed(mob/living/carbon/source)
	SIGNAL_HANDLER
	check_patient(source)

/datum/component/links_to_operating_computers/proc/check_patient(mob/living/carbon/patient)
	if (patient.body_position == LYING_DOWN && !(patient in patients))
		patients += patient
		SEND_SIGNAL(src, COMSIG_LINKS_TO_OPERATING_COMPUTERS_PATIENT_ADDED, patient)
	else if (patient.body_position == STANDING_UP)
		remove_patient(patient)

/datum/component/links_to_operating_computers/proc/remove_patient(mob/living/carbon/patient)
	if (!(patient in patients))
		return

	patients -= patient
	SEND_SIGNAL(src, COMSIG_LINKS_TO_OPERATING_COMPUTERS_PATIENT_REMOVED, patient)

/datum/component/links_to_operating_computers/proc/on_operating_computer_initialized(datum/source, obj/machinery/computer/operating/operating_computer)
	SIGNAL_HANDLER
	initialize_to_operating_computer(operating_computer)

/datum/component/links_to_operating_computers/proc/initialize_to_operating_computer(obj/machinery/computer/operating/operating_computer)
	// Catch the new operating computer up to speed
	SEND_SIGNAL(operating_computer, COMSIG_LINKS_TO_OPERATING_COMPUTERS_INITIALIZED, src, patients)

/datum/component/links_to_operating_computers/proc/on_movable_moved(datum/source, atom/old_loc)
	SIGNAL_HANDLER

	unregister_loc(old_loc)
	register_to_loc()

/datum/component/links_to_operating_computers/proc/register_to_loc()
	var/atom/atom_parent = parent
	var/atom/loc = atom_parent.loc

	for (var/atom/potential_patient as anything in loc)
		try_add_patient(potential_patient)

	for (var/direction in GLOB.alldirs)
		var/turf/nearby_turf = get_step(loc, direction)
		if (isnull(nearby_turf))
			continue

		RegisterSignal(nearby_turf, COMSIG_OPERATING_COMPUTER_INITIALIZED, PROC_REF(on_operating_computer_initialized))

		for (var/obj/machinery/computer/operating/operating_computer in nearby_turf)
			initialize_to_operating_computer(operating_computer)

	RegisterSignal(loc, COMSIG_ATOM_ENTERED, PROC_REF(on_atom_entered))
	RegisterSignal(loc, COMSIG_ATOM_EXITED, PROC_REF(on_atom_exited))

/datum/component/links_to_operating_computers/proc/unregister_loc(old_loc)
	for (var/direction in GLOB.alldirs)
		var/turf/nearby_turf = get_step(old_loc, direction)
		if (isnull(nearby_turf))
			continue

		UnregisterSignal(nearby_turf, COMSIG_OPERATING_COMPUTER_INITIALIZED)

	for (var/atom/on_old_loc as anything in old_loc)
		UnregisterSignal(on_old_loc, COMSIG_LIVING_SET_BODY_POSITION)

	UnregisterSignal(old_loc, list(
		COMSIG_ATOM_ENTERED,
		COMSIG_ATOM_EXITED,
	))

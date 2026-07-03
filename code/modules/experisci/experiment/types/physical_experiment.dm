/datum/experiment/physical
	name = "Физический эксперимент"
	description = "Эксперимент, требующий физической реакции для продолжения"
	exp_tag = "Физ. Эксперимент"
	performance_hint = "Для проведения физических экспериментов вам необходимо использовать ручной сканер для отслеживания объектов, относящиеся к \
		вашему эксперименту. Активируйте эксперимент на своем сканере, отсканируйте объект для отслеживания, а затем выполните поставленную задачу."
	/// The atom that is currently being watched by this experiment
	var/atom/currently_scanned_atom
	/// Linked experiment handler
	var/datum/component/experiment_handler/linked_experiment_handler

/datum/experiment/physical/is_complete()
	return completed

/datum/experiment/physical/perform_experiment_actions(datum/component/experiment_handler/experiment_handler, atom/target)
	if(currently_scanned_atom)
		unregister_events()
	currently_scanned_atom = target
	linked_experiment_handler = experiment_handler
	if(register_events())
		return TRUE
	currently_scanned_atom = null
	linked_experiment_handler = null
	return FALSE

/**
 * Handles registering to events relevant to the experiment
 */
/datum/experiment/physical/proc/register_events()
	return FALSE

/**
 * Handles unregistering to events relevant to the experiment
 */
/datum/experiment/physical/proc/unregister_events()
	return

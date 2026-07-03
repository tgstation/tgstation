#define JOB_SLOT_RANDOMISED_SLOT -1
#define JOB_SLOT_CURRENT_SLOT 0
#define JOB_SLOT_RANDOMISED_TEXT "Случайное имя и внешность"
#define JOB_SLOT_CURRENT_TEXT "Текущий слот"

/datum/preferences
	/// Assoc list of [job title] = [slot number]. Stores which character slot to use for each job.
	var/list/pref_job_slots = list()

/**
 * Generates available slot selection options
 *
 * Returns associative list of slot IDs to display names, including:
 * - Current slot
 * - All saved character slots
 * - Randomized appearance option
 *
 * Format: list("[slot_id]" = "[display_name]")
 */
/datum/preferences/proc/get_slot_options()
	var/list/slot_options = list(num2text(JOB_SLOT_CURRENT_SLOT) = JOB_SLOT_CURRENT_TEXT)
	var/real_name = read_preference(/datum/preference/name/real_name)
	for(var/index in 1 to max_save_slots)
		var/slot_name = (index == default_slot) \
			? real_name \
			: savefile.get_entry("character[index]")?["real_name"]

		if(slot_name)
			slot_options[num2text(index)] = slot_name

	return slot_options += list(num2text(JOB_SLOT_RANDOMISED_SLOT) = JOB_SLOT_RANDOMISED_TEXT)

/// Resets pref_job_slots to empty list and saves preferences
/datum/preferences/proc/reset_job_slots()
	pref_job_slots = list()
	save_preferences()

/**
 * Loads assigned character slot for a job
 *
 * Loads appropriate character slot for the given job as assigned in preferences,
 *
 * Arguments:
 * * job_title - Job title to load configuration for
 * * is_late_join - Whether this is for late join
 *
 * Returns TRUE if randomized appearance should be used
 */
/datum/preferences/proc/set_assigned_slot(job_title, is_late_join = FALSE)
	if(is_late_join ? read_preference(/datum/preference/toggle/late_join_always_current_slot) : read_preference(/datum/preference/toggle/round_start_always_join_current_slot))
		return
	var/slot = pref_job_slots[job_title] || JOB_SLOT_CURRENT_SLOT
	switch(slot)
		if(JOB_SLOT_RANDOMISED_SLOT)
			return TRUE
		if(JOB_SLOT_CURRENT_SLOT)
			return

	if(slot != default_slot)
		switch_to_slot(slot)

/// Whether joining at roundstart ignores assigned character slot for the job and uses currently selected slot.
/datum/preference/toggle/round_start_always_join_current_slot
	savefile_key = "round_start_always_join_current_slot"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

/// Whether joining during the round ignores assigned character slot for the job and uses currently selected slot.
/datum/preference/toggle/late_join_always_current_slot
	savefile_key = "late_join_always_current_slot"
	savefile_identifier = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

#undef JOB_SLOT_RANDOMISED_TEXT
#undef JOB_SLOT_CURRENT_TEXT

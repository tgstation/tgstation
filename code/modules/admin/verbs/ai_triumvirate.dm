
///global reference to the current theme, if there is one.
GLOBAL_DATUM(triple_ai_controller, /datum/triple_ai_controller)

/**
 * The triple ai controller handles the admin triple AI mode, if enabled.
 * It is first created when "Toggle AI Triumvirate" triggers it, and it can be referenced from GLOB.triple_ai_controller
 * After it handles roundstart business, it cleans itself up.
 */
/datum/triple_ai_controller

/datum/triple_ai_controller/New()
	. = ..()
	RegisterSignal(SSjob, COMSIG_OCCUPATIONS_DIVIDED, PROC_REF(on_occupations_divided))

/datum/triple_ai_controller/proc/on_occupations_divided(datum/source)
	SIGNAL_HANDLER

	for(var/datum/job/ai/ai_datum in SSjob.joinable_occupations)
		ai_datum.spawn_positions = 3
	for(var/obj/effect/landmark/start/ai/secondary/secondary_ai_spawn in GLOB.start_landmarks_list)
		secondary_ai_spawn.latejoin_active = TRUE
	qdel(src)

/datum/triple_ai_controller/Destroy(force)
	UnregisterSignal(SSjob, COMSIG_OCCUPATIONS_DIVIDED)
	GLOB.triple_ai_controller = null
	. = ..()

ADMIN_VERB(events, toggle_ai_triumvirate, "Toggle AI Triumvirate", "", R_FUN)
	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(usr, "This option is currently only usable during pregame. This may change at a later date.", confidential = TRUE)
		return

	var/datum/job/job = SSjob.GetJobType(/datum/job/ai)
	if(!job)
		to_chat(usr, "Unable to locate the AI job", confidential = TRUE)
		CRASH("triple_ai() called, no /datum/job/ai to be found.")

	if(!GLOB.triple_ai_controller)
		GLOB.triple_ai_controller = new()
	else
		QDEL_NULL(GLOB.triple_ai_controller)
	to_chat(usr, "There will[GLOB.triple_ai_controller ? "" : "not"] be an AI Triumvirate at round start.")
	message_admins(span_adminnotice("[key_name_admin(usr)] has toggled [GLOB.triple_ai_controller ? "on" : "off"] triple AIs at round start."))

/**
 * A station trait which enables a temporary job
 * Generally speaking these should always all be mutually exclusive, don't have too many at once
 */
/datum/station_trait/job
	sign_up_button = TRUE
	abstract_type = /datum/station_trait/job
	/// What tooltip to show on the button
	var/button_desc = "Sign up to gain some kind of unusual job, not available in most rounds."
	/// Type of job to enable
	var/job_to_add = /datum/job/clown
	/// Who signed up to this in the lobby
	var/list/lobby_candidates

/datum/station_trait/job/New()
	. = ..()
	blacklist += subtypesof(/datum/station_trait/job) - type // All but ourselves
	RegisterSignal(SSdcs, COMSIG_GLOB_PRE_JOBS_ASSIGNED, PROC_REF(pre_jobs_assigned))

/datum/station_trait/job/setup_lobby_button(atom/movable/screen/lobby/button/sign_up/lobby_button)
	RegisterSignal(lobby_button, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_lobby_button_update_overlays))
	lobby_button.desc = button_desc
	return ..()

/datum/station_trait/job/on_lobby_button_click(atom/movable/screen/lobby/button/sign_up/lobby_button, location, control, params, mob/dead/new_player/user)
	if (LAZYFIND(lobby_candidates, user))
		LAZYREMOVE(lobby_candidates, user)
	else
		LAZYADD(lobby_candidates, user)

/datum/station_trait/job/on_lobby_button_update_icon(atom/movable/screen/lobby/button/sign_up/lobby_button, updates)
	if (LAZYFIND(lobby_candidates, lobby_button.get_mob()))
		lobby_button.base_icon_state = "signup_on"
	else
		lobby_button.base_icon_state = "signup"

/// Add an overlay based on whether you are actively signed up for this role
/datum/station_trait/job/proc/on_lobby_button_update_overlays(atom/movable/screen/lobby/button/sign_up/lobby_button, list/overlays)
	SIGNAL_HANDLER
	overlays += LAZYFIND(lobby_candidates, lobby_button.get_mob()) ? "tick" : "cross"

/// Called before we start assigning roles, assign ours first
/datum/station_trait/job/proc/pre_jobs_assigned()
	SIGNAL_HANDLER
	sign_up_button = FALSE
	destroy_lobby_buttons()
	for (var/mob/dead/new_player/signee as anything in lobby_candidates)
		if (isnull(signee) || !signee.client || !signee.mind || signee.ready != PLAYER_READY_TO_PLAY)
			LAZYREMOVE(lobby_candidates, signee)
	if (!LAZYLEN(lobby_candidates))
		on_failed_assignment()
		return // Nobody signed up :(
	var/mob/dead/new_player/picked_player = pick(lobby_candidates)
	picked_player.mind.assigned_role = new job_to_add()
	lobby_candidates = null

/// Called if we didn't assign a role before the round began, we add it to the latejoin menu instead
/datum/station_trait/job/proc/on_failed_assignment()
	var/datum/job/our_job = job_to_add
	our_job = SSjob.GetJob(our_job::title)
	our_job.total_positions++


/// Adds a gorilla to the cargo department, replacing the sloth and the mech
/datum/station_trait/job/cargorilla
	name = "Cargo Gorilla"
	button_desc = "Sign up to become the Cargo Gorilla, a peaceful shepherd of boxes."
	weight = 1
	show_in_report = FALSE // Selective attention test. Did you spot the gorilla?
	job_to_add = /datum/job/cargo_gorilla

/datum/station_trait/job/cargorilla/New()
	. = ..()
	RegisterSignal(SSatoms, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(replace_cargo))

/datum/station_trait/job/cargorilla/on_lobby_button_update_overlays(atom/movable/screen/lobby/button/sign_up/lobby_button, list/overlays)
	. = ..()
	overlays += LAZYFIND(lobby_candidates, lobby_button.get_mob()) ? "gorilla_on" : "gorilla_off"

/// Remove the cargo equipment and personnel that are being replaced by a gorilla.
/datum/station_trait/job/cargorilla/proc/replace_cargo(datum/source)
	SIGNAL_HANDLER
	var/mob/living/basic/sloth/cargo_sloth = GLOB.cargo_sloth
	if(isnull(cargo_sloth))
		lobby_candidates = list()
		destroy_lobby_buttons() // Sorry folks
		sign_up_button = FALSE
		return

	// hmm our sloth looks funny today
	qdel(cargo_sloth)
	// monkey carries the crates, the age of robot is over
	if(GLOB.cargo_ripley)
		qdel(GLOB.cargo_ripley)

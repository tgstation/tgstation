/**
 * # Experiment Handler
 *
 * This is the component for interacting with experiments from a connected techweb. It is generic
 * and should be set-up to automatically work on any class it is attached to without outside code
 * (Excluding potential callbacks)
 */
/datum/component/experiment_handler
	/// Holds the currently linked techweb to get experiments from
	var/datum/techweb/linked_web
	/// Holds the currently selected experiment
	var/datum/experiment/selected_experiment
	/// Holds the list of types of experiments that this experiment_handler can interact with
	var/list/allowed_experiments
	/// Holds the list of types of experiments that this experimennt_handler should NOT interact with
	var/list/blacklisted_experiments
	/// A set of optional experiment traits (see defines) that are disallowed for any experiments
	var/disallowed_traits
	/// Additional configuration flags for how the experiment_handler operates
	var/config_flags
	/// Callback that, when supplied, can be called from the UI
	var/datum/callback/start_experiment_callback

/**
 * Initializes a new instance of the experiment_handler component
 *
 * Arguments:
 * * allowed_experiments - The list of /datum/experiment types that can be performed with this component
 * * blacklisted_experiments - The list of /datum/experiment types that explicitly cannot be performed with this component
 * * config_mode - The define that determines how the experiment_handler should display the configuration UI
 * * disallowed_traits - Flags that control what experiment traits are blacklisted by this experiment handler
 * * config_flags - Flags that control the operational behaviour of the experiment handler, see experiment defines
 * * start_experiment_callback - When provided adds a UI button to use this callback to the start the experiment
 */
/datum/component/experiment_handler/Initialize(allowed_experiments = list(),
	blacklisted_experiments = list(),
	config_mode = EXPERIMENT_CONFIG_ATTACKSELF,
	disallowed_traits = null,
	config_flags = null,
	datum/callback/start_experiment_callback = null,
	list/experiment_signals
)
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.allowed_experiments = allowed_experiments
	src.blacklisted_experiments = blacklisted_experiments
	src.disallowed_traits = disallowed_traits
	src.config_flags = config_flags
	src.start_experiment_callback = start_experiment_callback

	for(var/signal in experiment_signals)
		RegisterSignal(parent, signal, experiment_signals[signal])

	// Determine UI display mode
	switch(config_mode)
		if(EXPERIMENT_CONFIG_ATTACKSELF)
			RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(configure_experiment))
		if(EXPERIMENT_CONFIG_ALTCLICK)
			RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(configure_experiment))
		if(EXPERIMENT_CONFIG_CLICK)
			RegisterSignal(parent, COMSIG_ATOM_UI_INTERACT, PROC_REF(configure_experiment_click))
		if(EXPERIMENT_CONFIG_UI)
			RegisterSignal(parent, COMSIG_UI_ACT, PROC_REF(ui_handle_experiment))

	// Auto connect to the first visible techweb (useful for always active handlers)
	// Note this won't work at the moment for non-machines that have been included
	// on the map as the servers aren't initialized when the non-machines are initializing
	if (!(config_flags & EXPERIMENT_CONFIG_NO_AUTOCONNECT))
		CONNECT_TO_RND_SERVER_ROUNDSTART(linked_web, parent)

	GLOB.experiment_handlers += src

/datum/component/experiment_handler/Destroy(force)
	. = ..()
	GLOB.experiment_handlers -= src

/**
 * Hooks on attack to try and run an experiment (When using a handheld handler)
 */
/datum/component/experiment_handler/proc/try_run_handheld_experiment(datum/source, atom/target, mob/user, params)
	SIGNAL_HANDLER
	if (!should_run_handheld_experiment(source, target, user))
		return
	INVOKE_ASYNC(src, PROC_REF(try_run_handheld_experiment_async), source, target, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * Provides feedback when an item isn't related to an experiment, and has fully passed the attack chain
 */
/datum/component/experiment_handler/proc/ignored_handheld_experiment_attempt(datum/source, atom/target, mob/user, params)
	SIGNAL_HANDLER
	if ((isnull(selected_experiment) && !(config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE)) || (config_flags & EXPERIMENT_CONFIG_SILENT_FAIL))
		return
	playsound(user, 'sound/machines/buzz/buzz-sigh.ogg', 25)
	to_chat(user, span_notice("[target] is not related to your currently selected experiment."))

/**
 * Checks that an experiment can be run using the provided target, used for preventing the cancellation of the attack chain inappropriately
 */
/datum/component/experiment_handler/proc/should_run_handheld_experiment(datum/source, atom/target, mob/user)
	// Check that there is actually an experiment selected
	if (selected_experiment == null && !(config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE))
		return
	if (!linked_web)
		return

	// Determine if this experiment is actionable with this target
	var/list/arguments = list(src)
	arguments = args.len > 1 ? arguments + args.Copy(2) : arguments
	if (config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE)
		for (var/datum/experiment/experiment in linked_web.available_experiments)
			if (experiment.actionable(arglist(arguments)))
				return TRUE
	else
		return selected_experiment.actionable(arglist(arguments))

/**
 * This proc exists because Jared Fogle really likes async
 */
/datum/component/experiment_handler/proc/try_run_handheld_experiment_async(datum/source, atom/target, mob/user)
	if (selected_experiment == null && !(config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE))
		if(!(config_flags & EXPERIMENT_CONFIG_SILENT_FAIL))
			to_chat(user, span_notice("You do not have an experiment selected!"))
		return
	if(!(config_flags & EXPERIMENT_CONFIG_IMMEDIATE_ACTION) && !do_after(user, 1 SECONDS, target = target))
		return
	if(action_experiment(source, target))
		playsound(user, 'sound/machines/ping.ogg', 25)
		to_chat(user, span_notice("You scan [target]."))
	else if(!(config_flags & EXPERIMENT_CONFIG_SILENT_FAIL))
		playsound(user, 'sound/machines/buzz/buzz-sigh.ogg', 25)
		to_chat(user, span_notice("[target] is not related to your currently selected experiment."))

/**
 * Hooks on destructive scans to try and run an experiment (When using a handheld handler)
 */
/datum/component/experiment_handler/proc/try_run_destructive_experiment(datum/source, list/scanned_atoms)
	SIGNAL_HANDLER
	var/atom/movable/our_scanner = parent
	if (selected_experiment == null)
		if(!(config_flags & EXPERIMENT_CONFIG_SILENT_FAIL))
			playsound(our_scanner, 'sound/machines/buzz/buzz-sigh.ogg', 25)
			to_chat(our_scanner, span_notice("No experiment selected!"))
		return
	var/successful_scan
	for(var/scan_target in scanned_atoms)
		if(action_experiment(source, scan_target))
			successful_scan = TRUE
	if(successful_scan)
		playsound(our_scanner, 'sound/machines/ping.ogg', 25)
		to_chat(our_scanner, span_notice("The scan succeeds."))
	else if(!(config_flags & EXPERIMENT_CONFIG_SILENT_FAIL))
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 25)
		our_scanner.say("The scan did not result in anything.")

/// Hooks on a successful autopsy experiment
/datum/component/experiment_handler/proc/try_run_autopsy_experiment(obj/source, mob/living/target)
	SIGNAL_HANDLER

	if (action_experiment(source, target))
		playsound(source, 'sound/machines/ping.ogg', 25)
		source.say("New unique autopsy successfully catalogued.")


/**
 * Announces a message to all experiment handlers
 *
 * Arguments:
 * * message - The message to announce
 */
/datum/component/experiment_handler/proc/announce_message_to_all(message)
	for(var/datum/component/experiment_handler/experi_handler as anything in GLOB.experiment_handlers)
		if(experi_handler.linked_web != linked_web)
			continue
		var/atom/movable/experi_parent = experi_handler.parent
		experi_parent.say(message)

/**
 * Announces a message to this experiment handler
 *
 * Arguments:
 * * message - The message to announce
 */
/datum/component/experiment_handler/proc/announce_message(message)
	var/atom/movable/experi_parent = parent
	experi_parent.say(message)

/**
 * Attempts to perform the selected experiment given some arguments
 */
/datum/component/experiment_handler/proc/action_experiment(datum/source, ...)
	// Check if an experiment is selected
	if (selected_experiment == null && !(config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE))
		return FALSE

	// Get arguments for passing to the experiment[s]
	var/list/arguments = list(src)
	arguments = args.len > 1 ? arguments + args.Copy(2) : arguments

	// Check if this handler is configured to be always active, in which case we
	// attempt to action every experiment that is available to this handler.
	if (config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE)
		var/any_success
		for (var/datum/experiment/experiment in linked_web.available_experiments)
			// Because this checks any experiment, we have to ensure it is allowable to be selected with can_select_experiment(...)
			// this handles the handler's blacklist, whitelist, etc (potentially refactor this in the future if possible because this could be expensive)
			if (can_select_experiment(experiment) && experiment.actionable(arglist(arguments)) && experiment.perform_experiment(arglist(arguments)))
				any_success = TRUE
		return any_success
	else
		// Returns true if the experiment was successfuly handled
		return selected_experiment.actionable(arglist(arguments)) && selected_experiment.perform_experiment(arglist(arguments))

/**
 * Hook for handling UI interaction via signals
 */
/datum/component/experiment_handler/proc/ui_handle_experiment(datum/source, mob/user, action)
	SIGNAL_HANDLER
	switch(action)
		if("open_experiments")
			INVOKE_ASYNC(src, PROC_REF(configure_experiment), null, usr)

/**
 * Attempts to show the user the experiment configuration panel
 *
 * Arguments:
 * * user - The user to show the experiment configuration panel to
 */
/datum/component/experiment_handler/proc/configure_experiment(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(ui_interact), user)
	return CLICK_ACTION_SUCCESS

/**
 * Attempts to show the user the experiment configuration panel
 *
 * Arguments:
 * * user - The user to show the experiment configuration panel to
 */
/datum/component/experiment_handler/proc/configure_experiment_click(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, ui_interact), user)

/**
 * Attempts to link this experiment_handler to a provided techweb
 *
 * This proc attempts to link the handler to a provided techweb, overriding the existing techweb if relevant
 *
 * Arguments:
 * * new_web - The new techweb to link to
 */
/datum/component/experiment_handler/proc/link_techweb(datum/techweb/new_web)
	if (new_web == linked_web)
		return
	selected_experiment?.on_unselected(src)
	selected_experiment = null
	linked_web = new_web

/**
 * Unlinks this handler from the selected techweb
 */
/datum/component/experiment_handler/proc/unlink_techweb()
	selected_experiment?.on_unselected(src)
	selected_experiment = null
	linked_web = null

/**
 * Attempts to link this experiment_handler to a provided experiment
 *
 * Arguments:
 * * experiment - The experiment to attempt to link to
 */
/datum/component/experiment_handler/proc/link_experiment(datum/experiment/experiment)
	if (can_select_experiment(experiment))
		unlink_experiment()
		selected_experiment = experiment
		selected_experiment.on_selected(src)

/**
 * Unlinks this handler from the selected experiment
 */
/datum/component/experiment_handler/proc/unlink_experiment()
	selected_experiment?.on_unselected(src)
	selected_experiment = null

/**
 * Checks if an experiment is valid to be selected by this handler
 *
 * Arguments:
 * * experiment - The experiment to check
 */
/datum/component/experiment_handler/proc/can_select_experiment(datum/experiment/experiment)
	// Check that this experiments has no disallowed traits
	if (experiment.traits & disallowed_traits)
		return FALSE

	// Check against the list of allowed experimentors
	if (length(experiment.allowed_experimentors) && !is_type_in_list(parent, experiment.allowed_experimentors))
		return FALSE

	// Check that this experiment is visible currently
	if (!(experiment in linked_web?.available_experiments))
		return FALSE

	// Check that this experiment type isn't blacklisted
	if(is_type_in_list(experiment, blacklisted_experiments))
		return FALSE

	// Finally, check against the allowed experiment types
	return is_type_in_list(experiment, allowed_experiments)

/datum/component/experiment_handler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		var/atom/parent_atom = parent
		ui = new(user, src, "ExperimentConfigure", "[parent_atom ? "[parent_atom.name] | " : ""]Experiment Configuration")
		ui.open()

/datum/component/experiment_handler/ui_data(mob/user)
	. = list(
		"always_active" = (config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE),
		"has_start_callback" = !isnull(start_experiment_callback),
	)
	.["techwebs"] = list()
	for (var/datum/techweb/techwebs as anything in SSresearch.techwebs)
		if(!length(techwebs.techweb_servers)) //no servers, we don't care
			if(techwebs == linked_web) //disconnect if OUR techweb lost their servers.
				unlink_techweb()
			continue
		if(!length(SSresearch.find_valid_servers(get_turf(parent), techwebs)))
			continue
		var/list/data = list(
			web_id = techwebs.id,
			web_org = techwebs.organization,
			selected = (techwebs == linked_web),
			ref = REF(techwebs),
			all_servers = techwebs.techweb_servers,
		)
		.["techwebs"] += list(data)
	.["experiments"] = list()
	if (linked_web)
		for (var/datum/experiment/experiment as anything in linked_web.available_experiments)
			if(!can_select_experiment(experiment))
				continue
			var/list/data = list(
				name = experiment.name,
				description = experiment.description,
				tag = experiment.exp_tag,
				selected = selected_experiment == experiment,
				progress = experiment.check_progress(),
				performance_hint = experiment.performance_hint,
				ref = REF(experiment)
			)
			.["experiments"] += list(data)

/datum/component/experiment_handler/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch (action)
		if ("select_server")
			. = TRUE
			var/datum/techweb/new_techweb = locate(params["ref"])
			if (new_techweb)
				link_techweb(new_techweb)
				return
		if ("clear_server")
			. = TRUE
			unlink_techweb()
		if ("select_experiment")
			. = TRUE
			// Don't allow selection for always actives (no concept of active)
			if (config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE)
				return
			var/datum/experiment/experiment = locate(params["ref"])
			if (experiment)
				link_experiment(experiment)
		if ("clear_experiment")
			. = TRUE
			unlink_experiment()
		if("start_experiment_callback")
			start_experiment_callback.Invoke(selected_experiment)

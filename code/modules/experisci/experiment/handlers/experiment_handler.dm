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
												var/datum/callback/start_experiment_callback = null)
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.allowed_experiments = allowed_experiments
	src.blacklisted_experiments = blacklisted_experiments
	src.disallowed_traits = disallowed_traits
	src.config_flags = config_flags
	src.start_experiment_callback = start_experiment_callback

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, .proc/try_run_handheld_experiment)
		RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/ignored_handheld_experiment_attempt)
	if(istype(parent, /obj/machinery/doppler_array))
		RegisterSignal(parent, COMSIG_DOPPLER_ARRAY_EXPLOSION_DETECTED, .proc/try_run_doppler_experiment)
	if(istype(parent, /obj/machinery/destructive_scanner))
		RegisterSignal(parent, COMSIG_MACHINERY_DESTRUCTIVE_SCAN, .proc/try_run_destructive_experiment)

	// Determine UI display mode
	switch(config_mode)
		if(EXPERIMENT_CONFIG_ATTACKSELF)
			RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/configure_experiment)
		if(EXPERIMENT_CONFIG_ALTCLICK)
			RegisterSignal(parent, COMSIG_CLICK_ALT, .proc/configure_experiment)
		if(EXPERIMENT_CONFIG_CLICK)
			RegisterSignal(parent, COMSIG_ATOM_UI_INTERACT, .proc/configure_experiment_click)
		if(EXPERIMENT_CONFIG_UI)
			RegisterSignal(parent, COMSIG_UI_ACT, .proc/ui_handle_experiment)

	// Auto connect to the first visible techweb (useful for always active handlers)
	// Note this won't work at the moment for non-machines that have been included
	// on the map as the servers aren't initialized when the non-machines are initializing
	if (!(config_flags & EXPERIMENT_CONFIG_NO_AUTOCONNECT))
		var/list/found_servers = get_available_servers(parent)
		var/obj/machinery/rnd/server/s = found_servers.len ? found_servers[1] : null
		if (s)
			link_techweb(s.stored_research)

	GLOB.experiment_handlers += src

/datum/component/experiment_handler/Destroy(force, silent)
	. = ..()
	GLOB.experiment_handlers -= src

/**
 * Hooks on attack to try and run an experiment (When using a handheld handler)
 */
/datum/component/experiment_handler/proc/try_run_handheld_experiment(datum/source, atom/target, mob/user, params)
	SIGNAL_HANDLER
	if (!should_run_handheld_experiment(source, target, user, params))
		return
	INVOKE_ASYNC(src, .proc/try_run_handheld_experiment_async, source, target, user, params)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * Provides feedback when an item isn't related to an experiment, and has fully passed the attack chain
 */
/datum/component/experiment_handler/proc/ignored_handheld_experiment_attempt(datum/source, atom/target, mob/user, proximity_flag, params)
	SIGNAL_HANDLER
	if (!proximity_flag || (selected_experiment == null && !(config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE)))
		return
	playsound(user, 'sound/machines/buzz-sigh.ogg', 25)
	to_chat(user, "<span>\the [target.name] is not related to your currently selected experiment.</span>")

/**
 * Checks that an experiment can be run using the provided target, used for preventing the cancellation of the attack chain inappropriately
 */
/datum/component/experiment_handler/proc/should_run_handheld_experiment(datum/source, atom/target, mob/user, params)
	// Check that there is actually an experiment selected
	if (selected_experiment == null && !(config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE))
		return

	// Determine if this experiment is actionable with this target
	var/list/arguments = list(src)
	arguments = args.len > 1 ? arguments + args.Copy(2) : arguments
	if (config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE)
		for (var/datum/experiment/e in linked_web.available_experiments)
			if (e.actionable(arglist(arguments)))
				return TRUE
	else
		. = selected_experiment.actionable(arglist(arguments))

/**
 * This proc exists because Jared Fogle really likes async
 */
/datum/component/experiment_handler/proc/try_run_handheld_experiment_async(datum/source, atom/target, mob/user, params)
	if (selected_experiment == null && !(config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE))
		to_chat(user, "<span>You do not have an experiment selected!.</span>")
		return
	if(!do_after(user, 10, target = target))
		return
	if(action_experiment(source, target))
		playsound(user, 'sound/machines/ping.ogg', 25)
		to_chat(user, "<span>You scan \the [target.name].</span>")
	else
		playsound(user, 'sound/machines/buzz-sigh.ogg', 25)
		to_chat(user, "<span>\the [target.name] is not related to your currently selected experiment.</span>")


/**
 * Hooks on destructive scans to try and run an experiment (When using a handheld handler)
 */
/datum/component/experiment_handler/proc/try_run_destructive_experiment(datum/source, list/scanned_atoms)
	SIGNAL_HANDLER
	var/atom/movable/our_scanner = parent
	if (selected_experiment == null)
		playsound(our_scanner, 'sound/machines/buzz-sigh.ogg', 25)
		to_chat(our_scanner, "<span>No experiment selected!.</span>")
		return
	var/successful_scan
	for(var/scan_target in scanned_atoms)
		if(action_experiment(source, scan_target))
			successful_scan = TRUE
	if(successful_scan)
		playsound(our_scanner, 'sound/machines/ping.ogg', 25)
		to_chat(our_scanner, "<span>The scan succeeds.</span>")
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 25)
		our_scanner.say("The scan did not result in anything.")
/**
 * Hooks on successful explosions on the doppler array this is attached to
 */
/datum/component/experiment_handler/proc/try_run_doppler_experiment(datum/source, turf/epicenter, devastation_range,
	heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	SIGNAL_HANDLER
	var/atom/movable/our_array = parent
	if(action_experiment(source, devastation_range, heavy_impact_range, light_impact_range))
		playsound(src, 'sound/machines/ping.ogg', 25)
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 25)
		our_array.say("Insufficient explosion to contribute to current experiment.")

/**
 * Announces a message to all experiment handlers
 *
 * Arguments:
 * * message - The message to announce
 */
/datum/component/experiment_handler/proc/announce_message_to_all(message)
	for(var/experiment in GLOB.experiment_handlers)
		var/datum/component/experiment_handler/experi_handler = experiment
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

	// Attempt to run
	var/list/arguments = list(src)
	arguments = args.len > 1 ? arguments + args.Copy(2) : arguments
	if (config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE)
		for (var/datum/experiment/e in linked_web.available_experiments)
			. = e.actionable(arglist(arguments)) && e.perform_experiment(arglist(arguments))
	else
		// Returns true if the experiment was succesfuly handled
		. = selected_experiment.actionable(arglist(arguments)) && selected_experiment.perform_experiment(arglist(arguments))

/**
 * Hook for handling UI interaction via signals
 */
/datum/component/experiment_handler/proc/ui_handle_experiment(datum/source, mob/user, action)
	SIGNAL_HANDLER
	switch(action)
		if("open_experiments")
			INVOKE_ASYNC(src, .proc/configure_experiment, null, usr)

/**
 * Attempts to show the user the experiment configuration panel
 *
 * Arguments:
 * * user - The user to show the experiment configuration panel to
 */
/datum/component/experiment_handler/proc/configure_experiment(datum/source, mob/user)
	ui_interact(user)

/**
 * Attempts to show the user the experiment configuration panel
 *
 * Arguments:
 * * user - The user to show the experiment configuration panel to
 */
/datum/component/experiment_handler/proc/configure_experiment_click(datum/source, mob/user)
	ui_interact(user)

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
	selected_experiment = null
	linked_web = new_web

/**
 * Unlinks this handler from the selected techweb
 */
/datum/component/experiment_handler/proc/unlink_techweb()
	selected_experiment = null
	linked_web = null

/**
 * Attempts to link this experiment_handler to a provided experiment
 *
 * Arguments:
 * * e - The experiment to attempt to link to
 */
/datum/component/experiment_handler/proc/link_experiment(datum/experiment/experi)
	if (experi && can_select_experiment(experi))
		selected_experiment = experi

/**
 * Unlinks this handler from the selected experiment
 */
/datum/component/experiment_handler/proc/unlink_experiment()
	selected_experiment = null

/**
 * Attempts to get rnd servers on the same z-level as a provided turf
 *
 * Arguments:
 * * pos - The turf to get servers on the same z-level of
 */
/datum/component/experiment_handler/proc/get_available_servers(turf/pos = null)
	if (!pos)
		pos = get_turf(parent)
	var/list/local_servers = list()
	for (var/obj/machinery/rnd/server/serv in SSresearch.servers)
		var/turf/s_pos = get_turf(serv)
		if (pos && s_pos && s_pos.z == pos.z)
			local_servers += serv
	return local_servers

/**
 * Checks if an experiment is valid to be selected by this handler
 *
 * Arguments:
 * * e - The experiment to check
 */
/datum/component/experiment_handler/proc/can_select_experiment(datum/experiment/experi)
	// Check that this experiments has no disallowed traits
	if (experi.traits & disallowed_traits)
		return FALSE

	// Check against the list of allowed experimentors
	if (experi.allowed_experimentors && experi.allowed_experimentors.len)
		var/matched = FALSE
		for (var/experimentor in experi.allowed_experimentors)
			if (istype(parent, experimentor))
				matched = TRUE
				break
		if (!matched)
			return FALSE

	// Check that this experiment is visible currently
	if (!linked_web || !(experi in linked_web.available_experiments))
		return FALSE

	// Check that this experiment type isn't blacklisted
	for (var/badsci in blacklisted_experiments)
		if (istype(experi, badsci))
			return FALSE

	// Check against the allowed experiment types
	for (var/goodsci in allowed_experiments)
		if (istype(experi, goodsci))
			return TRUE

	// If we haven't returned yet then this shouldn't be allowed
	return FALSE

/datum/component/experiment_handler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		var/atom/p_atom = parent
		ui = new(user, src, "ExperimentConfigure", "[p_atom ? "[p_atom.name] | " : ""]Experiment Configuration")
		ui.open()

/datum/component/experiment_handler/ui_data(mob/user)
	. = list(
		"always_active" = config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE,
		"has_start_callback" = !!start_experiment_callback)
	.["servers"] = list()
	for (var/obj/machinery/rnd/server/serv in get_available_servers())
		var/list/data = list(
			name = serv.name,
			web_id = serv.stored_research ? serv.stored_research.id : null,
			web_org = serv.stored_research ? serv.stored_research.organization : null,
			location = get_area(serv),
			selected = linked_web && serv.stored_research ? serv.stored_research == linked_web : FALSE,
			ref = REF(serv)
		)
		.["servers"] += list(data)
	.["experiments"] = list()
	if (linked_web)
		for (var/datum/experiment/experi in linked_web.available_experiments)
			var/list/data = list(
				name = experi.name,
				description = experi.description,
				tag = experi.exp_tag,
				selectable = can_select_experiment(experi),
				selected = selected_experiment == experi,
				progress = experi.check_progress(),
				performance_hint = experi.performance_hint,
				ref = REF(experi)
			)
			.["experiments"] += list(data)

/datum/component/experiment_handler/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch (action)
		if ("select_server")
			. = TRUE
			var/obj/machinery/rnd/server/serv = locate(params["ref"])
			if (serv)
				link_techweb(serv.stored_research)
				return
		if ("clear_server")
			. = TRUE
			unlink_techweb()
		if ("select_experiment")
			. = TRUE
			// Don't allow selection for always actives (no concept of active)
			if (config_flags & EXPERIMENT_CONFIG_ALWAYS_ACTIVE)
				return
			var/datum/experiment/experi = locate(params["ref"])
			if (experi)
				link_experiment(experi)
		if ("clear_experiment")
			. = TRUE
			unlink_experiment()
		if("start_experiment_callback")
			start_experiment_callback.Invoke(selected_experiment)

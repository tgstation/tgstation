/**
  * # Experiment Handler
  *
  * This is the component for interacting with experiments from a connected techweb. It is generic and should be set-up to automatically work on any class it is attached to without outside code (Excluding potential callbacks)
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

/**
  * Initializes a new instance of the experiment_handler component
  *
  * Arguments:
  * * allowed_experiments - The list of /datum/experiment types that can be performed with this component
  * * blacklisted_experiments - The list of /datum/experiment types that explicitly cannot be performed with this component
  * * config_mode - The define that determines how the experiment_handler should display the configuration UI
  */
/datum/component/experiment_handler/Initialize(allowed_experiments = list(),
												blacklisted_experiments = list(),
												config_mode = EXPERIMENT_CONFIG_ATTACKSELF)
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.allowed_experiments = allowed_experiments
	src.blacklisted_experiments = blacklisted_experiments

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, .proc/try_run_handheld_experiment)
	if(istype(parent, /obj/machinery/doppler_array))
		RegisterSignal(parent, COMSIG_DOPPLER_ARRAY_EXPLOSION_DETECTED, .proc/try_run_doppler_experiment)

	// Determine UI display mode
	switch(config_mode)
		if(EXPERIMENT_CONFIG_ATTACKSELF)
			RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/configure_experiment)
		if(EXPERIMENT_CONFIG_ALTCLICK)
			RegisterSignal(parent, COMSIG_CLICK_ALT, .proc/configure_experiment)
	GLOB.experiment_handlers += src

/datum/component/experiment_handler/Destroy(force, silent)
	. = ..()
	GLOB.experiment_handlers -= src

//Hooks on attack to try and run an experiment (When using a handheld handler)
/datum/component/experiment_handler/proc/try_run_handheld_experiment(datum/source, atom/target, mob/user, params)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/try_run_handheld_experiment_async, source, target, user, params)
	return COMPONENT_NO_ATTACK


//This proc exists because Jared Fogle really likes async
/datum/component/experiment_handler/proc/try_run_handheld_experiment_async(datum/source, atom/target, mob/user, params)
	if(!do_after(user, 10, target = target))
		return
	if(action_experiment(source, target))
		playsound(user, 'sound/machines/ping.ogg', 25)
		to_chat(user, "<span>You scan [target.name].</span>")
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 25)
		to_chat(user, "<span>[target.name] was not relevant to your experiment.</span>")


///Hooks on succesful explosions on the doppler array this is attached to
/datum/component/experiment_handler/proc/try_run_doppler_experiment(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	SIGNAL_HANDLER
	var/atom/movable/our_array = parent
	if(action_experiment(source, devastation_range, heavy_impact_range, light_impact_range))
		playsound(src, 'sound/machines/ping.ogg', 25)
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 25)
		our_array.say("Insufficient explosion to contribute to current experiment.")

///Announces a message to all experiment handlers
/datum/component/experiment_handler/proc/announce_message_to_all(var/message)
	for(var/i in GLOB.experiment_handlers)
		var/datum/component/experiment_handler/experi_handler
		var/atom/movable/experi_parent = experi_handler.parent
		experi_parent.say(message)


/**
  * Attempts to perform the selected experiment given some arguments
  */
/datum/component/experiment_handler/proc/action_experiment(datum/source, ...)
	// Check if an experiment is selected
	if (selected_experiment == null)
		return FALSE

	// Attempt to run
	var/list/arguments = list(src)
	arguments = args.len > 1 ? arguments + args.Copy(2) : arguments
	if (!selected_experiment.actionable(arglist(arguments)))
		return FALSE

	return selected_experiment.perform_experiment(arglist(arguments)) //Returns true if the experiment was succesfuly handled


/**
  * Attempts to show the user the experiment configuration panel
  *
  * Arguments:
  * * user - The user to show the experiment configuration panel to
  */
/datum/component/experiment_handler/proc/configure_experiment(datum/source, mob/user)
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
/datum/component/experiment_handler/proc/link_experiment(datum/experiment/e)
	if (e && can_select_experiment(e))
		selected_experiment = e

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
/datum/component/experiment_handler/proc/get_available_servers(var/turf/pos = null)
	if (!pos)
		pos = get_turf(parent)
	var/list/local_servers = list()
	for (var/obj/machinery/rnd/server/s in SSresearch.servers)
		var/turf/s_pos = get_turf(s)
		if (pos && s_pos && s_pos.z == pos.z)
			local_servers += s
	return local_servers

/**
  * Checks if an experiment is valid to be selected by this handler
  *
  * Arguments:
  * * e - The experiment to check
  */
/datum/component/experiment_handler/proc/can_select_experiment(datum/experiment/e)
	// Check against the list of allowed experimentors
	if (e.allowed_experimentors && e.allowed_experimentors.len)
		var/matched = FALSE
		for (var/t in e.allowed_experimentors)
			if (istype(parent, t))
				matched = TRUE
				break
		if (!matched)
			return FALSE

	// Check that this experiment is visible currently
	if (!linked_web || !(e in linked_web.available_experiments))
		return FALSE

	// Check that this experiment type isn't blacklisted
	for (var/t in blacklisted_experiments)
		if (istype(e, t))
			return FALSE

	// Check against the allowed experiment types
	for (var/t in allowed_experiments)
		if (istype(e, t))
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
	. = list()
	.["servers"] = list()
	for (var/obj/machinery/rnd/server/s in get_available_servers())
		var/list/data = list(
			name = s.name,
			web_id = s.stored_research ? s.stored_research.id : null,
			web_org = s.stored_research ? s.stored_research.organization : null,
			location = get_area(s),
			selected = linked_web && s.stored_research ? s.stored_research == linked_web : FALSE,
			ref = REF(s)
		)
		.["servers"] += list(data)
	.["experiments"] = list()
	if (linked_web)
		for (var/datum/experiment/e in linked_web.available_experiments)
			var/list/data = list(
				name = e.name,
				description = e.description,
				tag = e.exp_tag,
				selectable = can_select_experiment(e),
				selected = selected_experiment == e,
				progress = e.check_progress(),
				ref = REF(e)
			)
			.["experiments"] += list(data)

/datum/component/experiment_handler/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch (action)
		if ("select_server")
			. = TRUE
			var/obj/machinery/rnd/server/s = locate(params["ref"])
			if (s)
				link_techweb(s.stored_research)
				return
		if ("clear_server")
			. = TRUE
			unlink_techweb()
		if ("select_experiment")
			. = TRUE
			var/datum/experiment/e = locate(params["ref"])
			if (e)
				link_experiment(e)
		if ("clear_experiment")
			. = TRUE
			unlink_experiment()

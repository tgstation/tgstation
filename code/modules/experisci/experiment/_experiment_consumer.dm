/**
  * # Experiment Consumer
  *
  * This is the base component for getting experiments for consumption from a connected techweb.
  */
/datum/component/experiment_consumer
	/// Holds the currently linked techweb to get experiments from
	var/datum/techweb/linked_web
	/// Holds the currently selected experiment
	var/datum/experiment/selected_experiment

/datum/component/experiment_consumer/Initialize(...)
	. = ..()
	RegisterSignal(parent, COMSIG_TECHWEB_SELECT, .proc/select_techweb)
	RegisterSignal(parent, COMSIG_EXPERIMENT_SELECT, .proc/select_experiment)

/**
  * Attempts to have a user select an experiment from the connected techweb
  *
  * This proc attempts to have a user select an experiment from a filtered list developed
  * from the active experiments on the connected techweb.
  * Arguments:
  * * user - The user to show the select prompt to
  * * experiment_types - A collection of /datum/experiment typepaths to filter the experiments shown
  * * strict_types - Boolean operator to determine if type paths have to absolute matches or not
  */
/datum/component/experiment_consumer/proc/select_experiment(mob/user, var/list/experiment_types = null, strict_types = FALSE)
	if (!linked_web)
		to_chat(user, "<span class='notice'>There is no linked research server to get experiments from.</span>")
		return

	var/list/experiments = list()
	for (var/datum/experiment/e in linked_web.active_experiments)
		if (parent.type in e.allowed_experimentors)
			var/matched_type = null
			if (strict_types)
				matched_type = (e.type in experiment_types) ? e.type : null
			else
				for (var/i in experiment_types)
					if (istype(e, i))
						matched_type = i
						break
			if (matched_type)
				experiments[e.name] = e
	if (experiments.len == 0)
		to_chat(user, "<span class='notice'>There are no active experiments on this research server that are compatible with this device.</span>")
		return

	var/selected = input(user, "Select an experiment", "Experiments") as null|anything in experiments
	var/datum/experiment/new_experiment = selected ? experiments[selected] : null
	if (new_experiment && new_experiment != selected_experiment)
		selected_experiment = new_experiment
		to_chat(user, "<span class='notice'>You selected [new_experiment.name].</span>")
	else
		to_chat(user, "<span class='notice'>You decide not to change the selected experiment.</span>")

/**
  * Attempts to link this experiment_consumer to a provided techweb
  *
  * This proc attempts to link the consumer to a provided techweb, overriding the existing techweb if relevant
  * Arguments:
  * * new_web - The new techweb to link to
  */
/datum/component/experiment_consumer/proc/link_techweb(datum/techweb/new_web)
	if (new_web == linked_web)
		return
	selected_experiment = null
	linked_web = new_web

/**
  * Unlinks this consumer from its techweb
  */
/datum/component/experiment_consumer/proc/unlink_techweb()
	selected_experiment = null
	linked_web = null

/**
  * Attempts to have a user select a techweb on a rnd server from the same z-level as them
  *
  * This proc attempts to find rnd servers on the same z-level as the user and has them select a server
  * from those found to use as a source for connecting to a new techweb
  * Arguments:
  * * user - The user to show the select prompt to
  */
/datum/component/experiment_consumer/proc/select_techweb(mob/user)
	var/list/servers = get_available_servers()
	if (servers.len == 0)
		to_chat(user, "No research servers detected in your vicinity.")
		return
	var/snames = list()
	for (var/obj/s in servers)
		snames[s.name] = s
	var/selected = input(user, "Select a research server", "Research Servers") as null|anything in snames
	var/obj/machinery/rnd/server/new_server = selected ? snames[selected] : null
	if (new_server && new_server.stored_research != linked_web)
		link_techweb(new_server.stored_research)
		to_chat(user, "<span class='notice'>Linked to [new_server.name].</span>")
	else
		to_chat(user, "<span class='notice'>You decide not to change the linked research server.</span>")

/**
  * Attempts to get rnd servers on the same z-level as a provided turf
  *
  * Arguments:
  * * pos - The turf to get servers on the same z-level of
  */
/datum/component/experiment_consumer/proc/get_available_servers(var/turf/pos = null)
	if (!pos)
		pos = get_turf(parent)
	var/list/local_servers = list()
	for (var/obj/machinery/rnd/server/s in SSresearch.servers)
		var/turf/s_pos = get_turf(s)
		if (pos && s_pos && s_pos.z == pos.z)
			local_servers += s
	return local_servers

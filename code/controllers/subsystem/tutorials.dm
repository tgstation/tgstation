SUBSYSTEM_DEF(tutorials)
	name = "Tutorials"
	flags = SS_NO_FIRE

	var/list/datum/tutorial_manager/tutorial_managers = list()
	VAR_PRIVATE/list/datum/tutorial_manager/tutorial_managers_by_key = list()

/datum/controller/subsystem/tutorials/Initialize()
	init_tutorial_managers()
	load_initial_tutorial_completions()
	RegisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT, PROC_REF(on_client_connect))

	return SS_INIT_SUCCESS

/datum/controller/subsystem/tutorials/proc/suggest_tutorial(mob/user, datum/tutorial/tutorial_type, ...)
	var/datum/tutorial_manager/tutorial_manager = tutorial_managers[tutorial_type]
	if (isnull(tutorial_manager))
		CRASH("[tutorial_type] is not a valid tutorial type")

	if (!tutorial_manager.should_run(user))
		return

	INVOKE_ASYNC(tutorial_manager, TYPE_PROC_REF(/datum/tutorial_manager, try_perform), user, args.Copy(3))

/datum/controller/subsystem/tutorials/proc/init_tutorial_managers()
	PRIVATE_PROC(TRUE)

	for (var/datum/tutorial/tutorial_type as anything in subtypesof(/datum/tutorial))
		var/datum/tutorial_manager/tutorial_manager = new /datum/tutorial_manager(tutorial_type)
		tutorial_managers[tutorial_type] = tutorial_manager
		tutorial_managers_by_key[tutorial_manager.get_key()] = tutorial_manager

/datum/controller/subsystem/tutorials/proc/load_initial_tutorial_completions()
	PRIVATE_PROC(TRUE)
	set waitfor = FALSE // There's no reason to halt init for this

	var/list/ckey_options = list()
	var/list/ckeys = list()

	for (var/client/client as anything in GLOB.clients)
		var/ckey = client?.ckey
		if (!ckey)
			continue // client shenanigans, never trust

		var/index = ckeys.len + 1
		ckey_options += "ckey = :ckey[index]"
		ckeys["ckey[index]"] = ckey

	if (ckey_options.len == 0)
		return

	var/datum/db_query/select_all_query = SSdbcore.NewQuery(
		"SELECT ckey, tutorial_key FROM [format_table_name("tutorial_completions")] WHERE ([ckey_options.Join(" OR ")])",
		ckeys,
	)

	if (!select_all_query.warn_execute())
		qdel(select_all_query)
		return

	while (select_all_query.NextRow())
		var/ckey = select_all_query.item[1]
		var/tutorial_key = select_all_query.item[2]

		mark_ckey_completed_tutorial(ckey, tutorial_key)

	qdel(select_all_query)

/datum/controller/subsystem/tutorials/proc/on_client_connect(datum/source, client/client)
	SIGNAL_HANDLER

	var/ckey = client.ckey
	if (!ckey)
		return

	INVOKE_ASYNC(src, PROC_REF(check_completed_tutorials_for_ckey), ckey)

/datum/controller/subsystem/tutorials/proc/check_completed_tutorials_for_ckey(ckey)
	if (!SSdbcore.IsConnected())
		return

	var/datum/db_query/select_tutorials_for_ckey = SSdbcore.NewQuery(
		"SELECT tutorial_key FROM [format_table_name("tutorial_completions")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)

	if (!select_tutorials_for_ckey.warn_execute())
		return

	while (select_tutorials_for_ckey.NextRow())
		var/tutorial_key = select_tutorials_for_ckey.item[1]

		mark_ckey_completed_tutorial(ckey, tutorial_key)

	qdel(select_tutorials_for_ckey)

/datum/controller/subsystem/tutorials/proc/mark_ckey_completed_tutorial(ckey, tutorial_key)
	var/datum/tutorial_manager/tutorial_manager = tutorial_managers_by_key[tutorial_key]
	if (isnull(tutorial_manager))
		// Not necessarily a bug.
		// Could be an outdated server or a removed tutorial.
		return

	tutorial_manager.mark_as_completed(ckey)


/datum/config_entry/flag/metrics_enabled
	default = TRUE

SUBSYSTEM_DEF(metrics)
	name = "Metrics"
	init_order = INIT_ORDER_METRICS
	wait = 30 SECONDS
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME // ALL THE LEVELS
	ss_id = "metrics"
	flags = SS_KEEP_TIMING // This needs to ingest every 30 IRL seconds, not ingame seconds. I mean it doesn't but it fucks with my pretty graph.
	/// The real time of day the server started. Used to calculate time drift
	var/world_init_time = 0 // Not set in here. Set in world/New()
	/// If this is on live the world will end, just kidding but admin chat will be literally unusuable
	var/debug = FALSE

/datum/controller/subsystem/metrics/Initialize(start_timeofday)
	if(!CONFIG_GET(flag/metrics_enabled) && !debug)
		flags |= SS_NO_FIRE // Disable firing to save CPU
	return SS_INIT_SUCCESS

/datum/controller/subsystem/metrics/fire(resumed)
	if (!SSdbcore.Connect() && !debug)
		return
	var/sql_at_fire = SQLtime()
	var/list/generic_insert = get_metric_data_main()
	var/list/subsystem_extra_insert = list()
	var/list/subsystem_insert = list()
	for(var/datum/controller/subsystem/SS in Master.subsystems)
		var/list/data = SS.get_metrics()
		subsystem_insert += list(list(
			"datetime" = sql_at_fire,
			"round_id" = text2num(GLOB.round_id), //NUM
			"ss_id" = SS.ss_id, //VARSET
			"relation_id_SS" = data["relation_id_SS"], //VARSET
			"cost" = data["cost"], //DECIMAL
			"tick_usage" = data["tick_usage"], //DECIMAL
			"relational_id" = generic_insert["relational_id"] //VARSET
		))
		if(length(data["custom"]))
			var/list/custom_data = data["custom"]
			for(var/item in custom_data)
				subsystem_extra_insert += list(list(
					"datetime" = sql_at_fire,
					"round_id" = text2num(GLOB.round_id), //NUM
					"ss_id" = SS.ss_id, //VARSET
					"relation_id_SS" = data["relation_id_SS"], //VARSET
					"ss_value" = json_encode(list("name" = item, "value" = custom_data[item])), //LONG STRING
				))
	if(debug) //sqls are handled after this
		return

	var/datum/db_query/query_add_metrics = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("metric_data")] (`datetime`, `cpu`, `maptick`, `elapsed_processed`, `elapsed_real`, `client_count`, `round_id`, `relational_id`) VALUES (:datetime, :cpu, :maptick, :elapsed_processed, :elapsed_real, :client_count, :round_id, :relational_id)"},
		list(
			"datetime" = sql_at_fire,
			"cpu" = generic_insert["cpu"],
			"maptick" = generic_insert["maptick"],
			"elapsed_processed" = generic_insert["elapsed_processed"],
			"elapsed_real" = generic_insert["elapsed_real"],
			"client_count" = generic_insert["client_count"],
			"round_id" = generic_insert["round_id"],
			"relational_id" = generic_insert["relational_id"],
		))
	if(!query_add_metrics.Execute())
		addtimer(CALLBACK(src, PROC_REF(retry_failed), generic_insert, sql_at_fire), 10 SECONDS)
	qdel(query_add_metrics)

	SSdbcore.MassInsert(format_table_name("subsystem_metrics"), subsystem_insert , ignore_errors = TRUE, duplicate_key = TRUE)
	if(length(subsystem_extra_insert))
		SSdbcore.MassInsert(format_table_name("subsystem_extra_metrics"), subsystem_extra_insert , ignore_errors = TRUE, duplicate_key = TRUE)

/datum/controller/subsystem/metrics/proc/get_metric_data_main()
	var/list/out = list()
	out["cpu"] = world.cpu //DECIMAL
	out["maptick"] = world.map_cpu  //DECIMAL
	out["elapsed_processed"] = world.time //NUM
	out["elapsed_real"] = (REALTIMEOFDAY - world_init_time) //NUM
	out["client_count"] = length(GLOB.clients) //NUM
	out["round_id"] = text2num(GLOB.round_id) // This is so we can filter the metrics by a single round ID //NUM
	out["relational_id"] = "[text2num(GLOB.round_id)]-[time_stamp()]-[rand(100, 100000)]" //VARSET

	return out

/datum/controller/subsystem/metrics/proc/retry_failed(list/generic_insert, sql_at_fire)
	var/datum/db_query/query_add_metrics = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("metric_data")] (`datetime`, `cpu`, `maptick`, `elapsed_processed`, `elapsed_real`, `client_count`, `round_id`, `relational_id`) VALUES (:datetime, :cpu, :maptick, :elapsed_processed, :elapsed_real, :client_count, :round_id, :relational_id)"},
		list(
			"datetime" = sql_at_fire,
			"cpu" = generic_insert["cpu"],
			"maptick" = generic_insert["maptick"],
			"elapsed_processed" = generic_insert["elapsed_processed"],
			"elapsed_real" = generic_insert["elapsed_real"],
			"client_count" = generic_insert["client_count"],
			"round_id" = generic_insert["round_id"],
			"relational_id" = generic_insert["relational_id"],
		))
	if(!query_add_metrics.Execute())
		addtimer(CALLBACK(src, PROC_REF(retry_failed), generic_insert, sql_at_fire), 10 SECONDS)
	qdel(query_add_metrics)

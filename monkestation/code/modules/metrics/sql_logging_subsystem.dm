/* IMPORTANT INFORMATION
* If you are making a new proc make sure the lists are in proper format so we dont have to re-aggregate it inside the db
* Its done as followed
* list(
* "timestamp" = SQLtime() - THIS IS SUPER SUPER IMPORTANT IF NO TIMESTAMP PROVIDED YOUR LOGS WILL NOT BE IN THE CORRECT ORDER AFTER PARSE
* "round_id" = CURRENT_ROUND
* "logging_key" = KEY - Example: GAME
* "source" = LOG_SOURCE - Example: large beaker
* "source_ckey" = if has a ckey, mobs ckey
* "target" = Target of whatever log - optional populated with No Target Log if not set
* "target_ckey" = Ckey of the target if applicable set to No Target Log without target, or No Target Ckey for ones with targets
* "log_data" = What we Log - Example: Reacted with Potassium Creating a Small Explosion
* "x" = SOURCE_X
* "y" = SOURCE_Y
* "z" = SOURCE_Z
* "area" = SOURCE_AREA
* "map" = Current rounds map name
* "roundstate" = INT of the roundstate refer to code/__DEFINES/subsystems.dm for what each value means
* "voluntary" = TRUE/FALSE - Boolean value for if this log was generated involunarily, for instance virus emotes are involuntary.
*)
*/

/* THIS IS JUST FOR CLARITY SAKE.
* log_{type}'s finished
* log_traitor
* log_attack
* log_bomb
* log_wound
* log_say
* log_uplink
* log_malf_upgrades
* log_changeling_power
* log_heretic_knowledge
* log_spellbook
* log_economy
* log_emote
* log_ooc
* log_prayer
* log_silicon
*/

/datum/config_entry/flag/sqlgamelogs
	default = TRUE


SUBSYSTEM_DEF(sql_logging)
	name = "SQL Logging"

	init_order = INIT_ORDER_METRICS
	wait = 2 MINUTES
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME // ALL THE LEVELS
	ss_id = "sql-logs"
	flags = SS_KEEP_TIMING // We want consistancy so we run every 5 irl minutes plus at round end.
	///this list is our to be added queue thats stored as an array list emptied every 5 minutes
	var/list/buffered_data = list()

/datum/controller/subsystem/sql_logging/Initialize(start_timeofday)
	if(!CONFIG_GET(flag/sqlgamelogs))
		flags |= SS_NO_FIRE // Disable firing to save CPU
	return SS_INIT_SUCCESS


/datum/controller/subsystem/sql_logging/fire(resumed)
	if (!SSdbcore.Connect() || !length(buffered_data))
		return

	if(SSdbcore.MassInsert(format_table_name("logs"), buffered_data , ignore_errors = TRUE, duplicate_key = TRUE))
		buffered_data = list()

/proc/add_event_to_buffer(atom/source, atom/target, data, log_key = "GAME", voluntary = TRUE)
	if(!data)
		return
	if(istype(source, /datum/mind))
		var/datum/mind/mind = source
		source = mind.current

	var/list/sorted_data = list()

	var/source_name = "Unsourced Data"
	var/source_x = 0
	var/source_y = 0
	var/source_z = 0
	var/source_area = "Unsourced Data"
	var/source_ckey = "Non Client Source"

	var/target_name = "No Target"
	var/target_ckey = "No Target"
	if(target && !isnull(target))
		if(ismob(target))
			var/mob/mob = target
			if(mob.client)
				target_ckey = mob.client.ckey
				target_name = mob.real_name
			else
				target_name = target.name
				target_ckey = "Non Client Target"

	if(source && !isnull(source))
		if(ismob(source))
			var/mob/mob = source
			if(mob.client)
				source_ckey = mob.client.ckey
			source_name = mob.real_name

		else
			source_name = source.name
		source_x = source.x
		source_y = source.y
		source_z = source.z
		var/area/area = get_area(source)
		if(!isnull(area))
			source_area = area.name

	if(isnull(source_name))
		source_name = target_ckey

	sorted_data = list(
		"timestamp" = SQLtime(),
		"round_id" = text2num(GLOB.round_id),
		"logging_key" = log_key,
		"source" = source_name,
		"source_ckey" = source_ckey,
		"target" = target_name,
		"target_ckey" = target_ckey,
		"log_data" = data,
		"x" = source_x,
		"y" = source_y,
		"z" = source_z,
		"area" = source_area,
		"map" = SSmapping.config.map_name,
		"roundstate" = SSticker.current_state,
		"voluntary" = voluntary,
	)

	SSsql_logging.buffered_data += list(sorted_data)

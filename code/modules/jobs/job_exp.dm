GLOBAL_LIST_EMPTY(exp_to_update)
GLOBAL_PROTECT(exp_to_update)

#define IS_XP_LOCKED(job) (exp_requirements && ((exp_required_type_department && CONFIG_GET(flag/use_exp_restrictions_heads)) || (exp_required_type && CONFIG_GET(flag/use_exp_restrictions_other))))
// Procs
/datum/job/proc/required_playtime_remaining(client/C)
	if(!C)
		return 0
	if(!CONFIG_GET(flag/use_exp_tracking))
		return 0
	if(!SSdbcore.Connect())
		return 0
	if(!IS_XP_LOCKED(src))
		return 0
	if(CONFIG_GET(flag/use_exp_restrictions_admin_bypass) && check_rights_for(C,R_ADMIN))
		return 0
	var/isexempt = C.prefs.db_flags & DB_FLAG_EXEMPT
	if(isexempt)
		return 0
	var/my_exp = C.calc_exp_type(get_exp_req_type())
	var/job_requirement = get_exp_req_amount()
	if(my_exp >= job_requirement)
		return 0
	else
		return (job_requirement - my_exp)
#undef IS_XP_LOCKED


/datum/job/proc/get_exp_req_amount()
	if(exp_required_type_department)
		var/uerhh = CONFIG_GET(number/use_exp_restrictions_heads_hours)
		if(uerhh)
			return uerhh * 60
	return exp_requirements


/datum/job/proc/get_exp_req_type()
	if(exp_required_type_department && CONFIG_GET(flag/use_exp_restrictions_heads_department))
		return exp_required_type_department
	return exp_required_type


/client/proc/calc_exp_type(exptype)
	var/list/job_list = SSjob.experience_jobs_map[exptype]
	if(!job_list)
		return -1
	var/list/exp_map = prefs.exp.Copy()
	. = 0
	for(var/datum/job/job as anything in job_list)
		. += exp_map[job.title]


/client/proc/get_exp_living(pure_numeric = FALSE)
	if(!prefs.exp || !prefs.exp[EXP_TYPE_LIVING])
		return pure_numeric ? 0 : "No data"
	var/exp_living = text2num(prefs.exp[EXP_TYPE_LIVING])
	return pure_numeric ? exp_living : get_exp_format(exp_living)

/proc/get_exp_format(expnum)
	if(expnum > 60)
		return num2text(round(expnum / 60)) + "h"
	else if(expnum > 0)
		return num2text(expnum) + "m"
	else
		return "0h"

/datum/controller/subsystem/blackbox/proc/update_exp(mins)
	if(!SSdbcore.Connect())
		return -1
	for(var/client/L in GLOB.clients)
		if(L.is_afk())
			continue
		L.update_exp_list(mins)

/datum/controller/subsystem/blackbox/proc/update_exp_db()
	set waitfor = FALSE
	var/list/old_minutes = GLOB.exp_to_update
	GLOB.exp_to_update = null
	SSdbcore.MassInsert(format_table_name("role_time"), old_minutes, duplicate_key = "ON DUPLICATE KEY UPDATE minutes = minutes + VALUES(minutes)")

//resets a client's exp to what was in the db.
/client/proc/set_exp_from_db()
	if(!CONFIG_GET(flag/use_exp_tracking))
		return -1
	if(!SSdbcore.Connect())
		return -1
	var/datum/db_query/exp_read = SSdbcore.NewQuery(
		"SELECT job, minutes FROM [format_table_name("role_time")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	if(!exp_read.Execute(async = TRUE))
		qdel(exp_read)
		return -1
	var/list/play_records = list()
	while(exp_read.NextRow())
		play_records[exp_read.item[1]] = text2num(exp_read.item[2])
	qdel(exp_read)

	for(var/rtype in SSjob.name_occupations)
		if(!play_records[rtype])
			play_records[rtype] = 0
	for(var/rtype in GLOB.exp_specialmap)
		if(!play_records[rtype])
			play_records[rtype] = 0

	prefs.exp = play_records

//updates player db flags
/client/proc/update_flag_db(newflag, state = FALSE)

	if(!SSdbcore.Connect())
		return -1

	if(!set_db_player_flags())
		return -1

	if((prefs.db_flags & newflag) && !state)
		prefs.db_flags &= ~newflag
	else
		prefs.db_flags |= newflag

	var/datum/db_query/flag_update = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET flags=:flags WHERE ckey=:ckey",
		list("flags" = "[prefs.db_flags]", "ckey" = ckey)
	)

	if(!flag_update.Execute())
		qdel(flag_update)
		return -1
	qdel(flag_update)

/**
 * Tallies up the exp for the playtime tracking and adds it to the global update list.
 *
 * For a client mob of [/mob/dead/observer], it adds EXP_TYPE_GHOST.
 *
 * For a client mob of [/mob/living], it grabs the exp list from a mob proc call.
 * Being dead but still in your body will tally time towards your /mob/living roles instead of ghost roles.
 * If /mob/living returns an empty list, uses "Unknown" instead.
 *
 * For anything else, it doesn't update anything.
 *
 * Arguments:
 * * minutes - The number of minutes to add to the playtime tally.
 */
/client/proc/update_exp_list(minutes)
	if(!CONFIG_GET(flag/use_exp_tracking))
		return -1
	if(!SSdbcore.Connect())
		return -1
	if (!isnum(minutes))
		return -1

	var/list/play_records = list()

	if(isobserver(mob))
		play_records[EXP_TYPE_GHOST] = minutes
	else if(isliving(mob) && !isnull(mob.mind))
		var/mob/living/living_mob = mob
		var/list/mob_exp_list = living_mob.get_exp_list(minutes)
		if(!length(mob_exp_list))
			play_records["Unknown"] = minutes
		else
			play_records |= mob_exp_list

		play_records[EXP_TYPE_LIVING] = minutes
	// Lobby surfing? /mob/dead/new_player? Not worth any exp!
	else
		return

	if(holder && !holder.deadmined && holder.check_for_rights(R_BAN))
		play_records[EXP_TYPE_ADMIN] = minutes

	for(var/jtype in play_records)
		var/jvalue = play_records[jtype]
		if (!jvalue)
			continue
		if (!isnum(jvalue))
			CRASH("invalid job value [jtype]:[jvalue]")
		LAZYINITLIST(GLOB.exp_to_update)
		GLOB.exp_to_update.Add(list(list(
			"job" = jtype,
			"ckey" = ckey,
			"minutes" = jvalue)))
		prefs.exp[jtype] += jvalue
	addtimer(CALLBACK(SSblackbox, TYPE_PROC_REF(/datum/controller/subsystem/blackbox, update_exp_db)),20,TIMER_OVERRIDE|TIMER_UNIQUE)


//ALWAYS call this at beginning to any proc touching player flags, or your database admin will probably be mad
/client/proc/set_db_player_flags()
	if(!SSdbcore.Connect())
		return FALSE

	var/datum/db_query/flags_read = SSdbcore.NewQuery(
		"SELECT flags FROM [format_table_name("player")] WHERE ckey=:ckey",
		list("ckey" = ckey)
	)

	if(!flags_read.Execute(async = TRUE))
		qdel(flags_read)
		return FALSE

	if(flags_read.NextRow())
		prefs.db_flags = text2num(flags_read.item[1])
	else if(isnull(prefs.db_flags))
		prefs.db_flags = NONE //This PROBABLY won't happen, but better safe than sorry.
	qdel(flags_read)
	return TRUE

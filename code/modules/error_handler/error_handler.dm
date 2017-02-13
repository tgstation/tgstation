var/global/list/error_last_seen = list()
var/global/list/error_cooldown = list() /* Error_cooldown items will either be positive(cooldown time) or negative(silenced error)
											 If negative, starts at -1, and goes down by 1 each time that error gets skipped*/
var/global/total_runtimes = 0
var/global/total_runtimes_skipped = 0

#ifdef DEBUG
/world/Error(exception/E, datum/e_src)
	if(!istype(E)) //Something threw an unusual exception
		world.log << "\[[time_stamp()]] Uncaught exception: [E]"
		return ..()
	if(!error_last_seen) // A runtime is occurring too early in start-up initialization
		return ..()

	total_runtimes++

	var/erroruid = "[E.file][E.line]"
	var/last_seen = error_last_seen[erroruid]
	var/cooldown = error_cooldown[erroruid] || 0

	if(last_seen == null)
		error_last_seen[erroruid] = world.time
		last_seen = world.time

	if(cooldown < 0)
		error_cooldown[erroruid]-- //Used to keep track of skip count for this error
		total_runtimes_skipped++
		return //Error is currently silenced, skip handling it
	//Handle cooldowns and silencing spammy errors
	var/silencing = FALSE

	// We can runtime before config is initialized because BYOND initialize objs/map before a bunch of other stuff happens.
	// This is a bunch of workaround code for that. Hooray!

	var/configured_error_cooldown = initial(config.error_cooldown)
	var/configured_error_limit = initial(config.error_limit)
	var/configured_error_silence_time = initial(config.error_silence_time)
	if(config)
		configured_error_cooldown = config.error_cooldown
		configured_error_limit = config.error_limit
		configured_error_silence_time = config.error_silence_time


	//Each occurence of an unique error adds to its cooldown time...
	cooldown = max(0, cooldown - (world.time - last_seen)) + configured_error_cooldown
	// ... which is used to silence an error if it occurs too often, too fast
	if(cooldown > configured_error_cooldown * configured_error_limit)
		cooldown = -1
		silencing = TRUE
		spawn(0)
			usr = null
			sleep(configured_error_silence_time)
			var/skipcount = abs(error_cooldown[erroruid]) - 1
			error_cooldown[erroruid] = 0
			if(skipcount > 0)
				world.log << "\[[time_stamp()]] Skipped [skipcount] runtimes in [E.file],[E.line]."
				error_cache.log_error(E, skip_count = skipcount)

	error_last_seen[erroruid] = world.time
	error_cooldown[erroruid] = cooldown

	var/list/usrinfo = null
	var/locinfo
	if(istype(usr))
		usrinfo = list("  usr: [datum_info_line(usr)]")
		locinfo = atom_loc_line(usr)
		if(locinfo)
			usrinfo += "  usr.loc: [locinfo]"

	E.name = "\n\[[time2text(world.timeofday,"hh:mm:ss")]\][E.name]"

	//this is done this way rather then replace text to pave the way for processing the runtime reports more thoroughly
	//	(and because runtimes end with a newline, and we don't want to basically print an empty time stamp)
	var/list/split = splittext(E.desc, "\n")
	for (var/i in 1 to split.len)
		if (split[i] != "")
			split[i] = "\[[time2text(world.timeofday,"hh:mm:ss")]\][split[i]]"
	E.desc = jointext(split, "\n")

	. = ..(E)

	if(silencing)
		split += "  (This error will now be silenced for [configured_error_silence_time / 600] minutes)"

	if(error_cache)
		error_cache.log_error(E, split)

#endif
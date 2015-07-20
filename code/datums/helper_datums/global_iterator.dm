/*
README:

The global_iterator datum is supposed to provide a simple and robust way to
create some constantly "looping" processes with ability to stop and restart them at will.
Generally, the only thing you want to play with (meaning, redefine) is the process() proc.
It must contain all the things you want done.

Control functions:
	new - used to create datum. First argument (optional) - var list(to use in process() proc) as list,
	second (optional) - autostart control.
	If autostart == TRUE, the loop will be started immediately after datum creation.

	start(list/arguments) - starts the loop. Takes arguments(optional) as a list, which is then used
	by process() proc. Returns null if datum already active, 1 if loop started succesfully and 0 if there's
	an error in supplied arguments (not list or empty list).

	stop() - stops the loop. Returns null if datum is already inactive and 1 on success.

	set_delay(new_delay) - sets the delay between iterations. Pretty selfexplanatory.
	Returns 0 on error(new_delay is not numerical), 1 otherwise.

	set_process_args(list/arguments) - passes the supplied arguments to the process() proc.

	active() - Returns 1 if datum is active, 0 otherwise.

	toggle() - toggles datum state. Returns new datum state (see active()).

Misc functions:

	get_last_exec_time() - Returns the time of last iteration.

	get_last_exec_time_as_text() - Returns the time of last iteration as text


Control vars:

	delay - 	delay between iterations

	check_for_null - if equals TRUE, on each iteration the supplied arguments will be checked for nulls.
	If some varible equals null (and null only), the loop is stopped.
	Usefull, if some var unexpectedly becomes null - due to object deletion, for example.
	Of course, you can also check the variables inside process() proc to prevent runtime errors.

Data storage vars:

	result - stores the value returned by process() proc
*/

/datum/global_iterator
	var/control_switch = 0
	var/delay = 10
	var/list/arg_list = new
	var/last_exec = null
	var/check_for_null = 1
	var/forbid_garbage = 0
	var/result
	var/state = 0

	New(list/arguments=null,autostart=1)
		delay = delay>0?(delay):1
		if(forbid_garbage) //prevents garbage collection with tag != null
			tag = "\ref[src]"
		set_process_args(arguments)
		if(autostart)
			start()
		return

	proc/main()
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/main() called tick#: [world.time]")
		state = 1
		while(src && control_switch)
			last_exec = world.timeofday
			if(check_for_null && has_null_args())
				stop()
				return 0
			result = process(arglist(arg_list))
			for(var/sleep_time=delay;sleep_time>0;sleep_time--) //uhh, this is ugly. But I see no other way to terminate sleeping proc. Such disgrace.
				if(!control_switch)
					return 0
				sleep(1)
		return 0

	proc/start(list/arguments=null)
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/start() called tick#: [world.time]")
		if(active())
			return
		if(arguments)
			if(!set_process_args(arguments))
				return 0
		if(!state_check()) //the main loop is sleeping, wait for it to terminate.
			return
		control_switch = 1
		spawn()
			state = main()
		return 1

	proc/stop()
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/stop() called tick#: [world.time]")
		if(!active())
			return
		control_switch = 0
		spawn(-1) //report termination error but don't wait for state_check().
			state_check()
		return 1

	proc/state_check()
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/state_check() called tick#: [world.time]")
		var/lag = 0
		while(state)
			sleep(1)
			if(++lag>10)
				CRASH("The global_iterator loop \ref[src] failed to terminate in designated timeframe. This may be caused by server lagging.")
		return 1

	proc/process()
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/process() called tick#: [world.time]")
		return

	proc/active()
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/active() called tick#: [world.time]")
		return control_switch

	proc/has_null_args()
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/has_null_args() called tick#: [world.time]")
		if(null in arg_list)
			return 1
		return 0


	proc/set_delay(new_delay)
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/set_delay() called tick#: [world.time]")
		if(isnum(new_delay))
			delay = max(1, round(new_delay))
			return 1
		else
			return 0

	proc/get_last_exec_time()
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/get_last_exec_time() called tick#: [world.time]")
		return (last_exec||0)

	proc/get_last_exec_time_as_text()
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/get_last_exec_time_as_text() called tick#: [world.time]")
		return (time2text(last_exec)||"Wasn't executed yet")

	proc/set_process_args(list/arguments)
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/set_process_args() called tick#: [world.time]")
		if(arguments && istype(arguments, /list) && arguments.len)
			arg_list = arguments
			return 1
		else
//			world << "<span class='warning'>Invalid arguments supplied for [src.type], ref = \ref[src]</span>"
			return 0

	proc/toggle_null_checks()
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/toggle_null_checks() called tick#: [world.time]")
		check_for_null = !check_for_null
		return check_for_null

	proc/toggle()
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/toggle() called tick#: [world.time]")
		if(!stop())
			start()
		return active()



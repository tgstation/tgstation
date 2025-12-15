#define RESTART_COUNTER_PATH "data/round_counter.txt"
/// Load byond-tracy. If USE_BYOND_TRACY is defined, then this is ignored and byond-tracy is always loaded.
#define USE_TRACY_PARAMETER "tracy"
/// Force the log directory to be something specific in the data/logs folder
#define OVERRIDE_LOG_DIRECTORY_PARAMETER "log-directory"
/// Prevent the master controller from starting automatically
#define NO_INIT_PARAMETER "no-init"

GLOBAL_VAR(restart_counter)

/**
 * WORLD INITIALIZATION
 * THIS IS THE INIT ORDER:
 *
 * BYOND =>
 * - (secret init native) =>
 *   - world.Genesis() =>
 *     - world.init_byond_tracy()
 *     - (Start native profiling)
 *     - new /datum/debugger()
 *     - world.setup_external_cpu()
 *     - Master =>
 *       - config *unloaded
 *       - (all subsystems) PreInit()
 *       - GLOB =>
 *         - make_datum_reference_lists()
 *   - (/static variable inits, reverse declaration order)
 * - (all pre-mapped atoms) /atom/New()
 * - world.New() =>
 *   - config.Load()
 *   - world.InitTgs() =>
 *     - TgsNew() *may sleep
 *     - GLOB.rev_data.load_tgs_info()
 *   - world.ConfigLoaded() =>
 *     - SSdbcore.InitializeRound()
 *     - world.SetupLogs()
 *     - load_admins()
 *     - ...
 *   - Master.Initialize() =>
 *     - (all subsystems) Initialize()
 *     - Master.StartProcessing() =>
 *       - Master.Loop() =>
 *         - Failsafe
 *   - world.RunUnattendedFunctions()
 *
 * Now listen up because I want to make something clear:
 * If something is not in this list it should almost definitely be handled by a subsystem Initialize()ing
 * If whatever it is that needs doing doesn't fit in a subsystem you probably aren't trying hard enough tbhfam
 *
 * GOT IT MEMORIZED?
 * - Dominion/Cyberboss
 *
 * Where to put init shit quick guide:
 * If you need it to happen before the mc is created: world/Genesis.
 * If you need it to happen last: world/New(),
 * Otherwise, in a subsystem preinit or init. Subsystems can set an init priority.
 */

/**
 * THIS !!!SINGLE!!! PROC IS WHERE ANY FORM OF INIITIALIZATION THAT CAN'T BE PERFORMED IN SUBSYSTEMS OR WORLD/NEW IS DONE
 * NOWHERE THE FUCK ELSE
 * I DON'T CARE HOW MANY LAYERS OF DEBUG/PROFILE/TRACE WE HAVE, YOU JUST HAVE TO DEAL WITH THIS PROC EXISTING
 * I'M NOT EVEN GOING TO TELL YOU WHERE IT'S CALLED FROM BECAUSE I'M DECLARING THAT FORBIDDEN KNOWLEDGE
 * SO HELP ME GOD IF I FIND ABSTRACTION LAYERS OVER THIS!
 */
/world/proc/Genesis(tracy_initialized = FALSE)
	RETURN_TYPE(/datum/controller/master)

	if(!tracy_initialized)
		Tracy = new
#ifdef USE_BYOND_TRACY
		if(Tracy.enable("USE_BYOND_TRACY defined"))
			Genesis(tracy_initialized = TRUE)
			return
#else
		var/tracy_enable_reason
		if(USE_TRACY_PARAMETER in params)
			tracy_enable_reason = "world.params"
		if(fexists(TRACY_ENABLE_PATH))
			tracy_enable_reason ||= "enabled for round"
			SEND_TEXT(world.log, "[TRACY_ENABLE_PATH] exists, initializing byond-tracy!")
			fdel(TRACY_ENABLE_PATH)
		if(!isnull(tracy_enable_reason) && Tracy.enable(tracy_enable_reason))
			Genesis(tracy_initialized = TRUE)
			return
#endif

	Profile(PROFILE_RESTART)
	Profile(PROFILE_RESTART, type = "sendmaps")

	// Write everything to this log file until we get to SetupLogs() later
	_initialize_log_files("data/logs/config_error.[GUID()].log")

	// Init the debugger first so we can debug Master
	Debugger = new

	// Create the logger
	logger = new

	// Cpu tracking setup
	world.setup_external_cpu()

	// THAT'S IT, WE'RE DONE, THE. FUCKING. END.
	Master = new

/**
 * World creation
 *
 * Here is where a round itself is actually begun and setup.
 * * db connection setup
 * * config loaded from files
 * * loads admins
 * * Sets up the dynamic menu system
 * * and most importantly, calls initialize on the master subsystem, starting the game loop that causes the rest of the game to begin processing and setting up
 *
 *
 * Nothing happens until something moves. ~Albert Einstein
 *
 * For clarity, this proc gets triggered later in the initialization pipeline, it is not the first thing to happen, as it might seem.
 *
 * Initialization Pipeline:
 * Global vars are new()'ed, (including config, glob, and the master controller will also new and preinit all subsystems when it gets new()ed)
 * Compiled in maps are loaded (mainly centcom). all areas/turfs/objs/mobs(ATOMs) in these maps will be new()ed
 * world/New() (You are here)
 * Once world/New() returns, client's can connect.
 * 1 second sleep
 * Master Controller initialization.
 * Subsystem initialization.
 * Non-compiled-in maps are maploaded, all atoms are new()ed
 * All atoms in both compiled and uncompiled maps are initialized()
 */
/world/New()
	log_world("World loaded at [time_stamp()]!")

	// From a really fucking old commit (91d7150)
	// I wanted to move it but I think this needs to be after /world/New is called but before any sleeps?
	// - Dominion/Cyberboss
	GLOB.timezoneOffset = world.timezone * 36000

	// First possible sleep()
	InitTgs()

	config.Load(params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])

	ConfigLoaded()

	if(NO_INIT_PARAMETER in params)
		return

	Master.Initialize(10, FALSE, TRUE)

	RunUnattendedFunctions()

/// Initializes TGS and loads the returned revising info into GLOB.revdata
/world/proc/InitTgs()
	TgsNew(new /datum/tgs_event_handler/impl, TGS_SECURITY_TRUSTED)
	GLOB.revdata.load_tgs_info()

/// Runs after config is loaded but before Master is initialized
/world/proc/ConfigLoaded()
	// Everything in here is prioritized in a very specific way.
	// If you need to add to it, ask yourself hard if what your adding is in the right spot
	// (i.e. basically nothing should be added before load_admins() in here)

	// Try to set round ID
	SSdbcore.InitializeRound()

	SetupLogs()

	load_admins(initial = TRUE)

	load_poll_data()

	// Initialize RETA system - code/modules/reta/reta_system.dm
	reta_init_config()

	LoadVerbs(/datum/verbs/menu)

	if(fexists(RESTART_COUNTER_PATH))
		GLOB.restart_counter = text2num(trim(file2text(RESTART_COUNTER_PATH)))
		fdel(RESTART_COUNTER_PATH)

/// Runs after the call to Master.Initialize, but before the delay kicks in. Used to turn the world execution into some single function then exit
/world/proc/RunUnattendedFunctions()
	#ifdef UNIT_TESTS
	HandleTestRun()
	#endif

	#ifdef AUTOWIKI
	setup_autowiki()
	#endif

/world/proc/HandleTestRun()
	//trigger things to run the whole process
	Master.sleep_offline_after_initializations = FALSE
	SSticker.start_immediately = TRUE
	CONFIG_SET(number/round_end_countdown, 0)
	var/datum/callback/cb
#ifdef UNIT_TESTS
	cb = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(RunUnitTests))
#else
	cb = VARSET_CALLBACK(SSticker, force_ending, ADMIN_FORCE_END_ROUND)
#endif
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_addtimer), cb, 10 SECONDS))

/// Returns a list of data about the world state, don't clutter
/world/proc/get_world_state_for_logging()
	var/data = list()
	data["tick_usage"] = world.tick_usage
	data["tick_lag"] = world.tick_lag
	data["time"] = world.time
	data["timestamp"] = rustg_unix_timestamp()
	return data

/world/proc/SetupLogs()
	var/override_dir = params[OVERRIDE_LOG_DIRECTORY_PARAMETER]
	if(!override_dir)
		var/realtime = world.realtime
		var/texttime = time2text(realtime, "YYYY/MM/DD", TIMEZONE_UTC)
		GLOB.log_directory = "data/logs/[texttime]/round-"
		GLOB.picture_logging_prefix = "L_[time2text(realtime, "YYYYMMDD", TIMEZONE_UTC)]_"
		GLOB.picture_log_directory = "data/picture_logs/[texttime]/round-"
		if(GLOB.round_id)
			GLOB.log_directory += "[GLOB.round_id]"
			GLOB.picture_logging_prefix += "R_[GLOB.round_id]_"
			GLOB.picture_log_directory += "[GLOB.round_id]"
		else
			var/timestamp = replacetext(time_stamp(), ":", ".")
			GLOB.log_directory += "[timestamp]"
			GLOB.picture_log_directory += "[timestamp]"
			GLOB.picture_logging_prefix += "T_[timestamp]_"
	else
		GLOB.log_directory = "data/logs/[override_dir]"
		GLOB.picture_logging_prefix = "O_[override_dir]_"
		GLOB.picture_log_directory = "data/picture_logs/[override_dir]"

	logger.init_logging()

	if(Tracy.trace_path)
		rustg_file_write("[Tracy.trace_path]", "[GLOB.log_directory]/tracy.loc")

	var/latest_changelog = file("[global.config.directory]/../html/changelogs/archive/" + time2text(world.timeofday, "YYYY-MM", TIMEZONE_UTC) + ".yml")
	GLOB.changelog_hash = fexists(latest_changelog) ? md5(latest_changelog) : 0 //for telling if the changelog has changed recently

	if(GLOB.round_id)
		log_game("Round ID: [GLOB.round_id]")

	// This was printed early in startup to the world log and config_error.log,
	// but those are both private, so let's put the commit info in the runtime
	// log which is ultimately public.
	log_runtime(GLOB.revdata.get_log_message())

#ifndef USE_CUSTOM_ERROR_HANDLER
	world.log = file("[GLOB.log_directory]/dd.log")
#else
	if (TgsAvailable()) // why
		world.log = file("[GLOB.log_directory]/dd.log") //not all runtimes trigger world/Error, so this is the only way to ensure we can see all of them.
#endif

// Tick control variables used in case something breaks
/// Should we intentionally consume cpu time to try to keep SendMaps deltas constant?
GLOBAL_VAR_INIT(attempt_corrective_cpu, TRUE)
/// Should we use the corrective cpu threshold to calculate the mc's target cpu?
GLOBAL_VAR_INIT(use_dynamic_mc_limit, TRUE)

// MC dynamic autoaccounting variables
/// What value are we attempting to correct cpu TO (autoaccounts for lag, ideally)
GLOBAL_VAR_INIT(corrective_cpu_threshold, 0)
/// What cpu value are we trying to meet safely
/// For reasons I do not yet understand 90 is too high for this on highpop. I think it has to do with
/// maptick being averaged/spikey? unsure.
GLOBAL_VAR_INIT(corrective_cpu_target, 85)
/// What cpu value we actually end up pinning the mc to, used for debug display
GLOBAL_VAR_INIT(corrective_cpu_cost, 0)
/// How far away from the average can we get before discarding a datapoint
GLOBAL_VAR_INIT(corrective_cpu_ratio, 30)
/// How far away from the average can we get before discarding a datapoint
GLOBAL_VAR_INIT(glide_threshold_ratio, 10)

// Debug tools
/// Lets us set the floor of cpu consumption
GLOBAL_VAR_INIT(floor_cpu, 0)
/// Lets us set a sometimes used floor for cpu consumption
GLOBAL_VAR_INIT(sustain_cpu, 0)
// Sets the chance to use GLOB.sustain_cpu as a floor
GLOBAL_VAR_INIT(sustain_cpu_chance, 0)
// Floors cpu to its value, then resets itself
GLOBAL_VAR_INIT(spike_cpu, 0)

/world/Tick()
	// this is for next tick so don't display it yet yeah?
	var/datum/tick_holder/tick_info = ____tick_info
	var/current_index = TICK_INFO_INDEX()
	if(tick_info)
		tick_info.pre_tick_cpu_usage[current_index] = TICK_USAGE
		// MC sometimes yields and such
		if(!tick_info.mc_fired(world.time))
			tick_info.mc_start_usage[current_index] = 0
			tick_info.mc_finished_usage[current_index] = 0

	refresh_cpu_values()
	if(GLOB.floor_cpu)
		// avoids byond sleeping the loop and causing the MC to infinistall
		// Run first to set a floor for sustain to spike up to
		CONSUME_UNTIL(min(GLOB.floor_cpu, 500))

	if(GLOB.sustain_cpu && prob(GLOB.sustain_cpu_chance))
		CONSUME_UNTIL(min(GLOB.sustain_cpu, 500))

	if(GLOB.spike_cpu)
		CONSUME_UNTIL(min(GLOB.spike_cpu, 10000))
		GLOB.spike_cpu = 0

	// attempt to correct cpu overrun
	var/cpu_corrected = FALSE
	// If we're supposed to be correcting cpu
	if(GLOB.attempt_corrective_cpu && GLOB.corrective_cpu_threshold > TICK_USAGE)
		cpu_corrected = TRUE
		CONSUME_UNTIL(GLOB.corrective_cpu_threshold)
	// or if we HAVE already corrected cpu with the MC (roughly, hard to be exact about this stuff)
	else if(GLOB.use_dynamic_mc_limit && GLOB.corrective_cpu_threshold + GLOB.corrective_cpu_threshold * 0.05 > TICK_USAGE)
		cpu_corrected = TRUE
	if(tick_info)
		tick_info.corrected_ticks[current_index] = cpu_corrected

	GLOB.cpu_tracker.update_display()

	if(tick_info)
		tick_info.tick_cpu_usage[current_index] = TICK_USAGE

	GLOB.verb_trackers_this_tick = list()

/// Holds and tracks information about the past [TICK_INFO_SIZE] ticks
/// Global datum, for real (Done to avoid dropping the first couple tick's worth of information, not actually required)
/datum/tick_holder
	var/name = "Tick Holder (DO NOT FUCK THIS UP)"
	// All of these lists are TICK_INFO_SIZE rolling lists
	/// Deaveraged world.cpu values (it's normally a 16 index long rolling average)
	var/list/cpu_values = new /list(TICK_INFO_SIZE)
	/// If the mc fired this stores the tick it happen in to avoid issues with mc sleeps leading to old data sticking around.
	var/list/mc_fired = new /list(TICK_INFO_SIZE)
	/// world.tick_usage when the mc first woke up (Should be the cost of sleeping procs invoked before the mc)
	var/list/mc_start_usage = new /list(TICK_INFO_SIZE)
	/// world.tick_usage when the mc falls back asleep
	var/list/mc_finished_usage = new /list(TICK_INFO_SIZE)
	/// difference between mc_finished_usage and mc_start_usage, provided for convenience
	var/list/mc_usage = new /list(TICK_INFO_SIZE)
	/// difference between pre_tick_cpu_usage and mc_finished_usage, provided for convenience (Should be just sleeping procs invoked post mc)
	var/list/post_mc_usage = new /list(TICK_INFO_SIZE)
	/// world.tick_usage at the begining of Tick()
	var/list/pre_tick_cpu_usage = new /list(TICK_INFO_SIZE)
	/// world.tick_usage at the end of Tick()
	var/list/tick_cpu_usage = new /list(TICK_INFO_SIZE)
	/// difference between cpu_values and tick_cpu_usage, provided for convenience (Should be exclusively the deaveraged cost of maptick)
	var/list/maptick_usage = new /list(TICK_INFO_SIZE)
	/// total verb cost, sum of verb tracker information
	var/list/verb_cost = new /list(TICK_INFO_SIZE)
	/// Parsed information from [GLOB.verb_trackers_this_tick]
	/// list( list( list(verb_started, verb_ended), ...), list( list(verb_cost), ...))
	var/list/verb_timings = new /list(TICK_INFO_SIZE)
	/// world.tick_usage we had when the last verb finished running
	var/list/last_verb_ran = new /list(TICK_INFO_SIZE)
	/// difference between our calculated world.cpu (from cpu_values) and the real one, for debugging
	var/list/cpu_error = new /list(TICK_INFO_SIZE)
	/// TRUE if we corrected the tick to try and target some threshold usage to avoid jitter, FALSE otherwise
	var/list/corrected_ticks = new /list(TICK_INFO_SIZE)
	/// Subsystems fired in the previous tick, paired with thier usage
	var/list/last_subsystem_usages = list()
	/// tick info index for the LAST tick, so we can fill in data we'd otherwise be missing
	var/cpu_index = 1
	/// last world.time refresh_cpu_values was ran
	var/last_cpu_update = -1

/// If the mc fired in the passed in tick (assuming it's within [TICK_INFO_SIZE] of our current tick)
/datum/tick_holder/proc/mc_fired(tick_inspecting)
	if(mc_fired[TICK_INFO_TICK2INDEX(DS2TICKS(tick_inspecting))] == tick_inspecting)
		return TRUE
	return FALSE

// Not initialized, because we have to do that manually
GLOBAL_REAL(____tick_info, /datum/tick_holder)
GLOBAL_DATUM(tick_info, /datum/tick_holder)

/// Pushes information about cpu usage from the last tick into our /datum/tick_holder
/world/proc/refresh_cpu_values()
	if(!____tick_info)
		____tick_info = new()
	if(GLOB)
		GLOB.tick_info = ____tick_info

	var/datum/tick_holder/tick_info = ____tick_info
	if(tick_info.last_cpu_update == world.time)
		return

	tick_info.last_cpu_update = world.time
	// info about the last game tick so it should be logged as the last game tick
	var/cpu_index = TICK_INFO_TICK2INDEX(DS2TICKS(world.time) - 1)
	tick_info.cpu_index = cpu_index
	// cache for sonic speed
	var/list/cpu_values = tick_info.cpu_values

	// ok so world.cpu is a 16 entry wide moving average of the actual cpu value
	// because fuck you
	// I want the ACTUAL unrolled value, which lucy's cool helpers can give me
	// yes byond does average against a constant window size, it doesn't account for a lack of values initially it just sorta assumes they exist.
	// I'd manually unroll it myself instead of using auxcpu, but unfortunately byond carries garbage data between soft reboots,
	// which makes this impossible even IF we had perfect info for each tick (which is already quite hard)
	// ♪ it ain't me, it ain't me ♪
	var/real_cpu = current_true_cpu()

	// Shit check our memhacking
	var/calculated_avg = real_cpu
	for(var/i in 1 to INTERNAL_CPU_SIZE - 1)
		calculated_avg += cpu_values[WRAP(cpu_index - i, 1, TICK_INFO_SIZE + 1)]
	// (95.7994 * 16) - 1536.35 == -3.3
	// (a+b+c+d...) / 16 * 16 - (a+b+c+d...) == -g
	var/inbuilt_error = world.cpu * INTERNAL_CPU_SIZE - calculated_avg

	// We have info about all verb costs last tick, let's unroll that and make it useful
	var/total_verb_cost
	// Windows of time that verbs have spanned
	var/list/verb_spans = list()
	// Costs of each verb, paired with verb_spans
	var/list/cost_breakdown = list()
	var/last_verb_finished = 0
	for(var/datum/verb_cost_tracker/verb_info as anything in GLOB.verb_trackers_this_tick)
		if(verb_info.invoked_on != verb_info.finished_on)
			stack_trace("We somehow slept between logpoints for [verb_info.name_to_use], ahhhhh ([json_encode(verb_info.vars)])")
			continue
		if(verb_info.finished_on != world.time - world.tick_lag)
			stack_trace("there's a verb we think is from last tick that happen this tick, what? ([json_encode(verb_info.vars)])")
			continue
		total_verb_cost += verb_info.usage_at_end - verb_info.usage_at_start
		verb_spans += list(list(verb_info.usage_at_start, verb_info.usage_at_end))
		last_verb_finished = max(last_verb_finished, verb_info.usage_at_end)
		cost_breakdown[verb_info.name_to_use] += verb_info.usage_at_end - verb_info.usage_at_start

	cpu_values[cpu_index] = real_cpu
	tick_info.mc_usage[cpu_index] = tick_info.mc_finished_usage[cpu_index] - tick_info.mc_start_usage[cpu_index]
	tick_info.post_mc_usage[cpu_index] = tick_info.pre_tick_cpu_usage[cpu_index] - tick_info.mc_finished_usage[cpu_index]
	// world.cpu is continuious cpu from tick start to right after maptick, so we can doooo this
	tick_info.maptick_usage[cpu_index] = cpu_values[cpu_index] - tick_info.tick_cpu_usage[cpu_index]
	tick_info.verb_cost[cpu_index] = total_verb_cost
	tick_info.verb_timings[cpu_index] = list(verb_spans, cost_breakdown)
	tick_info.last_verb_ran[cpu_index] = last_verb_finished
	tick_info.cpu_error[cpu_index] = inbuilt_error

/// Updates [GLOB.glide_size_multiplier] and [GLOB.corrective_cpu_threshold] to account for any persistant tidi we may be experiencing
/proc/update_cpu_compensation()
	world.refresh_cpu_values()
	var/datum/tick_holder/tick_info = ____tick_info
	var/list/cpu_values = tick_info.cpu_values
	var/list/corrected_ticks = tick_info.corrected_ticks

	// We've got a big ass list of cpu values from the last however many ticks
	// We want to know how much passive tick overrun we're experiencing, so we can:
	// A: Compensate clientside glide times to line up with how long we predict each tick to actually take
	// B: Pin cpu usage to a consistant value, so we can provide verbs time to execute and to ensure there is
	//   a consistent period of time between each map send to clients
	//   (since if things aren't consistent clients will have to jump frames, which leads to jitter)
	// In order to do this effectively we want to work out the average cpu cost, ignoring large spikes from uncontrolable parts of the codebase
	// We track capped (maxed out to 100) and corrected (touched by this system) usage seprately
	// capped is used for glide size, since we don't care if you're below 100% of the tick. we do for cpu pinning tho so we gotta do it differently
	var/capped_sum = 0
	var/non_zero = 0
	var/corrected_sum = 0
	var/non_zero_corrected = 0
	for(var/i in 1 to length(cpu_values))
		var/value = cpu_values[i]
		capped_sum += max(value, 100)
		if(corrected_ticks[i])
			corrected_sum += value
			if(value != 0)
				non_zero_corrected += 1
		if(value != 0)
			non_zero += 1

	var/first_capped_average = non_zero ? capped_sum / non_zero : 1
	var/trimmed_capped_sum = 0
	var/cap_used = 0
	var/first_corrected_average = non_zero_corrected ? corrected_sum / non_zero_corrected : 1
	var/trimmed_max_value = 0
	for(var/i in 1 to length(cpu_values))
		var/value = cpu_values[i]
		// If we're within 10% of the capped average, include us in the capped sum
		if(value && max(value, 100) / first_capped_average - 1 <= GLOB.glide_threshold_ratio / 100)
			trimmed_capped_sum += max(value, 100)
			cap_used += 1
		// If we deviate more then 30% above the average (since we care about filtering spikes), skip us over
		if(corrected_ticks[i] && value / first_corrected_average - 1 <= GLOB.corrective_cpu_ratio / 100)
			trimmed_max_value = max(value, trimmed_max_value)

	var/final_capped_average = trimmed_capped_sum ? trimmed_capped_sum / cap_used : first_capped_average
	GLOB.glide_size_multiplier = min(100 / final_capped_average, 1)

	var/final_corrected_value = trimmed_max_value ? trimmed_max_value : first_corrected_average
	if(final_corrected_value > GLOB.corrective_cpu_target)
		GLOB.corrective_cpu_threshold = GLOB.corrective_cpu_target - (final_corrected_value - GLOB.corrective_cpu_target)
		GLOB.corrective_cpu_cost = final_corrected_value
	else
		GLOB.corrective_cpu_threshold = GLOB.corrective_cpu_target
		GLOB.corrective_cpu_cost = 0

/world/Topic(T, addr, master, key)
	TGS_TOPIC //redirect to server tools if necessary

	var/static/list/topic_handlers = TopicHandlers()

	var/list/input = params2list(T)
	var/datum/world_topic/handler
	for(var/I in topic_handlers)
		if(I in input)
			handler = topic_handlers[I]
			break

	if((!handler || initial(handler.log)) && config && CONFIG_GET(flag/log_world_topic))
		log_topic("\"[T]\", from:[addr], master:[master], key:[key]")

	if(!handler)
		return

	handler = new handler()
	return handler.TryRun(input)

/world/proc/AnnouncePR(announcement, list/payload)
	var/static/list/PRcounts = list() //PR id -> number of times announced this round
	var/id = "[payload["pull_request"]["id"]]"
	if(!PRcounts[id])
		PRcounts[id] = 1
	else
		++PRcounts[id]
		if(PRcounts[id] > CONFIG_GET(number/pr_announcements_per_round))
			return

	var/final_composed = span_announce("PR: [announcement]")
	for(var/client/C in GLOB.clients)
		C.AnnouncePR(final_composed)

/world/proc/FinishTestRun()
	set waitfor = FALSE
	var/list/fail_reasons
	if(GLOB)
		if(GLOB.total_runtimes != 0)
			fail_reasons = list("Total runtimes: [GLOB.total_runtimes]")
#ifdef UNIT_TESTS
		if(GLOB.failed_any_test)
			LAZYADD(fail_reasons, "Unit Tests failed!")
#endif
		if(!GLOB.log_directory)
			LAZYADD(fail_reasons, "Missing GLOB.log_directory!")
	else
		fail_reasons = list("Missing GLOB!")
	if(!fail_reasons)
		text2file("Success!", "[GLOB.log_directory]/clean_run.lk")
	else
		log_world("Test run failed!\n[fail_reasons.Join("\n")]")
	sleep(0) //yes, 0, this'll let Reboot finish and prevent byond memes
	qdel(src) //shut it down

/// Returns TRUE if the world should do a TGS hard reboot.
/world/proc/check_hard_reboot()
	if(!TgsAvailable())
		return FALSE
	// byond-tracy can't clean up itself, and thus we should always hard reboot if its enabled, to avoid an infinitely growing trace.
	if(Tracy?.enabled)
		return TRUE
	var/ruhr = CONFIG_GET(number/rounds_until_hard_restart)
	switch(ruhr)
		if(-1)
			return FALSE
		if(0)
			return TRUE
		else
			if(GLOB.restart_counter >= ruhr)
				return TRUE
			else
				text2file("[++GLOB.restart_counter]", RESTART_COUNTER_PATH)
				return FALSE

/world/Reboot(reason = 0, fast_track = FALSE)
	if (reason || fast_track) //special reboot, do none of the normal stuff
		if (usr)
			log_admin("[key_name(usr)] Has requested an immediate world restart via client side debugging tools")
			message_admins("[key_name_admin(usr)] Has requested an immediate world restart via client side debugging tools")
		to_chat(world, span_boldannounce("Rebooting World immediately due to host request."))
	else
		to_chat(world, span_boldannounce("Rebooting world..."))
		Master.Shutdown() //run SS shutdowns

	#ifdef UNIT_TESTS
	FinishTestRun()
	return
	#else
	if(check_hard_reboot())
		log_world("World hard rebooted at [time_stamp()]")
		shutdown_logging() // See comment below.
		world.cleanup_external_cpu()
		QDEL_NULL(Tracy)
		QDEL_NULL(Debugger)
		TgsEndProcess()
		return ..()

	log_world("World rebooted at [time_stamp()]")

	shutdown_logging() // Past this point, no logging procs can be used, at risk of data loss.
	world.cleanup_external_cpu()
	QDEL_NULL(Tracy)
	QDEL_NULL(Debugger)

	TgsReboot() // TGS can decide to kill us right here, so it's important to do it last

	..()
	#endif

/world/Del()
	world.cleanup_external_cpu()
	QDEL_NULL(Tracy)
	QDEL_NULL(Debugger)
	. = ..()

/world/proc/update_status()

	var/list/features = list()

	if(LAZYACCESS(SSlag_switch.measures, DISABLE_NON_OBSJOBS))
		features += "closed"

	var/new_status = ""
	var/hostedby
	if(config)
		var/server_name = CONFIG_GET(string/servername)
		if (server_name)
			new_status += "<b>[server_name]</b> "
		if(CONFIG_GET(flag/allow_respawn))
			features += "respawn" // show "respawn" regardless of "respawn as char" or "free respawn"
		if(!CONFIG_GET(flag/allow_ai))
			features += "AI disabled"
		hostedby = CONFIG_GET(string/hostedby)

	if (CONFIG_GET(flag/station_name_in_hub_entry))
		new_status += " &#8212; <b>[station_name()]</b>"

	var/players = GLOB.clients.len

	game_state = (CONFIG_GET(number/extreme_popcap) && players >= CONFIG_GET(number/extreme_popcap)) //tells the hub if we are full

	if (!host && hostedby)
		features += "hosted by <b>[hostedby]</b>"

	if(length(features))
		new_status += ": [jointext(features, ", ")]"

	if(!SSticker || SSticker?.current_state == GAME_STATE_STARTUP)
		new_status += "<br><b>STARTING</b>"
	else if(SSticker)
		if(SSticker.current_state == GAME_STATE_PREGAME && SSticker.GetTimeLeft() > 0)
			new_status += "<br>Starting: <b>[round((SSticker.GetTimeLeft())/10)]</b>"
		else if(SSticker.current_state == GAME_STATE_SETTING_UP)
			new_status += "<br>Starting: <b>Now</b>"
		else if(SSticker.IsRoundInProgress())
			new_status += "<br>Time: <b>[time2text(STATION_TIME_PASSED(), "hh:mm", NO_TIMEZONE)]</b>"
			if(SSshuttle?.emergency && SSshuttle?.emergency?.mode != (SHUTTLE_IDLE || SHUTTLE_ENDGAME))
				new_status += " | Shuttle: <b>[SSshuttle.emergency.getModeStr()] [SSshuttle.emergency.getTimerStr()]</b>"
		else if(SSticker.current_state == GAME_STATE_FINISHED)
			new_status += "<br><b>RESTARTING</b>"
	if(SSmapping.current_map)
		new_status += "<br>Map: <b>[SSmapping.current_map.map_path == CUSTOM_MAP_PATH ? "Uncharted Territory" : SSmapping.current_map.map_name]</b>"
	if(SSmap_vote.next_map_config)
		new_status += "[SSmapping.current_map ? " | " : "<br>"]Next: <b>[SSmap_vote.next_map_config.map_path == CUSTOM_MAP_PATH ? "Uncharted Territory" : SSmap_vote.next_map_config.map_name]</b>"

	status = new_status

/world/proc/update_hub_visibility(new_visibility)
	if(new_visibility == GLOB.hub_visibility)
		return
	GLOB.hub_visibility = new_visibility
	if(GLOB.hub_visibility)
		hub_password = "kMZy3U5jJHSiBQjr"
	else
		hub_password = "SORRYNOPASSWORD"

/**
 * Handles increasing the world's maxx var and initializing the new turfs and assigning them to the global area.
 * If map_load_z_cutoff is passed in, it will only load turfs up to that z level, inclusive.
 * This is because maploading will handle the turfs it loads itself.
 */
/world/proc/increase_max_x(new_maxx, map_load_z_cutoff = maxz)
	if(new_maxx <= maxx)
		return
	var/old_max = world.maxx
	maxx = new_maxx
	if(!map_load_z_cutoff)
		return
	var/area/global_area = GLOB.areas_by_type[world.area] // We're guaranteed to be touching the global area, so we'll just do this
	LISTASSERTLEN(global_area.turfs_by_zlevel, map_load_z_cutoff, list())
	for (var/zlevel in 1 to map_load_z_cutoff)
		var/list/to_add = block(
			old_max + 1, 1, zlevel,
			maxx, maxy, zlevel
		)

		global_area.turfs_by_zlevel[zlevel] += to_add

/world/proc/increase_max_y(new_maxy, map_load_z_cutoff = maxz)
	if(new_maxy <= maxy)
		return
	var/old_maxy = maxy
	maxy = new_maxy
	if(!map_load_z_cutoff)
		return
	var/area/global_area = GLOB.areas_by_type[world.area] // We're guaranteed to be touching the global area, so we'll just do this
	LISTASSERTLEN(global_area.turfs_by_zlevel, map_load_z_cutoff, list())
	for (var/zlevel in 1 to map_load_z_cutoff)
		var/list/to_add = block(
			1, old_maxy + 1, 1,
			maxx, maxy, map_load_z_cutoff
		)
		global_area.turfs_by_zlevel[zlevel] += to_add

/world/proc/incrementMaxZ()
	maxz++
	SSmobs.MaxZChanged()
	SSai_controllers.on_max_z_changed()

/world/proc/change_fps(new_value = 20)
	if(new_value <= 0)
		CRASH("change_fps() called with [new_value] new_value.")
	if(fps == new_value)
		return //No change required.

	fps = new_value
	on_tickrate_change()


/world/proc/change_tick_lag(new_value = 0.5)
	if(new_value <= 0)
		CRASH("change_tick_lag() called with [new_value] new_value.")
	if(tick_lag == new_value)
		return //No change required.

	tick_lag = new_value
	on_tickrate_change()


/world/proc/on_tickrate_change()
	SStimer?.reset_buckets()
#ifndef DISABLE_DREAMLUAU
	DREAMLUAU_SET_EXECUTION_LIMIT_MILLIS(tick_lag * 100)
#endif

/world/Profile(command, type, format)
	if((command & PROFILE_STOP) || !global.config?.loaded || !CONFIG_GET(flag/forbid_all_profiling))
		. = ..()

#undef NO_INIT_PARAMETER
#undef OVERRIDE_LOG_DIRECTORY_PARAMETER
#undef USE_TRACY_PARAMETER
#undef RESTART_COUNTER_PATH

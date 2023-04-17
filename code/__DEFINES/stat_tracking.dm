#define STAT_ENTRY_TIME 1
#define STAT_ENTRY_COUNT 2
#define STAT_ENTRY_LENGTH 2


#define STAT_START_STOPWATCH var/STAT_STOP_WATCH = TICK_USAGE
#define STAT_STOP_STOPWATCH var/STAT_TIME = TICK_USAGE_TO_MS(STAT_STOP_WATCH)
#define STAT_LOG_ENTRY(entrylist, entryname) \
	var/list/STAT_ENTRY = entrylist[entryname] || (entrylist[entryname] = new /list(STAT_ENTRY_LENGTH));\
	STAT_ENTRY[STAT_ENTRY_TIME] += STAT_TIME;\
	STAT_ENTRY[STAT_ENTRY_COUNT] += 1;

// Cost tracking macros, to be used in one proc. If you're using this raw you'll want to use global lists
// If you don't you'll need another way of reading it
#define INIT_COST(costs, counting) \
	var/list/_costs = costs; \
	var/list/_counting = counting; \
	var/_usage = TICK_USAGE;

// STATIC cost tracking macro. Uses static lists instead of the normal global ones
// Good for debug stuff, and for running before globals init
#define INIT_COST_STATIC(...) \
	var/static/list/hidden_static_list_for_fun1 = list(); \
	var/static/list/hidden_static_list_for_fun2 = list(); \
	INIT_COST(hidden_static_list_for_fun1, hidden_static_list_for_fun2)

// Cost tracking macro for global lists, prevents erroring if GLOB has not yet been initialized
#define INIT_COST_GLOBAL(costs, counting) \
	INIT_COST_STATIC() \
	if(GLOB){\
		costs = hidden_static_list_for_fun1; \
		counting = hidden_static_list_for_fun2 ; \
	} \
	_usage = TICK_USAGE;


#define SET_COST(category) \
	do { \
		var/_cost = TICK_USAGE; \
		_costs[category] += TICK_DELTA_TO_MS(_cost - _usage);\
		_counting[category] += 1; \
	} while(FALSE); \
	_usage = TICK_USAGE;

#define SET_COST_LINE(...) SET_COST("[__LINE__]")

/// A quick helper for running the code as a statement and profiling its cost.
/// For example, `SET_COST_STMT(var/x = do_work())`
#define SET_COST_STMT(code...) ##code; SET_COST("[__LINE__] - [#code]")

#define EXPORT_STATS_TO_JSON_LATER(filename, costs, counts) EXPORT_STATS_TO_FILE_LATER(filename, costs, counts, stat_tracking_export_to_json_later)
#define EXPORT_STATS_TO_CSV_LATER(filename, costs, counts) EXPORT_STATS_TO_FILE_LATER(filename, costs, counts, stat_tracking_export_to_csv_later)

#define EXPORT_STATS_TO_FILE_LATER(filename, costs, counts, proc) \
	do { \
		var/static/last_export = 0; \
		if (world.time - last_export > 1.1 SECONDS) { \
			last_export = world.time; \
			/* spawn() is used here because this is often used to track init times, where timers act oddly. */ \
			/* I was making timers and even after init times were complete, the timers didn't run :shrug: */ \
			spawn (1 SECONDS) { \
				##proc(filename, costs, counts); \
			} \
		} \
	} while (FALSE); \
	_usage = TICK_USAGE;

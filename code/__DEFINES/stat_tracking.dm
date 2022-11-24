#define STAT_ENTRY_TIME 1
#define STAT_ENTRY_COUNT 2
#define STAT_ENTRY_LENGTH 2


#define STAT_START_STOPWATCH var/STAT_STOP_WATCH = TICK_USAGE
#define STAT_STOP_STOPWATCH var/STAT_TIME = TICK_USAGE_TO_MS(STAT_STOP_WATCH)
#define STAT_LOG_ENTRY(entrylist, entryname) \
	var/list/STAT_ENTRY = entrylist[entryname] || (entrylist[entryname] = new /list(STAT_ENTRY_LENGTH));\
	STAT_ENTRY[STAT_ENTRY_TIME] += STAT_TIME;\
	STAT_ENTRY[STAT_ENTRY_COUNT] += 1;

// Cost tracking macros, to be used in one proc
// The static lists are under the assumption that costs and counting are global lists, and will therefor
// Break during world init
#define INIT_COST(costs, counting) \
	var/list/_costs = costs; \
	var/list/_counting = counting; \
	var/usage = TICK_USAGE;

// Cost tracking macro for global lists, prevents erroring if GLOB has not yet been initialized
#define INIT_COST_GLOBAL(costs, counting) \
	var/static/list/hidden_static_list_for_fun1 = list(); \
	var/static/list/hidden_static_list_for_fun2 = list(); \
	if(GLOB){\
		costs = hidden_static_list_for_fun1; \
		counting = hidden_static_list_for_fun2 ; \
	} \
	INIT_COST(hidden_static_list_for_fun1, hidden_static_list_for_fun2)

#define SET_COST(category) \
	do { \
		var/cost = TICK_USAGE; \
		_costs[category] += TICK_DELTA_TO_MS(cost - usage);\
		_counting[category] += 1; \
	} while(FALSE); \
	usage = TICK_USAGE;

#define SET_COST_LINE(...) SET_COST("[__LINE__]")

#define EXPORT_STATS_TO_FILE_LATER(filename, costs, counts) \
	do { \
		var/static/last_export = 0; \
		if (world.time - last_export > 1.1 SECONDS) { \
			last_export = world.time; \
			/* spawn() is used here because this is often used to track init times, where timers act oddly. */ \
			/* I was making timers and even after init times were complete, the timers didn't run :shrug: */ \
			spawn (1 SECONDS) { \
				stat_tracking_export_to_file_later(filename, costs, counts); \
			} \
		} \
	} while (FALSE);

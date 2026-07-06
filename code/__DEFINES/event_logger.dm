//  Event Logger macros. The logging functions only run if the logger is active and the datum being logged has the DF_EVLOGGING flag set. This makes logging itself relatively cheap when not in use.
/// Log a plain text event.
#define EVLOG_TEXT(DATUM, CATEGORY, INFO) \
	if(GLOB.event_logger.running && (DATUM.datum_flags & DF_EVLOGGING)) \
		{ GLOB.event_logger.log_event_text(DATUM, CATEGORY, INFO) }

/// Log a location event that highlights a single tile when selected.
/// TURF is a /turf. DATUM must have DF_EVLOGGING set.
#define EVLOG_LOCATION(DATUM, CATEGORY, INFO, TURF) \
	if(GLOB.event_logger.running && (DATUM.datum_flags & DF_EVLOGGING)) \
		{ GLOB.event_logger.log_event_location(DATUM, CATEGORY, INFO, TURF) }

/// Log a turfs event that highlights a set of tiles when selected.
/// TURFS is a list of /turf. DATUM must have DF_EVLOGGING set.
#define EVLOG_TURFS(DATUM, CATEGORY, INFO, TURFS) \
	if(GLOB.event_logger.running && (DATUM.datum_flags & DF_EVLOGGING)) \
		{ GLOB.event_logger.log_event_turfs(DATUM, CATEGORY, INFO, TURFS) }

/// Log a line event that highlights a path from one tile to another when selected.
/// TURF_A and TURF_B are /turf. DATUM must have DF_EVLOGGING set.
#define EVLOG_LINES(DATUM, CATEGORY, INFO, TURF_A, TURF_B) \
	if(GLOB.event_logger.running && (DATUM.datum_flags & DF_EVLOGGING)) \
		{ GLOB.event_logger.log_event_lines(DATUM, CATEGORY, INFO, TURF_A, TURF_B) }

/// Log a path event that renders directional arrows + start/end markers when selected.
/// TURFS is an ordered list of /turf. DATUM must have DF_EVLOGGING set.
#define EVLOG_PATH(DATUM, CATEGORY, INFO, TURFS) \
	if(GLOB.event_logger.running && (DATUM.datum_flags & DF_EVLOGGING)) \
		{ GLOB.event_logger.log_event_path(DATUM, CATEGORY, INFO, TURFS) }

/// Log a maptext event that renders a floating text string at a turf when selected.
/// TURF is a /turf. TEXT is the string to display. DATUM must have DF_EVLOGGING set.
#define EVLOG_MAPTEXT(DATUM, CATEGORY, INFO, TURF, TEXT) \
	if(GLOB.event_logger.running && (DATUM.datum_flags & DF_EVLOGGING)) \
		{ GLOB.event_logger.log_event_maptext(DATUM, CATEGORY, INFO, TURF, TEXT) }


/// Append a categorized title and entry to a track_info snapshot list.
#define EVLOG_TRACK_INFO_ENTRY(LIST, CATEGORY, KEY, VALUE) \
	LIST += list(list("category" = CATEGORY, "title" = KEY, "entry" = VALUE))

#define IS_EVLOGGING GLOB.event_logger.running


///All the types of log entries we have.

#define EVLOG_TYPE_TEXT "text"
#define EVLOG_TYPE_LOCATION "location"
#define EVLOG_TYPE_TURFS "turfs"
#define EVLOG_TYPE_LINES "lines"
#define EVLOG_TYPE_PATH "path"
#define EVLOG_TYPE_MAPTEXT "maptext"



///Categories go here. Put sane names in the string since they get displayed.
#define EVLOG_CATEGORY_MOVELOOPS "Moveloops"
#define EVLOG_CATEGORY_JPS "JPS"
#define EVLOG_CATEGORY_AI_DECISIONMAKING "AI Decisionmaking"
#define EVLOG_CATEGORY_AI_BEHAVIORS "AI Behaviors"
#define EVLOG_CATEGORY_AI_TARGETING "AI Targeting"

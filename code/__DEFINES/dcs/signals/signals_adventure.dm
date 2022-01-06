/// Exoprobe adventure finished: (result) result is ADVENTURE_RESULT_??? values
#define COMSIG_ADVENTURE_FINISHED "adventure_done"

/// Sent on initial adventure qualities generation from /datum/adventure/proc/initialize_qualities(): (list/quality_list)
#define COMSIG_ADVENTURE_QUALITY_INIT "adventure_quality_init"

/// Sent on adventure node delay start: (delay_time, delay_message)
#define COMSIG_ADVENTURE_DELAY_START "adventure_delay_start"
/// Sent on adventure delay finish: ()
#define COMSIG_ADVENTURE_DELAY_END "adventure_delay_end"

/// Exoprobe status changed : ()
#define COMSIG_EXODRONE_STATUS_CHANGED "exodrone_status_changed"

// Scanner controller signals
/// Sent on begingging of new scan : (datum/exoscan/new_scan)
#define COMSIG_EXOSCAN_STARTED "exoscan_started"
/// Sent on successful finish of exoscan: (datum/exoscan/finished_scan)
#define COMSIG_EXOSCAN_FINISHED "exoscan_finished"

// Exosca signals
/// Sent on exoscan failure/manual interruption: ()
#define COMSIG_EXOSCAN_INTERRUPTED "exoscan_interrupted"

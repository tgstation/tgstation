// Subsystem signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///Subsystem signals
///From base of datum/controller/subsystem/Initialize: (start_timeofday)
#define COMSIG_SUBSYSTEM_POST_INITIALIZE "subsystem_post_initialize"

///Called when the ticker enters the pre-game phase
#define COMSIG_TICKER_ENTER_PREGAME "comsig_ticker_enter_pregame"

///Called when the ticker sets up the game for start
#define COMSIG_TICKER_ENTER_SETTING_UP "comsig_ticker_enter_setting_up"

///Called when the ticker fails to set up the game for start
#define COMSIG_TICKER_ERROR_SETTING_UP "comsig_ticker_error_setting_up"

/// Called when the round has started, but before GAME_STATE_PLAYING
#define COMSIG_TICKER_ROUND_STARTING "comsig_ticker_round_starting"

// Point of interest signals
/// Sent from base of /datum/controller/subsystem/points_of_interest/proc/on_poi_element_added : (atom/new_poi)
#define COMSIG_ADDED_POINT_OF_INTEREST "added_point_of_interest"
/// Sent from base of /datum/controller/subsystem/points_of_interest/proc/on_poi_element_removed : (atom/old_poi)
#define COMSIG_REMOVED_POINT_OF_INTEREST "removed_point_of_interest"

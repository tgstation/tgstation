/// Key that holds a nearby vent that looks like it's a good place to hide
#define BB_ENTRY_VENT_TARGET "BB_entry_vent_target"
/// Key that holds a vent that we want to exit out of (when we're already in a pipenet)
#define BB_EXIT_VENT_TARGET "BB_exit_vent_target"
/// Do we plan on going inside a vent? Boolean.
#define BB_CURRENTLY_TARGETTING_VENT "BB_currently_targetting_vent"
/// How long should we wait before we try and enter a vent again?
#define BB_VENTCRAWL_COOLDOWN "BB_ventcrawl_cooldown"
/// The least amount of time (in seconds) we take to go through the vents.
#define BB_LOWER_VENT_TIME_LIMIT "BB_lower_vent_time_limit"
/// The most amount of time (in seconds) we take to go through the vents.
#define BB_UPPER_VENT_TIME_LIMIT "BB_upper_vent_time_limit"
/// How much time (in seconds) do we take until we completely go bust on vent pathing?
#define BB_TIME_TO_GIVE_UP_ON_VENT_PATHING "BB_seconds_until_we_give_up_on_vent_pathing"
/// The timer ID of the timer that makes us give up on vent pathing.
#define BB_GIVE_UP_ON_VENT_PATHING_TIMER_ID "BB_give_up_on_vent_pathing_timer_id"

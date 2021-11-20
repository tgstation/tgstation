/// Sent from /obj/structure/industrial_lift/tram when its travelling status updates. (travelling)
#define COMSIG_TRAM_SET_TRAVELLING "tram_set_travelling"

/// Sent from /obj/structure/industrial_lift/tram when it begins to travel. (obj/effect/landmark/tram/from_where, obj/effect/landmark/tram/to_where)
#define COMSIG_TRAM_TRAVEL "tram_travel"

/// Called in /obj/structure/moneybot/add_money(). (to_add)
#define COMSIG_MONEYBOT_ADD_MONEY "moneybot_add_money"

/// Called in /obj/structure/dispenserbot/add_item(). (obj/item/to_add)
#define COMSIG_DISPENSERBOT_ADD_ITEM "moneybot_add_item"

/// Called in /obj/structure/dispenserbot/remove_item(). (obj/item/to_remove)
#define COMSIG_DISPENSERBOT_REMOVE_ITEM "moneybot_remove_item"

/// Called when somebody passes through a scanner gate and it triggers
#define COMSIG_SCANGATE_PASS_TRIGGER "scangate_pass_trigger"

/// Called when somebody passes through a scanner gate and it does not trigger
#define COMSIG_SCANGATE_PASS_NO_TRIGGER "scangate_pass_no_trigger"

/// Called when something passes through a scanner gate shell
#define COMSIG_SCANGATE_SHELL_PASS "scangate_shell_pass"
// Alarm listener datum signals
///Sent when an alarm is fired (alarm, area/source_area)
#define COMSIG_ALARM_TRIGGERED "comsig_alarm_triggered"
///Send when an alarm source is cleared (alarm_type, area/source_area)
#define COMSIG_ALARM_CLEARED "comsig_alarm_clear"
// Vacuum signals
/// Called on a bag being attached to a vacuum parent
#define COMSIG_VACUUM_BAG_ATTACH "comsig_vacuum_bag_attach"
/// Called on a bag being detached from a vacuum parent
#define COMSIG_VACUUM_BAG_DETACH "comsig_vacuum_bag_detach"

// Organ signals
/// Called on the organ when it is implanted into someone (mob/living/carbon/receiver)
#define COMSIG_ORGAN_IMPLANTED "comsig_organ_implanted"

/// Called on the organ when it is removed from someone (mob/living/carbon/old_owner)
#define COMSIG_ORGAN_REMOVED "comsig_organ_removed"

///Called when the ticker enters the pre-game phase
#define COMSIG_TICKER_ENTER_PREGAME "comsig_ticker_enter_pregame"

///Called when the ticker sets up the game for start
#define COMSIG_TICKER_ENTER_SETTING_UP "comsig_ticker_enter_setting_up"

///Called when the ticker fails to set up the game for start
#define COMSIG_TICKER_ERROR_SETTING_UP "comsig_ticker_error_setting_up"

/// Called when the round has started, but before GAME_STATE_PLAYING
#define COMSIG_TICKER_ROUND_STARTING "comsig_ticker_round_starting"

#define COMSIG_GREYSCALE_CONFIG_REFRESHED "greyscale_config_refreshed"

// Point of interest signals
/// Sent from base of /datum/controller/subsystem/points_of_interest/proc/on_poi_element_added : (atom/new_poi)
#define COMSIG_ADDED_POINT_OF_INTEREST "added_point_of_interest"
/// Sent from base of /datum/controller/subsystem/points_of_interest/proc/on_poi_element_removed : (atom/old_poi)
#define COMSIG_REMOVED_POINT_OF_INTEREST "removed_point_of_interest"

//Cytology signals
///Sent from /datum/biological_sample/proc/reset_sample
#define COMSIG_SAMPLE_GROWTH_COMPLETED "sample_growth_completed"
	#define SPARE_SAMPLE (1<<0)

// Radiation signals

/// From the radiation subsystem, called before a potential irradiation.
/// This does not guarantee radiation can reach or will succeed, but merely that there's a radiation source within range.
/// (datum/radiation_pulse_information/pulse_information, insulation_to_target)
#define COMSIG_IN_RANGE_OF_IRRADIATION "in_range_of_irradiation"

/// Fired when the target could be irradiated, right before the chance check is rolled.
/// (datum/radiation_pulse_information/pulse_information)
#define COMSIG_IN_THRESHOLD_OF_IRRADIATION "pre_potential_irradiation_within_range"
	#define CANCEL_IRRADIATION (1 << 0)

	/// If this is flipped, then minimum exposure time will not be checked.
	/// If it is not flipped, and the pulse information has a minimum exposure time, then
	/// the countdown will begin.
	#define SKIP_MINIMUM_EXPOSURE_TIME_CHECK (1 << 1)

/// Fired when scanning something with a geiger counter.
/// (mob/user, obj/item/geiger_counter/geiger_counter)
#define COMSIG_GEIGER_COUNTER_SCAN "geiger_counter_scan"
	/// If not flagged by any handler, will report the subject as being free of irradiation
	#define COMSIG_GEIGER_COUNTER_SCAN_SUCCESSFUL (1 << 0)

/// Called when a techweb design is researched (datum/design/researched_design, custom)
#define COMSIG_TECHWEB_ADD_DESIGN "techweb_add_design"

/// Called when a techweb design is removed (datum/design/removed_design, custom)
#define COMSIG_TECHWEB_REMOVE_DESIGN "techweb_remove_design"

// Antagonist signals
/// Called on the mind when an antagonist is being gained, after the antagonist list has updated (datum/antagonist/antagonist)
#define COMSIG_ANTAGONIST_GAINED "antagonist_gained"

/// Called on the mind when an antagonist is being removed, after the antagonist list has updated (datum/antagonist/antagonist)
#define COMSIG_ANTAGONIST_REMOVED "antagonist_removed"
///Restaurant

///(customer, container) venue signal sent when a venue sells an item. source is the thing sold, which can be a datum, so we send container for location checks
#define COMSIG_ITEM_SOLD_TO_CUSTOMER "item_sold_to_customer"
//Xenobio hotkeys

///from slime CtrlClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_CTRL "xeno_slime_click_ctrl"
///from slime AltClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_ALT "xeno_slime_click_alt"
///from slime ShiftClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_SHIFT "xeno_slime_click_shift"
///from turf ShiftClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_SHIFT "xeno_turf_click_shift"
///from turf AltClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_CTRL "xeno_turf_click_alt"
///from monkey CtrlClickOn(): (/mob)
#define COMSIG_XENO_MONKEY_CLICK_CTRL "xeno_monkey_click_ctrl"
///sent to everyone in range of being affected by mask of madness
#define COMSIG_VOID_MASK_ACT "void_mask_act"

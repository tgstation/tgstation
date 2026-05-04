/// Exploration event
/datum/exploration_event
	/// These types will be ignored in event creation
	abstract_type = /datum/exploration_event
	///This name will show up in exploration list if it's repeatable
	var/name = "Something interesting"
	/// encountered at least once
	var/visited = FALSE
	/// Modifies site scan results by these
	var/band_values
	/// This will be added to site description, mind this will most likely reveal presence of this event early if set.
	var/site_description_mod
	/// message logged when first encountering the event.
	var/discovery_log
	/// Exploration site required_traits for this event to show up
	var/required_site_traits
	/// If these site traits are present the event won't show up
	var/blacklisted_site_traits
	/// Optional description that will be added to site description when point scan is completed.
	var/point_scan_description
	/// Optional description that will be added to site description when point scan is completed.
	var/deep_scan_description

/// Main event functionality, called when exploring randomly/revisiting.
/datum/exploration_event/proc/encounter(obj/item/exodrone/drone)
	SHOULD_CALL_PARENT(TRUE)
	if(!visited)
		var/log = get_discovery_message(drone)
		if(log)
			drone.drone_log(log)
	visited = TRUE

/// Override this if you need to modify discovery message
/datum/exploration_event/proc/get_discovery_message(obj/item/exodrone/drone)
	return discovery_log

/// Should this event show up on site exploration list.
/datum/exploration_event/proc/is_targetable()
	return FALSE

/// Simple events, not a full fledged adventure, consist only of single encounter screen
/datum/exploration_event/simple
	abstract_type = /datum/exploration_event/simple
	var/ui_image = "default"
	/// Show ignore button.
	var/skippable = TRUE
	/// Ignore button text
	var/ignore_text = "Ignore"
	/// Action text, can be further parametrized in get_action_text()
	var/action_text = "encounter"
	/// Description, can be further parametrized in get_description()
	var/description = "You encounter a bug."

/// On exploration, only display our information with the act/ignore options
/datum/exploration_event/simple/encounter(obj/item/exodrone/drone)
	. = ..()
	drone.current_event_ui_data = build_ui_event(drone)

/// After choosing not to ignore the event, THIS IS DONE AFTER UNKNOWN DELAY SO YOU NEED TO VALIDATE IF ACTION IS POSSIBLE AGAIN
/datum/exploration_event/simple/proc/fire(obj/item/exodrone/drone)
	return

/// Ends simple event and cleans up display data
/datum/exploration_event/simple/proc/end(obj/item/exodrone/drone)
	drone.current_event_ui_data = null

/// Description shown below image
/datum/exploration_event/simple/proc/get_description(obj/item/exodrone/drone)
	return description

/// Text on the act button
/datum/exploration_event/simple/proc/get_action_text(obj/item/exodrone/drone)
	return action_text

/// Button to act disabled or not
/datum/exploration_event/simple/proc/action_enabled(obj/item/exodrone/drone)
	return TRUE

/// Creates ui data for displaying the event
/datum/exploration_event/simple/proc/build_ui_event(obj/item/exodrone/drone)
	. = list()
	.["image"] = ui_image
	.["description"] = get_description(drone)
	.["action_enabled"] = action_enabled(drone)
	.["action_text"] = get_action_text(drone)
	.["skippable"] = skippable
	.["ignore_text"] = ignore_text
	.["ref"] = ref(src)

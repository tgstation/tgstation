/// Parent will send a warning message that it's in a space area, because people can slip and fall into other z-levels and lose the item.
#define IN_SPACE "In Space"
/// Parent will send a warning message that it's in a mining zone, it's not fond of the climate and animals found in this zone so it'll be unhappy.
#define IN_MINING "In Mining"
/// Parent is outside in the rocky wastes of the icemoon, how tragic. It's not happy about that.
#define IN_ICEMOON "In Icemoon"
/// Parent will send a message about how we're on a good shuttle going to a valid location! Yippie!
#define ON_FAVORABLE_SHUTTLE "On Favorable Shuttle"
/// Parent will send a message about how this shuttle goes somewhere we don't want to go! Uh-oh!
#define ON_UNFAVORABLE_SHUTTLE "On Unfavorable Shuttle"
/// Parent will send a message about the nice amenities of the Syndicate Shuttle they are currently on.
#define ON_SYNDICATE_SHUTTLE "On Syndicate Shuttle"
/// Parent will send a message about how we're safe inside the station. Just chilling out and hanging around. Good times.
#define ON_STATION "On Station"
/// Parent will send a message about how they're thankful that they're safe inside the station. Could also be considered a "Clingy Timer End Message" in how we use it.
#define BACK_INSIDE_STATION "Back Inside Station"
/// Parent will send a callous message to anyone who can hear it right before it zoops away.
#define PISSING_OFF "Pissing Off"
/// Parent will send a message about how it's going to start counting down until you put it back in a station area.
#define CLINGY_TIMER_START_MESSAGE "Clingy Timer Start Message"

#define COMPONENT_FORCED_SPEAK_NAME "Clingy Stationloving Component"

///Subtype of stationloving component where the disk is "clingy to the station."
/datum/component/stationloving/clingy
	/// Boolean that tracks if this disk is "clingy". In short terms, "clingy" disks are more strict about where they can be placed (as in being more resistant to being in a non-station area)
	/// This variable will enhance the behavior to give more user feedback as to it's preferences. It's more annoying to have to deal with, but such is the cost for being the bearer of such an important item.
	var/clingy = TRUE
	/// Boolean that tracks if we are currently processing behavior related to clinginess. Prevents message flooding (lag, things happening during timers), and allows graceful overrides of certain actions.
	var/clingy_handling = FALSE
	/// Number of seconds we create a bound-checking timer for. This only matters in clingy mode, and it's how long the item-holder has to get back to a safe zone.
	var/clingy_timer_duration = 30 SECONDS
	/// Are we currently on a cooldown for the (unimportant) messaging tree? This is to prevent spamming the user with messages. Don't use this for the important stuff, like the off-station timer.
	/// Default to using clingy_timer_duration as the actual length of the cooldown.
	COOLDOWN_DECLARE(unimportant_clingy_message_cooldown)
	/// The file name of the JSON strings file that we will use to get our messages from. Default to using the one for the Nuclear Disk file, but make up your own strings to be pertinent to the object should you choose to deviate.
	var/strings_file = NUCLEAR_DISK_FILE
	/// Area cache, used for instances where we just want to quickly check if our area has mismatched so we can dispatch a message.
	var/area/last_cached_area

	/// Typecache of areas that are considered "outdoors" on the station Z-level. This is... everything that's not reasonably a station area (/area/station subtypes)
	var/static/list/outdoors_areas = typecacheof(list(
		/area/icemoon,
		/area/lavaland, // planetary maps could use lavaland areas!
		/area/mine,
	))

/datum/component/stationloving/clingy/Initialize(inform_admins = FALSE, allow_item_destruction = FALSE, clingy = FALSE, clingy_timer_duration = 30 SECONDS, strings_file)
	src.clingy = clingy
	src.clingy_timer_duration = clingy_timer_duration
	src.strings_file = strings_file

	return ..()

/datum/component/stationloving/clingy/relocate()
	if(clingy_handling)
		return

	clingy_handling = TRUE
	// Give it a second in case we're switching z-levels so the user can actually hear the message, and then teleport it back a second after their mistake is made and all they can do is watch in horror.
	addtimer(CALLBACK(src, .proc/clingy_message, PISSING_OFF), 1 SECONDS)
	addtimer(CALLBACK(src, .proc/full_move, target_turf), 2 SECONDS)
	return target_turf

/datum/component/stationloving/clingy/full_move(turf/location_turf)
	// Set clingy handling to FALSE here, we have exhausted all possible avenues of user feedback and we're now resetting our state.
	clingy_handling = FALSE
	return ..()

/// Add arg clingy_timer_expired as TRUE for a special log if that did occur.
/datum/component/stationloving/clingy/generate_logs(atom/source, turf/destination_turf, turf/final_turf, loc_changed = TRUE, clingy_timer_expired = FALSE)
	if(clingy_timer_expired)
		log_game("The [DisplayTimeText(clingy_timer_duration)] timer on [parent] ran out after finding itself in [loc_name(source)], \
		so it has been moved to [loc_name(final_turf)] from it's final recorded position of [loc_name(destination_turf)].")

		if(inform_admins)
			message_admins("The [DisplayTimeText(clingy_timer_duration)] timer on [parent] ran out after finding itself in [loc_name(source)], \
			so it has been moved to [ADMIN_VERBOSEJMP(final_turf)] from it's final recorded position of [ADMIN_VERBOSEJMP(destination_turf)].")

	return ..()

/datum/component/stationloving/clingy/atom_in_bounds(atom/atom_to_check)
	if(is_station_level(destination_turf.z))
		if(!clingy)
			return TRUE
		if(!validate_parent_area(atom_to_check))
			return clingy_outdoors_setup() // if passed, we over-write the rest of the proc here, just in case we're doing some clingy handling timers and such
		else
			clingy_messaging_tree()
			return TRUE

	return ..()

/// An area-checker useful for rapid checking if we're in an outdoors area.
/datum/component/stationloving/clingy/proc/validate_parent_area(atom/atom_to_check)
	var/area/destination_area = get_area(atom_to_check)

	if(istype(destination_area, /area/station))
		return TRUE
	else if(is_type_in_typecache(destination_area, outdoors_areas))
		return FALSE
	else
		return TRUE // we're probably fine since we're in some sort of edge-case yet still on a station z-level.

/// Sets up the clingy timer to run (async) if that hasn't already been set up earlier.
/datum/component/stationloving/cling/proc/clingy_outdoors_setup()
	// This is here so we don't have to go through and summon the async timer if we're already doing something.
	if(clingy_handling)
		return TRUE

	var/atom/movable/object = parent
	var/object_area = get_area(object)
	var/object_first_turf = get_turf(object)

	// Everything is assembled, it's hustle time.
	clingy_handling = TRUE
	clingy_message(determine_appropriate_message(object_area))

	addtimer(CALLBACK(src, .proc/clingy_message, CLINGY_TIMER_START_MESSAGE), 1.5 SECONDS) // little bit of a delay to make it look more natural even though the timers spitting out messages
	INVOKE_ASYNC(src, .proc/clingy_timer_handling, object, object_first_turf)

	// Whenever we are called, we are in a valid station z-level, just in an invalid area, and we'll let the above async'd timer handle the rest.
	return TRUE

/// The actual timer we use when we are in an outdoors area, but still on a valid z-level otherwise. Call asynchonously so we don't interfere with anything that involves SIGNAL_HANDLER.
/// Item is just type-casted parent (done prior to calling this proc), first_recorded_turf is the turf we started on before we called this proc (for book-keeping and logging).
/datum/component/stationloving/clingy/proc/clingy_timer_handling(atom/movable/item, turf/first_recorded_turf)
	if(!item || !first_recorded_turf)
		stack_trace("clingy_timer_handling() was called with invalid arguments!")
		return

	var/timer_countdown = (clingy_timer_duration / (1 SECONDS))

	for(var/integer in 1 to timer_countdown)
		item.balloon_alert_to_viewers("[timer_countdown - integer] seconds left...") // "29 seconds left..."
		if(validate_parent_area(item))
			clingy_message(BACK_INSIDE_STATION)
			clingy_handling = FALSE
			return
		sleep(1 SECONDS)

	// Timer ran out, and our plead was not heeded. We're moving.
	clingy_message(PISSING_OFF)
	var/final_recorded_turf = get_turf(item)
	var/turf_to_move_to = find_safe_turf()
	generate_logs(first_recorded_turf, final_recorded_turf, turf_to_move_to, clingy_timer_expired = TRUE)
	addtimer(CALLBACK(src, .proc/full_move, turf_to_move_to), 1 SECONDS)
	addtimer(CALLBACK(src, .proc/invert_clingy_handling), 1.25 SECONDS) // this is just so the override lasts long enough so we can teleport once, and not trigger another one immediately after.

/// We're not in a safe area, so we need to move. Let's figure out what message we should send based on our area. Return the type of message we want to say.
/datum/component/stationloving/clingy/proc/determine_appropriate_message(area/area_in_question)
	if(istype(area_in_question, /area/icemoon))
		return IN_ICEMOON
	if(istype(area_in_question, /area/mine) || istype(area_in_question, /area/lavaland))
		return IN_MINING
	stack_trace("determine_appropriate_message() called on an area that doesn't have a message defined. Area: [area_in_question]")

/// Simple proc that just inverts the value of clingy_handling, just so we can assign a timer to it.
/datum/component/stationloving/clingy/proc/invert_clingy_handling()
	clingy_handling = !clingy_handling

/// This handles saying funny/important messages in certain situations that our parent can find itself in.
/// Do not put anything critical to atom_in_bounds() here, add a new proc or update clingy_outdoors_handling() instead.
/datum/component/stationloving/clingy/proc/clingy_messaging_tree()
	if(!COOLDOWN_FINISHED(src, unimportant_clingy_message_cooldown) || clingy_handling) // clingy_handling being TRUE means we're doing something important with messages somewhere else, let's not bother.
		return

	var/atom/movable/item = parent
	var/item_area = get_area(item)

	if(last_cached_area == item_area) // let's not spam messages if we're just sitting in the same area doing nothing.
		return

	last_cached_area = item_area

	// We're in space now!
	if(istype(item_area, /area/space))
		clingy_message(IN_SPACE)
		COOLDOWN_START(src, unimportant_clingy_message_cooldown, clingy_timer_duration)
		return

	// Handle shuttles.
	if(istype(item_area, /area/shuttle))
		if(is_type_in_typecache(item_area, allowed_shuttles))
			if(istype(item_area, /area/shuttle/syndicate))
				clingy_message(ON_SYNDICATE_SHUTTLE) // some funny special lines here :)
				COOLDOWN_START(src, unimportant_clingy_message_cooldown, clingy_timer_duration)
				return
			else if(EMERGENCY_AT_LEAST_DOCKED) // The lines are created with the intent of being "end of the journey", so only say them if shuttle's docked
				clingy_message(ON_FAVORABLE_SHUTTLE)
				COOLDOWN_START(src, unimportant_clingy_message_cooldown, clingy_timer_duration)
			else
				return
		// We aren't in a whitelisted shuttle, so yell at the user that they might be off to a bad location.
		clingy_message(ON_UNFAVORABLE_SHUTTLE)
		COOLDOWN_START(src, unimportant_clingy_message_cooldown, clingy_timer_duration)
		return

	// Small message to tell you how much it appreciates being on the station :). One in a thousand times (on any area change) doesn't sound annoying to me, change it if it gets too spammy.
	if(prob(0.01) && istype(item_area, /area/station))
		clingy_message(ON_STATION)
		COOLDOWN_START(src, unimportant_clingy_message_cooldown, clingy_timer_duration)
		return

/// This creates the message (user feedback) that the parent will say aloud when a certain situation occurs.
/// Pass in one of the define macros at the top of this file to get the appropriate message for that situation. They should match the key in the JSON file.
/datum/component/stationloving/clingy/proc/clingy_message(message_type)
	var/atom/movable/speaker = parent
	var/concatenated_message = ""

	concatenated_message = pick(strings(strings_file, message_type))

	switch(message_type) // san7890 - these are default messages. change these.
		if(BACK_INSIDE_STATION) // could also be considered a "Clingy Timer Stop Message", but it can also work from just getting back inside from space.
			if(clingy_handling) // Clingy Handling is TRUE while this proc is called from clingy_timer_handling(), so we can leverage that to give a small fluff message saying that the timer ended.
				concatenated_message += " I'm okay now."
		if(CLINGY_TIMER_START_MESSAGE)
			concatenated_message += " You've got roughly [DisplayTimeText(clingy_timer_duration)] to get me back!"

	if(concatenated_message == "")
		stack_trace("Unable to generate a clingy message for [speaker]. Likely an issue with the strings file [strings_file]. Message type: [message_type]")
		return

	speaker.say(concatenated_message, forced = COMPONENT_FORCED_SPEAK_NAME)


#undef CLINGY_TIMER_START_MESSAGE
#undef COMPONENT_FORCED_SPEAK_NAME
#undef IN_ICEMOON
#undef IN_MINING
#undef IN_SPACE
#undef ON_FAVORABLE_SHUTTLE
#undef ON_STATION
#undef ON_SYNDICATE_SHUTTLE
#undef ON_UNFAVORABLE_SHUTTLE
#undef PISSING_OFF
#undef BACK_INSIDE_STATION





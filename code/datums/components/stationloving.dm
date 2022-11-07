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

/// Teleports the movable atom back to a safe turf on the station if it leaves the z-level or becomes inaccessible.
/datum/component/stationloving
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// If TRUE, notifies admins when parent is teleported back to the station.
	var/inform_admins = FALSE
	/// Boolean that prevents liches from imbuing their soul in this item.
	var/disallow_soul_imbue = TRUE
	/// If FALSE, prevents parent from being qdel'd unless it's a force = TRUE qdel.
	var/allow_item_destruction = FALSE

	/// Boolean that tracks if this disk is "clingy". In short terms, "clingy" disks are more strict about where they can be placed (as in being more resistant to being in a non-station area)
	/// This variable will enhance the behavior to give more user feedback as to it's preferences. It's more annoying to have to deal with, but such is the cost for being the bearer of such an important item.
	var/clingy = FALSE
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
	/// Only really used for clingy behaviors, since we don't really check for area changes much more often.
	var/area/last_cached_area

	/// Typecache of shuttles that we allow the disk to stay on
	var/static/list/allowed_shuttles = typecacheof(list(
		/area/shuttle/syndicate,
		/area/shuttle/escape,
		/area/shuttle/pod_1,
		/area/shuttle/pod_2,
		/area/shuttle/pod_3,
		/area/shuttle/pod_4,
	))
	/// Typecache of areas on the centcom Z-level that we do not allow the disk to stay on
	var/static/list/disallowed_centcom_areas = typecacheof(list(
		/area/centcom/abductor_ship,
		/area/awaymission/errorroom,
	))
	/// Typecache of areas that are considered "outdoors" on the station Z-level. This is... everything that's not reasonably a station area (/area/station subtypes)
	var/static/list/outdoors_areas = typecacheof(list(
		/area/icemoon,
		/area/lavaland, // planetary maps could use lavaland areas!
		/area/mine,
	))

/datum/component/stationloving/Initialize(inform_admins = FALSE, allow_item_destruction = FALSE, clingy = FALSE, clingy_timer_duration = 30 SECONDS, strings_file)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.inform_admins = inform_admins
	src.allow_item_destruction = allow_item_destruction
	src.clingy = clingy
	src.clingy_timer_duration = clingy_timer_duration
	src.strings_file = strings_file

	// Just in case something is being created outside of station/centcom
	if(!atom_in_bounds(parent))
		relocate()

/datum/component/stationloving/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_PREQDELETED, .proc/on_parent_pre_qdeleted)
	RegisterSignal(parent, COMSIG_ITEM_IMBUE_SOUL, .proc/check_soul_imbue)
	RegisterSignal(parent, COMSIG_ITEM_MARK_RETRIEVAL, .proc/check_mark_retrieval)
	// Relocate when we become unreachable
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/on_parent_moved)
	// Relocate when our loc, or any of our loc's locs, becomes unreachable
	var/static/list/loc_connections = list(
		COMSIG_MOVABLE_MOVED = .proc/on_parent_moved,
		SIGNAL_ADDTRAIT(TRAIT_SECLUDED_LOCATION) = .proc/on_loc_secluded,
	)
	AddComponent(/datum/component/connect_containers, parent, loc_connections)

/datum/component/stationloving/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_Z_CHANGED,
		COMSIG_PARENT_PREQDELETED,
		COMSIG_ITEM_IMBUE_SOUL,
		COMSIG_ITEM_MARK_RETRIEVAL,
		COMSIG_MOVABLE_MOVED,
	))

	qdel(GetComponent(/datum/component/connect_containers))

/datum/component/stationloving/InheritComponent(datum/component/stationloving/newc, original, inform_admins, allow_death)
	if (original)
		if (newc)
			inform_admins = newc.inform_admins
			allow_death = newc.allow_item_destruction
		else
			inform_admins = inform_admins

/// We're relocated to an unfavorable position! Determine if we should immediately get back to the station, or if we're clingy, do some extra stuff.
/// If we aren't going to immediately relocate, return null to prevent any further processing on behalf of other procs. Otherwise, return the turf we're going to.
/datum/component/stationloving/proc/relocate()
	if(clingy_handling)
		return

	var/target_turf = find_safe_turf()

	if(!target_turf)
		if(GLOB.blobstart.len > 0)
			target_turf = get_turf(pick(GLOB.blobstart))
		else
			CRASH("Unable to find a blobstart landmark for [type] to relocate [parent].")

	if(clingy)
		clingy_handling = TRUE
		// Give it a second in case we're switching z-levels so the user can actually hear the message, and then teleport it back a second after their mistake is made and all they can do is watch in horror.
		addtimer(CALLBACK(src, .proc/clingy_message, PISSING_OFF), 1 SECONDS)
		addtimer(CALLBACK(src, .proc/full_move, target_turf), 2 SECONDS)
		return target_turf

	full_move(target_turf)
	return target_turf

/// Alright, let's actually move (we've exceeded all possible thresholds/affordances to the holder of this item). If no turf is provided, we'll find one ourselves.
/// Don't handle logging here. Please do it in the calling proc, since this is meant to operate agnostic of context.
/datum/component/stationloving/proc/full_move(turf/location_turf)
	// Set clingy handling to FALSE here, we have exhausted all possible avenues of user feedback and we're now resetting our state.
	clingy_handling = FALSE
	if(!location_turf)
		location_turf = find_safe_turf()

	var/atom/movable/movable_parent = parent
	playsound(movable_parent, 'sound/machines/synth_no.ogg', 5, TRUE)

	var/mob/holder = get(movable_parent, /mob)
	if(holder)
		to_chat(holder, span_danger("You can't help but feel that you just lost something back there..."))
		holder.temporarilyRemoveItemFromInventory(parent, TRUE) // prevents ghost diskie

	movable_parent.forceMove(location_turf)

	return location_turf

/// Signal proc for [COMSIG_MOVABLE_MOVED], called when our parent moves, or our parent's loc, or our parent's loc loc...
/// To check if our disk is moving somewhere it shouldn't be, such as off Z level, or into an invalid area
/datum/component/stationloving/proc/on_parent_moved(atom/movable/source, turf/old_turf)
	SIGNAL_HANDLER

	if(atom_in_bounds(source))
		return

	var/turf/current_turf = get_turf(source)
	var/turf/new_destination = relocate()

	// Expected behavior from relocate() is that it will return a turf if it's full-steam-ahead on moving the parent, and null if it's not.
	if(isnull(new_destination))
		return

	var/secluded
	// Our turf actually didn't change, so it's more likely we became secluded
	if(current_turf == old_turf)
		secluded = TRUE

	generate_logs(old_turf, current_turf, new_destination, loc_changed = !secluded)

/// Signal proc for [SIGNAL_ADDTRAIT], via [TRAIT_SECLUDED_LOCATION] on our locs, to ensure nothing funky happens
/datum/component/stationloving/proc/on_loc_secluded(atom/movable/source)
	SIGNAL_HANDLER

	var/turf/new_destination = relocate()
	// for our intents and purposes regarding secluded, the source is both the source atom and the destination turf
	generate_logs(source, source, new_destination, loc_changed = FALSE)

/// Generate logs and messages for when our parent goes back to the station. Args are important in how you pass them in in relation to their meaning.
/// Source Atom was the location where the parent was "safe", the very last coordinate that it was okay at right before we started to move it. Could be the thing that's secluding the disk, or the source turf.
/// Destination Turf was the turf that the parent was moved to. This is the "unsafe" turf that triggered the forceMove. If we're calling this since parent got put in a secluded area, pass loc_changed as FALSE.
/// Final Turf is the turf that we forceMoved the parent to after we determined it was in an invalid area.
/// Use clingy_timer_expired if we do a timer countdown to requesting the parent to be moved back to the station, and the timer expired.
/datum/component/stationloving/proc/generate_logs(atom/source, turf/destination_turf, turf/final_turf, loc_changed = TRUE, clingy_timer_expired = FALSE)
	if(clingy_timer_expired)
		log_game("The [DisplayTimeText(clingy_timer_duration)] timer on [parent] ran out after finding itself in [loc_name(source)], \
		so it has been moved to [loc_name(final_turf)] from it's final recorded position of [loc_name(destination_turf)].")

		if(inform_admins)
			message_admins("The [DisplayTimeText(clingy_timer_duration)] timer on [parent] ran out after finding itself in [loc_name(source)], \
			so it has been moved to [ADMIN_VERBOSEJMP(final_turf)] from it's final recorded position of [ADMIN_VERBOSEJMP(destination_turf)].")

	if(loc_changed)
		log_game("[parent] attempted to be moved out of bounds from [loc_name(source)] \
		to [loc_name(destination_turf)]. Moving it to [loc_name(final_turf)].")

		if(inform_admins)
			message_admins("[parent] attempted to be moved out of bounds from [ADMIN_VERBOSEJMP(source)] \
				to [ADMIN_VERBOSEJMP(destination_turf)]. Moving it to [ADMIN_VERBOSEJMP(final_turf)].")
	else
		log_game("[parent] moved out of bounds at [loc_name(source)], becoming inaccessible / secluded. \
			Moving it to [loc_name(final_turf)].")

		if(inform_admins)
			message_admins("[parent] moved out of bounds at [ADMIN_VERBOSEJMP(source)], becoming inaccessible / secluded. \
				Moving it to [ADMIN_VERBOSEJMP(final_turf)].")

/datum/component/stationloving/proc/check_soul_imbue(datum/source)
	SIGNAL_HANDLER

	if(disallow_soul_imbue)
		return COMPONENT_BLOCK_IMBUE

/datum/component/stationloving/proc/check_mark_retrieval(datum/source)
	SIGNAL_HANDLER

	return COMPONENT_BLOCK_MARK_RETRIEVAL

/// Checks whether a given atom's turf is within bounds. Returns TRUE if it is, FALSE if it isn't.
/datum/component/stationloving/proc/atom_in_bounds(atom/atom_to_check)
	// Our loc is a secluded location = not in bounds
	if (atom_to_check.loc && HAS_TRAIT(atom_to_check.loc, TRAIT_SECLUDED_LOCATION))
		return FALSE
	// No turf below us = nullspace = not in bounds
	var/turf/destination_turf = get_turf(atom_to_check)
	var/area/destination_area = get_area(atom_to_check)
	if (!destination_turf)
		return FALSE
	if (is_station_level(destination_turf.z))
		if(!clingy)
			return TRUE
		if(!validate_parent_area(atom_to_check))
			return clingy_outdoors_setup() // if passed, we over-write the rest of the proc here, just in case we're doing some clingy handling timers and such
		else
			clingy_messaging_tree()
			return TRUE

	if (is_centcom_level(destination_turf.z))
		if (is_type_in_typecache(destination_area, disallowed_centcom_areas))
			return FALSE
		return TRUE
	if (is_reserved_level(destination_turf.z))
		if (is_type_in_typecache(destination_area, allowed_shuttles))
			return TRUE

/// Signal handler for before the parent is qdel'd. Can prevent the parent from being deleted where allow_item_destruction is FALSE and force is FALSE.
/datum/component/stationloving/proc/on_parent_pre_qdeleted(datum/source, force)
	SIGNAL_HANDLER

	var/turf/current_turf = get_turf(parent)

	if(force && inform_admins)
		message_admins("[parent] has been !!force deleted!! in [ADMIN_VERBOSEJMP(current_turf)].")
		log_game("[parent] has been !!force deleted!! in [loc_name(current_turf)].")

	if(force || allow_item_destruction)
		return FALSE

	var/turf/new_turf = relocate()
	log_game("[parent] has been destroyed in [loc_name(current_turf)]. \
		Preventing destruction and moving it to [loc_name(new_turf)].")
	if(inform_admins)
		message_admins("[parent] has been destroyed in [ADMIN_VERBOSEJMP(current_turf)]. \
			Preventing destruction and moving it to [ADMIN_VERBOSEJMP(new_turf)].")
	return TRUE

// Pretty much everything after this point is only useful for clingy behaviors.

/// A stripped down area-checker useful for rapid checking, typically only used for clingy behaviors.
/datum/component/stationloving/proc/validate_parent_area(atom/atom_to_check)
	var/area/destination_area = get_area(atom_to_check)

	if(istype(destination_area, /area/station))
		return TRUE
	else if(is_type_in_typecache(destination_area, outdoors_areas))
		return FALSE
	else
		return TRUE // we're probably fine since we're in some sort of edge-case yet still on a station z-level.

/// Handles specific clingy behavior for when our parent is outdoors (like in space, or outside on a planetary map), with a lot of setup for the clingy timer if that hasn't already been set up earlier.
/datum/component/stationloving/proc/clingy_outdoors_setup()
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
/// Item is just type-casted parent (done prior to calling this proc), first_recorded_turf is the turf we started on before we called this proc (for book-keeping).
/datum/component/stationloving/proc/clingy_timer_handling(atom/movable/item, turf/first_recorded_turf)
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

/// Simple proc that just inverts the value of clingy_handling, just so we can assign a timer to it.
/datum/component/stationloving/proc/invert_clingy_handling()
	clingy_handling = !clingy_handling
	return clingy_handling

/// This handles saying funny/important messages in certain situations that our parent can find itself in.
/// Do not put anything critical to atom_in_bounds() here, add a new proc or update clingy_outdoors_handling() instead.
/datum/component/stationloving/proc/clingy_messaging_tree()
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

/// We're not in a safe area, so we need to move. Let's figure out what message we should send based on our area. Return the type of message we want to say.
/datum/component/stationloving/proc/determine_appropriate_message(area/area_in_question)
	if(istype(area_in_question, /area/icemoon))
		return IN_ICEMOON
	if(istype(area_in_question, /area/mine) || istype(area_in_question, /area/lavaland))
		return IN_MINING
	stack_trace("determine_appropriate_message() called on an area that doesn't have a message defined. Area: [area_in_question]")

/// Special proc for clingy items. This is the message (user feedback) that the parent will say aloud when a certain situation occurs.
/// Pass in one of the define macros at the top of this file to get the appropriate message for that situation. They should match the key in the JSON file.
/datum/component/stationloving/proc/clingy_message(message_type)
	var/atom/movable/speaker = parent
	var/concatenated_message = ""

	concatenated_message = pick(strings(strings_file, message_type))

	switch(message_type) // san7890 - these are default messages. change these.
		if(BACK_INSIDE_STATION) // could also be considered a "Clingy Timer Stop Message", but it can also work from just getting back inside from space.
			if(clingy_handling) // Clingy Handling is TRUE while this proc is called from clingy_timer_handling(), so we can leverage that to give a small fluff message saying that the timer ended.
				concatenated_message += " I'm okay now."
		if(CLINGY_TIMER_START_MESSAGE)
			concatenated_message += " You've got roughly [DisplayTimeText(clingy_timer_duration)] to get me back!"

	if(!concatenated_message)
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

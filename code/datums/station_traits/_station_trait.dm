/// Station traits displayed in the lobby
GLOBAL_LIST_EMPTY(lobby_station_traits)

///Base class of station traits. These are used to influence rounds in one way or the other by influencing the levers of the station.
/datum/station_trait
	/// Trait should not be instantiated in a round if its type matches this type
	abstract_type = /datum/station_trait
	///Name of the trait
	var/name = "unnamed station trait"
	///The type of this trait. Used to classify how this trait influences the station
	var/trait_type = STATION_TRAIT_NEUTRAL
	///Whether or not this trait uses process()
	var/trait_processes = FALSE
	///Chance relative to other traits of its type to be picked
	var/weight = 10
	///The cost of the trait, which is removed from the budget.
	var/cost = STATION_TRAIT_COST_FULL
	///Whether this trait is always enabled; generally used for debugging
	var/force = FALSE
	///Does this trait show in the centcom report?
	var/show_in_report = FALSE
	///What message to show in the centcom report?
	var/report_message
	///What code-trait does this station trait give? gives none if null
	var/trait_to_give
	///What traits are incompatible with this one?
	var/blacklist
	///Extra flags for station traits such as it being abstract, planetary or space only
	var/trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	/// Whether or not this trait can be reverted by an admin
	var/can_revert = TRUE
	/// If set to true we'll show a button on the lobby to notify people about this trait
	var/sign_up_button = FALSE
	/// The ID that we look for in dynamic.json. Not synced with 'name' because I can already see this go wrong
	var/dynamic_threat_id

/datum/station_trait/New()
	. = ..()

	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(on_round_start))

	if(sign_up_button)
		GLOB.lobby_station_traits += src
		SEND_SIGNAL(SSdcs, COMSIG_GLOB_LOBBY_TRAIT_ADDED)
	if(trait_processes)
		START_PROCESSING(SSstation, src)
	if(trait_to_give)
		ADD_TRAIT(SSstation, trait_to_give, STATION_TRAIT)

/datum/station_trait/Destroy()
	var/had_button = sign_up_button
	SSstation.station_traits -= src
	GLOB.lobby_station_traits -= src
	if(had_button)
		SEND_SIGNAL(SSdcs, COMSIG_GLOB_LOBBY_TRAIT_REMOVED)
	REMOVE_TRAIT(SSstation, trait_to_give, STATION_TRAIT)
	return ..()

/// Returns the type of info the centcom report has on this trait, if any.
/datum/station_trait/proc/get_report()
	return "<i>[name]</i> - [report_message]"

/// Will attempt to revert the station trait, used by admins.
/datum/station_trait/proc/revert()
	if (!can_revert)
		CRASH("revert() was called on [type], which can't be reverted!")

	if (trait_to_give)
		REMOVE_TRAIT(SSstation, trait_to_give, STATION_TRAIT)

	qdel(src)

/// Return a color for the decals, if any
/datum/station_trait/proc/get_decal_color(thing_to_color, pattern)
	return

/// Return TRUE if we want to show a lobby button, by default we assume we don't want it after the round begins
/datum/station_trait/proc/can_display_lobby_button(client/player)
	return sign_up_button && !SSticker.HasRoundStarted()

/// Called when a player clicks this trait's lobby button.
/// Return a string to show as feedback in the lobby UI.
/datum/station_trait/proc/on_lobby_button_click(mob/dead/new_player/player)
	return

/// Returns the tooltip text for this trait's lobby button
/datum/station_trait/proc/get_lobby_description()
	return report_message

/// Returns the icon state for this trait's lobby button for a given player
/datum/station_trait/proc/get_lobby_icon_state(mob/dead/new_player/player)
	return "signup"

/// Returns a list of overlay icon states to layer on top of the lobby button
/datum/station_trait/proc/get_lobby_overlay_states(mob/dead/new_player/player)
	return list()

/// Proc ran when round starts. Use this for roundstart effects.
/datum/station_trait/proc/on_round_start()
	SIGNAL_HANDLER

/// Called when overriding a pulsar star command report message.
/datum/station_trait/proc/get_pulsar_message()
	return

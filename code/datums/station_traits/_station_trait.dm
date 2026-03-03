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
	/// Lobby buttons controlled by this trait
	var/list/lobby_buttons = list()
	/// The ID that we look for in dynamic.json. Not synced with 'name' because I can already see this go wrong
	var/dynamic_threat_id

/datum/station_trait/New()
	. = ..()

	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(on_round_start))

	if(sign_up_button)
		GLOB.lobby_station_traits += src
		if(SSstation.initialized)
			SSstation.display_lobby_traits()
	if(trait_processes)
		START_PROCESSING(SSstation, src)
	if(trait_to_give)
		ADD_TRAIT(SSstation, trait_to_give, STATION_TRAIT)

/datum/station_trait/Destroy()
	destroy_lobby_buttons()
	SSstation.station_traits -= src
	GLOB.lobby_station_traits -= src
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

/// Called by decals if they can be colored, to see if we got some cool colors for them. Only takes the first station trait
/proc/request_station_colors(atom/thing_to_color, pattern)
	for(var/datum/station_trait/trait in SSstation.station_traits)
		var/decal_color = trait.get_decal_color(thing_to_color, pattern || PATTERN_DEFAULT)
		if(decal_color)
			return decal_color
	return null

/// Return a color for the decals, if any
/datum/station_trait/proc/get_decal_color(thing_to_color, pattern)
	return

/// Return TRUE if we want to show a lobby button, by default we assume we don't want it after the round begins
/datum/station_trait/proc/can_display_lobby_button(client/player)
	return sign_up_button && !SSticker.HasRoundStarted()

/// Apply any additional handling we need to our lobby button
/datum/station_trait/proc/setup_lobby_button(atom/movable/screen/lobby/button/sign_up/lobby_button)
	SHOULD_CALL_PARENT(TRUE)
	lobby_button.name = name
	lobby_buttons |= lobby_button
	RegisterSignal(lobby_button, COMSIG_ATOM_UPDATE_ICON, PROC_REF(on_lobby_button_update_icon))
	RegisterSignal(lobby_button, COMSIG_SCREEN_ELEMENT_CLICK, PROC_REF(on_lobby_button_click))
	RegisterSignal(lobby_button, COMSIG_QDELETING, PROC_REF(on_lobby_button_destroyed))
	lobby_button.update_appearance(UPDATE_ICON)

/// Called when our lobby button is clicked on
/datum/station_trait/proc/on_lobby_button_click(atom/movable/screen/lobby/button/sign_up/lobby_button, location, control, params, mob/dead/new_player/user)
	SIGNAL_HANDLER
	return

/// Called when our lobby button tries to update its appearance
/datum/station_trait/proc/on_lobby_button_update_icon(atom/movable/screen/lobby/button/sign_up/lobby_button, updates)
	SIGNAL_HANDLER
	return

/// Don't hold references to deleted buttons
/datum/station_trait/proc/on_lobby_button_destroyed(atom/movable/screen/lobby/button/sign_up/lobby_button)
	SIGNAL_HANDLER
	lobby_buttons -= lobby_button

/// Proc ran when round starts. Use this for roundstart effects. By default we clean up our buttons here.
/datum/station_trait/proc/on_round_start()
	SIGNAL_HANDLER
	destroy_lobby_buttons()

/// Remove all of our active lobby buttons
/datum/station_trait/proc/destroy_lobby_buttons()
	for (var/atom/movable/screen/button as anything in lobby_buttons)
		var/mob/dead/new_player/hud_owner = button.get_mob()
		if (QDELETED(hud_owner))
			qdel(button)
			continue
		var/datum/hud/new_player/using_hud = hud_owner.hud_used
		if(!using_hud)
			qdel(button)
			continue
		using_hud.remove_station_trait_button(src)

/// Called when overriding a pulsar star command report message.
/datum/station_trait/proc/get_pulsar_message()
	return

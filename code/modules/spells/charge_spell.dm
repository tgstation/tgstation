/**
 * ## Charge Spell Component
 *
 * Attached to a spell to make it charged based, instead of cooldown based.
 */
/datum/component/charge_based_spell
	// Set in initialize
	/// The max amount of charges the spell has
	var/max_charges = 3
	/// The time it takes to regenerate charges
	var/charge_regeneration_rate = 10 SECONDS

	// Internal use
	/// The current number of charges the spell has
	var/charges = 0

/datum/component/charge_based_spell/Initialize(max_charges = 3, charge_regeneration_rate = 10 SECONDS)
	if(!istype(parent, /datum/action/cooldown/spell))
		return COMPONENT_INCOMPATIBLE

	src.charges = max_charges
	src.max_charges = max_charges
	src.charge_regeneration_rate = charge_regeneration_rate

/datum/component/charge_based_spell/RegisterWithParent()
	RegisterSignal(parent, COMSIG_SPELL_BEFORE_CAST, .proc/on_before_cast)
	RegisterSignal(parent, COMSIG_SPELL_AFTER_CAST, .proc/on_after_cast)
	RegisterSignal(parent, COMSIG_SPELL_CAST_REVERTED, .proc/on_cast_revert)
	RegisterSignal(parent, COMSIG_ACTION_SET_STATPANEL, .proc/on_statpanel_set)

/datum/component/charge_based_spell/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_SPELL_BEFORE_CAST,
		COMSIG_SPELL_AFTER_CAST,
		COMSIG_SPELL_CAST_REVERTED,
		COMSIG_ACTION_SET_STATPANEL,
	))

/**
 * Signal proc for [COMSIG_SPELL_BEFORE_CAST]
 *
 * Prevents casting if no charges are present.
 */
/datum/component/charge_based_spell/proc/on_before_cast(datum/source)
	SIGNAL_HANDLER

	if(charges <= 0)
		return COMPONENT_CANCEL_SPELL

/**
 * Signal proc for [COMSIG_SPELL_AFTER_CAST]
 *
 * Uses up a charge after a cast is done, and starts the recharge time.
 */
/datum/component/charge_based_spell/proc/on_after_cast(datum/source)
	SIGNAL_HANDLER

	charges = clamp(charges - 1, 0, max_charges)
	addtimer(CALLBACK(src, .proc/recharge), charge_regeneration_rate)

/**
 * Signal proc for [COMSIG_SPELL_CAST_REVERTED]
 *
 * Recharges the spell if a cast is reverted.
 */
/datum/component/charge_based_spell/proc/on_cast_revert(datum/source)
	SIGNAL_HANDLER

	recharge()

/// Simple proc to to re-increment the charge value.
/datum/component/charge_based_spell/proc/recharge()
	charges = clamp(charges + 1, 0, max_charges)


/**
 * Signal proc for [COMSIG_ACTION_SET_STATPANEL]
 *
 * Overrides PANEL_DISPLAY_COOLDOWN to show the number of charges remaining instead of a cooldown
 */
/datum/component/charge_based_spell/proc/on_statpanel_set(datum/source, list/stat_panel_data)
	SIGNAL_HANDLER

	stat_panel_data[PANEL_DISPLAY_COOLDOWN] = "[charges] / [max_charges]"

/datum/component/charge_based_spell
	// Set in initialize
	var/max_charges = 3
	var/charge_regeneration_rate = 10 SECONDS

	// Internal use
	var/charges = 0
	var/list/recharge_timers

/datum/component/charge_based_spell/Initialize(max_charges = 3, charge_regeneration_rate = 10 SECONDS)
	if(!istype(parent, /datum/action/cooldown/spell))
		return COMPONENT_INCOMPATIBLE

	src.charges = max_charges
	src.max_charges = max_charges
	src.charge_regeneration_rate = charge_regeneration_rate

/datum/component/charge_based_spell/RegisterWithParent()
	RegisterSignal(parent, COMSIG_SPELL_BEFORE_CAST, .proc/on_before_cast)
	RegisterSignal(parent, COMSIG_SPELL_AFTER_CAST, .proc/on_after_cast)

/datum/component/charge_based_spell/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_SPELL_BEFORE_CAST, COMSIG_SPELL_AFTER_CAST))

/datum/component/charge_based_spell/proc/on_before_cast(datum/source)
	SIGNAL_HANDLER

	if(charges <= 0)
		return COMPONENT_CANCEL_SPELL

/datum/component/charge_based_spell/proc/on_after_cast(datum/source)
	SIGNAL_HANDLER

	charges--
	addtimer(CALLBACK(src, .proc/recharge), charge_regeneration_rate)

/datum/component/charge_based_spell/proc/recharge()
	charges++

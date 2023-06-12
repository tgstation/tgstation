/// Items with this component will have a chance to get knocked off
/// (unequipped and sent to the ground) when the wearer is disarmed or knocked down.
/datum/component/knockoff
	/// Chance to knockoff when a knockoff action occurs.
	var/knockoff_chance = 100
	/// Used in being disarmed.
	/// If set, we will only roll the knockoff chance if the disarmer is targeting one of these zones.
	/// If unset, any disarm act will cause the knock-off chance to be rolled, no matter the zone targeted.
	var/list/target_zones
	/// Bitflag used in equip to determine what slots we need to be in to be knocked off.
	/// If set, we must be equipped in one of the slots to have a chance of our item being knocked off.
	/// If unset / NONE, a disarm or knockdown will have a chance of our item being knocked off regardless of slot, INCLUDING hand slots.
	var/slots_knockoffable = NONE

/datum/component/knockoff/Initialize(knockoff_chance = 100, target_zones, slots_knockoffable = NONE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.knockoff_chance = knockoff_chance
	src.target_zones = target_zones
	src.slots_knockoffable = slots_knockoffable

/datum/component/knockoff/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))

/datum/component/knockoff/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

	var/obj/item/item_parent = parent
	if(ismob(item_parent.loc))
		UnregisterSignal(item_parent.loc, list(COMSIG_HUMAN_DISARM_HIT, COMSIG_LIVING_STATUS_KNOCKDOWN))

/// Signal proc for [COMSIG_HUMAN_DISARM_HIT] on the mob who's equipped our parent
/// Rolls a chance for knockoff whenever we're disarmed
/datum/component/knockoff/proc/on_equipped_mob_disarm(mob/living/carbon/human/source, mob/living/attacker, zone)
	SIGNAL_HANDLER

	if(!istype(source))
		return

	if(target_zones && !(zone in target_zones))
		return
	if(!prob(knockoff_chance))
		return

	var/obj/item/item_parent = parent
	if(!source.dropItemToGround(item_parent))
		return

	source.visible_message(
		span_warning("[attacker] knocks off [source]'s [item_parent.name]!"),
		span_userdanger("[attacker] knocks off your [item_parent.name]!"),
	)

/// Signal proc for [COMSIG_LIVING_STATUS_KNOCKDOWN] on the mob who's equipped our parent
/// Rolls a chance for knockoff whenever we're knocked down
/datum/component/knockoff/proc/on_equipped_mob_knockdown(mob/living/carbon/human/source, amount)
	SIGNAL_HANDLER

	if(!istype(source))
		return

	// Healing knockdown or setting knockdown to zero or something? Don't knock off.
	if(amount <= 0)
		return
	if(!prob(knockoff_chance))
		return

	var/obj/item/item_parent = parent
	if(!source.dropItemToGround(item_parent))
		return

	source.visible_message(
		span_warning("[source]'s [item_parent.name] get[item_parent.p_s()] knocked off!"),
		span_userdanger("Your [item_parent.name] [item_parent.p_were()] knocked off!"),
	)

/// Signal proc for [COMSIG_ITEM_EQUIPPED]
/// Registers our signals which can cause a knockdown whenever we're equipped correctly
/datum/component/knockoff/proc/on_equipped(datum/source, mob/living/carbon/human/equipper, slot)
	SIGNAL_HANDLER

	if(!istype(equipper))
		return

	if(slots_knockoffable && !(slot & slots_knockoffable))
		UnregisterSignal(equipper, list(COMSIG_HUMAN_DISARM_HIT, COMSIG_LIVING_STATUS_KNOCKDOWN))
		return

	RegisterSignal(equipper, COMSIG_HUMAN_DISARM_HIT, PROC_REF(on_equipped_mob_disarm), TRUE)
	RegisterSignal(equipper, COMSIG_LIVING_STATUS_KNOCKDOWN, PROC_REF(on_equipped_mob_knockdown), TRUE)

/// Signal proc for [COMSIG_ITEM_DROPPED]
/// Unregisters our signals which can cause a knockdown when we're unequipped (dropped)
/datum/component/knockoff/proc/on_dropped(datum/source, mob/living/dropper)
	SIGNAL_HANDLER

	UnregisterSignal(dropper, list(COMSIG_HUMAN_DISARM_HIT, COMSIG_LIVING_STATUS_KNOCKDOWN))

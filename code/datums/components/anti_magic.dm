/// This provides different types of magic resistance on an object
/datum/component/anti_magic
	/// The types of magic resistance present on the object
	var/antimagic_flags = MAGIC_RESISTANCE // see DEFINES/magic.dm for list of antimagic flags
	/// The amount of times the object can protect the user
	var/remaining_charges = INFINITY
	/// The inventory slot the object must be located at in order to activate
	var/inventory_flags = ~ITEM_SLOT_BACKPACK // items in a backpack won't activate, anywhere else is fine
	/// The proc that is triggered when magic has been successfully blocked
	var/datum/callback/react
	/// The proc that is triggered when the object is depleted of charges
	var/datum/callback/expire

/**
 * Adds magic resistances to an object
 *
 * Magic resistance will prevent magic from affecting the user if it has resistance to
 * the type of magic being used
 * 
 * args:
 * * resistances (optional) The types of magic resistance on the object
 * * total_charges (optional) The amount of times the object can protect the user from magic 
 * * inventory_slots (optional) The inventory slot the object must be located at in order to activate
 * * reaction (optional) The proc that is triggered when magic has been successfully blocked
 * * expiration (optional) The proc that is triggered when the object is depleted of charges
 * 
 * resistances bitflags: (see code/__DEFINES/magic.dm)
 * * MAGIC_RESISTANCE - Default magic resistance that blocks normal magic (wizard, spells, staffs)
 * * MAGIC_RESISTANCE_MIND - Tinfoil hat magic resistance that blocks mental magic (telepathy, abductors, jelly people)
 * * MAGIC_RESISTANCE_HOLY - Holy magic resistance that blocks unholy magic (revenant, cult, vampire, voice of god)
 * * MAGIC_CASTING_RESTRICTION - Prevents a user from casting magic
 * * MAGIC_RESISTANCE_ALL - All magic resistances combined
**/
/datum/component/anti_magic/Initialize(resistances, total_charges, inventory_slots, datum/callback/reaction, datum/callback/expiration)

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
	else if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_RECEIVE_MAGIC, .proc/protect)
	else
		return COMPONENT_INCOMPATIBLE

	if(resistances)
		antimagic_flags = resistances
	if(total_charges)
		remaining_charges = total_charges
	if(inventory_slots)
		inventory_flags = inventory_slots 
	react = reaction
	expire = expiration

/datum/component/anti_magic/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!(inventory_flags & slot)) //Check that the slot is valid for antimagic
		UnregisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC)
		return
	RegisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC, .proc/protect, TRUE)

/datum/component/anti_magic/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)

/datum/component/anti_magic/proc/protect(datum/source, mob/user, resistances, charge_cost, list/protection_sources)
	SIGNAL_HANDLER

	// ignore magic casting restrictions since proc/protect is only called
	// when being attacked with magic by another mob
	var/antimagic = antimagic_flags & ~MAGIC_CASTING_RESTRICTION
	if(resistances & antimagic) 
		protection_sources += parent
		react?.Invoke(user, charge_cost, parent)
		remaining_charges -= charge_cost
		if(remaining_charges <= 0)
			expire?.Invoke(user, parent)
			qdel(src)
		return COMPONENT_BLOCK_MAGIC

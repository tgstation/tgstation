/// Default magic resistance that blocks normal magic (wizard, spells, staffs)
#define MAGIC_RESISTANCE (1<<0)
/// Tinfoil hat magic resistance that blocks mental magic (telepathy, abductors, jelly people)
#define MAGIC_RESISTANCE_MIND (1<<1)
/// Holy magic resistance that blocks unholy magic (revenant, cult, vampire, voice of god, )
#define MAGIC_RESISTANCE_HOLY (1<<2)
/// Prevents a user from casting magic
#define MAGIC_CASTING_RESTRICTION (1<<3)
/// All magic resistances combined
#define MAGIC_RESISTANCE_ALL (MAGIC_RESISTANCE | MAGIC_RESISTANCE_MIND | MAGIC_RESISTANCE_HOLY | MAGIC_CASTING_RESTRICTION)

/// This provides different types of magic resistance on an object
/datum/component/anti_magic
	var/antimagic_flags
	var/charges
	var/inventory_flags
	var/datum/callback/reaction
	var/datum/callback/expiration

/**
 * Adds magic resistances to an object
 *
 * Magic resistance will prevent magic from affecting the user if it has the correct resistance
 * against the type of magic being used
 * 
 * args:
 * * antimagic_flags (optional) A bitflag with the types of magic resistance on the object
 * * charges (optional) The amount of times the object can protect the user from magic 
 * * inventory_flags (optional) The inventory slot the object must be located at in order to activate
 * * reaction (optional) The proc that is triggered when magic has been successfully blocked
 * * expiration (optional) The proc that is triggered when the object is depleted of charges
**/
/datum/component/anti_magic/Initialize(
		antimagic_flags = MAGIC_RESISTANCE,
		charges = INFINITY, 
		inventory_flags = ~ITEM_SLOT_BACKPACK, // items in a backpack won't activate, anywhere else is fine
		reaction, 
		expiration
	)

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
	else if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_RECEIVE_MAGIC, .proc/protect)
	else
		return COMPONENT_INCOMPATIBLE

	src.antimagic_flags = antimagic_flags
	src.charges = charges
	src.inventory_flags = inventory_flags 
	src.reaction = reaction
	src.expiration = expiration

/datum/component/anti_magic/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!(inventory_flags & slot)) //Check that the slot is valid for antimagic
		UnregisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC)
		return
	RegisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC, .proc/protect, TRUE)

/datum/component/anti_magic/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)

/datum/component/anti_magic/proc/protect(datum/source, mob/user, casted_magic_flags, charge_cost, list/protection_sources)
	SIGNAL_HANDLER

	// ignore magic casting restrictions since protect is only called when magic is being casted at you
	casted_magic_flags = casted_magic_flags & ~MAGIC_CASTING_RESTRICTION

	if(casted_magic_flags & antimagic_flags) 
		protection_sources += parent
		reaction?.Invoke(user, charge_cost, parent)
		charges -= charge_cost
		if(charges <= 0)
			expiration?.Invoke(user, parent)
			qdel(src)
		return COMPONENT_BLOCK_MAGIC

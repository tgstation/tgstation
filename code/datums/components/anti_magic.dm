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
 * *
 * antimagic bitflags: (see code/__DEFINES/magic.dm)
 * * MAGIC_RESISTANCE - Default magic resistance that blocks normal magic (wizard, spells, staffs)
 * * MAGIC_RESISTANCE_MIND - Tinfoil hat magic resistance that blocks mental magic (telepathy, abductors, jelly people)
 * * MAGIC_RESISTANCE_HOLY - Holy magic resistance that blocks unholy magic (revenant, cult, vampire, voice of god)
 * * MAGIC_RESISTANCE_ALL - All magic resistances combined
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
		RegisterSignal(parent, COMSIG_MOB_RECEIVE_MAGIC, .proc/block_receiving_magic)
		RegisterSignal(parent, COMSIG_MOB_RESTRICT_MAGIC, .proc/restrict_casting_magic)
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
		UnregisterSignal(equipper, COMSIG_MOB_RESTRICT_MAGIC)
		equipper.update_action_buttons()
		return
	RegisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC, .proc/block_receiving_magic)
	RegisterSignal(equipper, COMSIG_MOB_RESTRICT_MAGIC, .proc/restrict_casting_magic)
	equipper.update_action_buttons()

/datum/component/anti_magic/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)
	UnregisterSignal(user, COMSIG_MOB_RESTRICT_MAGIC)
	user.update_action_buttons()

/datum/component/anti_magic/proc/block_receiving_magic(datum/source, mob/user, casted_magic_flags, charge_cost)
	SIGNAL_HANDLER

	// disclaimer - All anti_magic sources will be drained a charge_cost
	if(casted_magic_flags & antimagic_flags) 
		reaction?.Invoke(user, casted_magic_flags, charge_cost, parent)
		charges -= charge_cost
		if(charges <= 0)
			expiration?.Invoke(user, parent)
			qdel(src)
		return TRUE
	return FALSE

/datum/component/anti_magic/proc/restrict_casting_magic(datum/source, mob/user, magic_flags)
	SIGNAL_HANDLER

	if(magic_flags & antimagic_flags)
		return TRUE // cannot cast magic with the same type of antimagic present
	else
		return FALSE

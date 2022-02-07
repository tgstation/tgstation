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
		RegisterSignal(parent, COMSIG_MOB_CAST_MAGIC, .proc/try_casting)
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
		UnregisterSignal(equipper, COMSIG_MOB_CAST_MAGIC)
		return
	RegisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC, .proc/protect, TRUE)
	RegisterSignal(equipper, COMSIG_MOB_CAST_MAGIC, .proc/try_casting)

/datum/component/anti_magic/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)
	UnregisterSignal(user, COMSIG_MOB_CAST_MAGIC)

/datum/component/anti_magic/proc/protect(datum/source, mob/user, casted_magic_flags, charge_cost)
	SIGNAL_HANDLER

	if(casted_magic_flags == NONE) // magic with the NONE flag is immune to blocking
		return FALSE

	// disclaimer - All anti_magic sources will be drained a charge_cost
	if(casted_magic_flags & antimagic_flags) 
		reaction?.Invoke(user, charge_cost, parent)
		charges -= charge_cost
		if(charges <= 0)
			expiration?.Invoke(user, parent)
			qdel(src)
		return COMPONENT_BLOCK_MAGIC

/datum/component/anti_magic/proc/try_casting(datum/source, mob/user, magic_flags)
	SIGNAL_HANDLER

	// if we are trying to cast wizard spells (not mime abilities, abductor telepathy, etc.)
	// and we have an antimagic equipped that blocks casting, we can't cast that type of magic
	if((magic_flags & MAGIC_RESISTANCE) && (antimagic_flags & MAGIC_CASTING_RESTRICTION))
		return COMPONENT_BLOCK_MAGIC

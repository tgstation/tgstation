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

/datum/component/anti_magic/Initialize(
		resistances = null, 
		total_charges = null, 
		inventory_slots = null, 
		datum/callback/reaction = null, 
		datum/callback/expiration = null
	)

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

	if(resistances & antimagic_flags)
		protection_sources += parent
		react?.Invoke(user, charge_cost, parent)
		remaining_charges -= charge_cost
		if(remaining_charges <= 0)
			expire?.Invoke(user, parent)
			qdel(src)
		return COMPONENT_BLOCK_MAGIC

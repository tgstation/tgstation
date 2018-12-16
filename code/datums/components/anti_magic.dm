/datum/component/anti_magic
	var/magic = FALSE
	var/holy = FALSE
	var/charges = INFINITY
	var/blocks_self = TRUE
	var/datum/callback/reaction
	var/datum/callback/expire

/datum/component/anti_magic/Initialize(_magic = FALSE, _holy = FALSE, _charges, _blocks_self = TRUE, datum/callback/_reaction, datum/callback/_expire)
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
	else if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_RECEIVE_MAGIC, .proc/protect)
	else
		return COMPONENT_INCOMPATIBLE

	magic = _magic
	holy = _holy
	if(!isnull(_charges))
		charges = _charges
	blocks_self = _blocks_self
	reaction = _reaction
	expire = _expire

/datum/component/anti_magic/proc/on_equip(datum/source, mob/equipper, slot)
	if(slot == SLOT_IN_BACKPACK)
		UnregisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC)
		return
	RegisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC, .proc/protect, TRUE)

/datum/component/anti_magic/proc/on_drop(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)

/datum/component/anti_magic/proc/protect(datum/source, mob/user, _magic, _holy, major, self, list/protection_sources)
	if(((_magic && magic) || (_holy && holy)) && (self && blocks_self))
		protection_sources += parent
		reaction.Invoke(user, major)
		if(major)
			charges--
			if(charges <= 0)
				expire.Invoke(user)
		return COMPONENT_BLOCK_MAGIC


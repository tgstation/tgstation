/datum/component/anti_magic
	var/magic = FALSE
	var/holy = FALSE

/datum/component/anti_magic/Initialize(_magic = FALSE, _holy = FALSE)
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
	else if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_RECEIVE_MAGIC, .proc/can_protect)
	else
		return COMPONENT_INCOMPATIBLE

	magic = _magic
	holy = _holy

/datum/component/anti_magic/proc/on_equip(mob/equipper, slot)
	RegisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC, .proc/can_protect, TRUE)

/datum/component/anti_magic/proc/on_drop(mob/user)
	UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)

/datum/component/anti_magic/proc/can_protect(_magic, _holy, list/protection_sources)
	if((_magic && magic) || (_holy && holy))
		protection_sources += parent
		return COMPONENT_BLOCK_MAGIC

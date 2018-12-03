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

/datum/component/anti_magic/proc/on_equip(datum/source, mob/equipper, slot)
	if(slot == SLOT_IN_BACKPACK)
		UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)
		return
	RegisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC, .proc/can_protect, TRUE)

/datum/component/anti_magic/proc/on_drop(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)

/datum/component/anti_magic/proc/can_protect(datum/source, _magic, _holy, major, list/protection_sources)
	if((_magic && magic) || (_holy && holy))
		protection_sources += parent
		react(major)
		return COMPONENT_BLOCK_MAGIC
		
/datum/component/anti_magic/proc/react(major)
	return
		
		
/datum/component/anti_magic/holymelon
	var/uses = 0
	
/datum/component/anti_magic/holymelon/Initialize(_magic = FALSE, _holy = FALSE)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE || !istype(parent, /obj/item/reagent_containers/food/snacks/grown/holymelon))
		return COMPONENT_INCOMPATIBLE
		
	var/obj/item/reagent_containers/food/snacks/grown/holymelon/melon = parent
	if(melon.seed)
		uses = round(melon.seed.potency / 20)
	if(!uses)
		return COMPONENT_INCOMPATIBLE
		
/datum/component/anti_magic/holymelon/react(major)
	if(major)
		uses--
		if(uses <= 0)
			var/obj/item/melon = parent
			melon.visible_message("<span class='warning'>[parent] rapidly turns into ash!</span>")
			new /obj/effect/decal/cleanable/ash(melon.drop_location())
			qdel(parent)
		

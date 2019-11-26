/datum/component/clothing_toggle
	var/obj/item/toggled_clothing
	var/mob/living/wearer
	var/equip_slot
	var/state = FALSE
	var/datum/action/toggle_action
	var/toggle_action_path

/datum/component/clothing_toggle/Initialize(obj/item/toggled_clothing, equip_slot, datum/action/toggle_action)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(!istype(toggled_clothing))
		CRASH("No clothing item path given")
	if(isnull(equip_slot))
		CRASH("No equip slot given")
	if(!istype(toggle_action))
		CRASH("No toggle_action type given")
	src.toggled_clothing = new toggled_clothing(src)
	src.equip_slot = equip_slot
	toggle_action_path = toggle_action

/datum/component/clothing_toggle/Destroy(force, silent)
	QDEL_NULL(toggle_action)
	QDEL_NULL(toggled_clothing)
	wearer = null
	return ..()

/datum/component/clothing_toggle/RegisterWithParent()
	. = ..()
	toggle_action = new toggle_action_path(parent)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED_TO_SLOT, .proc/equipped)
	RegisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, 
		COMSIG_ITEM_DROPPED), .proc/unequipped)
	RegisterSignal(toggle_action, COMSIG_ACTION_TRIGGER, .proc/toggle_clothing)

/datum/component/clothing_toggle/UnregisterFromParent()
	. = ..()
	UnregisterSignal(toggle_action, COMSIG_ACTION_TRIGGER)
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED_TO_SLOT, 
		COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, 
		COMSIG_ITEM_DROPPED))
	QDEL_NULL(toggle_action)

/datum/component/clothing_toggle/proc/equipped(datum/source, mob/equipper)
	if(!isliving(equipper))
		return
	wearer = equipper
	toggle_action.Grant(wearer)

/datum/component/clothing_toggle/proc/unequipped(datum/source, mob/user)
	if(!isliving(user))
		return
	toggle_action.Remove(wearer)
	wearer = null

/datum/component/clothing_toggle/proc/toggle_clothing(datum/source, datum/action/action)
	if(state)
		wearer.transferItemToLoc(toggled_clothing, src, TRUE)
		state = FALSE
		return

	if(wearer.equip_to_slot_if_possible(toggled_clothing, equip_slot))
		state = TRUE

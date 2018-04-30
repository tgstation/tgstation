/datum/component/magnet_drop
    var/target_inventory

/datum/component/magnet_drop/Initialize(_target_inventory)
    if(!isitem(parent))
        return COMPONENT_INCOMPATIBLE
    target_inventory = _target_inventory
    RegisterSignal(COMSIG_ITEM_DROPPED, .proc/mdropped)

/datum/component/magnet_drop/proc/mdropped()
    var/obj/item/I = parent
    I.forceMove(target_inventory)
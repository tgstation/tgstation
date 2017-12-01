/obj/item/stack/merge(obj/item/stack/S)
    // Can't merge items that are pinned
    if (pinned || S.pinned)
        return
    
    return ..()
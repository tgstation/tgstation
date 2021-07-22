/datum/component/storage/concrete/extract_inventory
    max_combined_w_class = WEIGHT_CLASS_TINY * 3
    max_items = 3
    insert_preposition = "in"
    attack_hand_interact = FALSE
    quickdraw = FALSE
    can_transfer = FALSE
    drop_all_on_deconstruct = FALSE
    locked = TRUE
    rustle_sound = FALSE
    silent = TRUE

//These need to be false in order for the extract's food to be unextractable
//from the inventory

/datum/component/storage/concrete/extract_inventory/Initialize()
    . = ..()
    RegisterSignal(parent, COMSIG_TRY_STORAGE_CONSUME_CONTENTS, .proc/processCubes)
    set_holdable(/obj/item/food/monkeycube, list(/obj/item/food/monkeycube/syndicate, /obj/item/food/monkeycube/gorilla, /obj/item/food/monkeycube/chicken, /obj/item/food/monkeycube/bee))


/datum/component/storage/concrete/extract_inventory/proc/processCubes(obj/item/slimecross/reproductive/P)
    SIGNAL_HANDLER

    var/obj/item/slimecross/reproductive/parent = P
    if(length(parent.contents) >= max_items)
        QDEL_LIST(parent.contents)
        createExtracts(parent)

/datum/component/storage/concrete/extract_inventory/proc/createExtracts(obj/item/slimecross/reproductive/P)
    var/obj/item/slimecross/reproductive/parent = P
    var/cores = rand(1,4)
    playsound(parent, 'sound/effects/splat.ogg', 40, TRUE)
    parent.last_produce = world.time
    for(var/i = 0, i < cores, i++)
        new parent.extract_type(get_turf(parent.loc))

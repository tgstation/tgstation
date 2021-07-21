/datum/component/storage/concrete/extract_inventory
	max_combined_w_class = WEIGHT_CLASS_TINY * 3
	max_items = 3
	insert_preposition = "in"
	attack_hand_interact = FALSE
	quickdraw = FALSE

//These need to be false in order for the extract's food to be unextractable
//from the inventory

/datum/component/storage/concrete/extract_inventory/Initialize()
	. = ..()
	RegisterSignal(parent, COMSIG_TRY_STORAGE_CONSUME_CONTENTS, .proc/processCubes)
	set_holdable(/obj/item/food/monkeycube)


/datum/component/storage/concrete/extract_inventory/proc/processCubes(var/obj/item/slimecross/reproductive/P)
    var/obj/item/slimecross/reproductive/parent = P
    if(length(parent.contents) >= max_items)
        QDEL_LIST(parent.contents)
        createExtracts()

/datum/component/storage/concrete/extract_inventory/proc/createExtracts(var/obj/item/slimecross/reproductive/P)
	var/obj/item/slimecross/reproductive/parent = P
	var/cores = rand(1,4)
	to_chat(span_notice("[P] briefly swells to a massive size, and expels [cores] extract[cores > 1 ? "s":""]!"))
	playsound(parent, 'sound/effects/splat.ogg', 40, TRUE)
	parent.last_produce = world.time
	for(var/i = 0, i < cores, i++)
		new parent.extract_type(get_turf(parent.loc))





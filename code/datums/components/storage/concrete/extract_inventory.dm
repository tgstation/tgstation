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
	var/obj/item/slimecross/reproductive/parentSlimeExtract
//These need to be false in order for the extract's food to be unextractable
//from the inventory

/datum/component/storage/concrete/extract_inventory/Initialize()
	. = ..()
	set_holdable(/obj/item/food/monkeycube, list(/obj/item/food/monkeycube/syndicate, /obj/item/food/monkeycube/gorilla, /obj/item/food/monkeycube/chicken, /obj/item/food/monkeycube/bee))
	parentSlimeExtract = parent

/datum/component/storage/concrete/extract_inventory/proc/processCubes(obj/item/slimecross/reproductive/parentSlimeExtract, mob/user)

	if(length(parentSlimeExtract.contents) >= max_items)
		QDEL_LIST(parentSlimeExtract.contents)
		createExtracts(parentSlimeExtract,user)

/datum/component/storage/concrete/extract_inventory/proc/createExtracts(obj/item/slimecross/reproductive/parentSlimeExtract, mob/user)
	var/cores = rand(1,4)
	playsound(parentSlimeExtract, 'sound/effects/splat.ogg', 40, TRUE)
	parentSlimeExtract.last_produce = world.time
	to_chat(user, span_notice("[parent] briefly swells to a massive size, and expels [cores] extract[cores > 1 ? "s":""]!"))
	for(var/i = 0, i < cores, i++)
		new parentSlimeExtract.extract_type(get_turf(parentSlimeExtract.loc))

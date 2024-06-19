/datum/storage/extract_inventory
	max_total_storage = WEIGHT_CLASS_TINY * 3
	max_slots = 3
	insert_preposition = "in"
	attack_hand_interact = FALSE
	quickdraw = FALSE
	locked = STORAGE_FULLY_LOCKED
	rustle_sound = FALSE
	silent = TRUE
	// Snowflake so you can feed it
	insert_on_attack = FALSE

/datum/storage/extract_inventory/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(/obj/item/food/monkeycube)

	var/obj/item/slimecross/reproductive/parent_slime = parent
	if(!istype(parent_slime, /obj/item/slimecross/reproductive))
		stack_trace("storage subtype ([type]) incompatible with [parent_slime] ([parent_slime.type])")
		qdel(src)

/datum/storage/extract_inventory/proc/processCubes(mob/user)
	var/obj/item/slimecross/reproductive/parentSlimeExtract = parent
	if(real_location.contents.len >= max_slots)
		QDEL_LIST(parentSlimeExtract.contents)
		createExtracts(user)

/datum/storage/extract_inventory/proc/createExtracts(mob/user)
	var/obj/item/slimecross/reproductive/parentSlimeExtract = parent

	var/cores = rand(1,4)
	playsound(parentSlimeExtract, 'sound/effects/splat.ogg', 40, TRUE)
	parentSlimeExtract.last_produce = world.time
	to_chat(user, span_notice("[parentSlimeExtract] briefly swells to a massive size, and expels [cores] extract[cores > 1 ? "s":""]!"))
	for(var/i in 1 to cores)
		new parentSlimeExtract.extract_type(parentSlimeExtract.drop_location())

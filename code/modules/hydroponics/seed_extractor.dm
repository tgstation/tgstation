/**
 * Finds and extracts seeds from an object
 *
 * Checks if the object is such that creates a seed when extracted.  Used by seed
 * extractors or posably anything that would create seeds in some way.  The seeds
 * are dropped either at the extractor, if it exists, or where the original object
 * was and it qdel's the object
 *
 * Arguments:
 * * O - Object containing the seed, can be the loc of the dumping of seeds
 * * t_max - Amount of seed copies to dump, -1 is ranomized
 * * extractor - Seed Extractor, used as the dumping loc for the seeds and seed multiplier
 * * user - checks if we can remove the object from the inventory
 * *
 */
/proc/seedify(obj/item/O, t_max, obj/machinery/seed_extractor/extractor, mob/living/user)
	var/t_amount = 0
	var/list/seeds = list()
	if(t_max == -1)
		if(extractor)
			t_max = rand(1,4) * extractor.seed_multiplier
		else
			t_max = rand(1,4)

	var/seedloc = O.loc
	if(extractor)
		seedloc = extractor.loc

	if(istype(O, /obj/item/food/grown/))
		var/obj/item/food/grown/F = O
		if(F.seed)
			if(user && !user.temporarilyRemoveItemFromInventory(O)) //couldn't drop the item
				return
			while(t_amount < t_max)
				var/obj/item/seeds/t_prod = F.seed.Copy()
				seeds.Add(t_prod)
				t_prod.forceMove(seedloc)
				t_amount++
			qdel(O)
			return seeds

	else if(istype(O, /obj/item/grown))
		var/obj/item/grown/F = O
		if(F.seed)
			if(user && !user.temporarilyRemoveItemFromInventory(O))
				return
			while(t_amount < t_max)
				var/obj/item/seeds/t_prod = F.seed.Copy()
				t_prod.forceMove(seedloc)
				t_amount++
			qdel(O)
		return 1

	return 0


/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "sextractor"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/seed_extractor
	/// Associated list of seeds, they are all weak refs.  We check the len to see how many refs we have for each
	// seed
	var/list/piles = list()
	var/max_seeds = 1000
	var/seed_multiplier = 1

/obj/machinery/seed_extractor/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	register_context()

/obj/machinery/seed_extractor/add_context(
	atom/source,
	list/context,
	obj/item/held_item,
	mob/living/user,
)

	if(held_item?.get_plant_seed())
		context[SCREENTIP_CONTEXT_LMB] = "Make seeds"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/storage/bag/plants) && (locate(/obj/item/seeds) in held_item.contents))
		context[SCREENTIP_CONTEXT_LMB] = "Store seeds"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/machinery/seed_extractor/RefreshParts()
	. = ..()
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		max_seeds = initial(max_seeds) * matter_bin.tier
	for(var/datum/stock_part/manipulator/manipulator in component_parts)
		seed_multiplier = initial(seed_multiplier) * manipulator.tier

/obj/machinery/seed_extractor/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Extracting <b>[seed_multiplier] to [seed_multiplier * 4]</b> seed(s) per piece of produce.<br>Machine can store up to <b>[max_seeds]</b> seeds.")

/obj/machinery/seed_extractor/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/seed_extractor/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!isliving(user) || user.combat_mode)
		return ..()

	if(default_deconstruction_screwdriver(user, "sextractor_open", "sextractor", attacking_item))
		return TRUE

	if(default_pry_open(attacking_item))
		return TRUE

	if(default_deconstruction_crowbar(attacking_item))
		return TRUE

	if(istype(attacking_item, /obj/item/storage/bag/plants))
		var/loaded = 0
		for(var/obj/item/seeds/to_store in attacking_item.contents)
			if(contents.len >= max_seeds)
				to_chat(user, span_warning("[src] is full."))
				break
			if(!add_seed(to_store, attacking_item))
				continue
			loaded += 1

		if(loaded)
			to_chat(user, span_notice("You put as many seeds from [attacking_item] into [src] as you can."))
		else
			to_chat(user, span_warning("There are no seeds in [attacking_item]."))

		return TRUE

	if(seedify(attacking_item, -1, src, user))
		to_chat(user, span_notice("You extract some seeds."))
		return TRUE

	else if(istype(attacking_item, /obj/item/seeds))
		if(contents.len >= max_seeds)
			to_chat(user, span_warning("[src] is full."))

		else if(add_seed(attacking_item, user))
			to_chat(user, span_notice("You add [attacking_item] to [src]."))

		else
			to_chat(user, span_warning("You can't seem to add [attacking_item] to [src]."))
		return TRUE

	else if(!attacking_item.tool_behaviour) // Using the wrong tool shouldn't assume you want to turn it into seeds.
		to_chat(user, span_warning("You can't extract any seeds from [attacking_item]!"))
		return TRUE

	return ..()

/**
 * Generate seed string
 *
 * Creates a string based of the traits of a seed.  We use this string as a bucket for all
 * seeds that match as well as the key the ui uses to get the seed.  We also use the key
 * for the data shown in the ui.  Javascript parses this string to display
 *
 * Arguments:
 * * O - seed to generate the string from
 */
/obj/machinery/seed_extractor/proc/generate_seed_hash(obj/item/seeds/O)
	var/genes = list2params(O.genes)
	return md5("[O.name][O.lifespan][O.endurance][O.maturation][O.production][O.yield][O.potency][O.instability][genes]");

/** Add Seeds Proc.
 *
 * Adds the seeds to the contents and to an associated list that pregenerates the data
 * needed to go to the ui handler
 *
 * to_add - what seed are we adding?
 * taking_from - where are we taking the seed from? A mob, a bag, etc?
 * user - who is inserting the seed?
 **/
/obj/machinery/seed_extractor/proc/add_seed(obj/item/seeds/to_add, atom/taking_from)
	if(ismob(taking_from))
		var/mob/mob_loc = taking_from
		if(!mob_loc.transferItemToLoc(to_add, src))
			return FALSE

	else if(!taking_from.atom_storage?.attempt_remove(to_add, src, silent = TRUE))
		return FALSE

	var/seed_id = generate_seed_hash(to_add)
	if(piles[seed_id])
		piles[seed_id]["refs"] += WEAKREF(to_add)
	else
		var/list/seed_data = list()
		seed_data["icon"] = sanitize_css_class_name("[initial(to_add.icon)][initial(to_add.icon_state)]")
		seed_data["name"] = capitalize(replacetext(to_add.name,"pack of ", ""));
		seed_data["lifespan"] = to_add.lifespan
		seed_data["endurance"] = to_add.endurance
		seed_data["maturation"] = to_add.maturation
		seed_data["production"] = to_add.production
		seed_data["yield"] = to_add.yield
		seed_data["potency"] = to_add.potency
		seed_data["instability"] = to_add.instability
		seed_data["refs"] = list(WEAKREF(to_add))
		seed_data["traits"] = list()
		for(var/datum/plant_gene/trait/trait in to_add.genes)
			seed_data["traits"] += trait.type
		seed_data["reagents"] = list()
		for(var/datum/plant_gene/reagent/reagent in to_add.genes)
			seed_data["reagents"] += list(list(
				"name" = reagent.name,
				"rate" = reagent.rate
			))
		seed_data["volume_mod"] = (locate(/datum/plant_gene/trait/maxchem) in to_add.genes) ? 2 : 1
		piles[seed_id] = seed_data
	return TRUE

/obj/machinery/seed_extractor/ui_state(mob/user)
	return GLOB.notcontained_state

/obj/machinery/seed_extractor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SeedExtractor", name)
		ui.open()

/obj/machinery/seed_extractor/ui_data()
	var/list/seeds = list()
	for(var/seed_id in piles)
		if (!length(piles[seed_id]["refs"]))
			piles.Remove(seed_id) // This shouldn't happen but still
			continue
		var/list/seed_data = piles[seed_id]
		seed_data = seed_data.Copy()
		seed_data["key"] = seed_id
		seed_data["amount"] = length(seed_data["refs"])
		seed_data.Remove("refs")
		seeds += list(seed_data)
	. = list()
	.["seeds"] = seeds

/obj/machinery/seed_extractor/ui_static_data(mob/user)
	var/list/data = list()
	data["cycle_seconds"] = HYDROTRAY_CYCLE_DELAY / 10
	data["trait_db"] = list()
	for(var/trait_path in subtypesof(/datum/plant_gene/trait))
		var/datum/plant_gene/trait/trait = new trait_path
		var/trait_data = list(list(
			"path" = trait.type,
			"name" = trait.name,
			"icon" = trait.icon,
			"description" = trait.description
		))
		data["trait_db"] += trait_data
	return data

/obj/machinery/seed_extractor/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("scrap")
			var/item = params["item"]
			if(piles[item])
				piles.Remove(item)
				. = TRUE
		if("take")
			var/item = params["item"]
			if(piles[item] && length(piles[item]) > 0)
				var/datum/weakref/found_seed_weakref = piles[item]["refs"][1]
				var/obj/item/seeds/found_seed = found_seed_weakref.resolve()
				if(!found_seed)
					return

				piles[item]["refs"] -= found_seed_weakref
				if(usr)
					var/mob/user = usr
					if(user.put_in_hands(found_seed))
						to_chat(user, span_notice("You take [found_seed] out of the slot."))
					else
						to_chat(user, span_notice("[found_seed] falls onto the floor."))
				else
					found_seed.forceMove(drop_location())
					visible_message(span_notice("[found_seed] falls onto the floor."), null, span_hear("You hear a soft clatter."), COMBAT_MESSAGE_RANGE)
				. = TRUE

/obj/machinery/seed_extractor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/seeds)
	)

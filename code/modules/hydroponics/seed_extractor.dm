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

/obj/machinery/seed_extractor/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		max_seeds = initial(max_seeds) * B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		seed_multiplier = initial(seed_multiplier) * M.rating

/obj/machinery/seed_extractor/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Extracting <b>[seed_multiplier]</b> seed(s) per piece of produce.<br>Machine can store up to <b>[max_seeds]%</b> seeds.</span>"

/obj/machinery/seed_extractor/attackby(obj/item/O, mob/user, params)

	if(default_deconstruction_screwdriver(user, "sextractor_open", "sextractor", O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		return

	if(default_deconstruction_crowbar(O))
		return

	if(istype(O, /obj/item/storage/bag/plants))
		var/obj/item/storage/P = O
		var/loaded = 0
		for(var/obj/item/seeds/G in P.contents)
			if(contents.len >= max_seeds)
				break
			++loaded
			add_seed(G)
		if (loaded)
			to_chat(user, "<span class='notice'>You put as many seeds from \the [O.name] into [src] as you can.</span>")
		else
			to_chat(user, "<span class='notice'>There are no seeds in \the [O.name].</span>")
		return

	else if(seedify(O,-1, src, user))
		to_chat(user, "<span class='notice'>You extract some seeds.</span>")
		return
	else if (istype(O, /obj/item/seeds))
		if(add_seed(O))
			to_chat(user, "<span class='notice'>You add [O] to [src.name].</span>")
			updateUsrDialog()
		return
	else if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>You can't extract any seeds from \the [O.name]!</span>")
	else
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
/obj/machinery/seed_extractor/proc/generate_seed_string(obj/item/seeds/O)
	return "name=[O.name];lifespan=[O.lifespan];endurance=[O.endurance];maturation=[O.maturation];production=[O.production];yield=[O.yield];potency=[O.potency];instability=[O.instability]"


/** Add Seeds Proc.
 *
 * Adds the seeds to the contents and to an associated list that pregenerates the data
 * needed to go to the ui handler
 *
 **/
/obj/machinery/seed_extractor/proc/add_seed(obj/item/seeds/O)
	if(contents.len >= 999)
		to_chat(usr, "<span class='notice'>\The [src] is full.</span>")
		return FALSE

	var/datum/component/storage/STR = O.loc.GetComponent(/datum/component/storage)
	if(STR)
		if(!STR.remove_from_storage(O,src))
			return FALSE
	else if(ismob(O.loc))
		var/mob/M = O.loc
		if(!M.transferItemToLoc(O, src))
			return FALSE

	var/seed_string = generate_seed_string(O)
	if(piles[seed_string])
		piles[seed_string] += WEAKREF(O)
	else
		piles[seed_string] = list(WEAKREF(O))

	. = TRUE

/obj/machinery/seed_extractor/ui_state(mob/user)
	return GLOB.notcontained_state

/obj/machinery/seed_extractor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SeedExtractor", name)
		ui.open()

/obj/machinery/seed_extractor/ui_data()
	var/list/V = list()
	for(var/key in piles)
		if(piles[key])
			var/len = length(piles[key])
			if(len)
				V[key] = len

	. = list()
	.["seeds"] = V

/obj/machinery/seed_extractor/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("select")
			var/item = params["item"]
			if(piles[item] && length(piles[item]) > 0)
				var/datum/weakref/found_seed_weakref = piles[item][1]
				var/obj/item/seeds/found_seed = found_seed_weakref.resolve()
				if(!found_seed)
					return

				piles[item] -= found_seed_weakref
				if(usr)
					var/mob/user = usr
					if(user.put_in_hands(found_seed))
						to_chat(user, "<span class='notice'>You take [found_seed] out of the slot.</span>")
					else
						to_chat(user, "<span class='notice'>[found_seed] falls onto the floor.</span>")
				else
					found_seed.forceMove(drop_location())
					visible_message("<span class='notice'>[found_seed] falls onto the floor.</span>", null, "<span class='hear'>You hear a soft clatter.</span>", COMBAT_MESSAGE_RANGE)
				. = TRUE


//Fish sources that're usually associated with structures or machinery.

/datum/fish_source/moisture_trap
	background = "background_dank"
	catalog_description = "Moisture trap basins"
	radial_state = "garbage"
	overlay_state = "portal_river" // placeholder
	fish_table = list(
		FISHING_DUD = 20,
		/obj/item/fish/ratfish = 10,
		/obj/item/fish/slimefish = 4,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 20

/datum/fish_source/toilet
	background = "background_dank"
	catalog_description = "Station toilets"
	radial_state = "toilet"
	duds = list("ewww... nothing", "it was nothing", "it was toilet paper", "it was flushed away", "the hook is empty", "where's the damn money?!")
	overlay_state = "portal_river" // placeholder
	fish_table = list(
		FISHING_DUD = 18,
		/obj/item/fish/sludgefish = 18,
		/obj/item/fish/slimefish = 4,
		/obj/item/storage/wallet/money = 2,
		/obj/item/survivalcapsule/fishing = 1,
	)
	fish_counts = list(
		/obj/item/storage/wallet/money = 2,
		/obj/item/survivalcapsule/fishing = 1,
	)
	fishing_difficulty = FISHING_EASY_DIFFICULTY + 10

/datum/fish_source/holographic
	catalog_description = "Holographic water"
	fish_table = list(
		/obj/item/fish/holo = 10,
		/obj/item/fish/holo/crab = 10,
		/obj/item/fish/holo/puffer = 10,
		/obj/item/fish/holo/angel = 10,
		/obj/item/fish/holo/clown = 10,
		/obj/item/fish/holo/checkered = 5,
		/obj/item/fish/holo/halffish = 5,
	)
	fishing_difficulty = FISHING_EASY_DIFFICULTY + 10
	fish_source_flags = FISH_SOURCE_FLAG_NO_BLUESPACE_ROD
	associated_safe_turfs = list(/turf/open/floor/holofloor/beach/water)

/datum/fish_source/holographic/on_fishing_spot_init(datum/component/fishing_spot/spot)
	ADD_TRAIT(spot.parent, TRAIT_UNLINKABLE_FISHING_SPOT, REF(src)) //You would have to be inside the holodeck anyway...

/datum/fish_source/holographic/on_fishing_spot_del(datum/component/fishing_spot/spot)
	REMOVE_TRAIT(spot.parent, TRAIT_UNLINKABLE_FISHING_SPOT, REF(src))

/datum/fish_source/holographic/generate_wiki_contents(datum/autowiki/fish_sources/wiki)
	var/obj/item/fish/prototype = /obj/item/fish/holo/checkered
	return LIST_VALUE_WRAP_LISTS(list(
		FISH_SOURCE_AUTOWIKI_NAME = "Holographic Fish",
		FISH_SOURCE_AUTOWIKI_ICON = FISH_AUTOWIKI_FILENAME(prototype),
		FISH_SOURCE_AUTOWIKI_WEIGHT = 100,
		FISH_SOURCE_AUTOWIKI_NOTES = "Holographic fish disappears outside the Holodeck",
	))

/datum/fish_source/holographic/reason_we_cant_fish(obj/item/fishing_rod/rod, mob/fisherman, atom/parent)
	. = ..()
	if(!istype(get_area(fisherman), /area/station/holodeck))
		return "You need to be inside the Holodeck to catch holographic fish."

/datum/fish_source/holographic/pre_challenge_started(obj/item/fishing_rod/rod, mob/user, datum/fishing_challenge/challenge)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(check_area))

/datum/fish_source/holographic/proc/check_area(mob/user)
	SIGNAL_HANDLER
	if(!istype(get_area(user), /area/station/holodeck))
		interrupt_challenge("exited holodeck")

/datum/fish_source/holographic/on_challenge_completed(datum/fishing_challenge/source, mob/user, success)
	. = ..()
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/datum/fish_source/hydro_tray
	background = "background_tray"
	catalog_description = "Hydroponics trays"
	radial_state = "hydro"
	overlay_state = "portal_tray"
	fish_table = list(
		FISHING_DUD = 25,
		/obj/item/food/grown/grass = 25,
		FISHING_RANDOM_SEED = 16,
		/obj/item/seeds/grass = 6,
		/obj/item/seeds/random = 1,
		/mob/living/basic/frog = 1,
		/mob/living/basic/axolotl = 1,
		/mob/living/basic/turtle = 2,
	)
	fish_counts = list(
		/obj/item/food/grown/grass = 10,
		/obj/item/seeds/grass = 4,
		FISHING_RANDOM_SEED = 4,
		/obj/item/seeds/random = 1,
		/mob/living/basic/frog = 1,
		/mob/living/basic/axolotl = 1,
	)
	fishing_difficulty = FISHING_EASY_DIFFICULTY + 5

/datum/fish_source/hydro_tray/generate_wiki_contents(datum/autowiki/fish_sources/wiki)
	var/list/data = list()
	var/total_weight = 0
	var/critter_weight = 0
	var/seed_weight = 0
	var/other_weight = 0
	var/dud_weight = fish_table[FISHING_DUD]
	for(var/content in fish_table)
		var/weight = fish_table[content]
		total_weight += weight
		if(ispath(content, /mob/living))
			critter_weight += weight
		else if(ispath(content, /obj/item/food/grown) || ispath(content, /obj/item/seeds) || content == FISHING_RANDOM_SEED)
			seed_weight += weight
		else if(content != FISHING_DUD)
			other_weight += weight

	data += LIST_VALUE_WRAP_LISTS(list(
		FISH_SOURCE_AUTOWIKI_NAME = FISH_SOURCE_AUTOWIKI_DUD,
		FISH_SOURCE_AUTOWIKI_DUD = "",
		FISH_SOURCE_AUTOWIKI_WEIGHT = PERCENT(dud_weight/total_weight),
		FISH_SOURCE_AUTOWIKI_WEIGHT_SUFFIX = "WITHOUT A BAIT",
		FISH_SOURCE_AUTOWIKI_NOTES = "",
	))

	data += LIST_VALUE_WRAP_LISTS(list(
		FISH_SOURCE_AUTOWIKI_NAME = "Critter",
		FISH_SOURCE_AUTOWIKI_DUD = "",
		FISH_SOURCE_AUTOWIKI_WEIGHT = PERCENT(critter_weight/total_weight),
		FISH_SOURCE_AUTOWIKI_NOTES = "A small creature, usually a frog or an axolotl",
	))

	if(other_weight)
		data += LIST_VALUE_WRAP_LISTS(list(
			FISH_SOURCE_AUTOWIKI_NAME = "Other Stuff",
			FISH_SOURCE_AUTOWIKI_DUD = "",
			FISH_SOURCE_AUTOWIKI_WEIGHT = PERCENT(other_weight/total_weight),
			FISH_SOURCE_AUTOWIKI_NOTES = "Other stuff, who knows...",
		))

	return data

/datum/fish_source/hydro_tray/reason_we_cant_fish(obj/item/fishing_rod/rod, mob/fisherman, atom/parent)
	if(!istype(parent, /obj/machinery/hydroponics/constructable))
		return ..()

	var/obj/machinery/hydroponics/constructable/basin = parent
	if(basin.waterlevel <= 0)
		return "There's no water in [parent] to fish in."
	if(basin.myseed)
		return "There's a plant growing in [parent]."

	return ..()

/datum/fish_source/hydro_tray/spawn_reward_from_explosion(atom/location, severity)
	if(!istype(location, /obj/machinery/hydroponics/constructable))
		return ..()

	var/obj/machinery/hydroponics/constructable/basin = location
	if(basin.myseed || basin.waterlevel <= 0)
		return
	return ..()

/datum/fish_source/hydro_tray/spawn_reward(reward_path, atom/spawn_location, atom/fishing_spot, obj/item/fishing_rod/used_rod)
	if(reward_path != FISHING_RANDOM_SEED)
		var/mob/living/created_reward = ..()
		if(istype(created_reward))
			created_reward.name = "small [created_reward.name]"
			created_reward.update_transform(0.75)
		return created_reward

	var/static/list/seeds_to_draw_from
	if(isnull(seeds_to_draw_from))
		seeds_to_draw_from = subtypesof(/obj/item/seeds)
		// These two are already covered innately
		seeds_to_draw_from -= /obj/item/seeds/random
		seeds_to_draw_from -= /obj/item/seeds/grass
		// -1 yield are unharvestable plants so we don't care
		// 20 rarirty is where most of the wacky plants are so let's ignore them
		for(var/obj/item/seeds/seed_path as anything in seeds_to_draw_from)
			if(initial(seed_path.yield) == -1 || initial(seed_path.rarity) >= PLANT_MODERATELY_RARE)
				seeds_to_draw_from -= seed_path

	var/picked_path = pick(seeds_to_draw_from)
	return new picked_path(spawn_location)

/datum/fish_source/deepfryer
	background = "background_lavaland"
	catalog_description = "Deep Fryers"
	radial_state = "fryer"
	overlay_state = "portal_fry" // literally resprited lava. better than nothing
	fish_table = list(
		/obj/item/food/badrecipe = 15,
		/obj/item/food/nugget = 5,
		/obj/item/fish/fryish = 40,
		/obj/item/fish/fryish/fritterish = 4,
		/obj/item/fish/fryish/nessie = 1,
	)
	fish_counts = list(
		/obj/item/fish/fryish = 10,
		/obj/item/fish/fryish/fritterish = 4,
		/obj/item/fish/fryish/nessie = 1,
	)
	fish_count_regen = list(
		/obj/item/fish/fryish = 2 MINUTES,
		/obj/item/fish/fryish/fritterish = 6 MINUTES,
		/obj/item/fish/fryish/nessie = 22 MINUTES,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 23

#define RANDOM_AQUARIUM_FISH "random_aquarium_fish"

/datum/fish_source/aquarium
	catalog_description = "Aquariums"
	radial_state = "fish_tank"
	fish_table = list(
		FISHING_DUD = 10,
	)
	fish_source_flags = FISH_SOURCE_FLAG_NO_BLUESPACE_ROD|FISH_SOURCE_FLAG_IGNORE_HIDDEN_ON_CATALOG|FISH_SOURCE_FLAG_EXPLOSIVE_NONE
	fishing_difficulty = FISHING_EASY_DIFFICULTY + 5

#undef RANDOM_AQUARIUM_FISH

/datum/fish_source/aquarium/get_fish_table(atom/location, from_explosion = FALSE)
	if(istype(location, /obj/machinery/fishing_portal_generator))
		var/obj/machinery/fishing_portal_generator/portal = location
		location = portal.current_linked_atom
	var/list/table = list()
	for(var/obj/item/fish/fish in location)
		if(fish.status == FISH_DEAD) //dead fish cannot be caught
			continue
		table[fish] = 10
	if(!length(table))
		return fish_table.Copy()
	return table

/datum/fish_source/aquarium/generate_wiki_contents(datum/autowiki/fish_sources/wiki)
	var/list/data = list()

	data += LIST_VALUE_WRAP_LISTS(list(
		FISH_SOURCE_AUTOWIKI_NAME = "Fish",
		FISH_SOURCE_AUTOWIKI_DUD = "",
		FISH_SOURCE_AUTOWIKI_WEIGHT = 100,
		FISH_SOURCE_AUTOWIKI_NOTES = "Any fish currently inside the aquarium, be they alive or dead.",
	))

	return data

/datum/fish_source/vending
	background = "background_chasm"
	catalog_description = "Vending Machines"
	radial_state = "vending"
	overlay_state = "portal_randomizer"
	fish_table = list(
		FISHING_DUD = 10,
	)
	fish_source_flags = FISH_SOURCE_FLAG_NO_BLUESPACE_ROD|FISH_SOURCE_FLAG_EXPLOSIVE_NONE
	fishing_difficulty = FISHING_EASY_DIFFICULTY //with some equipment and just enough dosh, you should be able to skip the minigame

/datum/fish_source/vending/generate_wiki_contents(datum/autowiki/fish_sources/wiki)
	var/list/data = list()

	data += LIST_VALUE_WRAP_LISTS(list(
		FISH_SOURCE_AUTOWIKI_NAME = "Vending Products",
		FISH_SOURCE_AUTOWIKI_DUD = "",
		FISH_SOURCE_AUTOWIKI_WEIGHT = 100,
		FISH_SOURCE_AUTOWIKI_NOTES = "Use chips, bills or coins as bait to get a semi-random vending product, depending on both its and the bait's monetary values",
	))

	return data

/datum/fish_source/vending/get_modified_fish_table(obj/item/fishing_rod/rod, mob/fisherman, atom/location)
	if(istype(location, /obj/machinery/fishing_portal_generator))
		var/obj/machinery/fishing_portal_generator/portal = location
		location = portal.current_linked_atom
	if(!istype(location, /obj/machinery/vending))
		return list()

	return get_vending_table(rod, fisherman, location)

/datum/fish_source/vending/proc/get_vending_table(obj/item/fishing_rod/rod, mob/fisherman, obj/machinery/vending/location)
	var/list/table = list()
	///Create a list of products, ordered by price from highest to lowest
	var/list/products = location.product_records + location.coin_records + location.hidden_records
	sortTim(products, GLOBAL_PROC_REF(cmp_vending_prices))

	var/bait_value = rod.bait?.get_item_credit_value() || 1

	var/highest_record_price = 0
	for(var/datum/data/vending_product/product_record as anything in products)
		if(product_record.amount <= 0)
			products -= product_record
			table[FISHING_DUD] += PAYCHECK_LOWER //it gets harder the emptier the machine is
			continue
		if(!highest_record_price)
			highest_record_price = product_record.price
		var/high = max(highest_record_price, bait_value)
		var/low = min(highest_record_price, bait_value)

		//the smaller the difference between product price and bait value, the more likely you're to get it.
		table[product_record] = low/high * 1000 //multiply the value by 1000 for accuracy. pick_weight() doesn't work with zero decimals yet.

	add_risks(table, bait_value, highest_record_price, length(products) * 0.5)
	return table

/datum/fish_source/vending/proc/add_risks(list/table, bait_value, highest_price, malus_multiplier)
	///Using more than the money needed to buy the most expensive item (why would you do it?!) will remove the dud chance.
	if(bait_value > highest_price)
		table -= FISHING_DUD
	else
		//Makes using 1 cred chips with the minigame skip (negative fishing difficulty) a bit less cheesy.
		var/malus = min(PAYCHECK_LOWER - bait_value, highest_price)
		if(malus > 0)
			table[FISHING_DUD] += malus * malus_multiplier
			table[FISHING_VENDING_CHUCK] += malus * malus_multiplier

#define FISHING_PRODUCT_DIFFICULTY_MULT 1.6

/datum/fish_source/vending/calculate_difficulty(datum/fishing_challenge/challenge, result, obj/item/fishing_rod/rod, mob/fisherman)
	//Using less than a minimum paycheck is going to make the challenge a tad harder.
	var/bait_value = rod.bait?.get_item_credit_value()
	var/base_diff = PAYCHECK_LOWER - bait_value
	return ..() + get_product_difficulty(base_diff, result) * FISHING_PRODUCT_DIFFICULTY_MULT

/datum/fish_source/vending/proc/get_product_difficulty(diff, datum/result)
	if(istype(result, /datum/data/vending_product))
		var/datum/data/vending_product/product = result
		diff = min(diff, product.price) // low priced items are easier to catch anyway
	return diff

#undef FISHING_PRODUCT_DIFFICULTY_MULT

/datum/fish_source/vending/dispense_reward(reward_path, mob/fisherman, atom/fishing_spot, obj/item/fishing_rod/rod)
	var/obj/machinery/vending/vending = fishing_spot
	if(istype(fishing_spot, /obj/machinery/fishing_portal_generator))
		var/obj/machinery/fishing_portal_generator/portal = fishing_spot
		vending = portal.current_linked_atom

	if(reward_path == FISHING_VENDING_CHUCK)
		if(fishing_spot != vending) //fishing portals
			vending.forceMove(get_turf(fishing_spot))
		vending.tilt(fisherman, range = 4)
		return null //Don't spawn a reward at all

	var/atom/movable/reward = ..()
	if(reward)
		var/creds_value = rod.bait?.get_item_credit_value()
		if(creds_value)
			vending.credits_contained += round(creds_value * VENDING_CREDITS_COLLECTION_AMOUNT)
			qdel(rod.bait)
	return reward

/datum/fish_source/vending/spawn_reward(reward_path, atom/spawn_location, obj/machinery/vending/fishing_spot, obj/item/fishing_rod/used_rod)
	if(istype(fishing_spot, /obj/machinery/fishing_portal_generator))
		var/obj/machinery/fishing_portal_generator/portal = fishing_spot
		fishing_spot = portal.current_linked_atom
	if(!istype(fishing_spot))
		return null
	return spawn_vending_reward(reward_path, spawn_location, fishing_spot)

/datum/fish_source/vending/proc/spawn_vending_reward(reward_path, atom/spawn_location, obj/machinery/vending/fishing_spot)
	var/datum/data/vending_product/product_record = reward_path
	if(!istype(product_record) || product_record.amount <= 0)
		return null
	return fishing_spot.dispense(product_record, spawn_location)

/datum/fish_source/vending/pre_challenge_started(obj/item/fishing_rod/rod, mob/user, datum/fishing_challenge/challenge)
	RegisterSignal(rod, COMSIG_FISHING_ROD_CAUGHT_FISH, PROC_REF(on_reward))

/datum/fish_source/vending/on_challenge_completed(mob/user, datum/fishing_challenge/challenge, success)
	. = ..()
	UnregisterSignal(challenge.used_rod, COMSIG_FISHING_ROD_CAUGHT_FISH)

/datum/fish_source/vending/proc/on_reward(obj/item/fishing_rod/rod, atom/movable/reward, mob/user)
	SIGNAL_HANDLER
	if(reward && !QDELETED(rod.bait) && rod.bait.get_item_credit_value()) //you pay for what you get
		qdel(rod.bait) // fishing_rod.Exited() will handle clearing the hard ref.

///subtype of fish_source/vending for custom vending machines
/datum/fish_source/vending/custom
	catalog_description = null //no duplicate entries on autowiki or catalog

/datum/fish_source/vending/custom/get_vending_table(obj/item/fishing_rod/rod, mob/fisherman, obj/machinery/vending/location)
	var/list/table = list()
	///Create a list of products, ordered by price from highest to lowest
	var/list/products = location.vending_machine_input.Copy()
	sortTim(products, GLOBAL_PROC_REF(cmp_item_vending_prices))

	var/bait_value = rod.bait?.get_item_credit_value() || 1

	var/highest_record_price = 0
	for(var/obj/item/stocked as anything in products)
		if(location.vending_machine_input[stocked] <= 0)
			products -= stocked
			table[FISHING_DUD] += PAYCHECK_LOWER //it gets harder the emptier the machine is
			continue
		if(!highest_record_price)
			highest_record_price = stocked.custom_price
		var/high = max(highest_record_price, bait_value)
		var/low = min(highest_record_price, bait_value)

		//the smaller the difference between product price and bait value, the more likely you're to get it.
		table[stocked] = low/high * 1000 //multiply the value by 1000 for accuracy. pick_weight() doesn't work with zero decimals yet.

	add_risks(table, bait_value, highest_record_price, length(products) * 0.5)
	return table

/datum/fish_source/vending/custom/get_product_difficulty(diff, datum/result)
	if(isitem(result))
		var/obj/item/product = result
		diff = min(diff, product.custom_price)
	return diff

/datum/fish_source/vending/custom/spawn_vending_reward(obj/item/reward, atom/spawn_location, obj/machinery/vending/fishing_spot)
	if(!isitem(reward))
		return null
	reward.forceMove(spawn_location)
	return reward

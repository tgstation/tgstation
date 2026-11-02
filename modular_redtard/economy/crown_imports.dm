// The Crown's imports (Ratwood code/modules/roguetown/roguestock/_crown_imports.dm, crown_imports.dm, the "import" action of the
// nerve master, and code/controllers/subsystem/rogue/economy/auto_import.dm):
// - crown imports: crates the Steward orders from the regions out of the Crown's Purse, delivered to the warehouse; each order
//   of a kind in a day makes the next dearer, a held road doubles the price;
// - standing imports: every treasury tick the Crown tops up the essentials of the stockpile (and any good the Steward adds)
//   from the cheapest open region, in batches, while the price is sane and the Purse stays above its floor.
// Ratwood's crates are typed chests that fill themselves; here a crown import names its contents, and they are packed into a
// chest under the Steward's lock (or a bin). Contents not ported are skipped, and an import with none is not offered.

/// Goods the Crown keeps stocked on its own unless the Steward stops it (Ratwood AUTO_IMPORT_ESSENTIALS).
GLOBAL_LIST_INIT(rogue_auto_import_essentials, list("COAL", "WOOD", "GRAIN", "IRON_ORE", "HIDE", "FUR", "FAT"))

/**
 * A crate the Crown imports (Ratwood /datum/crown_import): its price, the region it comes from and what it holds.
 */
/datum/rogue_crown_import
	var/name = ""
	var/desc = ""
	var/base_cost = 100
	/// Region it comes from; a held road to it doubles the price (Ratwood source_region_id).
	var/region_id
	/// Path text -> how many it holds.
	var/list/contents = list()
	/// Holds one of these, picked when it is packed (Ratwood's horses of three coats).
	var/list/pick_one
	/// What it holds is shrunk to this size (Ratwood's miniature pony).
	var/shrink = 1
	/// Packed in a wooden bin instead of a chest under the Steward's lock.
	var/bin = FALSE
	/// Orders of it today: each makes the next dearer (Ratwood daily_import_count).
	var/ordered_today = 0

/// Ratwood get_import_price(): the base cost, dearer with every order today and on a held road.
/datum/rogue_crown_import/proc/price()
	var/mult = 1 + ordered_today * rogue_value("trade_crown_import_elasticity")
	var/datum/rogue_trade_region/region = SSrogue_trade.regions[region_id]
	if(region?.blockaded)
		mult *= rogue_value("trade_blockade_import_mult")
	return max(round(base_cost * mult), rogue_value("trade_crown_import_min"))

/// Ported contents: path -> count.
/datum/rogue_crown_import/proc/ported_contents()
	var/list/ported = list()
	for(var/path_text in contents)
		var/path = text2path(path_text)
		if(ispath(path, /atom/movable))
			ported[path] = contents[path_text]
	return ported

/datum/rogue_crown_import/proc/available()
	if(length(ported_contents()))
		return TRUE
	for(var/path_text in pick_one)
		if(ispath(text2path(path_text), /atom/movable))
			return TRUE
	return FALSE

/// Packs the crate and leaves it at a free spot of the warehouse, or by the fallback (Ratwood do_import()).
/datum/rogue_crown_import/proc/deliver(turf/fallback)
	var/list/spots = list()
	for(var/turf/open/spot in get_area_turfs(/area/rogue/indoors/town/warehouse, 0, TRUE))
		if(!spot.is_blocked_turf(exclude_mobs = TRUE))
			spots += spot
	var/turf/spot = length(spots) ? pick(spots) : fallback
	if(!spot)
		return
	var/atom/movable/container
	if(bin)
		container = new /obj/item/roguebin(spot)
	else
		var/obj/structure/closet/crate/wooden/rockhill/crate/chest/chest = new(spot)
		chest.lockid = "steward"
		container = chest
	var/list/to_pack = ported_contents()
	var/list/picks = list()
	for(var/path_text in pick_one)
		var/path = text2path(path_text)
		if(ispath(path, /atom/movable))
			picks += path
	if(length(picks))
		to_pack[pick(picks)] = 1
	for(var/path in to_pack)
		for(var/i in 1 to to_pack[path])
			var/atom/movable/packed = new path(container)
			if(shrink != 1)
				packed.transform = packed.transform.Scale(shrink, shrink)
	if(istype(container, /obj/structure/closet))
		var/obj/structure/closet/chest = container
		chest.locked = TRUE
		chest.update_appearance()
	playsound(spot, ROGUE_SOUND_HISS, 100, FALSE, -1)

/datum/controller/subsystem/rogue_trade
	var/list/datum/rogue_crown_import/crown_imports = list()

/datum/controller/subsystem/rogue_trade/proc/setup_crown_imports()
	for(var/import_type in subtypesof(/datum/rogue_crown_import))
		crown_imports += new import_type

/// Ratwood reset_daily_demand(): at dawn the imports cost their base price again.
/datum/controller/subsystem/rogue_trade/proc/reset_crown_imports()
	for(var/datum/rogue_crown_import/crown_import as anything in crown_imports)
		crown_import.ordered_today = 0

/**
 * The Steward orders a crate (Ratwood steward.dm "import"): the Purse pays, a large purchase is cried on the SCOM, and the
 * crate arrives at the warehouse a little later. Returns TRUE when ordered.
 */
/datum/controller/subsystem/rogue_trade/proc/order_crown_import(datum/rogue_crown_import/crown_import, mob/user, turf/fallback)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	if(!crown_import?.available() || !treasury.crown_purse)
		return FALSE
	var/price = crown_import.price()
	if(!treasury.burn(treasury.crown_purse, price, "Import: [crown_import.name]"))
		to_chat(user, span_warning("Insufficient mammon."))
		return FALSE
	treasury.total_import += price
	crown_import.ordered_today++
	if(price >= rogue_value("trade_crown_import_announce"))
		rogue_scom_announce("Rockhill imports [crown_import.name] for [price] mammon.")
	addtimer(CALLBACK(crown_import, TYPE_PROC_REF(/datum/rogue_crown_import, deliver), fallback), rogue_value("trade_crown_import_delay"))
	log_game("CROWN IMPORT: [key_name(user)] imported [crown_import.name] for [price]m")
	return TRUE

/datum/rogue_crown_import/proc/ui_entry()
	var/datum/rogue_trade_region/region = SSrogue_trade.regions[region_id]
	return list(
		"ref" = REF(src),
		"name" = name,
		"desc" = desc,
		"price" = price(),
		"region" = region?.name,
		"blockaded" = region?.blockaded,
		"ordered" = ordered_today,
	)

// Standing imports.

/datum/controller/subsystem/rogue_treasury
	/// Goods the Steward put on standing import, and essentials the Steward stopped (Ratwood auto_import_standing, _disabled).
	var/list/auto_import_standing = list()
	var/list/auto_import_disabled = list()
	/// Below this the standing imports buy nothing (Ratwood auto_import_purse_floor); the Steward sets it.
	var/auto_import_floor = 0
	/// What the standing imports spent and did today, and on past days (Ratwood auto_import_daily_*).
	var/auto_import_spent = 0
	var/auto_import_dawn = -1
	var/list/auto_import_lines = list()
	var/list/auto_import_history = list()

/datum/controller/subsystem/rogue_treasury/proc/auto_import_active(good_id)
	if(good_id in GLOB.rogue_auto_import_essentials)
		return !auto_import_disabled[good_id]
	return !!auto_import_standing[good_id]

/// Ratwood set_auto_import(): an essential is stopped or resumed, another good put on or taken off standing import.
/datum/controller/subsystem/rogue_treasury/proc/set_auto_import(good_id, active)
	if(good_id in GLOB.rogue_auto_import_essentials)
		if(active)
			auto_import_disabled -= good_id
		else
			auto_import_disabled[good_id] = TRUE
		return
	var/datum/rogue_trade_good/good = SSrogue_trade.goods[good_id]
	if(active && good?.stock)
		auto_import_standing[good_id] = TRUE
	else
		auto_import_standing -= good_id

/// Ratwood kill_switch_auto_import(): every standing import stops.
/datum/controller/subsystem/rogue_treasury/proc/stop_auto_imports()
	for(var/good_id in GLOB.rogue_auto_import_essentials)
		auto_import_disabled[good_id] = TRUE
	auto_import_standing.Cut()

/// Ratwood run_auto_import_tick(), every treasury tick: the day's tally rolls over at a new dawn, then each good is topped up.
/datum/controller/subsystem/rogue_treasury/proc/run_auto_imports()
	if(auto_import_dawn != ROGUE_TREASURY_DAY)
		if(auto_import_dawn != -1)
			auto_import_history += list(list("dawn" = auto_import_dawn, "spent" = auto_import_spent, "lines" = auto_import_lines))
			while(length(auto_import_history) > rogue_value("trade_auto_import_history"))
				auto_import_history.Cut(1, 2)
		auto_import_dawn = ROGUE_TREASURY_DAY
		auto_import_spent = 0
		auto_import_lines = list()
	for(var/good_id in GLOB.rogue_auto_import_essentials)
		if(!auto_import_disabled[good_id])
			auto_import_good(good_id)
	for(var/good_id in auto_import_standing)
		if(!(good_id in GLOB.rogue_auto_import_essentials))
			auto_import_good(good_id)

/**
 * Ratwood process_auto_import_for_good(): a good below its floor in the stockpile is bought from the cheapest region in a batch,
 * unless the price has climbed too far over its trade price or the Purse would fall below the floor.
 */
/datum/controller/subsystem/rogue_treasury/proc/auto_import_good(good_id)
	var/datum/rogue_trade_good/good = SSrogue_trade.goods[good_id]
	if(!good?.stock || good.stock.stockpile_amount >= rogue_value("trade_auto_import_floor"))
		return
	var/list/quote = SSrogue_trade.import_quote(good)
	if(!quote)
		auto_import_lines += "[good.name]: no producing region available."
		return
	var/datum/rogue_trade_region/region = quote["region"]
	var/batch = round(rogue_value("trade_auto_import_batch"))
	var/total = 0
	var/dearest = 0
	for(var/i in 1 to batch)
		var/unit = region.import_unit_cost(good, i - 1)
		total += unit
		dearest = max(dearest, unit)
	if(dearest > good.base_price * rogue_value("trade_auto_import_price_cap"))
		auto_import_lines += "[good.name]: skipped (unit price [dearest]m over [rogue_value("trade_auto_import_price_cap")]x its price of [good.base_price]m)."
		return
	if(crown_purse.account_balance - total < auto_import_floor)
		auto_import_lines += "[good.name]: skipped (the purse floor of [auto_import_floor]m would be breached)."
		return
	var/spent = SSrogue_trade.region_import(region, good, batch)
	if(!spent)
		return
	auto_import_spent += spent
	auto_import_lines += "[good.name]: +[batch] from [region.name] ([spent]m)."

/// The standing imports, for the nerve master's window (Ratwood build_auto_import_data()).
/datum/controller/subsystem/rogue_treasury/proc/auto_import_ui_data()
	var/list/goods = list()
	for(var/good_id in SSrogue_trade.goods)
		var/datum/rogue_trade_good/good = SSrogue_trade.goods[good_id]
		if(!good.stock || !length(SSrogue_trade.import_quote(good)))
			continue
		goods += list(list(
			"id" = good_id,
			"name" = good.name,
			"essential" = (good_id in GLOB.rogue_auto_import_essentials),
			"active" = auto_import_active(good_id),
			"stocked" = good.stock.stockpile_amount,
		))
	return list(
		"goods" = goods,
		"floor" = auto_import_floor,
		"stock_floor" = rogue_value("trade_auto_import_floor"),
		"batch" = rogue_value("trade_auto_import_batch"),
		"spent" = auto_import_spent,
		"lines" = auto_import_lines,
		"history" = auto_import_history,
	)

// Ratwood's crown imports.

/datum/rogue_crown_import/crackers
	name = "Bin of Rations"
	desc = "Low moisture bread that keeps well."
	region_id = "kingsfield"
	bin = TRUE
	contents = list("/obj/item/reagent_containers/food/snacks/rogue/crackerscooked" = 10)

/datum/rogue_crown_import/redpotion
	name = "Crate of Health Potions"
	desc = "Red that keeps men alive."
	region_id = "rockhill"
	contents = list("/obj/item/reagent_containers/glass/bottle/rogue/healthpot" = 5)

/datum/rogue_crown_import/rotpotion
	name = "Crate of Rot Cure Potions"
	desc = "A sought-after crate of rare potions of rot-curing."
	base_cost = 400
	region_id = "rockhill"
	contents = list("/obj/item/reagent_containers/glass/bottle/alchemical/rogue/rotcure" = 2)

/datum/rogue_crown_import/knight
	name = "Knight Equipment Crate"
	desc = "Starting kit for a new knight."
	base_cost = 500
	contents = list(
		"/obj/item/clothing/head/roguetown/helmet/heavy/knight" = 1,
		"/obj/item/clothing/gloves/roguetown/plate" = 1,
		"/obj/item/clothing/under/roguetown/platelegs" = 1,
		"/obj/item/clothing/cloak/tabard/knight/guard" = 1,
		"/obj/item/clothing/neck/roguetown/bevor" = 1,
		"/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk" = 1,
		"/obj/item/clothing/suit/roguetown/armor/plate/full" = 1,
		"/obj/item/clothing/shoes/roguetown/boots/armor" = 1,
		"/obj/item/storage/keyring/guardcastle" = 1,
		"/obj/item/storage/belt/rogue/leather/steel" = 1,
		"/obj/item/rogueweapon/sword/long" = 1,
	)

/datum/rogue_crown_import/warden
	name = "Warden Equipment Crate"
	desc = "Starting kit for a new warden."
	base_cost = 250
	contents = list(
		"/obj/item/clothing/cloak/wardencloak" = 1,
		"/obj/item/storage/keyring/guard" = 1,
		"/obj/item/clothing/suit/roguetown/armor/leather/studded/warden" = 1,
		"/obj/item/rogueweapon/stoneaxe/woodcut/wardenpick" = 1,
		"/obj/item/rogueweapon/huntingknife/idagger/warden_machete" = 1,
		"/obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve/warden" = 1,
	)

/datum/rogue_crown_import/manatarms
	name = "Man at Arms Equipment Crate"
	desc = "Starting kit for a man at arms."
	base_cost = 250
	contents = list(
		"/obj/item/clothing/head/roguetown/helmet/bascinet" = 1,
		"/obj/item/clothing/under/roguetown/chainlegs" = 1,
		"/obj/item/clothing/cloak/stabard/surcoat/guard" = 1,
		"/obj/item/clothing/gloves/roguetown/plate" = 1,
		"/obj/item/clothing/neck/roguetown/gorget" = 1,
		"/obj/item/clothing/suit/roguetown/armor/chainmail" = 1,
		"/obj/item/clothing/suit/roguetown/armor/plate/half" = 1,
		"/obj/item/clothing/shoes/roguetown/boots/armor" = 1,
		"/obj/item/storage/keyring/guardcastle" = 1,
		"/obj/item/storage/belt/rogue/leather/steel" = 1,
		"/obj/item/rogueweapon/spear" = 1,
	)

/datum/rogue_crown_import/crossbow
	name = "Crossbows Crate"
	desc = "A crate with 3 crossbows with 3 full quivers."
	base_cost = 300
	contents = list(
		"/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow" = 3,
		"/obj/item/quiver/bolts" = 3,
	)

/datum/rogue_crown_import/saigabuck
	name = "Saigabuck"
	desc = "One Saigabuck tamed with a saddle from a far away land."
	contents = list("/mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigabuck/tame/saddled" = 1)

/datum/rogue_crown_import/volfcrate
	name = "Volf Crate"
	desc = "An angry, feral volf has been stuffed inside this crate. By the time it arrives, it'll likely be starving."
	base_cost = 300
	contents = list("/mob/living/simple_animal/hostile/retaliate/rogue/wolf" = 1)

/datum/rogue_crown_import/bearcrate
	name = "Direbear Crate"
	desc = "A pack of lunatic fools claim to have crammed an entire, full-sized bear inside this crate. Their assurance is that it'll be angry."
	base_cost = 1000
	contents = list("/mob/living/simple_animal/hostile/retaliate/rogue/direbear" = 1)

/datum/rogue_crown_import/horsecrate
	name = "Horse Crate"
	desc = "A strange and unfamiliar mount in Ferentia. Horses, unlike saigas, have uniquely uncloven, single-toed hooves."
	base_cost = 500
	contents = list()
	pick_one = list(
		"/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/white/tame/saddled",
		"/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/brown/tame/saddled",
		"/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/black/tame/saddled",
	)

/datum/rogue_crown_import/ponycrate
	name = "Miniature Pony Crate"
	desc = "This novelty pony has been bred to be quaint of size, but more than makes up for it as a valiant steed."
	base_cost = 1500
	contents = list()
	pick_one = list(
		"/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/white/tame/saddled",
		"/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/brown/tame/saddled",
		"/mob/living/simple_animal/hostile/retaliate/rogue/horse/male/black/tame/saddled",
	)
	shrink = 0.7

/datum/rogue_crown_import/cow
	name = "Cow"
	desc = "Farmer's best friend, reliable provider of milk and meat."
	region_id = "kingsfield"
	contents = list("/mob/living/simple_animal/hostile/retaliate/rogue/cow" = 1)

/datum/rogue_crown_import/bull
	name = "Bull"
	desc = "Horned and aggressive, required to start a herd."
	region_id = "kingsfield"
	contents = list("/mob/living/simple_animal/hostile/retaliate/rogue/bull" = 1)

/datum/rogue_crown_import/goat
	name = "Doe Goat"
	desc = "An all-purpose source of milk, hide and fat."
	region_id = "kingsfield"
	contents = list("/mob/living/simple_animal/hostile/retaliate/rogue/goat" = 1)

/datum/rogue_crown_import/goatmale
	name = "Billy Goat"
	desc = "Bearded, male goat capable of saddling."
	region_id = "kingsfield"
	contents = list("/mob/living/simple_animal/hostile/retaliate/rogue/goatmale" = 1)

/datum/rogue_crown_import/chicken
	name = "Chicken"
	desc = "A reliable source of egg and meat."
	base_cost = 50
	region_id = "kingsfield"
	contents = list("/mob/living/simple_animal/hostile/retaliate/rogue/chicken" = 1)

/datum/rogue_crown_import/farmequip
	name = "Farm Equipment Crate"
	desc = "A crate with a pitchfork, sickle, hoe and some seeds."
	region_id = "kingsfield"
	contents = list(
		"/obj/item/rogueweapon/hoe" = 1,
		"/obj/item/rogueweapon/pitchfork" = 1,
		"/obj/item/rogueweapon/sickle" = 1,
		"/obj/item/seeds/apple" = 1,
		"/obj/item/seeds/wheat" = 1,
		"/obj/item/seeds/berryrogue" = 1,
	)

/datum/rogue_crown_import/blacksmith
	name = "Smith Crate"
	desc = "Stone, coal , iron ingot, wood bin, bucket with hammer and tongs."
	region_id = "daftsmarch"
	contents = list(
		"/obj/item/rogueweapon/hammer/iron" = 1,
		"/obj/item/rogueweapon/tongs" = 1,
		"/obj/item/natural/stone" = 8,
		"/obj/item/rogueore/coal" = 2,
		"/obj/item/ingot/iron" = 1,
		"/obj/item/roguebin" = 1,
		"/obj/item/reagent_containers/glass/bucket" = 1,
	)

/datum/rogue_crown_import/craftsman
	name = "Craftsman Crate"
	desc = "Handsaw, chisel, hammer."
	base_cost = 60
	region_id = "rosawood"
	contents = list(
		"/obj/item/rogueweapon/hammer/wood" = 1,
		"/obj/item/rogueweapon/chisel" = 1,
		"/obj/item/rogueweapon/handsaw" = 1,
	)

/datum/rogue_crown_import/glasscrate
	name = "Glass Crate"
	desc = "A crate full of glass for windows, repairs, and works of art.."
	base_cost = 150
	region_id = "daftsmarch"
	contents = list("/obj/item/natural/glass" = 5)

/datum/rogue_crown_import/tailor
	name = "Tailor Crate"
	desc = "A crate with basic tailoring tools."
	base_cost = 150
	region_id = "rosawood"
	contents = list(
		"/obj/item/rogueweapon/huntingknife/scissors/steel" = 1,
		"/obj/item/needle" = 1,
		"/obj/item/grown/log/tree/small" = 2,
		"/obj/item/natural/bundle/fibers" = 1,
		"/obj/item/grown/log/tree/stick" = 2,
	)

/datum/rogue_crown_import/keyringsset
	name = "Man-At-Arms Keyring Set Crate"
	desc = "A set of keys for new hires."
	contents = list("/obj/item/storage/keyring/guardcastle" = 4)

/datum/rogue_crown_import/alcoholset
	name = "Alcohol Crate"
	desc = "A crate with a selection of beers and liquors, fit for a party."
	base_cost = 800
	contents = list(
		"/obj/item/reagent_containers/glass/bottle/rogue/beer/gronnmead" = 1,
		"/obj/item/reagent_containers/glass/bottle/rogue/beer/nred" = 1,
		"/obj/item/reagent_containers/glass/bottle/rogue/beer/voddena" = 1,
		"/obj/item/reagent_containers/glass/bottle/rogue/whitewine" = 1,
		"/obj/item/reagent_containers/glass/bottle/rogue/redwine" = 1,
		"/obj/item/reagent_containers/glass/bottle/rogue/elfred" = 1,
		"/obj/item/reagent_containers/glass/bottle/rogue/wine/sourwine" = 1,
		"/obj/item/reagent_containers/glass/bottle/rogue/beer/kgunplum" = 1,
		"/obj/item/reagent_containers/glass/bottle/rogue/beer/aurorian" = 1,
		"/obj/item/reagent_containers/glass/bottle/rogue/beer/butterhairs" = 1,
		"/obj/item/reagent_containers/glass/bottle/rogue/beer/avarmead" = 1,
		"/obj/item/reagent_containers/glass/bottle/rogue/beer/kgunshochu" = 1,
		"/obj/item/reagent_containers/glass/bottle/rogue/beer/apfelweinheim" = 1,
	)

/datum/rogue_crown_import/minecarttracks
	name = "Minecart Tracks"
	desc = "A crate with One hundred minecart tracks and four break tracks"
	base_cost = 310
	region_id = "daftsmarch"
	contents = list(
		"/obj/item/rotation_contraption/minecart_rail" = 100,
		"/obj/item/rotation_contraption/minecart_rail/railbreak" = 4,
	)

/datum/rogue_crown_import/rotationalnetwork
	name = "Rotational Network"
	desc = "A crate of ten large gears, sixteen small gears, three gearboxes, three verticle gearboxes, and twenty shafts"
	base_cost = 362
	region_id = "daftsmarch"
	contents = list(
		"/obj/item/rotation_contraption/large_cog" = 10,
		"/obj/item/rotation_contraption/cog" = 16,
		"/obj/item/rotation_contraption/horizontal" = 3,
		"/obj/item/rotation_contraption/vertical" = 3,
		"/obj/item/rotation_contraption/shaft" = 20,
	)

/datum/rogue_crown_import/waterwheels
	name = "Waterwheels"
	desc = "A crate of five waterwheels"
	base_cost = 75
	region_id = "rosawood"
	contents = list("/obj/item/rotation_contraption/waterwheel" = 5)

/datum/rogue_crown_import/stoneblocks
	name = "Stoneblocks"
	desc = "A crate of twenty Stoneblocks, useful in building"
	base_cost = 40
	region_id = "daftsmarch"
	contents = list("/obj/item/natural/stoneblock" = 20)

/datum/rogue_crown_import/planks
	name = "Planks"
	desc = "A crate of twenty planks, useful in building"
	base_cost = 60
	region_id = "rosawood"
	contents = list("/obj/item/natural/wood/plank" = 20)

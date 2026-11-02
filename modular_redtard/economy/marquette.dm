/**
 * The MARQUETTE (Ratwood code/modules/roguetown/roguemachine/mail.dm and inqports/): the Otavan Inquisition's secret shop in
 * every HERMES. An adherent of the Inquisition loads Otavan marques (Ratwood's inquisition coins) into a HERMES and buys the
 * Otavan imports for them: supplies, articles, equipment and wardrobe, some in limited stock for the whole realm. The goods
 * arrive in the Inquisition's import room, crated as in Ratwood. The Puritan's key, or a Puritan at the machine, turns the
 * Puritan's Lock on every HERMES: while it holds, only Puritans may spend. The garrote is sold only to those trained to seize.
 * Goods not ported yet stay off the shelves; the marque itself (/obj/item/roguecoin/inqcoin) waits for the porter.
 */

#define MARQUETTE_COIN_PATH "/obj/item/roguecoin/inqcoin"
#define MARQUETTE_SUPPLIES "✤ SUPPLIES ✤"
#define MARQUETTE_ARTICLES "✤ ARTICLES ✤"
#define MARQUETTE_EQUIPMENT "✤ EQUIPMENT ✤"
#define MARQUETTE_WARDROBE "✤ WARDROBE ✤"
#define MARQUETTE_CRATE_SUPPLIES "inquisitorial supply crate"
#define MARQUETTE_CRATE_ARTICLES "inquisitorial article crate"
#define MARQUETTE_CRATE_EQUIPMENT "inquisitorial equipment crate"
#define MARQUETTE_CRATE_WARDROBE "otava's finest wardrobe crate"
#define MARQUETTE_CRATE_RELIQUARY "inquisitorial reliquary"

/// While it holds, only Puritans may spend marques at any HERMES (Ratwood inqonly, kept on every machine at once).
GLOBAL_VAR_INIT(rogue_puritan_lock, FALSE)

/// Ratwood's Otavan imports (inqports/inqshop.dm): name, category, marques, stock for the round (0: no limit), item path -> how
/// many, and the crate they come in (null: the item alone).
GLOBAL_LIST_INIT(rogue_inqport_data, list(
	list("(80 Silvers) Extra Funding", MARQUETTE_SUPPLIES, 16, 1, list("/obj/item/roguecoin/silver" = 80), MARQUETTE_CRATE_SUPPLIES),
	list("1 Lump of Inquisitorial Tallow", MARQUETTE_SUPPLIES, 1, 0, list("/obj/item/reagent_containers/food/snacks/tallow/red" = 1), null),
	list("5 Rolls of Cloth and Needles", MARQUETTE_SUPPLIES, 1, 0, list("/obj/item/needle" = 5, "/obj/item/natural/bundle/cloth/bandage/full" = 4), MARQUETTE_CRATE_SUPPLIES),
	list("2 Lengths of Chain", MARQUETTE_SUPPLIES, 1, 0, list("/obj/item/rope/chain" = 2), MARQUETTE_CRATE_SUPPLIES),
	list("1 Quiver of Holy Water Bolts", MARQUETTE_SUPPLIES, 2, 0, list("/obj/item/quiver/holybolts" = 1), null),
	list("1 Quiver of Heavy Blunt Bolts (Not for the sauterelle)", MARQUETTE_SUPPLIES, 4, 0, list("/obj/item/quiver/bluntbolts" = 1), null),
	list("5 Blessed Heavy Bolts", MARQUETTE_SUPPLIES, 5, 0, list("/obj/item/ammo_casing/caseless/rogue/heavy_bolt/holy" = 5), MARQUETTE_CRATE_SUPPLIES),
	list("10 Silver Blessed Psysling Bullets & Sling", MARQUETTE_SUPPLIES, 5, 0, list("/obj/item/ammo_casing/caseless/rogue/sling_bullet/silverblessed" = 10, "/obj/item/quiver/sling" = 1, "/obj/item/gun/ballistic/revolver/grenadelauncher/sling" = 1), MARQUETTE_CRATE_SUPPLIES),
	list("3 Bottles of Red", MARQUETTE_SUPPLIES, 3, 0, list("/obj/item/reagent_containers/glass/bottle/rogue/healthpot" = 3), MARQUETTE_CRATE_SUPPLIES),
	list("3 Vials of Strong Red", MARQUETTE_SUPPLIES, 6, 0, list("/obj/item/reagent_containers/glass/bottle/alchemical/healthpotnew" = 3), MARQUETTE_CRATE_SUPPLIES),
	list("3 Bottles of Blue", MARQUETTE_SUPPLIES, 3, 0, list("/obj/item/reagent_containers/glass/bottle/rogue/manapot" = 3), MARQUETTE_CRATE_SUPPLIES),
	list("3 Vials of Strong Blue", MARQUETTE_SUPPLIES, 6, 0, list("/obj/item/reagent_containers/glass/bottle/alchemical/strongmanapot" = 3), MARQUETTE_CRATE_SUPPLIES),
	list("Saint Eora's Elixr of Lyfe", MARQUETTE_SUPPLIES, 10, 0, list("/obj/item/reagent_containers/glass/bottle/revival" = 1), null),
	list("4 Smokebombs", MARQUETTE_SUPPLIES, 3, 0, list("/obj/item/bomb/smoke" = 4), MARQUETTE_CRATE_SUPPLIES),
	list("The Otavan Bakery Special", MARQUETTE_SUPPLIES, 1, 0, list("/obj/item/reagent_containers/food/snacks/rogue/psycrossbun_jamtallowed" = 1, "/obj/item/reagent_containers/food/snacks/rogue/psycrossbun" = 9, "/obj/item/reagent_containers/glass/bottle/alchemical/blessedwater" = 10), MARQUETTE_CRATE_SUPPLIES),
	list("3 Bottlebombs", MARQUETTE_SUPPLIES, 3, 0, list("/obj/item/bomb" = 3), MARQUETTE_CRATE_SUPPLIES),
	list("3 Blastsand Sticks", MARQUETTE_SUPPLIES, 6, 0, list("/obj/item/tntstick" = 3), MARQUETTE_CRATE_SUPPLIES),
	list("3 Silencing Gas Bombs", MARQUETTE_SUPPLIES, 6, 0, list("/obj/item/impact_grenade/smoke/mute_gas" = 3), MARQUETTE_CRATE_SUPPLIES),
	list("6 Blessed Silver Bullion", MARQUETTE_SUPPLIES, 12, 0, list("/obj/item/ingot/silverblessed/bullion" = 6), MARQUETTE_CRATE_RELIQUARY),
	list("1 Emergency Poultice", MARQUETTE_ARTICLES, 10, 1, list("/obj/item/quicksilver" = 1), null),
	list("1 Silver Psycross", MARQUETTE_ARTICLES, 6, 0, list("/obj/item/clothing/neck/roguetown/psicross/silver" = 1), null),
	list("1 Psycross", MARQUETTE_ARTICLES, 2, 0, list("/obj/item/clothing/neck/roguetown/psicross" = 1), null),
	list("3 INDEXERs, 3 Accusations", MARQUETTE_ARTICLES, 3, 0, list("/obj/item/inqarticles/indexer" = 3, "/obj/item/paper/inqslip/accusation" = 3), MARQUETTE_CRATE_ARTICLES),
	list("3 Confessions", MARQUETTE_ARTICLES, 5, 0, list("/obj/item/paper/inqslip/confession" = 3), MARQUETTE_CRATE_ARTICLES),
	list("3 Books Of Psydon", MARQUETTE_ARTICLES, 2, 0, list("/obj/item/book/rogue/bibble/psy" = 3), MARQUETTE_CRATE_ARTICLES),
	list("1 Black Mirror", MARQUETTE_ARTICLES, 6, 0, list("/obj/item/inqarticles/bmirror" = 1), null),
	list("1 Attentive Ear", MARQUETTE_ARTICLES, 3, 0, list("/obj/item/listeningdevice" = 1), null),
	list("1 Secret Whisperer", MARQUETTE_ARTICLES, 3, 0, list("/obj/item/speakerinq" = 1), null),
	list("1 Holy Monk Robes", MARQUETTE_EQUIPMENT, 8, 0, list("/obj/item/clothing/suit/roguetown/shirt/robe/monk/holy" = 1), null),
	list("1 Psydonian Thorns", MARQUETTE_EQUIPMENT, 12, 0, list("/obj/item/clothing/wrists/roguetown/bracers/psythorns" = 1), null),
	list("1 Seizing Garrote", MARQUETTE_EQUIPMENT, 4, 0, list("/obj/item/inqarticles/garrote" = 1), null),
	list("1 Confessional Mask", MARQUETTE_EQUIPMENT, 8, 0, list("/obj/item/clothing/mask/rogue/facemask/steel/confessor" = 1), null),
	list("1 Otavan Leather Satchel", MARQUETTE_EQUIPMENT, 2, 0, list("/obj/item/storage/backpack/rogue/satchel/otavan" = 1), null),
	list("1 Identity Concealer", MARQUETTE_EQUIPMENT, 2, 0, list("/obj/item/clothing/mask/rogue/sack/psy" = 1), null),
	list("2 Spools of Inquiry Cordage", MARQUETTE_EQUIPMENT, 4, 0, list("/obj/item/rope/inqarticles/inquirycord" = 2), MARQUETTE_CRATE_EQUIPMENT),
	list("3 Black Bags", MARQUETTE_EQUIPMENT, 6, 0, list("/obj/item/clothing/head/inqarticles/blackbag" = 3), MARQUETTE_CRATE_EQUIPMENT),
	list("Helms of Psydon", MARQUETTE_EQUIPMENT, 10, 2, list("/obj/item/clothing/head/roguetown/helmet/heavy/psydonbarbute" = 1, "/obj/item/clothing/head/roguetown/helmet/heavy/psysallet" = 1, "/obj/item/clothing/head/roguetown/helmet/heavy/psybucket" = 1, "/obj/item/clothing/head/roguetown/helmet/heavy/psydonhelm" = 1, "/obj/item/clothing/head/roguetown/helmet/heavy/volfplate/psydonic" = 1), MARQUETTE_CRATE_EQUIPMENT),
	list("The Crankbox", MARQUETTE_EQUIPMENT, 16, 1, list("/obj/item/psydonmusicbox" = 1), MARQUETTE_CRATE_RELIQUARY),
	list("1 Nocshade Lens-Pair", MARQUETTE_EQUIPMENT, 10, 0, list("/obj/item/clothing/mask/rogue/spectacles/inq" = 1), null),
	list("1 Inquisitorial SCOMgnet Ring", MARQUETTE_EQUIPMENT, 6, 0, list("/obj/item/clothing/ring/signet/silver/inqscomm" = 1), null),
	list("The Otavan Fencer's Finest Set Crate", MARQUETTE_WARDROBE, 10, 0, list("/obj/item/clothing/suit/roguetown/armor/gambeson/heavy/otavan/inq" = 1, "/obj/item/clothing/neck/roguetown/fencerguard/inq" = 1, "/obj/item/clothing/gloves/roguetown/otavan" = 1, "/obj/item/clothing/under/roguetown/heavy_leather_pants/otavan" = 1, "/obj/item/clothing/shoes/roguetown/boots/otavan" = 1), MARQUETTE_CRATE_WARDROBE),
	list("The Confessional Combination", MARQUETTE_WARDROBE, 10, 0, list("/obj/item/clothing/head/roguetown/roguehood/psydon/confessor" = 1, "/obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/confessor" = 1), MARQUETTE_CRATE_WARDROBE),
	list("The Inquisition's Finest Coats and Hats", MARQUETTE_WARDROBE, 10, 0, list("/obj/item/clothing/head/roguetown/inqhat" = 2, "/obj/item/clothing/suit/roguetown/armor/plate/scale/inqcoat" = 2), MARQUETTE_CRATE_WARDROBE),
	list("The Inquisitorial Inspector's Best Crate", MARQUETTE_WARDROBE, 10, 0, list("/obj/item/clothing/head/roguetown/inqhat" = 1, "/obj/item/clothing/suit/roguetown/armor/plate/scale/inqcoat" = 1, "/obj/item/clothing/gloves/roguetown/otavan/inqgloves" = 1, "/obj/item/clothing/shoes/roguetown/boots/otavan/inqboots" = 1), MARQUETTE_CRATE_WARDROBE),
	list("The Fencer's Gambeson Three-Pack", MARQUETTE_WARDROBE, 8, 0, list("/obj/item/clothing/suit/roguetown/armor/gambeson/heavy/otavan/inq" = 3), MARQUETTE_CRATE_WARDROBE),
	list("The Inquisitorial Standard", MARQUETTE_WARDROBE, 10, 0, list("/obj/item/clothing/under/roguetown/heavy_leather_pants/otavan" = 1, "/obj/item/clothing/suit/roguetown/armor/gambeson/heavy/inq" = 1, "/obj/item/clothing/gloves/roguetown/otavan/psygloves" = 1, "/obj/item/clothing/shoes/roguetown/boots/psydonboots" = 1), MARQUETTE_CRATE_WARDROBE),
	list("The Cost of Nobility Crate", MARQUETTE_WARDROBE, 14, 0, list("/obj/item/clothing/cloak/lordcloak/ladycloak" = 1, "/obj/item/clothing/cloak/lordcloak" = 1, "/obj/item/clothing/suit/roguetown/shirt/tunic/noblecoat" = 1, "/obj/item/clothing/suit/roguetown/shirt/dress/royal" = 1, "/obj/item/clothing/wrists/roguetown/royalsleeves" = 1, "/obj/item/clothing/suit/roguetown/shirt/dress/royal/prince" = 1), MARQUETTE_CRATE_WARDROBE),
))

/// The Otavan imports whose goods are all ported, with the stock left for the round; listed the first time they are asked for.
GLOBAL_LIST_EMPTY(rogue_inqports)

/proc/rogue_inqports()
	if(!length(GLOB.rogue_inqports))
		GLOB.rogue_inqports = init_rogue_inqports()
	return GLOB.rogue_inqports

/// An Otavan import of the MARQUETTE (Ratwood /datum/inqports).
/datum/rogue_inqport
	var/name
	var/category
	var/cost = 0
	/// Stock for the whole round; 0 has no limit.
	var/maximum = 0
	var/remaining = 0
	/// Item path -> how many.
	var/list/wares = list()
	/// The crate they come in; null delivers the item alone.
	var/crate_name

/proc/init_rogue_inqports()
	. = list()
	for(var/list/entry as anything in GLOB.rogue_inqport_data)
		var/datum/rogue_inqport/import = new
		import.name = entry[1]
		import.category = entry[2]
		import.cost = entry[3]
		import.maximum = entry[4]
		import.remaining = entry[4]
		import.crate_name = entry[6]
		var/list/goods = entry[5]
		for(var/path_text in goods)
			var/path = text2path(path_text)
			if(!path)
				import = null
				break
			import.wares[path] = goods[path_text]
		if(import)
			. += import

/// The import arrives in the Inquisition's import room (Ratwood buy Topic()): crated, or the item alone.
/datum/rogue_inqport/proc/deliver(turf/spot)
	var/atom/holder = spot
	if(crate_name)
		var/obj/structure/closet/crate = new /obj/structure/closet/crate/wooden/rockhill/crate/chest(spot)
		crate.name = crate_name
		holder = crate
	for(var/path in wares)
		var/count = wares[path]
		if(ispath(path, /obj/item/roguecoin))
			while(count > 0)
				new path(holder, min(count, ROGUE_COIN_PILE_MAX), FALSE)
				count -= ROGUE_COIN_PILE_MAX
			continue
		for(var/i in 1 to count)
			new path(holder)

/obj/structure/roguemachine/mail
	/// Otavan marques loaded into the machine (Ratwood inqcoins).
	var/marques = 0

/// The Otavan marque, once the porter brings it.
/proc/rogue_marque_type()
	return text2path(MARQUETTE_COIN_PATH)

/// Loads marques into the HERMES (Ratwood: an adherent of the Inquisition inserts inquisition coins).
/obj/structure/roguemachine/mail/proc/load_marques(obj/item/roguecoin/coins, mob/living/user)
	if(!HAS_TRAIT(user, TRAIT_INQUISITION))
		return
	marques += coins.amount
	qdel(coins)
	playsound(src, ROGUE_SOUND_COIN_INSERT, 100, FALSE, -1)
	update_appearance()
	ui_interact(user)

/// The Puritan's Lock turns on every HERMES at once (Ratwood inqlock() on every hermailer).
/proc/rogue_toggle_puritan_lock(mob/user)
	GLOB.rogue_puritan_lock = !GLOB.rogue_puritan_lock
	to_chat(user, span_warning("I [GLOB.rogue_puritan_lock ? "enable" : "disable"] the Puritan's Lock."))
	for(var/obj/structure/roguemachine/mail/box as anything in GLOB.rogue_mailboxes)
		SStgui.update_uis(box)

/obj/structure/roguemachine/mail/ui_status(mob/user, datum/ui_state/state)
	if(!HAS_TRAIT(user, TRAIT_INQUISITION))
		return UI_CLOSE
	return ..()

/obj/structure/roguemachine/mail/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RogueMarquette", "MARQUETTE")
		ui.open()

/// The import may be bought by this adherent now (Ratwood display_marquette(): lock, stock, marques, the garrote's training).
/obj/structure/roguemachine/mail/proc/can_buy(datum/rogue_inqport/import, mob/user)
	if(GLOB.rogue_puritan_lock && !HAS_TRAIT(user, TRAIT_PURITAN))
		return FALSE
	if(import.maximum && import.remaining <= 0)
		return FALSE
	return marques >= import.cost

/obj/structure/roguemachine/mail/proc/sells_to(datum/rogue_inqport/import, mob/user)
	return import.name != "1 Seizing Garrote" || HAS_TRAIT(user, TRAIT_BLACKBAGGER)

/obj/structure/roguemachine/mail/ui_data(mob/user)
	var/list/data = list()
	data["marques"] = marques
	data["puritan_lock"] = GLOB.rogue_puritan_lock
	data["can_toggle_lock"] = HAS_TRAIT(user, TRAIT_PURITAN)
	data["categories"] = list(MARQUETTE_SUPPLIES, MARQUETTE_ARTICLES, MARQUETTE_EQUIPMENT, MARQUETTE_WARDROBE)
	var/list/items = list()
	for(var/datum/rogue_inqport/import as anything in rogue_inqports())
		if(!sells_to(import, user))
			continue
		items += list(list(
			"ref" = REF(import),
			"name" = import.name,
			"category" = import.category,
			"cost" = import.cost,
			"maximum" = import.maximum,
			"remaining" = import.remaining,
			"buyable" = can_buy(import, user),
		))
	data["items"] = items
	return data

/obj/structure/roguemachine/mail/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = ui.user
	switch(action)
		if("eject")
			eject_marques(user)
		if("toggle_lock")
			if(HAS_TRAIT(user, TRAIT_PURITAN))
				playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)
				rogue_toggle_puritan_lock(user)
		if("buy")
			var/datum/rogue_inqport/import = locate(params["ref"]) in rogue_inqports()
			if(import && sells_to(import, user) && can_buy(import, user))
				buy_import(import, user)
	return TRUE

/// Ratwood buy: the marques are spent, the stock falls, and the goods arrive in the Inquisition's import room.
/obj/structure/roguemachine/mail/proc/buy_import(datum/rogue_inqport/import, mob/living/user)
	marques -= import.cost
	if(import.maximum)
		import.remaining--
	update_appearance()
	visible_message(span_warning("[user] sends something."))
	playsound(src, ROGUE_SOUND_FLUSH, 100, FALSE, -1)
	var/list/import_room = list()
	for(var/turf/room_turf as anything in get_area_turfs(/area/rogue/indoors/inq/import, subtypes = TRUE))
		if(isopenturf(room_turf) && !room_turf.is_blocked_turf())
			import_room += room_turf
	var/turf/spot = length(import_room) ? pick(import_room) : drop_location()
	playsound(spot, ROGUE_SOUND_FLUSH, 100, FALSE, -1)
	import.deliver(spot)
	log_game("MARQUETTE: [key_name(user)] bought [import.name] for [import.cost] marques")

/// The loaded marques come back out (Ratwood eject).
/obj/structure/roguemachine/mail/proc/eject_marques(mob/living/user)
	var/marque_type = rogue_marque_type()
	if(marques <= 0 || !marque_type)
		return
	var/turf/spot = drop_location()
	while(marques > 0)
		var/pile = min(marques, ROGUE_COIN_PILE_MAX)
		var/obj/item/coins = new marque_type(spot, pile, FALSE)
		user.put_in_hands(coins)
		marques -= pile
	playsound(src, ROGUE_SOUND_COIN_DISPENSE, 100, FALSE, -1)
	update_appearance()
	SStgui.close_uis(src)

#undef MARQUETTE_COIN_PATH
#undef MARQUETTE_SUPPLIES
#undef MARQUETTE_ARTICLES
#undef MARQUETTE_EQUIPMENT
#undef MARQUETTE_WARDROBE
#undef MARQUETTE_CRATE_SUPPLIES
#undef MARQUETTE_CRATE_ARTICLES
#undef MARQUETTE_CRATE_EQUIPMENT
#undef MARQUETTE_CRATE_WARDROBE
#undef MARQUETTE_CRATE_RELIQUARY
